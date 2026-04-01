import { Module } from '@nestjs/common';
import { OrdersModule } from '../orders/orders.module';
import { AccountingController } from './accounting.controller';
import { AccountingService } from './accounting.service';

@Module({
  imports: [OrdersModule],
  controllers: [AccountingController],
  providers: [AccountingService],
})
export class AccountingModule {}
