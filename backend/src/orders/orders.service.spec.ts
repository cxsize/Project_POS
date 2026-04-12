import { BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DataSource, Repository } from 'typeorm';
import { InventoryService } from '../inventory/inventory.service';
import { ProductsService } from '../products/products.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { Order } from './entities/order.entity';
import { OrderItem } from './entities/order-item.entity';
import { Payment } from './entities/payment.entity';
import { OrdersService } from './orders.service';

describe('OrdersService.create', () => {
  let service: OrdersService;

  const ordersRepository = {} as Repository<Order>;
  const orderItemsRepository = {} as Repository<OrderItem>;
  const paymentsRepository = {} as Repository<Payment>;
  const manager = {
    create: jest.fn((_: unknown, payload: Record<string, unknown>) => payload),
    save: jest.fn((entity: unknown) => {
      if (Array.isArray(entity)) {
        return Promise.resolve(entity as unknown[]);
      }
      return Promise.resolve({
        id: 'order-id',
        ...(entity as Record<string, unknown>),
      });
    }),
    findOne: jest.fn(() => Promise.resolve({ id: 'order-id', items: [] })),
  };

  const dataSource = {
    transaction: jest.fn((handler: (manager: typeof manager) => unknown) =>
      Promise.resolve(handler(manager)),
    ),
  } as unknown as DataSource;

  const productsService = {
    findOne: jest.fn(),
  } as unknown as ProductsService;

  const inventoryService = {} as InventoryService;
  const configService = {
    get: jest.fn((key: string) => {
      if (key === 'VAT_RATE') {
        return '0.07';
      }
      return undefined;
    }),
  } as unknown as ConfigService;

  const baseDto: CreateOrderDto = {
    branch_id: '11111111-1111-1111-1111-111111111111',
    staff_id: '22222222-2222-2222-2222-222222222222',
    items: [
      {
        product_id: '33333333-3333-3333-3333-333333333333',
        qty: 1,
      },
      {
        product_id: '44444444-4444-4444-4444-444444444444',
        qty: 1,
      },
    ],
  };

  beforeEach(() => {
    jest.clearAllMocks();
    productsService.findOne = jest.fn().mockResolvedValue({ base_price: 100 });
    service = new OrdersService(
      ordersRepository,
      orderItemsRepository,
      paymentsRepository,
      dataSource,
      productsService,
      inventoryService,
      configService,
    );
  });

  it('calculates totals correctly with flat discount', async () => {
    await service.create({
      ...baseDto,
      discount_type: 'flat',
      discount_amount: 30,
    });

    expect(manager.create).toHaveBeenCalledWith(
      Order,
      expect.objectContaining({
        total_amount: 200,
        discount_amount: 30,
        vat_amount: 11.9,
        net_amount: 181.9,
      }),
    );
  });

  it('calculates totals correctly with percentage discount', async () => {
    await service.create({
      ...baseDto,
      discount_type: 'percent',
      discount_percent: 10,
    });

    expect(manager.create).toHaveBeenCalledWith(
      Order,
      expect.objectContaining({
        total_amount: 200,
        discount_amount: 20,
        vat_amount: 12.6,
        net_amount: 192.6,
      }),
    );
  });

  it('rejects when client totals do not match server-calculated totals', async () => {
    await expect(
      service.create({
        ...baseDto,
        total_amount: 199,
      }),
    ).rejects.toThrow(BadRequestException);
  });
});
