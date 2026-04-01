import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { CreateOrderDto } from './dto/create-order.dto';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { OrderItem } from './entities/order-item.entity';
import { Order, PaymentStatus } from './entities/order.entity';
import { Payment } from './entities/payment.entity';

@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(Order)
    private ordersRepository: Repository<Order>,
    @InjectRepository(OrderItem)
    private orderItemsRepository: Repository<OrderItem>,
    @InjectRepository(Payment)
    private paymentsRepository: Repository<Payment>,
    private dataSource: DataSource,
  ) {}

  async create(dto: CreateOrderDto) {
    return this.dataSource.transaction(async (manager) => {
      const items = dto.items.map((item) => ({
        ...item,
        subtotal: item.qty * item.unit_price,
      }));

      const totalAmount = items.reduce((sum, item) => sum + item.subtotal, 0);
      const discountAmount = dto.discount_amount || 0;
      const vatAmount = (totalAmount - discountAmount) * 0.07;
      const netAmount = totalAmount - discountAmount + vatAmount;

      const order = manager.create(Order, {
        order_no: `ORD-${Date.now()}`,
        branch_id: dto.branch_id,
        staff_id: dto.staff_id,
        total_amount: totalAmount,
        discount_amount: discountAmount,
        vat_amount: Math.round(vatAmount * 100) / 100,
        net_amount: Math.round(netAmount * 100) / 100,
      });
      const savedOrder = await manager.save(order);

      const orderItems = items.map((item) =>
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
    const payment = this.paymentsRepository.create(dto);
    await this.paymentsRepository.save(payment);

    await this.ordersRepository.update(order.id, {
      payment_status: PaymentStatus.PAID,
    });

    return this.findOne(order.id);
  }

  findUnsynced() {
    return this.ordersRepository.find({
      where: { sync_status_acc: false, payment_status: PaymentStatus.PAID },
      relations: ['items', 'payments'],
    });
  }
}
