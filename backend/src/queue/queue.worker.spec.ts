import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import {
  OFFLINE_ORDER_FLUSH_QUEUE,
  WEBHOOK_RETRY_QUEUE,
} from './queue.constants';
import { OrderSyncQueueService } from './order-sync-queue.service';
import { RedisQueueService } from './redis-queue.service';
import { QueueWorkerService } from './queue.worker';
import { WebhookRetryService } from './webhook-retry.service';

describe('QueueWorkerService', () => {
  const redisQueueService = {
    poll: jest.fn(),
    reschedule: jest.fn(),
  };
  const orderSyncQueueService = {
    handleJob: jest.fn(),
  };
  const webhookRetryService = {
    handleJob: jest.fn(),
  };

  let service: QueueWorkerService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const moduleRef = await Test.createTestingModule({
      providers: [
        QueueWorkerService,
        {
          provide: ConfigService,
          useValue: { get: jest.fn().mockReturnValue(1000) },
        },
        { provide: RedisQueueService, useValue: redisQueueService },
        { provide: OrderSyncQueueService, useValue: orderSyncQueueService },
        { provide: WebhookRetryService, useValue: webhookRetryService },
      ],
    }).compile();

    service = moduleRef.get(QueueWorkerService);
  });

  afterEach(() => {
    service.onModuleDestroy();
  });

  it('routes jobs to the appropriate handlers', async () => {
    redisQueueService.poll
      .mockResolvedValueOnce({
        id: 'job-1',
        payload: { orderId: 'order-1' },
      })
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce({
        id: 'job-2',
        payload: {
          url: 'https://example.com',
          method: 'POST',
          headers: {},
          body: {},
        },
      })
      .mockResolvedValueOnce(null);

    await service.drainQueues();

    expect(orderSyncQueueService.handleJob).toHaveBeenCalledTimes(1);
    expect(webhookRetryService.handleJob).toHaveBeenCalledTimes(1);
    expect(redisQueueService.poll).toHaveBeenNthCalledWith(
      1,
      OFFLINE_ORDER_FLUSH_QUEUE,
    );
    expect(redisQueueService.poll).toHaveBeenNthCalledWith(
      3,
      WEBHOOK_RETRY_QUEUE,
    );
  });

  it('reschedules failed jobs', async () => {
    const job = {
      id: 'job-1',
      payload: { orderId: 'order-1' },
      attempt: 0,
      maxAttempts: 5,
      initialBackoffMs: 5000,
      enqueuedAt: new Date().toISOString(),
    };
    redisQueueService.poll
      .mockResolvedValueOnce(job)
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce(null);
    orderSyncQueueService.handleJob.mockRejectedValue(new Error('boom'));
    redisQueueService.reschedule.mockResolvedValue('rescheduled');

    await service.drainQueues();

    expect(redisQueueService.reschedule).toHaveBeenCalledWith(
      OFFLINE_ORDER_FLUSH_QUEUE,
      job,
      'boom',
    );
  });
});
