import { jwtVerify, SignJWT } from 'jose';
import { z } from 'zod';
import { env } from '@/lib/env';
import type { Session } from '@/types/auth';

type CookieReader = {
  get(name: string): { value: string } | undefined;
};

const sessionSchema = z.object({
  accessToken: z.string(),
  refreshToken: z.string(),
  username: z.string(),
  fullName: z.string().nullable(),
  role: z.enum(['admin', 'manager', 'cashier']),
  branchId: z.string().nullable()
});

const encoder = new TextEncoder();
const sessionIssuer = 'project-pos-backoffice';
const sessionAudience = 'project-pos-backoffice';

export async function encodeSession(session: Session) {
  return new SignJWT(sessionSchema.parse(session))
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuer(sessionIssuer)
    .setAudience(sessionAudience)
    .setIssuedAt()
    .setExpirationTime('8h')
    .sign(encoder.encode(env.JWT_SECRET));
}

export async function decodeSession(value: string): Promise<Session | null> {
  try {
    const { payload } = await jwtVerify(value, encoder.encode(env.JWT_SECRET), {
      issuer: sessionIssuer,
      audience: sessionAudience
    });

    return sessionSchema.parse(payload);
  } catch {
    return null;
  }
}

export async function getSessionFromCookieStore(
  cookieStore: CookieReader
) {
  const cookieValue = cookieStore.get(env.AUTH_COOKIE_NAME)?.value;
  if (!cookieValue) {
    return null;
  }

  return decodeSession(cookieValue);
}
