import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { ApiOperation, ApiSecurity, ApiTags } from '@nestjs/swagger';
import { ApiKeyGuard } from '../common/guards/api-key.guard';
import { AccountingService } from './accounting.service';
import { SyncReceiptDto } from './dto/sync-receipt.dto';

@ApiTags('Accounting')
@ApiSecurity('api-key')
@UseGuards(ApiKeyGuard)
@Controller('accounting')
export class AccountingController {
  constructor(private accountingService: AccountingService) {}

  @Post('sync-receipt')
  @ApiOperation({ summary: 'Push receipt details to external accounting' })
  syncReceipt(@Body() dto: SyncReceiptDto) {
    return this.accountingService.syncReceipt(dto);
  }
}
