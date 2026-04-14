import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  OFFLINE_ORDER_FLUSH_QUEUE,
  WEBHOOK_RETRY_QUEUE,
} from './queue.constants';
import { OrderSyncQueueService } from './order-sync-queue.service';
import { RedisQueueService } from './redis-queue.service';
import {
  OrderSyncJobPayload,
  QueueJobRecord,
  WebhookJobPayload,
} from './queue.types';
import { WebhookRetryService } from './webhook-retry.service';

@Injectable()
export class QueueWorkerService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(QueueWorkerService.name);
  private readonly pollIntervalMs: number;
  private timer?: NodeJS.Timeout;
  private isDraining = false;

  constructor(
    configService: ConfigService,
    private readonly redisQueueService: RedisQueueService,
    private readonly orderSyncQueueService: OrderSyncQueueService,
    private readonly webhookRetryService: WebhookRetryService,
  ) {
    this.pollIntervalMs = Number(
      configService.get<number>('QUEUE_POLL_INTERVAL_MS') || 1000,
    );
  }

  onModuleInit() {
    this.timer = setInterval(() => {
      void this.drainQueues();
    }, this.pollIntervalMs);
    void this.drainQueues();
  }

  onModuleDestroy() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }

  async drainQueues() {
    if (this.isDraining) {
      return;
    }

    this.isDraining = true;
    try {
      await this.processQueue(
        OFFLINE_ORDER_FLUSH_QUEUE,
        async (job: QueueJobRecord<OrderSyncJobPayload>) =>
          this.orderSyncQueueService.handleJob(job),
      );
      await this.processQueue(
        WEBHOOK_RETRY_QUEUE,
        async (job: QueueJobRecord<WebhookJobPayload>) =>
          this.webhookRetryService.handleJob(job),
      );
    } finally {
      this.isDraining = false;
    }
  }

  private async processQueue<TPayload>(
    queueName: string,
    handler: (job: QueueJobRecord<TPayload>) => Promise<unknown>,
  ) {
    for (let processed = 0; processed < 10; processed += 1) {
      let job: QueueJobRecord<TPayload> | null = null;
      try {
        job = await this.redisQueueService.poll<TPayload>(queueName);
        if (!job) {
          return;
        }
        await handler(job);
      } catch (error) {
        if (!job) {
          return;
        }

        const errorMessage =
          error instanceof Error ? error.message : String(error);
        const outcome = await this.redisQueueService.reschedule(
          queueName,
          job,
          errorMessage,
        );
        this.logger.warn(
          `Queue ${queueName} job ${job.id} failed (${outcome}): ${errorMessage}`,
        );
      }
    }
  }
}
