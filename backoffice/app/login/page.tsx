import { LoginForm } from '@/components/auth/login-form';

export default function LoginPage() {
  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <div className="w-full max-w-md rounded-[24px] border bg-white/92 p-8 shadow-[0_30px_100px_rgba(27,45,74,0.12)]">
        <div className="mb-8 space-y-3">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary">
            Project POS Backoffice
          </p>
          <h1 className="text-3xl font-semibold tracking-tight">Sign in</h1>
          <p className="text-sm leading-6 text-muted-foreground">
            Login form scaffold for POS-30. It already targets the backend auth
            endpoint and is ready to be wired to a server action.
          </p>
        </div>
        <LoginForm />
      </div>
    </main>
  );
}

