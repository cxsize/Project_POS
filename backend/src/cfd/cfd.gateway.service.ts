import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { HttpAdapterHost } from '@nestjs/core';
import { createHash } from 'crypto';
import { IncomingMessage, Server as HttpServer } from 'http';
import { Socket } from 'net';
import { Order } from '../orders/entities/order.entity';
import {
  CfdCartStateItem,
  CfdCartStatePayload,
} from './interfaces/cfd-cart-state.interface';

const WEBSOCKET_MAGIC_GUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';

interface ParsedFrame {
  opcode: number;
  payload: Buffer;
  bytesRead: number;
}

export function extractCfdBranchId(url?: string | null): string | null {
  if (!url) {
    return null;
  }

  const path = new URL(url, 'http://localhost').pathname;
  const match = path.match(/^\/(?:api\/v1\/)?pos-cfd\/([0-9a-fA-F-]+)$/);
  return match?.[1] ?? null;
}

export function encodeWebSocketFrame(
  payload: string | Buffer,
  opcode = 0x1,
): Buffer {
  const body = Buffer.isBuffer(payload) ? payload : Buffer.from(payload);

  if (body.length < 126) {
    return Buffer.concat([
      Buffer.from([0x80 | opcode, body.length]),
      body,
    ]);
  }

  if (body.length < 65536) {
    const header = Buffer.alloc(4);
    header[0] = 0x80 | opcode;
    header[1] = 126;
    header.writeUInt16BE(body.length, 2);
    return Buffer.concat([header, body]);
  }

  const header = Buffer.alloc(10);
  header[0] = 0x80 | opcode;
  header[1] = 127;
  header.writeBigUInt64BE(BigInt(body.length), 2);
  return Buffer.concat([header, body]);
}

export function decodeWebSocketFrame(buffer: Buffer): ParsedFrame | null {
  if (buffer.length < 2) {
    return null;
  }

  const firstByte = buffer[0];
  const secondByte = buffer[1];
  const masked = (secondByte & 0x80) !== 0;
  const opcode = firstByte & 0x0f;

  let offset = 2;
  let payloadLength = secondByte & 0x7f;

  if (payloadLength === 126) {
    if (buffer.length < offset + 2) {
      return null;
    }
    payloadLength = buffer.readUInt16BE(offset);
    offset += 2;
  } else if (payloadLength === 127) {
    if (buffer.length < offset + 8) {
      return null;
    }
    payloadLength = Number(buffer.readBigUInt64BE(offset));
    offset += 8;
  }

  const maskLength = masked ? 4 : 0;
  if (buffer.length < offset + maskLength + payloadLength) {
    return null;
  }

  const mask = masked ? buffer.subarray(offset, offset + 4) : undefined;
  offset += maskLength;

  const payload = Buffer.from(buffer.subarray(offset, offset + payloadLength));
  if (mask) {
    for (let i = 0; i < payload.length; i += 1) {
      payload[i] ^= mask[i % 4];
    }
  }

  return {
    opcode,
    payload,
    bytesRead: offset + payloadLength,
  };
}

