import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsUUID, Min } from 'class-validator';

export class CreateRecipeDto {
  @ApiProperty()
  @IsUUID()
  product_id: string;

  @ApiProperty()
  @IsUUID()
  ingredient_id: string;

  @ApiProperty({ example: 200, description: 'Usage quantity per product unit' })
  @IsNumber()
  @Min(0)
  usage_qty: number;
}
