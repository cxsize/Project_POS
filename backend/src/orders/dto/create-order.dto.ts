import { ApiProperty } from '@nestjs/swagger';
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

  @ApiProperty({ example: 150.0 })
  @IsNumber()
  unit_price: number;
}

export class CreateOrderDto {
  @ApiProperty()
  @IsUUID()
  branch_id: string;

  @ApiProperty()
  @IsUUID()
  staff_id: string;

  @ApiProperty({ example: 0, required: false })
  @IsNumber()
  @IsOptional()
  discount_amount?: number;

  @ApiProperty({ type: [CreateOrderItemDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items: CreateOrderItemDto[];
}
