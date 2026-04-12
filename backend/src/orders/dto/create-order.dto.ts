import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsIn,
  IsNumber,
  IsOptional,
  IsUUID,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';

export class CreateOrderItemDto {
  @ApiProperty()
  @IsUUID()
  product_id: string;

  @ApiProperty({ example: 2 })
  @IsNumber()
  @Min(1)
  qty: number;

  @ApiPropertyOptional({
    example: 150.0,
    description: 'Override price. If omitted, uses product base_price.',
  })
  @IsNumber()
  @IsOptional()
  unit_price?: number;
}

export class CreateOrderDto {
  @ApiPropertyOptional({
    example: '8cf0ab9d-71d6-4bce-a29c-4efd29f6cb35',
    description: 'Client-generated idempotency key for offline order sync.',
  })
  @IsUUID()
  @IsOptional()
  order_no?: string;

  @ApiProperty()
  @IsUUID()
  branch_id: string;

  @ApiProperty()
  @IsUUID()
  staff_id: string;

  @ApiPropertyOptional({
    enum: ['flat', 'percent'],
    description: 'Discount calculation mode. Defaults to flat.',
  })
  @IsOptional()
  @IsIn(['flat', 'percent'])
  discount_type?: 'flat' | 'percent';

  @ApiPropertyOptional({ example: 0 })
  @IsNumber()
  @Min(0)
  @IsOptional()
  discount_amount?: number;

  @ApiPropertyOptional({
    example: 10,
    description:
      'Percentage discount from 0-100. Used when discount_type=percent.',
  })
  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  discount_percent?: number;

  @ApiPropertyOptional({
    example: 320,
    description: 'Client-computed subtotal before discount/VAT.',
  })
  @IsNumber()
  @Min(0)
  @IsOptional()
  total_amount?: number;

  @ApiPropertyOptional({
    example: 20.16,
    description: 'Client-computed VAT amount used for validation.',
  })
  @IsNumber()
  @Min(0)
  @IsOptional()
  vat_amount?: number;

  @ApiPropertyOptional({
    example: 308.16,
    description: 'Client-computed net amount used for validation.',
  })
  @IsNumber()
  @Min(0)
  @IsOptional()
  net_amount?: number;

  @ApiProperty({ type: [CreateOrderItemDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items: CreateOrderItemDto[];
}
