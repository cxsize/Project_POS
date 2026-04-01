import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsString, Min } from 'class-validator';

export class CreateIngredientDto {
  @ApiProperty({ example: 'Flour' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 'grams' })
  @IsString()
  @IsNotEmpty()
  unit: string;

  @ApiProperty({ example: 5000 })
  @IsNumber()
  @Min(0)
  stock_qty: number;

  @ApiProperty({ example: 500 })
  @IsNumber()
  @Min(0)
  min_alert_qty: number;
}
