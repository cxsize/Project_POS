import { ApiProperty } from '@nestjs/swagger';
import { IsUUID } from 'class-validator';

export class SyncReceiptDto {
  @ApiProperty({ description: 'Order ID to sync to accounting' })
  @IsUUID()
  order_id: string;
}
