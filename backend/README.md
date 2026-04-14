# Project POS Backend

NestJS backend for authentication, products, orders, inventory, CRM stubs, and accounting sync endpoints.

## Prerequisites

- Node.js 20+
- npm
- PostgreSQL
- Redis

You can start PostgreSQL and Redis locally with:

```bash
cd backend
docker compose up -d
```

## Environment Setup

Create `.env` from the example file:

```bash
cd backend
cp .env.example .env
```

Important defaults:

- `PORT=3000`
- `DB_HOST=localhost`
- `DB_PORT=5432`
- `DB_USERNAME=pos_user`
- `DB_PASSWORD=pos_password`
- `DB_DATABASE=pos_db`
- `OPEN_API_KEY=change-me-to-a-random-api-key`

## Install And Run

```bash
cd backend
npm ci
npm run seed
npm run start:dev
```

Available URLs:

- API base: `http://localhost:3000/api/v1`
- Swagger: `http://localhost:3000/api/docs`

## Seed Data

`npm run seed` creates demo data for local usage:

- users:
  - `admin / admin123`
  - `cashier1 / cashier123`
- categories:
  - Bakery
  - Beverages
  - Snacks
- sample products
- ingredients and BOM recipes

## Core Endpoints

### Auth

- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `GET /api/v1/auth/me`

### Products

- `GET /api/v1/products`
- `GET /api/v1/products/categories/all`
- `POST /api/v1/products`
- `PATCH /api/v1/products/:id`

### Orders

- `POST /api/v1/orders`
- `GET /api/v1/orders`
- `GET /api/v1/orders/:id`
- `POST /api/v1/orders/:id/payments`
- `GET /api/v1/orders/unsynced`

## Local Verification

```bash
npm test -- --runInBand
npm run build
```

## Main Files

- [`backend/src/main.ts`](src/main.ts)
- [`backend/src/app.module.ts`](src/app.module.ts)
- [`backend/src/auth/auth.controller.ts`](src/auth/auth.controller.ts)
- [`backend/src/products/products.controller.ts`](src/products/products.controller.ts)
- [`backend/src/orders/orders.controller.ts`](src/orders/orders.controller.ts)
- [`backend/src/database/seed.ts`](src/database/seed.ts)
