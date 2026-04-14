import { BadRequestException, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DataSource, Repository } from 'typeorm';
import { CfdGatewayService } from '../cfd/cfd.gateway.service';
import { InventoryService } from '../inventory/inventory.service';
import { ProductsService } from '../products/products.service';
import { OrderSyncQueueService } from '../queue/order-sync-queue.service';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { OrderItem } from './entities/order-item.entity';
import { Order, PaymentStatus } from './entities/order.entity';
import { Payment, PaymentMethod } from './entities/payment.entity';
import { OrdersService } from './orders.service';

type RepoMock<T extends object> = {
  [K in keyof Partial<Repository<T>>]: jest.Mock;
};

describe('OrdersService', () => {
  let service: OrdersService;
  let ordersRepository: RepoMock<Order>;
  let orderItemsRepository: RepoMock<OrderItem>;
  let paymentsRepository: RepoMock<Payment>;
  let dataSource: { transaction: jest.Mock };
  let productsService: { findOne: jest.Mock };
  let inventoryService: { deductStock: jest.Mock; restoreStock: jest.Mock };
  let configService: { get: jest.Mock };
  let orderSyncQueueService: { enqueuePaidOrderSync: jest.Mock };
  let cfdGatewayService: { publishOrderSnapshot: jest.Mock };
  let transactionManager: {
    create: jest.Mock;
    save: jest.Mock;
    findOne: jest.Mock;
    update: jest.Mock;
  };

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
    transactionManager = {
      create: jest.fn((_: unknown, payload: object) => ({ ...payload })),
      save: jest.fn(async (entity: unknown) => entity),
      findOne: jest.fn(),
      update: jest.fn(),
    };
    dataSource = {
      transaction: jest.fn(async (callback: typeof transactionCallback) =>
        callback(transactionManager),
      ),
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
      paymentsRepository as unknown as Repository<Payment>,
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
    const savedOrder = {
      id: 'order-1',
      order_no: 'ORD-fixed',
    };
    const reloadedOrder = {
      ...savedOrder,
      items: [
        {
          product_id: 'product-1',
          qty: 2,
          unit_price: 100,
          subtotal: 200,
        },
      ],
    };
    const publishedOrder = {
      ...reloadedOrder,
      branch_id: 'branch-1',
      payments: [],
    };

    transactionManager.save.mockImplementation(async (entity: unknown) => {
      if (Array.isArray(entity)) {
        return entity;
      }
      return { ...entity, ...savedOrder };
    });
    transactionManager.findOne.mockResolvedValue(reloadedOrder);
    ordersRepository.findOne.mockResolvedValue(publishedOrder);

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
    expect(transactionManager.create).toHaveBeenNthCalledWith(
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

  it('returns the existing order when create hits a unique order_no race', async () => {
    productsService.findOne.mockResolvedValue({ base_price: 100 });
    const existingOrder = {
      id: 'existing-order',
      order_no: '840f2191-8679-437a-8099-a67ef5559344',
      items: [],
      payments: [],
    };

    ordersRepository.findOne
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce(existingOrder);
    dataSource.transaction.mockRejectedValue({ code: '23505' });

    await expect(
      service.create({
        order_no: existingOrder.order_no,
        branch_id: 'branch-1',
        staff_id: 'staff-1',
        items: [{ product_id: 'product-1', qty: 1 }],
      }),
    ).resolves.toEqual(existingOrder);
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
    };

    transactionManager.findOne
      .mockResolvedValueOnce(existingOrder)
      .mockResolvedValueOnce(updatedOrder);
    transactionManager.update.mockResolvedValue(undefined);
    ordersRepository.findOne.mockResolvedValue(publishedOrder);
    orderSyncQueueService.enqueuePaidOrderSync.mockResolvedValue(undefined);

    const result = await service.addPayment({
      order_id: 'order-1',
      method: PaymentMethod.CASH,
      amount_received: 100,
    });

    expect(transactionManager.update).toHaveBeenCalledWith(Order, 'order-1', {
      payment_status: PaymentStatus.PAID,
    });
    expect(inventoryService.deductStock).toHaveBeenNthCalledWith(
      1,
      'product-1',
      2,
      transactionManager,
    );
    expect(inventoryService.deductStock).toHaveBeenNthCalledWith(
      2,
      'product-2',
      1,
      transactionManager,
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
    };

    transactionManager.findOne
      .mockResolvedValueOnce(existingOrder)
      .mockResolvedValueOnce(updatedOrder);
    ordersRepository.findOne.mockResolvedValue(publishedOrder);

    const result = await service.addPayment({
      order_id: 'order-1',
      method: PaymentMethod.QR,
      amount_received: 30,
    });

    expect(transactionManager.update).not.toHaveBeenCalled();
    expect(inventoryService.deductStock).not.toHaveBeenCalled();
    expect(orderSyncQueueService.enqueuePaidOrderSync).not.toHaveBeenCalled();
    expect(result).toEqual({ ...updatedOrder, change: 0 });
  });

  it('rejects voiding an order that already synced to accounting', async () => {
    transactionManager.findOne.mockResolvedValue({
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
    expect(transactionManager.update).not.toHaveBeenCalled();
  });

  it('voids a paid order atomically and restores stock through the manager', async () => {
    const paidOrder = {
      id: 'order-1',
      payment_status: PaymentStatus.PAID,
      sync_status_acc: false,
      items: [{ product_id: 'product-1', qty: 2 }],
      payments: [{ amount_received: 100 }],
    };
    const voidedOrder = {
      ...paidOrder,
      payment_status: PaymentStatus.VOID,
    };
    const publishedOrder = {
      ...voidedOrder,
      branch_id: 'branch-1',
    };

    transactionManager.findOne
      .mockResolvedValueOnce(paidOrder)
      .mockResolvedValueOnce(voidedOrder);
    ordersRepository.findOne.mockResolvedValue(publishedOrder);

    await expect(service.voidOrder('order-1')).resolves.toEqual(voidedOrder);
    expect(inventoryService.restoreStock).toHaveBeenCalledWith(
      'product-1',
      2,
      transactionManager,
    );
    expect(transactionManager.update).toHaveBeenCalledWith(Order, 'order-1', {
      payment_status: PaymentStatus.VOID,
    });
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

type transactionCallback = (
  manager: {
    create: jest.Mock;
    save: jest.Mock;
    findOne: jest.Mock;
    update: jest.Mock;
  },
) => Promise<unknown>;
