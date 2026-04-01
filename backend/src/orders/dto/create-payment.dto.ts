import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';
import { PaymentMethod } from '../entities/payment.entity';

export class CreatePaymentDto {
  @ApiProperty()
  @IsUUID()
  order_id: string;

  @ApiProperty({ enum: PaymentMethod })
  @IsEnum(PaymentMethod)
  method: PaymentMethod;

  @ApiProperty({ example: 300.0 })
  @IsNumber()
  amount_received: number;

  @ApiPropertyOptional({ example: 'TXN-123456' })
  @IsString()
  @IsOptional()
  ref_no?: string;
}
