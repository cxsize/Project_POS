import { EventEmitter } from 'events';
import { Socket } from 'net';
import { HttpAdapterHost } from '@nestjs/core';
import {
  CfdGatewayService,
  decodeWebSocketFrame,
  extractCfdBranchId,
} from './cfd.gateway.service';
import { Order, PaymentStatus } from '../orders/entities/order.entity';

class FakeSocket extends EventEmitter {
  readonly writes: Buffer[] = [];
  destroyed = false;
  writable = true;

  write(chunk: string | Buffer) {
    this.writes.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
    return true;
  }

  end() {
    this.writable = false;
    this.emit('end');
    return this;
  }

  destroy() {
    this.destroyed = true;
    this.writable = false;
    this.emit('close');
    return this;
  }

  removeAllListeners(event?: string | symbol) {
    super.removeAllListeners(event);
    return this;
  }
}

describe('CfdGatewayService', () => {
  let service: CfdGatewayService;

  beforeEach(() => {
    service = new CfdGatewayService({
      httpAdapter: { getHttpServer: () => null },
    } as HttpAdapterHost);
  });

  test('extractCfdBranchId supports documented websocket paths', () => {
    const branchId = '9f3e4cf2-3a9c-4d7d-9b2b-e7ab5f1dcb14';

    expect(extractCfdBranchId(`/pos-cfd/${branchId}`)).toBe(branchId);
    expect(extractCfdBranchId(`/api/v1/pos-cfd/${branchId}`)).toBe(branchId);
    expect(extractCfdBranchId('/orders')).toBeNull();
  });

  test('publishCartState caches and broadcasts snapshots', () => {
    const socket = new FakeSocket() as unknown as Socket;
    const branchId = '9f3e4cf2-3a9c-4d7d-9b2b-e7ab5f1dcb14';

    service.registerClient(branchId, socket);
    const snapshot = service.publishCartState(branchId, {
      items: [
        {
          product_id: 'f13d4f5c-31a3-49ca-b22f-0f78c8e0ef31',
          name: 'Americano',
          qty: 2,
          unit_price: 55,
          subtotal: 110,
        },
      ],
      total_amount: 110,
      discount_amount: 0,
      vat_amount: 7.7,
      net_amount: 117.7,
    });

    expect(service.getLatestSnapshot(branchId)).toEqual(snapshot);

    const frame = decodeWebSocketFrame(
      (socket as unknown as FakeSocket).writes.at(-1) ?? Buffer.alloc(0),
    );
    expect(frame).not.toBeNull();
    expect(JSON.parse(frame!.payload.toString())).toMatchObject({
      type: 'cart_state',
      branch_id: branchId,
      total_amount: 110,
      net_amount: 117.7,
    });
  });

  test('publishOrderSnapshot maps order entity into CFD payload', () => {
    const order = {
      id: '3f8c75a2-4f51-4c55-a2c0-47e0c1a5b43d',
      order_no: 'ORD-001',
      branch_id: '9f3e4cf2-3a9c-4d7d-9b2b-e7ab5f1dcb14',
      staff_id: '7df9a1bd-1d7e-4c07-bf9f-c496739cb299',
      total_amount: 100,
      discount_amount: 0,
      vat_amount: 7,
      net_amount: 107,
      payment_status: PaymentStatus.PAID,
      sync_status_acc: false,
      created_at: new Date(),
      items: [
        {
          product_id: 'f13d4f5c-31a3-49ca-b22f-0f78c8e0ef31',
          qty: 1,
          unit_price: 100,
          subtotal: 100,
          product: { name: 'Americano' },
        },
      ],
      payments: [],
    } as unknown as Order;

    const snapshot = service.publishOrderSnapshot(order);

    expect(snapshot).toMatchObject({
      branch_id: order.branch_id,
      order_id: order.id,
      order_no: order.order_no,
      payment_status: PaymentStatus.PAID,
      items: [
        {
          product_id: 'f13d4f5c-31a3-49ca-b22f-0f78c8e0ef31',
          name: 'Americano',
          qty: 1,
        },
      ],
    });
  });
});
