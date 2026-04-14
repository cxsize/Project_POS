import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CfdModule } from '../cfd/cfd.module';
import { RolesGuard } from '../common/guards/roles.guard';
import { InventoryModule } from '../inventory/inventory.module';
import { ProductsModule } from '../products/products.module';
import { QueueModule } from '../queue/queue.module';
import { OrderItem } from './entities/order-item.entity';
import { Order } from './entities/order.entity';
import { Payment } from './entities/payment.entity';
import { OrdersController } from './orders.controller';
import { OrdersService } from './orders.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([Order, OrderItem, Payment]),
    CfdModule,
    ProductsModule,
    InventoryModule,
    QueueModule,
  ],
  controllers: [OrdersController],
  providers: [OrdersService, RolesGuard],
  exports: [OrdersService],
})
export class OrdersModule {}
