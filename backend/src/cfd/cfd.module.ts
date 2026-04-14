import { Module } from '@nestjs/common';
import { CfdController } from './cfd.controller';
import { CfdGatewayService } from './cfd.gateway.service';

@Module({
  controllers: [CfdController],
  providers: [CfdGatewayService],
  exports: [CfdGatewayService],
})
export class CfdModule {}
