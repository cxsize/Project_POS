import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { UpdateCfdCartStateDto } from './dto/update-cfd-cart-state.dto';
import { CfdGatewayService } from './cfd.gateway.service';

@ApiTags('CFD')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('cfd')
export class CfdController {
  constructor(private readonly cfdGatewayService: CfdGatewayService) {}

  @Get(':branchId/cart-state')
  @ApiOperation({ summary: 'Get the latest cached CFD cart state for a branch' })
  findLatestCartState(@Param('branchId', ParseUUIDPipe) branchId: string) {
    return this.cfdGatewayService.getLatestSnapshot(branchId);
  }

  @Post(':branchId/cart-state')
  @ApiOperation({
    summary: 'Publish a cart state snapshot to CFD websocket clients',
  })
  publishCartState(
    @Param('branchId', ParseUUIDPipe) branchId: string,
    @Body() payload: UpdateCfdCartStateDto,
  ) {
    return this.cfdGatewayService.publishCartState(branchId, payload);
  }
}
