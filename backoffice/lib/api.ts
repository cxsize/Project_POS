import { env } from '@/lib/env';
import { loginSchema, type LoginInput } from '@/lib/auth/schema';
import type { LoginResponse, Session } from '@/types/auth';

type ApiRequestOptions = Omit<RequestInit, 'body' | 'headers'> & {
  body?: unknown;
  headers?: HeadersInit;
  accessToken?: string | null;
};

export class ApiError extends Error {
  constructor(
    message: string,
    public readonly status: number,
    public readonly payload?: unknown
  ) {
    super(message);
  }
}

async function parseJsonSafely(response: Response) {
  const text = await response.text();
  if (!text) {
    return null;
  }

  try {
    return JSON.parse(text) as unknown;
  } catch {
    return text;
  }
}

export async function apiRequest<T>(
  path: string,
  options: ApiRequestOptions = {}
): Promise<T> {
  const response = await fetch(`${env.NEXT_PUBLIC_API_BASE_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(options.accessToken
        ? { Authorization: `Bearer ${options.accessToken}` }
        : {}),
      ...options.headers
    },
    body: options.body ? JSON.stringify(options.body) : undefined,
    cache: 'no-store'
  });

  const payload = await parseJsonSafely(response);
  if (!response.ok) {
    const message =
      typeof payload === 'object' &&
      payload !== null &&
      'message' in payload &&
      typeof payload.message === 'string'
        ? payload.message
        : 'Request failed';
    throw new ApiError(message, response.status, payload);
  }

  return payload as T;
}

export async function loginRequest(input: LoginInput) {
  const payload = loginSchema.parse(input);
  return apiRequest<LoginResponse>('/auth/login', {
    method: 'POST',
    body: payload
  });
}

export async function getMyProfile(session: Session) {
  return apiRequest<LoginResponse['user']>('/auth/me', {
    method: 'GET',
    accessToken: session.accessToken
  });
}

