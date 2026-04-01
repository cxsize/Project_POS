import { Injectable } from '@nestjs/common';
import { OrdersService } from '../orders/orders.service';
import { SyncReceiptDto } from './dto/sync-receipt.dto';

@Injectable()
export class AccountingService {
  constructor(private ordersService: OrdersService) {}

  async syncReceipt(dto: SyncReceiptDto) {
    const order = await this.ordersService.findOne(dto.order_id);

    // TODO: Push to external accounting system via HTTP
    return {
      order_id: order.id,
      order_no: order.order_no,
      synced: false,
      message: 'Accounting integration pending',
    };
  }
}
