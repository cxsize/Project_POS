import { Module } from '@nestjs/common';
import { BranchesModule } from './branches/branches.module';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AccountingModule } from './accounting/accounting.module';
import { AuthModule } from './auth/auth.module';
import { CfdModule } from './cfd/cfd.module';
import { getDatabaseConfig } from './config/database.config';
import { CrmModule } from './crm/crm.module';
import { InventoryModule } from './inventory/inventory.module';
import { OrdersModule } from './orders/orders.module';
import { ProductsModule } from './products/products.module';
import { QueueModule } from './queue/queue.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: getDatabaseConfig,
    }),
    BranchesModule,
    AuthModule,
    ProductsModule,
    InventoryModule,
    OrdersModule,
    CfdModule,
    CrmModule,
    AccountingModule,
    QueueModule,
  ],
})
export class AppModule {}
