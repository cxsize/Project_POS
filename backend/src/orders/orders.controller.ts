import {
  Body,
  Controller,
  ForbiddenException,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { UserRole } from '../auth/entities/user.entity';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CreateOrderDto } from './dto/create-order.dto';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { OrdersService } from './orders.service';

@ApiTags('Orders')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('orders')
export class OrdersController {
  constructor(private ordersService: OrdersService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new order with line items' })
  create(@Body() createOrderDto: CreateOrderDto) {
    return this.ordersService.create(createOrderDto);
  }

  @Get()
  @ApiOperation({ summary: 'List all orders' })
  findAll() {
    return this.ordersService.findAll();
  }

  @Get('unsynced')
  @ApiOperation({ summary: 'List paid orders not yet synced to accounting' })
  findUnsynced() {
    return this.ordersService.findUnsynced();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get order by ID with items and payments' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.ordersService.findOne(id);
  }

  @Post(':id/payments')
  @ApiOperation({ summary: 'Add payment to an order' })
  addPayment(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() createPaymentDto: CreatePaymentDto,
  ) {
    createPaymentDto.order_id = id;
    return this.ordersService.addPayment(createPaymentDto);
  }

  @Post(':id/void')
  @ApiOperation({ summary: 'Void order and reverse stock deduction' })
  voidOrder(
    @Param('id', ParseUUIDPipe) id: string,
    @Req()
    req: {
      user?: {
        role?: string;
      };
    },
  ) {
    const role = req.user?.role;
    if (role !== UserRole.ADMIN && role !== UserRole.MANAGER) {
      throw new ForbiddenException('Only manager or admin can void orders');
    }
    return this.ordersService.voidOrder(id);
  }
}
