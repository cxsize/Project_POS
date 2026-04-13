import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order, PaymentStatus } from '../orders/entities/order.entity';
import {
  OFFLINE_ORDER_FLUSH_QUEUE,
  SYNC_PAID_ORDER_JOB,
} from './queue.constants';
import { RedisQueueService } from './redis-queue.service';
import {
  OrderSyncJobPayload,
  QueueJobRecord,
  WebhookJobPayload,
} from './queue.types';
import { WebhookRetryService } from './webhook-retry.service';

@Injectable()
export class OrderSyncQueueService {
  constructor(
    private readonly configService: ConfigService,
    private readonly redisQueueService: RedisQueueService,
    private readonly webhookRetryService: WebhookRetryService,
    @InjectRepository(Order)
    private readonly ordersRepository: Repository<Order>,
  ) {}

  enqueuePaidOrderSync(orderId: string) {
    return this.redisQueueService.enqueue(
      OFFLINE_ORDER_FLUSH_QUEUE,
      SYNC_PAID_ORDER_JOB,
      { orderId },
      { maxAttempts: 5, initialBackoffMs: 5000 },
    );
  }

  async handleJob(job: QueueJobRecord<OrderSyncJobPayload>) {
    const order = await this.ordersRepository.findOne({
      where: { id: job.payload.orderId },
      relations: ['items', 'payments'],
    });

    if (!order) {
      return { skipped: 'order-not-found' };
    }
    if (order.payment_status !== PaymentStatus.PAID) {
      return { skipped: 'order-not-paid' };
    }
    if (order.sync_status_acc) {
      return { skipped: 'already-synced' };
    }

    const accountingUrl = this.configService.get<string>('ACCOUNTING_SYNC_URL');
    if (!accountingUrl) {
      return { skipped: 'accounting-url-not-configured' };
    }

    await this.webhookRetryService.enqueueJob(
      this.buildAccountingWebhookPayload(accountingUrl, order),
    );

    return {
      queued: true,
      orderId: order.id,
      orderNo: order.order_no,
    };
  }

  private buildAccountingWebhookPayload(
    url: string,
    order: Order,
  ): WebhookJobPayload {
    const apiKey = this.configService.get<string>('ACCOUNTING_API_KEY');
    const headers: Record<string, string> = {
      'content-type': 'application/json',
    };

    if (apiKey) {
      headers['x-api-key'] = apiKey;
    }

    return {
      url,
      method: 'POST',
      headers,
      body: {
        order_id: order.id,
        order_no: order.order_no,
        branch_id: order.branch_id,
        staff_id: order.staff_id,
        total_amount: Number(order.total_amount),
        discount_amount: Number(order.discount_amount),
        vat_amount: Number(order.vat_amount),
        net_amount: Number(order.net_amount),
        payment_status: order.payment_status,
        created_at: order.created_at,
        items:
          order.items?.map((item) => ({
            product_id: item.product_id,
            qty: item.qty,
            unit_price: Number(item.unit_price),
            subtotal: Number(item.subtotal),
          })) ?? [],
        payments:
          order.payments?.map((payment) => ({
            method: payment.method,
            amount_received: Number(payment.amount_received),
            ref_no: payment.ref_no,
          })) ?? [],
      },
      successAction: {
        type: 'mark-accounting-synced',
        orderId: order.id,
      },
    };
  }
}