@Injectable()
export class CfdGatewayService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(CfdGatewayService.name);
  private readonly clients = new Map<string, Set<Socket>>();
  private readonly socketBranches = new Map<Socket, string>();
  private readonly socketBuffers = new Map<Socket, Buffer>();
  private readonly latestSnapshots = new Map<string, CfdCartStatePayload>();
  private server?: HttpServer;

  constructor(private readonly httpAdapterHost: HttpAdapterHost) {}

  onModuleInit() {
    const httpServer = this.httpAdapterHost.httpAdapter?.getHttpServer?.();
    if (!httpServer) {
      return;
    }

    this.server = httpServer as HttpServer;
    this.server.on('upgrade', this.handleUpgrade);
  }

  onModuleDestroy() {
    if (this.server) {
      this.server.off('upgrade', this.handleUpgrade);
    }

    for (const socket of this.socketBranches.keys()) {
      socket.end();
    }

    this.clients.clear();
    this.socketBranches.clear();
    this.socketBuffers.clear();
  }

  getLatestSnapshot(branchId: string) {
    return this.latestSnapshots.get(branchId) ?? null;
  }

  publishCartState(
    branchId: string,
    payload: Omit<CfdCartStatePayload, 'type' | 'branch_id' | 'updated_at'>,
  ) {
    const snapshot: CfdCartStatePayload = {
      type: 'cart_state',
      branch_id: branchId,
      items: payload.items,
      total_amount: payload.total_amount,
      discount_amount: payload.discount_amount,
      vat_amount: payload.vat_amount,
      net_amount: payload.net_amount,
      updated_at: new Date().toISOString(),
      order_id: payload.order_id,
      order_no: payload.order_no,
      payment_status: payload.payment_status,
    };

    this.latestSnapshots.set(branchId, snapshot);
    this.broadcast(branchId, snapshot);
    return snapshot;
  }

  publishOrderSnapshot(order: Order) {
    const items: CfdCartStateItem[] =
      order.items?.map((item) => ({
        product_id: item.product_id,
        name: item.product?.name ?? item.product_id,
        qty: item.qty,
        unit_price: Number(item.unit_price),
        subtotal: Number(item.subtotal),
      })) ?? [];

    return this.publishCartState(order.branch_id, {
      items,
      total_amount: Number(order.total_amount),
      discount_amount: Number(order.discount_amount),
      vat_amount: Number(order.vat_amount),
      net_amount: Number(order.net_amount),
      order_id: order.id,
      order_no: order.order_no,
      payment_status: order.payment_status,
    });
  }

  registerClient(branchId: string, socket: Socket) {
    const branchClients = this.clients.get(branchId) ?? new Set<Socket>();
    branchClients.add(socket);
    this.clients.set(branchId, branchClients);
    this.socketBranches.set(socket, branchId);
    this.socketBuffers.set(socket, Buffer.alloc(0));

    socket.on('data', (chunk) => this.handleSocketData(socket, chunk));
    socket.on('close', () => this.unregisterClient(socket));
    socket.on('end', () => this.unregisterClient(socket));
    socket.on('error', (error) => {
      this.logger.warn(`CFD socket error: ${error.message}`);
      this.unregisterClient(socket);
    });

    const latestSnapshot = this.latestSnapshots.get(branchId);
    if (latestSnapshot) {
      this.sendJson(socket, latestSnapshot);
    }
  }

  private readonly handleUpgrade = (
    request: IncomingMessage,
    socket: Socket,
    head: Buffer,
  ) => {
    const branchId = extractCfdBranchId(request.url);
    if (!branchId) {
      return;
    }

    const websocketKey = request.headers['sec-websocket-key'];
    const upgradeHeader = request.headers.upgrade;

    if (
      typeof websocketKey !== 'string' ||
      typeof upgradeHeader !== 'string' ||
      upgradeHeader.toLowerCase() !== 'websocket'
    ) {
      socket.write('HTTP/1.1 400 Bad Request\r\n\r\n');
      socket.destroy();
      return;
    }

    const accept = createHash('sha1')
      .update(websocketKey + WEBSOCKET_MAGIC_GUID)
      .digest('base64');

    socket.write(
      [
        'HTTP/1.1 101 Switching Protocols',
        'Upgrade: websocket',
        'Connection: Upgrade',
        `Sec-WebSocket-Accept: ${accept}`,
        '\r\n',
      ].join('\r\n'),
    );

    this.registerClient(branchId, socket);

    if (head.length > 0) {
      this.handleSocketData(socket, head);
    }
  };

  private handleSocketData(socket: Socket, chunk: Buffer) {
    const existingBuffer = this.socketBuffers.get(socket) ?? Buffer.alloc(0);
    let buffer = Buffer.concat([existingBuffer, chunk]);

    while (true) {
      const frame = decodeWebSocketFrame(buffer);
      if (!frame) {
        break;
      }

      buffer = buffer.subarray(frame.bytesRead);

      if (frame.opcode === 0x8) {
        socket.write(encodeWebSocketFrame(Buffer.alloc(0), 0x8));
        socket.end();
        this.unregisterClient(socket);
        return;
      }

      if (frame.opcode === 0x9) {
        socket.write(encodeWebSocketFrame(frame.payload, 0x0a));
      }
    }

    this.socketBuffers.set(socket, buffer);
  }

  private unregisterClient(socket: Socket) {
    const branchId = this.socketBranches.get(socket);
    if (!branchId) {
      return;
    }

    const branchClients = this.clients.get(branchId);
    if (branchClients) {
      branchClients.delete(socket);
      if (branchClients.size === 0) {
        this.clients.delete(branchId);
      }
    }

    this.socketBranches.delete(socket);
    this.socketBuffers.delete(socket);
    socket.removeAllListeners();
  }

  private broadcast(branchId: string, payload: CfdCartStatePayload) {
    const branchClients = this.clients.get(branchId);
    if (!branchClients || branchClients.size === 0) {
      return;
    }

    for (const socket of branchClients) {
      if (socket.destroyed || !socket.writable) {
        this.unregisterClient(socket);
        continue;
      }

      this.sendJson(socket, payload);
    }
  }

  private sendJson(socket: Socket, payload: CfdCartStatePayload) {
    socket.write(encodeWebSocketFrame(JSON.stringify(payload)));
  }
}
