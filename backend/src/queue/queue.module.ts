import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OrderItem } from '../orders/entities/order-item.entity';
import { Order } from '../orders/entities/order.entity';
import { Payment } from '../orders/entities/payment.entity';
import { OrderSyncQueueService } from './order-sync-queue.service';
import { RedisQueueService } from './redis-queue.service';
import { RedisSocketTransport } from './redis-socket.transport';
import { QueueWorkerService } from './queue.worker';
import { WebhookRetryService } from './webhook-retry.service';

@Module({
  imports: [TypeOrmModule.forFeature([Order, OrderItem, Payment])],
  providers: [
    RedisSocketTransport,
    RedisQueueService,
    WebhookRetryService,
    OrderSyncQueueService,
    QueueWorkerService,
  ],
  exports: [OrderSyncQueueService, WebhookRetryService],
})
export class QueueModule {}
