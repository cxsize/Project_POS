import { Module } from '@nestjs/common';
import { OrdersModule } from '../orders/orders.module';
import { QueueModule } from '../queue/queue.module';
import { AccountingController } from './accounting.controller';
import { AccountingService } from './accounting.service';

@Module({
  imports: [OrdersModule, QueueModule],
  controllers: [AccountingController],
  providers: [AccountingService],
})
export class AccountingModule {}
