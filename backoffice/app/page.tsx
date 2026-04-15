import Link from 'next/link';
import { ArrowRight, ShieldCheck } from 'lucide-react';
import { Button } from '@/components/ui/button';

export default function HomePage() {
  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <section className="w-full max-w-5xl rounded-[28px] border border-white/70 bg-white/90 p-8 shadow-[0_25px_80px_rgba(27,45,74,0.12)] backdrop-blur md:p-12">
        <div className="grid gap-10 md:grid-cols-[1.2fr_0.8fr]">
          <div className="space-y-6">
            <div className="inline-flex items-center gap-2 rounded-full bg-secondary px-4 py-2 text-sm font-medium text-secondary-foreground">
              <ShieldCheck className="h-4 w-4" />
              Backoffice foundation is ready
            </div>
            <div className="space-y-4">
              <p className="text-sm font-semibold uppercase tracking-[0.24em] text-primary">
                Project POS
              </p>
              <h1 className="max-w-2xl text-4xl font-semibold tracking-tight md:text-5xl">
                Next.js App Router scaffold for backoffice work starts here.
              </h1>
              <p className="max-w-2xl text-base leading-7 text-muted-foreground">
                This workspace includes the app shell, Tailwind baseline, React
                Query provider, protected dashboard middleware, and a typed API
                client layer ready for login and dashboard features.
              </p>
            </div>
            <div className="flex flex-wrap gap-3">
              <Button asChild>
                <Link href="/login">
                  Open login
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
              <Button asChild variant="secondary">
                <Link href="/dashboard">Preview dashboard shell</Link>
              </Button>
            </div>
          </div>
          <div className="rounded-[24px] border bg-[linear-gradient(180deg,rgba(5,94,118,0.96),rgba(30,41,59,0.96))] p-6 text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.15)]">
            <div className="space-y-4">
              <p className="text-sm font-medium text-white/70">Included in POS-29</p>
              <ul className="space-y-3 text-sm leading-6 text-white/88">
                <li>App Router folder structure with typed aliases</li>
                <li>Middleware guard for dashboard routes</li>
                <li>Server-safe cookie helpers for auth session access</li>
                <li>JWT-aware API wrapper with helper methods for login/profile</li>
                <li>React Query provider and starter UI primitives</li>
              </ul>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}

