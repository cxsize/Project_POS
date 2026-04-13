import { BadRequestException, NotFoundException } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';
import { InventoryService } from '../inventory/inventory.service';
import { ProductsService } from '../products/products.service';
import { OrderItem } from './entities/order-item.entity';
import { Order, PaymentStatus } from './entities/order.entity';
import { PaymentMethod } from './entities/payment.entity';
import { OrdersService } from './orders.service';

type RepoMock<T extends object> = {
  [K in keyof Partial<Repository<T>>]: jest.Mock;
};

describe('OrdersService', () => {
  let service: OrdersService;
  let ordersRepository: RepoMock<Order>;
  let orderItemsRepository: RepoMock<OrderItem>;
  let paymentsRepository: RepoMock<any>;
  let dataSource: { transaction: jest.Mock };
  let productsService: { findOne: jest.Mock };
  let inventoryService: { deductStock: jest.Mock };

  beforeEach(() => {
    ordersRepository = {
      find: jest.fn(),
      findOne: jest.fn(),
      update: jest.fn(),
    };
    orderItemsRepository = {};
    paymentsRepository = {
      create: jest.fn(),
      save: jest.fn(),
    };
    dataSource = {
      transaction: jest.fn(),
    };
    productsService = {
      findOne: jest.fn(),
    };
    inventoryService = {
      deductStock: jest.fn(),
    };

    service = new OrdersService(
      ordersRepository as unknown as Repository<Order>,
      orderItemsRepository as unknown as Repository<OrderItem>,
      paymentsRepository as unknown as Repository<any>,
      dataSource as unknown as DataSource,
      productsService as unknown as ProductsService,
      inventoryService as unknown as InventoryService,
    );
  });

  it('creates an order with resolved prices and persisted items', async () => {
    productsService.findOne.mockResolvedValue({ base_price: 100 });

    const savedOrder = {
      id: 'order-1',
      order_no: 'ORD-fixed',
    };
    const reloadedOrder = {
      ...savedOrder,
      items: [{ product_id: 'product-1', qty: 2, unit_price: 100, subtotal: 200 }],
    };
    const manager = {
      create: jest.fn((_: unknown, payload: object) => ({ ...payload })),
      save: jest.fn(async (entity: unknown) => {
        if (Array.isArray(entity)) {
          return entity;
        }
        return { ...entity, ...savedOrder };
      }),
      findOne: jest.fn().mockResolvedValue(reloadedOrder),
    };
    dataSource.transaction.mockImplementation(async (callback: (mgr: typeof manager) => Promise<unknown>) =>
      callback(manager),
    );

    const result = await service.create({
      branch_id: 'branch-1',
      staff_id: 'staff-1',
      discount_amount: 10,
      items: [{ product_id: 'product-1', qty: 2 }],
    });

    expect(productsService.findOne).toHaveBeenCalledWith('product-1');
    expect(dataSource.transaction).toHaveBeenCalledTimes(1);
    expect(manager.create).toHaveBeenNthCalledWith(
      1,
      Order,
      expect.objectContaining({
        branch_id: 'branch-1',
        staff_id: 'staff-1',
        total_amount: 200,
        discount_amount: 10,
        vat_amount: 13.3,
        net_amount: 203.3,
      }),
    );
    expect(manager.create).toHaveBeenNthCalledWith(
      2,
      OrderItem,
      expect.objectContaining({
        order_id: 'order-1',
        product_id: 'product-1',
        qty: 2,
        unit_price: 100,
        subtotal: 200,
      }),
    );
    expect(manager.findOne).toHaveBeenCalledWith(Order, {
      where: { id: 'order-1' },
      relations: ['items'],
    });
    expect(result).toEqual(reloadedOrder);
  });

  it('throws when finding a missing order', async () => {
    ordersRepository.findOne.mockResolvedValue(null);

    await expect(service.findOne('missing-order')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('rejects payments for an already paid order', async () => {
    ordersRepository.findOne.mockResolvedValue({
      id: 'order-1',
      payment_status: PaymentStatus.PAID,
      payments: [],
    });

    await expect(
      service.addPayment({
        order_id: 'order-1',
        method: PaymentMethod.CASH,
        amount_received: 100,
      }),
    ).rejects.toBeInstanceOf(BadRequestException);

    expect(paymentsRepository.save).not.toHaveBeenCalled();
  });

  it('marks an order paid, deducts stock, and returns change when fully covered', async () => {
    const existingOrder = {
      id: 'order-1',
      net_amount: 100,
      payment_status: PaymentStatus.PENDING,
      payments: [{ amount_received: 20 }],
      items: [
        { product_id: 'product-1', qty: 2 },
        { product_id: 'product-2', qty: 1 },
      ],
    };
    const updatedOrder = {
      ...existingOrder,
      payment_status: PaymentStatus.PAID,
      payments: [
        { amount_received: 20 },
        { amount_received: 100 },
      ],
    };
    ordersRepository.findOne
      .mockResolvedValueOnce(existingOrder)
      .mockResolvedValueOnce(updatedOrder);
    paymentsRepository.create.mockImplementation((dto: object) => dto);
    paymentsRepository.save.mockResolvedValue(undefined);
    ordersRepository.update.mockResolvedValue(undefined);
    inventoryService.deductStock.mockResolvedValue(undefined);

    const result = await service.addPayment({
      order_id: 'order-1',
      method: PaymentMethod.CASH,
      amount_received: 100,
    });

    expect(paymentsRepository.create).toHaveBeenCalledWith({
      order_id: 'order-1',
      method: PaymentMethod.CASH,
      amount_received: 100,
    });
    expect(ordersRepository.update).toHaveBeenCalledWith('order-1', {
      payment_status: PaymentStatus.PAID,
    });
    expect(inventoryService.deductStock).toHaveBeenNthCalledWith(
      1,
      'product-1',
      2,
    );
    expect(inventoryService.deductStock).toHaveBeenNthCalledWith(
      2,
      'product-2',
      1,
    );
    expect(result).toEqual({ ...updatedOrder, change: 20 });
  });

  it('keeps an order pending when a payment is partial', async () => {
    const existingOrder = {
      id: 'order-1',
      net_amount: 100,
      payment_status: PaymentStatus.PENDING,
      payments: [{ amount_received: 20 }],
      items: [{ product_id: 'product-1', qty: 2 }],
    };
    const updatedOrder = {
      ...existingOrder,
      payments: [
        { amount_received: 20 },
        { amount_received: 30 },
      ],
    };
    ordersRepository.findOne
      .mockResolvedValueOnce(existingOrder)
      .mockResolvedValueOnce(updatedOrder);
    paymentsRepository.create.mockImplementation((dto: object) => dto);
    paymentsRepository.save.mockResolvedValue(undefined);

    const result = await service.addPayment({
      order_id: 'order-1',
      method: PaymentMethod.QR,
      amount_received: 30,
    });

    expect(ordersRepository.update).not.toHaveBeenCalled();
    expect(inventoryService.deductStock).not.toHaveBeenCalled();
    expect(result).toEqual({ ...updatedOrder, change: 0 });
  });

  it('finds paid orders that are still unsynced', async () => {
    ordersRepository.find.mockResolvedValue([]);

    await service.findUnsynced();

    expect(ordersRepository.find).toHaveBeenCalledWith({
      where: { sync_status_acc: false, payment_status: PaymentStatus.PAID },
      relations: ['items', 'payments'],
    });
  });
});
