import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { InventoryService } from '../inventory/inventory.service';
import { ProductsService } from '../products/products.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { OrderItem } from './entities/order-item.entity';
import { Order, PaymentStatus } from './entities/order.entity';
import { Payment } from './entities/payment.entity';

@Injectable()
export class OrdersService {
  private static readonly DEFAULT_VAT_RATE = 0.07;
  private static readonly CURRENCY_PRECISION = 100;
  private static readonly AMOUNT_TOLERANCE = 0.01;

  constructor(
    @InjectRepository(Order)
    private ordersRepository: Repository<Order>,
    @InjectRepository(OrderItem)
    private orderItemsRepository: Repository<OrderItem>,
    @InjectRepository(Payment)
    private paymentsRepository: Repository<Payment>,
    private dataSource: DataSource,
    private productsService: ProductsService,
    private inventoryService: InventoryService,
    private configService: ConfigService,
  ) {}

  async create(dto: CreateOrderDto) {
    if (dto.order_no) {
      const existingOrder = await this.ordersRepository.findOne({
        where: { order_no: dto.order_no },
        relations: ['items', 'payments'],
      });
      if (existingOrder) {
        return existingOrder;
      }
    }

    // Validate all products exist and resolve prices
    const resolvedItems = await Promise.all(
      dto.items.map(async (item) => {
        const product = await this.productsService.findOne(item.product_id);
        const unitPrice = item.unit_price ?? Number(product.base_price);
        return {
          product_id: item.product_id,
          qty: item.qty,
          unit_price: unitPrice,
          subtotal: item.qty * unitPrice,
        };
      }),
    );

    return this.dataSource.transaction(async (manager) => {
      const totalAmount = this.roundCurrency(
        resolvedItems.reduce((sum, item) => sum + item.subtotal, 0),
      );
      const discountAmount = this.resolveDiscountAmount(dto, totalAmount);
      const vatRate = this.getVatRate();
      const taxableAmount = Math.max(0, totalAmount - discountAmount);
      const vatAmount = this.roundCurrency(taxableAmount * vatRate);
      const netAmount = this.roundCurrency(
        totalAmount - discountAmount + vatAmount,
      );

      this.assertClientTotals(dto, { totalAmount, vatAmount, netAmount });

      const order = manager.create(Order, {
        order_no:
          dto.order_no ??
          `ORD-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`,
        branch_id: dto.branch_id,
        staff_id: dto.staff_id,
        total_amount: totalAmount,
        discount_amount: discountAmount,
        vat_amount: vatAmount,
        net_amount: netAmount,
      });
      const savedOrder = await manager.save(order);

      const orderItems = resolvedItems.map((item) =>
        manager.create(OrderItem, { ...item, order_id: savedOrder.id }),
      );
      await manager.save(orderItems);

      return manager.findOne(Order, {
        where: { id: savedOrder.id },
        relations: ['items'],
      });
    });
  }

  findAll() {
    return this.ordersRepository.find({
      relations: ['items', 'payments'],
      order: { created_at: 'DESC' },
    });
  }

  async findOne(id: string) {
    const order = await this.ordersRepository.findOne({
      where: { id },
      relations: ['items', 'payments'],
    });
    if (!order) throw new NotFoundException(`Order ${id} not found`);
    return order;
  }

  async addPayment(dto: CreatePaymentDto) {
    const order = await this.findOne(dto.order_id);

    if (order.payment_status === PaymentStatus.PAID) {
      throw new BadRequestException('Order is already fully paid');
    }
    if (order.payment_status === PaymentStatus.VOID) {
      throw new BadRequestException('Cannot pay for a voided order');
    }

    // Calculate total already paid
    const totalPaid = order.payments.reduce(
      (sum, p) => sum + Number(p.amount_received),
      0,
    );
    const remaining = Number(order.net_amount) - totalPaid;

    if (remaining <= 0) {
      throw new BadRequestException('Order is already fully paid');
    }

    const payment = this.paymentsRepository.create(dto);
    await this.paymentsRepository.save(payment);

    const newTotalPaid = totalPaid + dto.amount_received;
    const change = Math.max(
      0,
      Math.round((newTotalPaid - Number(order.net_amount)) * 100) / 100,
    );

    // Mark as paid if fully covered
    if (newTotalPaid >= Number(order.net_amount)) {
      await this.ordersRepository.update(order.id, {
        payment_status: PaymentStatus.PAID,
      });

      // Deduct stock for each item in the order
      for (const item of order.items) {
        await this.inventoryService.deductStock(item.product_id, item.qty);
      }
    }

    const updatedOrder = await this.findOne(order.id);
    return { ...updatedOrder, change };
  }

  findUnsynced() {
    return this.ordersRepository.find({
      where: { sync_status_acc: false, payment_status: PaymentStatus.PAID },
      relations: ['items', 'payments'],
    });
  }

  private assertClientTotals(
    dto: CreateOrderDto,
    computed: { totalAmount: number; vatAmount: number; netAmount: number },
  ) {
    this.assertAmountMatch(
      'total_amount',
      dto.total_amount,
      computed.totalAmount,
    );
    this.assertAmountMatch('vat_amount', dto.vat_amount, computed.vatAmount);
    this.assertAmountMatch('net_amount', dto.net_amount, computed.netAmount);
  }

  private assertAmountMatch(
    field: 'total_amount' | 'vat_amount' | 'net_amount',
    provided: number | undefined,
    expected: number,
  ) {
    if (provided == null) {
      return;
    }

    const normalizedProvided = this.roundCurrency(provided);
    const normalizedExpected = this.roundCurrency(expected);
    if (
      Math.abs(normalizedProvided - normalizedExpected) >
      OrdersService.AMOUNT_TOLERANCE
    ) {
      throw new BadRequestException(
        `${field} mismatch: expected ${normalizedExpected.toFixed(2)}`,
      );
    }
  }

  private resolveDiscountAmount(dto: CreateOrderDto, totalAmount: number) {
    const hasFlatDiscount = dto.discount_amount != null;
    const hasPercentDiscount = dto.discount_percent != null;
    if (hasFlatDiscount && hasPercentDiscount) {
      throw new BadRequestException(
        'Provide only one of discount_amount or discount_percent',
      );
    }

    const discountType =
      dto.discount_type ?? (hasPercentDiscount ? 'percent' : 'flat');

    if (discountType === 'percent') {
      const percent = dto.discount_percent ?? 0;
      if (percent < 0 || percent > 100) {
        throw new BadRequestException(
          'discount_percent must be between 0 and 100',
        );
      }
      return this.roundCurrency((totalAmount * percent) / 100);
    }

    const amount = dto.discount_amount ?? 0;
    if (amount < 0) {
      throw new BadRequestException('discount_amount must be >= 0');
    }
    if (amount > totalAmount) {
      throw new BadRequestException(
        'discount_amount cannot exceed total_amount',
      );
    }
    return this.roundCurrency(amount);
  }

  private getVatRate() {
    const configuredVatRate = this.configService.get<string>('VAT_RATE');
    if (!configuredVatRate) {
      return OrdersService.DEFAULT_VAT_RATE;
    }

    const parsedRate = Number(configuredVatRate);
    if (Number.isNaN(parsedRate) || parsedRate < 0) {
      return OrdersService.DEFAULT_VAT_RATE;
    }

    if (parsedRate <= 1) {
      return parsedRate;
    }

    return parsedRate / 100;
  }

  private roundCurrency(value: number) {
    return (
      Math.round((value + Number.EPSILON) * OrdersService.CURRENCY_PRECISION) /
      OrdersService.CURRENCY_PRECISION
    );
  }
}
