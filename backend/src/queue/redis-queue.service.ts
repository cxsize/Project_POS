import { Injectable, Logger } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { RedisResponse, RedisSocketTransport } from './redis-socket.transport';
import { QueueJobOptions, QueueJobRecord } from './queue.types';

@Injectable()
export class RedisQueueService {
  private readonly logger = new Logger(RedisQueueService.name);
  private readonly defaultMaxAttempts = 5;
  private readonly defaultInitialBackoffMs = 5000;
  private readonly readyPrefix = 'pos:queue:ready';
  private readonly delayedPrefix = 'pos:queue:delayed';
  private readonly deadLetterPrefix = 'pos:queue:dead';

  constructor(private readonly transport: RedisSocketTransport) {}

  async enqueue<TPayload>(
    queueName: string,
    jobName: string,
    payload: TPayload,
    options: QueueJobOptions = {},
  ): Promise<QueueJobRecord<TPayload>> {
    const job: QueueJobRecord<TPayload> = {
      id: randomUUID(),
      name: jobName,
      payload,
      attempt: 0,
      maxAttempts: options.maxAttempts ?? this.defaultMaxAttempts,
      initialBackoffMs:
        options.initialBackoffMs ?? this.defaultInitialBackoffMs,
      enqueuedAt: new Date().toISOString(),
    };
    const serializedJob = JSON.stringify(job);

    if (options.scheduledAt) {
      await this.command(
        'ZADD',
        this.delayedKey(queueName),
        options.scheduledAt.getTime(),
        serializedJob,
      );
      return job;
    }

    await this.command('LPUSH', this.readyKey(queueName), serializedJob);
    return job;
  }

  async poll<TPayload>(
    queueName: string,
  ): Promise<QueueJobRecord<TPayload> | null> {
    await this.releaseDueJobs(queueName);
    const response = await this.command('RPOP', this.readyKey(queueName));
    if (response == null) {
      return null;
    }

    return this.parseJob<TPayload>(response);
  }

  async reschedule<TPayload>(
    queueName: string,
    job: QueueJobRecord<TPayload>,
    errorMessage: string,
  ): Promise<'rescheduled' | 'dead-letter'> {
    const nextAttempt = job.attempt + 1;
    const updatedJob: QueueJobRecord<TPayload> = {
      ...job,
      attempt: nextAttempt,
      lastError: errorMessage,
    };

    if (nextAttempt >= job.maxAttempts) {
      await this.command(
        'LPUSH',
        this.deadLetterKey(queueName),
        JSON.stringify(updatedJob),
      );
      return 'dead-letter';
    }

    const delay = job.initialBackoffMs * 2 ** (nextAttempt - 1);
    await this.command(
      'ZADD',
      this.delayedKey(queueName),
      Date.now() + delay,
      JSON.stringify(updatedJob),
    );
    return 'rescheduled';
  }

  async releaseDueJobs(queueName: string, limit = 20): Promise<void> {
    const dueItems = await this.command(
      'ZRANGEBYSCORE',
      this.delayedKey(queueName),
      '-inf',
      Date.now(),
      'LIMIT',
      0,
      limit,
    );

    if (!Array.isArray(dueItems) || dueItems.length === 0) {
      return;
    }

    for (const item of dueItems) {
      if (typeof item !== 'string') {
        continue;
      }

      const removed = await this.command(
        'ZREM',
        this.delayedKey(queueName),
        item,
      );
      if (removed === 1) {
        await this.command('LPUSH', this.readyKey(queueName), item);
      }
    }
  }

  private async command(
    ...args: Array<string | number>
  ): Promise<RedisResponse> {
    try {
      return await this.transport.sendCommand(args);
    } catch (error) {
      this.logger.warn(
        `Redis command failed (${args[0]}): ${
          error instanceof Error ? error.message : String(error)
        }`,
      );
      throw error;
    }
  }

  private parseJob<TPayload>(
    response: RedisResponse,
  ): QueueJobRecord<TPayload> {
    if (typeof response !== 'string') {
      throw new Error('Queue payload is not a string');
    }

    return JSON.parse(response) as QueueJobRecord<TPayload>;
  }

  private readyKey(queueName: string) {
    return `${this.readyPrefix}:${queueName}`;
  }

  private delayedKey(queueName: string) {
    return `${this.delayedPrefix}:${queueName}`;
  }

  private deadLetterKey(queueName: string) {
    return `${this.deadLetterPrefix}:${queueName}`;
  }
}
