import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';

export class CreateProductDto {
  @ApiProperty({ example: 'SKU-001' })
  @IsString()
  @IsNotEmpty()
  sku: string;

  @ApiProperty({ example: 'Chocolate Cake' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 150.0 })
  @IsNumber()
  base_price: number;

  @ApiPropertyOptional()
  @IsUUID()
  @IsOptional()
  category_id?: string;

  @ApiPropertyOptional({ default: true })
  @IsBoolean()
  @IsOptional()
  is_active?: boolean;
}
