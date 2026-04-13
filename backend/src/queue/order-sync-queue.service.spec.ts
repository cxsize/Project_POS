import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Order, PaymentStatus } from '../orders/entities/order.entity';
import {
  OFFLINE_ORDER_FLUSH_QUEUE,
  SYNC_PAID_ORDER_JOB,
} from './queue.constants';
import { OrderSyncQueueService } from './order-sync-queue.service';
import { RedisQueueService } from './redis-queue.service';
import { WebhookRetryService } from './webhook-retry.service';

describe('OrderSyncQueueService', () => {
  const redisQueueService = {
    enqueue: jest.fn(),
  };
  const webhookRetryService = {
    enqueueJob: jest.fn(),
  };
  const ordersRepository = {
    findOne: jest.fn(),
  };
  const configService = {
    get: jest.fn(),
  };

  let service: OrderSyncQueueService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const moduleRef = await Test.createTestingModule({
      providers: [
        OrderSyncQueueService,
        { provide: RedisQueueService, useValue: redisQueueService },
        { provide: WebhookRetryService, useValue: webhookRetryService },
        { provide: ConfigService, useValue: configService },
        {
          provide: getRepositoryToken(Order),
          useValue: ordersRepository,
        },
      ],
    }).compile();

    service = moduleRef.get(OrderSyncQueueService);
  });

  it('enqueues paid order sync jobs onto the offline queue', async () => {
    await service.enqueuePaidOrderSync('order-1');

    expect(redisQueueService.enqueue).toHaveBeenCalledWith(
      OFFLINE_ORDER_FLUSH_QUEUE,
      SYNC_PAID_ORDER_JOB,
      { orderId: 'order-1' },
      { maxAttempts: 5, initialBackoffMs: 5000 },
    );
  });

  it('queues accounting webhook delivery for paid unsynced orders', async () => {
    configService.get.mockReturnValue('https://example.com/accounting');
    ordersRepository.findOne.mockResolvedValue({
      id: 'order-1',
      order_no: 'ORD-1',
      branch_id: 'branch-1',
      staff_id: 'staff-1',
      total_amount: 100,
      discount_amount: 0,
      vat_amount: 7,
      net_amount: 107,
      payment_status: PaymentStatus.PAID,
      sync_status_acc: false,
      created_at: new Date('2026-04-13T00:00:00.000Z'),
      items: [],
      payments: [],
    });

    const result = await service.handleJob({
      id: 'job-1',
      name: SYNC_PAID_ORDER_JOB,
      payload: { orderId: 'order-1' },
      attempt: 0,
      maxAttempts: 5,
      initialBackoffMs: 5000,
      enqueuedAt: new Date().toISOString(),
    });

    expect(webhookRetryService.enqueueJob).toHaveBeenCalledTimes(1);
    expect(result).toEqual({
      queued: true,
      orderId: 'order-1',
      orderNo: 'ORD-1',
    });
  });

  it('skips orders when accounting sync url is not configured', async () => {
    configService.get.mockReturnValue(undefined);
    ordersRepository.findOne.mockResolvedValue({
      id: 'order-1',
      payment_status: PaymentStatus.PAID,
      sync_status_acc: false,
    });

    await expect(
      service.handleJob({
        id: 'job-1',
        name: SYNC_PAID_ORDER_JOB,
        payload: { orderId: 'order-1' },
        attempt: 0,
        maxAttempts: 5,
        initialBackoffMs: 5000,
        enqueuedAt: new Date().toISOString(),
      }),
    ).resolves.toEqual({
      skipped: 'accounting-url-not-configured',
    });

    expect(webhookRetryService.enqueueJob).not.toHaveBeenCalled();
  });
});
