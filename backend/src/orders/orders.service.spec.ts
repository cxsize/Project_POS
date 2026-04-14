import { BadRequestException, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DataSource, Repository } from 'typeorm';
import { CfdGatewayService } from '../cfd/cfd.gateway.service';
import { InventoryService } from '../inventory/inventory.service';
import { ProductsService } from '../products/products.service';
import { OrderSyncQueueService } from '../queue/order-sync-queue.service';
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
  let inventoryService: { deductStock: jest.Mock; restoreStock: jest.Mock };
  let configService: { get: jest.Mock };
  let orderSyncQueueService: { enqueuePaidOrderSync: jest.Mock };
  let cfdGatewayService: { publishOrderSnapshot: jest.Mock };

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
      restoreStock: jest.fn(),
    };
    configService = {
      get: jest.fn((key: string) => {
        if (key === 'VAT_RATE') {
          return '0.07';
        }
        return undefined;
      }),
    };
    orderSyncQueueService = {
      enqueuePaidOrderSync: jest.fn(),
    };
    cfdGatewayService = {
      publishOrderSnapshot: jest.fn(),
    };

    service = new OrdersService(
      ordersRepository as unknown as Repository<Order>,
      orderItemsRepository as unknown as Repository<OrderItem>,
      paymentsRepository as unknown as Repository<any>,
      dataSource as unknown as DataSource,
      productsService as unknown as ProductsService,
      inventoryService as unknown as InventoryService,
      configService as unknown as ConfigService,
      orderSyncQueueService as unknown as OrderSyncQueueService,
      cfdGatewayService as unknown as CfdGatewayService,
    );
  });

  it('creates an order with validated totals and publishes a CFD snapshot', async () => {
    productsService.findOne.mockResolvedValue({ base_price: 100 });
    ordersRepository.findOne.mockResolvedValue({
      id: 'order-1',
      branch_id: 'branch-1',
      items: [],
      payments: [],
    });

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
    dataSource.transaction.mockImplementation(
      async (callback: (mgr: typeof manager) => Promise<unknown>) =>
        callback(manager),
    );

    const result = await service.create({
      branch_id: 'branch-1',
      staff_id: 'staff-1',
      discount_type: 'flat',
      discount_amount: 10,
      total_amount: 200,
      vat_amount: 13.3,
      net_amount: 203.3,
      items: [{ product_id: 'product-1', qty: 2 }],
    });

    expect(productsService.findOne).toHaveBeenCalledWith('product-1');
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
    expect(result).toEqual(reloadedOrder);
    expect(cfdGatewayService.publishOrderSnapshot).toHaveBeenCalledTimes(1);
  });

  it('rejects when client totals do not match server-calculated totals', async () => {
    productsService.findOne.mockResolvedValue({ base_price: 100 });

    await expect(
      service.create({
        branch_id: 'branch-1',
        staff_id: 'staff-1',
        total_amount: 199,
        items: [{ product_id: 'product-1', qty: 2 }],
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('throws when finding a missing order', async () => {
    ordersRepository.findOne.mockResolvedValue(null);

    await expect(service.findOne('missing-order')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('marks an order paid, deducts stock, enqueues sync, and returns change', async () => {
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
      payments: [{ amount_received: 20 }, { amount_received: 100 }],
    };
    const publishedOrder = {
      ...updatedOrder,
      branch_id: 'branch-1',
      items: [],
    };
    ordersRepository.findOne
      .mockResolvedValueOnce(existingOrder)
      .mockResolvedValueOnce(updatedOrder)
      .mockResolvedValueOnce(publishedOrder);
    paymentsRepository.create.mockImplementation((dto: object) => dto);
    paymentsRepository.save.mockResolvedValue(undefined);
    ordersRepository.update.mockResolvedValue(undefined);
    inventoryService.deductStock.mockResolvedValue(undefined);
    orderSyncQueueService.enqueuePaidOrderSync.mockResolvedValue(undefined);

    const result = await service.addPayment({
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
    expect(orderSyncQueueService.enqueuePaidOrderSync).toHaveBeenCalledWith(
      'order-1',
    );
    expect(cfdGatewayService.publishOrderSnapshot).toHaveBeenCalledTimes(1);
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
      payments: [{ amount_received: 20 }, { amount_received: 30 }],
    };
    const publishedOrder = {
      ...updatedOrder,
      branch_id: 'branch-1',
      items: [],
    };
    ordersRepository.findOne
      .mockResolvedValueOnce(existingOrder)
      .mockResolvedValueOnce(updatedOrder)
      .mockResolvedValueOnce(publishedOrder);
    paymentsRepository.create.mockImplementation((dto: object) => dto);
    paymentsRepository.save.mockResolvedValue(undefined);

    const result = await service.addPayment({
      order_id: 'order-1',
      method: PaymentMethod.QR,
      amount_received: 30,
    });

    expect(ordersRepository.update).not.toHaveBeenCalled();
    expect(inventoryService.deductStock).not.toHaveBeenCalled();
    expect(orderSyncQueueService.enqueuePaidOrderSync).not.toHaveBeenCalled();
    expect(result).toEqual({ ...updatedOrder, change: 0 });
  });

  it('rejects voiding an order that already synced to accounting', async () => {
    ordersRepository.findOne.mockResolvedValue({
      id: 'order-1',
      payment_status: PaymentStatus.PAID,
      sync_status_acc: true,
      items: [],
      payments: [],
    });

    await expect(service.voidOrder('order-1')).rejects.toBeInstanceOf(
      BadRequestException,
    );
    expect(inventoryService.restoreStock).not.toHaveBeenCalled();
    expect(ordersRepository.update).not.toHaveBeenCalled();
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
