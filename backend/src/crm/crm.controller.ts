import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiSecurity, ApiTags } from '@nestjs/swagger';
import { ApiKeyGuard } from '../common/guards/api-key.guard';
import { CrmService } from './crm.service';
import { EarnPointsDto } from './dto/earn-points.dto';

@ApiTags('CRM')
@ApiSecurity('api-key')
@UseGuards(ApiKeyGuard)
@Controller('crm')
export class CrmController {
  constructor(private crmService: CrmService) {}

  @Get('member')
  @ApiOperation({ summary: 'Look up CRM member by phone number' })
  findMember(@Query('phone') phone: string) {
    return this.crmService.findMemberByPhone(phone);
  }

  @Post('points/earn')
  @ApiOperation({ summary: 'Earn points for an order' })
  earnPoints(@Body() dto: EarnPointsDto) {
    return this.crmService.earnPoints(dto);
  }
}
