import { Injectable } from '@nestjs/common';
import { OrdersService } from '../orders/orders.service';
import { OrderSyncQueueService } from '../queue/order-sync-queue.service';
import { OFFLINE_ORDER_FLUSH_QUEUE } from '../queue/queue.constants';
import { SyncReceiptDto } from './dto/sync-receipt.dto';

@Injectable()
export class AccountingService {
  constructor(
    private ordersService: OrdersService,
    private orderSyncQueueService: OrderSyncQueueService,
  ) {}

  async syncReceipt(dto: SyncReceiptDto) {
    const order = await this.ordersService.findOne(dto.order_id);
    const job = await this.orderSyncQueueService.enqueuePaidOrderSync(order.id);

    return {
      order_id: order.id,
      order_no: order.order_no,
      queued: true,
      queue: OFFLINE_ORDER_FLUSH_QUEUE,
      job_id: job.id,
      message: 'Accounting sync queued for background processing',
    };
  }
}
