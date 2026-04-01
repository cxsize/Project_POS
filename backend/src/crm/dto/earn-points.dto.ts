import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsUUID, Min } from 'class-validator';

export class EarnPointsDto {
  @ApiProperty()
  @IsUUID()
  order_id: string;

  @ApiProperty({ example: 300.0 })
  @IsNumber()
  @Min(0)
  amount: number;

  @ApiProperty()
  @IsUUID()
  customer_id: string;
}
