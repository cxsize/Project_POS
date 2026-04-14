import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Socket } from 'net';

type RedisPrimitive = string | number | null;
export type RedisResponse = RedisPrimitive | RedisResponse[];

@Injectable()
export class RedisSocketTransport {
  constructor(private readonly configService: ConfigService) {}

  async sendCommand(args: Array<string | number>): Promise<RedisResponse> {
    const host = this.configService.get<string>('REDIS_HOST') || '127.0.0.1';
    const port = Number(this.configService.get<number>('REDIS_PORT') || 6379);
    const timeoutMs = Number(
      this.configService.get<number>('REDIS_COMMAND_TIMEOUT_MS') || 2000,
    );

    return new Promise<RedisResponse>((resolve, reject) => {
      const socket = new Socket();
      let buffer = Buffer.alloc(0);
      let settled = false;

      const finish = (callback: () => void) => {
        if (settled) {
          return;
        }
        settled = true;
        socket.destroy();
        callback();
      };

      socket.setTimeout(timeoutMs);

      socket.on('connect', () => {
        socket.write(encodeCommand(args));
      });

      socket.on('data', (chunk: Buffer) => {
        buffer = Buffer.concat([buffer, chunk]);
        try {
          const parsed = parseRedisResponse(buffer);
          if (!parsed) {
            return;
          }
          finish(() => resolve(parsed.value));
        } catch (error) {
          finish(() =>
            reject(error instanceof Error ? error : new Error(String(error))),
          );
        }
      });

      socket.on('timeout', () => {
        finish(() => reject(new Error('Redis command timed out')));
      });

      socket.on('error', (error) => {
        finish(() => reject(error));
      });

      socket.connect(port, host);
    });
  }
}

function encodeCommand(args: Array<string | number>): string {
  const serializedArgs = args.map((arg) => String(arg));
  const lines = [`*${serializedArgs.length}`];

  for (const finalArg of serializedArgs) {
    lines.push(`$${Buffer.byteLength(finalArg)}`);
    lines.push(finalArg);
  }

  return `${lines.join('\r\n')}\r\n`;
}

function parseRedisResponse(
  buffer: Buffer,
  offset = 0,
): { value: RedisResponse; offset: number } | null {
  if (buffer.length <= offset) {
    return null;
  }

  const prefix = String.fromCharCode(buffer[offset]);
  switch (prefix) {
    case '+': {
      const line = readLine(buffer, offset + 1);
      if (!line) {
        return null;
      }
      return { value: line.value, offset: line.offset };
    }
    case '-': {
      const line = readLine(buffer, offset + 1);
      if (!line) {
        return null;
      }
      throw new Error(line.value);
    }
    case ':': {
      const line = readLine(buffer, offset + 1);
      if (!line) {
        return null;
      }
      return { value: Number(line.value), offset: line.offset };
    }
    case '$': {
      const line = readLine(buffer, offset + 1);
      if (!line) {
        return null;
      }

      const length = Number(line.value);
      if (length === -1) {
        return { value: null, offset: line.offset };
      }

      const end = line.offset + length;
      if (buffer.length < end + 2) {
        return null;
      }

      return {
        value: buffer.toString('utf8', line.offset, end),
        offset: end + 2,
      };
    }
    case '*': {
      const line = readLine(buffer, offset + 1);
      if (!line) {
        return null;
      }

      const count = Number(line.value);
      if (count === -1) {
        return { value: null, offset: line.offset };
      }

      const values: RedisResponse[] = [];
      let cursor = line.offset;

      for (let index = 0; index < count; index += 1) {
        const parsed = parseRedisResponse(buffer, cursor);
        if (!parsed) {
          return null;
        }
        values.push(parsed.value);
        cursor = parsed.offset;
      }

      return { value: values, offset: cursor };
    }
    default:
      throw new Error(`Unsupported Redis response prefix: ${prefix}`);
  }
}

function readLine(
  buffer: Buffer,
  offset: number,
): { value: string; offset: number } | null {
  const end = buffer.indexOf('\r\n', offset);
  if (end === -1) {
    return null;
  }

  return {
    value: buffer.toString('utf8', offset, end),
    offset: end + 2,
  };
}
