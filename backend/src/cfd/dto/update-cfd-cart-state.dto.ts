import { Type } from 'class-transformer';
import {
  IsArray,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Min,
  ValidateNested,
} from 'class-validator';

export class CfdCartStateItemDto {
  @IsUUID()
  product_id: string;

  @IsString()
  name: string;

  @Type(() => Number)
  @IsNumber()
  @Min(1)
  qty: number;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  unit_price: number;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  subtotal: number;
}

export class UpdateCfdCartStateDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CfdCartStateItemDto)
  items: CfdCartStateItemDto[];

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  total_amount: number;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  discount_amount: number;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  vat_amount: number;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  net_amount: number;

  @IsOptional()
  @IsUUID()
  order_id?: string;

  @IsOptional()
  @IsString()
  order_no?: string;

  @IsOptional()
  @IsString()
  payment_status?: string;
}
