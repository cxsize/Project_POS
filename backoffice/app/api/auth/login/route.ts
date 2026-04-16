import { cookies } from 'next/headers';
import { NextResponse } from 'next/server';
import { env } from '@/lib/env';
import { loginSchema } from '@/lib/auth/schema';
import { encodeSession } from '@/lib/auth/session';
import { loginRequest } from '@/lib/api';

export async function POST(request: Request) {
  const payload = await request.json();
  const parsed = loginSchema.safeParse(payload);

  if (!parsed.success) {
    return NextResponse.json(
      {
        message: parsed.error.issues[0]?.message ?? 'Invalid login payload'
      },
      { status: 400 }
    );
  }

  try {
    const response = await loginRequest(parsed.data);
    const session = await encodeSession({
      accessToken: response.access_token,
      refreshToken: response.refresh_token,
      username: response.user.username,
      fullName: response.user.full_name,
      role: response.user.role,
      branchId: response.user.branch_id
    });

    cookies().set(env.AUTH_COOKIE_NAME, session, {
      httpOnly: true,
      sameSite: 'lax',
      secure: process.env.NODE_ENV === 'production',
      path: '/',
      maxAge: 60 * 60 * 8
    });

    return NextResponse.json({
      user: response.user
    });
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'Unable to sign in right now';
    return NextResponse.json({ message }, { status: 401 });
  }
}
