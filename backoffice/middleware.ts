import type { NextRequest } from 'next/server';
import { NextResponse } from 'next/server';
import { env } from '@/lib/env';
import { decodeSession } from '@/lib/auth/session';

const protectedPrefixes = ['/dashboard'];
const blockedRoles = new Set(['cashier']);

export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname;
  const isProtectedRoute = protectedPrefixes.some((prefix) =>
    pathname.startsWith(prefix)
  );

  if (!isProtectedRoute) {
    return NextResponse.next();
  }

  const token = request.cookies.get(env.AUTH_COOKIE_NAME)?.value;
  const session = token ? await decodeSession(token) : null;

  if (!session) {
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('next', pathname);
    return NextResponse.redirect(loginUrl);
  }

  if (blockedRoles.has(session.role)) {
    return NextResponse.redirect(new URL('/login?reason=forbidden', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*']
};
