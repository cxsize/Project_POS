# Project POS Backoffice

Next.js 14 App Router scaffold for the Project POS backoffice.

## Included In POS-29

- Next.js 14 + TypeScript project structure under `backoffice/`
- Tailwind CSS baseline
- React Query provider
- `lib/api.ts` request wrapper for the NestJS backend
- `middleware.ts` guard for `/dashboard/*`
- Starter pages for `/`, `/login`, and `/dashboard`
- Basic UI primitives compatible with a future shadcn/ui rollout

## Environment

Create a local environment file:

```bash
cd backoffice
cp .env.example .env.local
```

Default values:

```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000/api/v1
AUTH_COOKIE_NAME=project_pos_backoffice_token
JWT_SECRET=replace-with-a-random-secret-at-least-32-characters-long
```

## Run

```bash
cd backoffice
npm install
npm run dev
```

## Notes

- POS-29 focuses on scaffold and API client setup only.
- POS-30 will wire real login handling and cookie persistence.
- POS-31 will replace the placeholder dashboard shell with the shared sidebar layout.
