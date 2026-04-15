'use client';

import { useTransition } from 'react';
import { useRouter } from 'next/navigation';
import { LogOut } from 'lucide-react';
import { Button } from '@/components/ui/button';

export function LogoutButton() {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  return (
    <Button
      variant="secondary"
      onClick={() =>
        startTransition(async () => {
          await fetch('/api/auth/logout', { method: 'POST' });
          router.replace('/login');
          router.refresh();
        })
      }
      disabled={isPending}
    >
      <LogOut className="mr-2 h-4 w-4" />
      {isPending ? 'Signing out...' : 'Logout'}
    </Button>
  );
}

