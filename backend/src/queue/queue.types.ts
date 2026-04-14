export interface QueueJobOptions {
  maxAttempts?: number;
  initialBackoffMs?: number;
  scheduledAt?: Date;
}

export interface QueueJobRecord<TPayload = unknown> {
  id: string;
  name: string;
  payload: TPayload;
  attempt: number;
  maxAttempts: number;
  initialBackoffMs: number;
  enqueuedAt: string;
  lastError?: string;
}

export interface OrderSyncJobPayload {
  orderId: string;
}

export interface WebhookSuccessAction {
  type: 'mark-accounting-synced';
  orderId: string;
}

export interface WebhookJobPayload {
  url: string;
  method: 'POST';
  headers: Record<string, string>;
  body: Record<string, unknown>;
  successAction?: WebhookSuccessAction;
}
