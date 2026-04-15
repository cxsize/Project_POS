import { cookies } from 'next/headers';
import { NextResponse } from 'next/server';
import { env } from '@/lib/env';

export async function POST() {
  cookies().delete(env.AUTH_COOKIE_NAME);
  return NextResponse.json({ ok: true });
}

