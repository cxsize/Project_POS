import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsNumber,
  IsOptional,
  IsUUID,
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

  @ApiPropertyOptional({ example: 0 })
  @IsNumber()
  @IsOptional()
  discount_amount?: number;

  @ApiProperty({ type: [CreateOrderItemDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items: CreateOrderItemDto[];
}
