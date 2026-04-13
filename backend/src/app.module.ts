import { Module } from '@nestjs/common';
import { BranchesModule } from './branches/branches.module';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AccountingModule } from './accounting/accounting.module';
import { AuthModule } from './auth/auth.module';
import { getDatabaseConfig } from './config/database.config';
import { CrmModule } from './crm/crm.module';
import { InventoryModule } from './inventory/inventory.module';
import { OrdersModule } from './orders/orders.module';
import { ProductsModule } from './products/products.module';

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
    CrmModule,
    AccountingModule,
  ],
})
export class AppModule {}
