import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order } from '../orders/entities/order.entity';
import { DELIVER_WEBHOOK_JOB, WEBHOOK_RETRY_QUEUE } from './queue.constants';
import { RedisQueueService } from './redis-queue.service';
import { QueueJobRecord, WebhookJobPayload } from './queue.types';

@Injectable()
export class WebhookRetryService {
  private static readonly WEBHOOK_TIMEOUT_MS = 10_000;

  constructor(
    private readonly redisQueueService: RedisQueueService,
    @InjectRepository(Order)
    private readonly ordersRepository: Repository<Order>,
  ) {}

  enqueueJob(payload: WebhookJobPayload) {
    return this.redisQueueService.enqueue(
      WEBHOOK_RETRY_QUEUE,
      DELIVER_WEBHOOK_JOB,
      payload,
      { maxAttempts: 5, initialBackoffMs: 10000 },
    );
  }

  async handleJob(job: QueueJobRecord<WebhookJobPayload>) {
    const response = await fetch(job.payload.url, {
      method: job.payload.method,
      headers: job.payload.headers,
      body: JSON.stringify(job.payload.body),
      signal: AbortSignal.timeout(WebhookRetryService.WEBHOOK_TIMEOUT_MS),
    });

    if (!response.ok) {
      throw new Error(`Webhook responded with HTTP ${response.status}`);
    }

    if (job.payload.successAction?.type === 'mark-accounting-synced') {
      await this.ordersRepository.update(job.payload.successAction.orderId, {
        sync_status_acc: true,
      });
    }

    return {
      statusCode: response.status,
      syncedOrderId: job.payload.successAction?.orderId ?? null,
    };
  }
}
