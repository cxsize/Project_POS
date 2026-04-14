import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Order } from '../orders/entities/order.entity';
import { DELIVER_WEBHOOK_JOB } from './queue.constants';
import { RedisQueueService } from './redis-queue.service';
import { WebhookRetryService } from './webhook-retry.service';

describe('WebhookRetryService', () => {
  const redisQueueService = {
    enqueue: jest.fn(),
  };
  const ordersRepository = {
    update: jest.fn(),
  };

  let service: WebhookRetryService;
  const originalFetch = global.fetch;
  const originalAbortSignalTimeout = AbortSignal.timeout;
  let timeoutSignal: AbortSignal;

  beforeEach(async () => {
    jest.clearAllMocks();
    timeoutSignal = {} as AbortSignal;
    AbortSignal.timeout = jest.fn().mockReturnValue(timeoutSignal);

    const moduleRef = await Test.createTestingModule({
      providers: [
        WebhookRetryService,
        { provide: RedisQueueService, useValue: redisQueueService },
        {
          provide: getRepositoryToken(Order),
          useValue: ordersRepository,
        },
      ],
    }).compile();

    service = moduleRef.get(WebhookRetryService);
  });

  afterEach(() => {
    global.fetch = originalFetch;
    AbortSignal.timeout = originalAbortSignalTimeout;
  });

  it('marks orders synced after a successful webhook delivery', async () => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      status: 200,
    }) as typeof fetch;

    const result = await service.handleJob({
      id: 'job-1',
      name: DELIVER_WEBHOOK_JOB,
      payload: {
        url: 'https://example.com/hooks/accounting',
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: { order_id: 'order-1' },
        successAction: {
          type: 'mark-accounting-synced',
          orderId: 'order-1',
        },
      },
      attempt: 0,
      maxAttempts: 5,
      initialBackoffMs: 10000,
      enqueuedAt: new Date().toISOString(),
    });

    expect(ordersRepository.update).toHaveBeenCalledWith('order-1', {
      sync_status_acc: true,
    });
    expect(AbortSignal.timeout).toHaveBeenCalledWith(10000);
    expect(global.fetch).toHaveBeenCalledWith(
      'https://example.com/hooks/accounting',
      expect.objectContaining({
        signal: timeoutSignal,
      }),
    );
    expect(result).toEqual({
      statusCode: 200,
      syncedOrderId: 'order-1',
    });
  });

  it('throws on webhook failures so the queue worker can retry', async () => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: false,
      status: 503,
    }) as typeof fetch;

    await expect(
      service.handleJob({
        id: 'job-1',
        name: DELIVER_WEBHOOK_JOB,
        payload: {
          url: 'https://example.com/hooks/accounting',
          method: 'POST',
          headers: { 'content-type': 'application/json' },
          body: { order_id: 'order-1' },
        },
        attempt: 0,
        maxAttempts: 5,
        initialBackoffMs: 10000,
        enqueuedAt: new Date().toISOString(),
      }),
    ).rejects.toThrow('Webhook responded with HTTP 503');
  });
});
