import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import { getSessionFromCookieStore } from '@/lib/auth/session';

export default async function DashboardPage() {
  const session = getSessionFromCookieStore(cookies());
  if (!session) {
    redirect('/login');
  }

  return (
    <main className="min-h-screen p-6 md:p-10">
      <div className="mx-auto max-w-6xl space-y-6">
        <header className="space-y-2">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary">
            Dashboard shell
          </p>
          <h1 className="text-3xl font-semibold tracking-tight">
            Welcome back, {session.fullName ?? session.username}
          </h1>
          <p className="text-sm leading-6 text-muted-foreground">
            Middleware protection is active for dashboard routes. POS-31 will
            replace this placeholder with the shared sidebar layout.
          </p>
        </header>
        <section className="grid gap-4 md:grid-cols-3">
          <div className="rounded-3xl border bg-card p-5">
            <p className="text-sm text-muted-foreground">Role</p>
            <p className="mt-2 text-2xl font-semibold capitalize">{session.role}</p>
          </div>
          <div className="rounded-3xl border bg-card p-5">
            <p className="text-sm text-muted-foreground">Branch</p>
            <p className="mt-2 text-2xl font-semibold">
              {session.branchId ?? 'All branches'}
            </p>
          </div>
          <div className="rounded-3xl border bg-card p-5">
            <p className="text-sm text-muted-foreground">Session source</p>
            <p className="mt-2 text-2xl font-semibold">Cookie middleware</p>
          </div>
        </section>
      </div>
    </main>
  );
}

