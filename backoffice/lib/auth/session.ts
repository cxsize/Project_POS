import { env } from '@/lib/env';
import type { Session } from '@/types/auth';

type CookieReader = {
  get(name: string): { value: string } | undefined;
};

export function encodeSession(session: Session) {
  return Buffer.from(JSON.stringify(session), 'utf8').toString('base64url');
}

export function decodeSession(value: string): Session | null {
  try {
    const json = Buffer.from(value, 'base64url').toString('utf8');
    return JSON.parse(json) as Session;
  } catch {
    return null;
  }
}

export function getSessionFromCookieStore(
  cookieStore: CookieReader
) {
  const cookieValue = cookieStore.get(env.AUTH_COOKIE_NAME)?.value;
  if (!cookieValue) {
    return null;
  }

  return decodeSession(cookieValue);
}
