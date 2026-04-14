import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateBranchDto {
  @ApiProperty({ example: 'Main Branch' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  name: string;

  @ApiProperty({ example: '123 Sukhumvit Rd, Bangkok', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  address?: string;
}
