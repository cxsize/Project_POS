# CLAUDE.md — Project POS

## Project Overview

**Lean & Fast Modular POS** — a high-speed retail checkout system targeting 500+ receipts/day with Open API integration for CRM and Accounting.

**Current state:** Backend scaffolded with NestJS. Frontend (Flutter) not yet started. See `README.md` for the full project specification.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (iOS/Android, tablet-optimized) |
| State Management | Riverpod or BLoC |
| Local Database | Isar (NoSQL, offline-first) |
| Backend API | Node.js with NestJS (TypeScript) |
| Cloud Database | PostgreSQL |
| Caching/Queue | Redis (background sync, webhooks) |
| Communication | REST API, WebSockets, Webhooks |

## Architecture — Core Modules

The system is designed as **four decoupled modules**:

- **Module A: Core Checkout Engine** — Barcode scanning (Bluetooth/USB HID), sub-100ms item selection, thermal printer integration (ESC/POS), full offline mode with auto-sync.
- **Module B: Customer Facing Display (CFD)** — Real-time cart display via WebSockets, dynamic PromptPay/Thai QR generation, promotional standby mode.
- **Module C: Inventory & BOM** — Recipe management (product-to-ingredient mapping), real-time stock deduction on sale sync.
- **Module D: Open API Gateway** — CRM member lookup and points, accounting receipt push with full line-item detail.

## Data Schema

Key entities and relationships:

- **products** (id, sku, name, base_price, category_id, is_active)
- **ingredients** (id, name, unit, stock_qty, min_alert_qty)
- **recipes** — joins products to ingredients with usage_qty (Bill of Materials)
- **orders** (id, order_no, branch_id, staff_id, totals, payment_status, sync_status_acc, created_at)
- **order_items** (order_id, product_id, qty, unit_price, subtotal)
- **payments** (order_id, method [cash/qr/credit_card], amount_received, ref_no)

All primary keys are UUIDs.

## API Conventions

- Base path: `/api/v1/`
- RESTful naming with resource-based URLs
- Defined integration endpoints:
  - `GET /api/v1/crm/member?phone={phone}` — member profile & points
  - `POST /api/v1/crm/points/earn` — earn points `{order_id, amount, customer_id}`
  - `POST /api/v1/accounting/sync-receipt` — push full receipt JSON (orders + order_items)

## Development Conventions

### Backend (NestJS/TypeScript)

- **File naming:** kebab-case — `orders.controller.ts`, `orders.service.ts`, `orders.module.ts`
- **Structure:** Feature-based modules under `backend/src/`
  ```
  backend/src/
  ├── main.ts                    # App bootstrap, global prefix, Swagger
  ├── app.module.ts              # Root module wiring
  ├── config/
  │   └── database.config.ts     # TypeORM PostgreSQL config
  ├── common/
  │   └── guards/                # JwtAuthGuard, ApiKeyGuard
  ├── auth/                      # JWT login, Passport strategy
  ├── products/                  # Product CRUD
  ├── inventory/                 # Ingredients + Recipes (BOM)
  ├── orders/                    # Orders + OrderItems + Payments
  ├── crm/                       # CRM integration (API Key auth)
  └── accounting/                # Accounting sync (API Key auth)
  ```
- **Naming:** camelCase for variables/methods, PascalCase for classes/interfaces, UPPER_SNAKE_CASE for constants
- **DTOs** for request validation, **entities** for database models
- **Authentication:** JWT (`JwtAuthGuard`) for internal endpoints, API Key (`ApiKeyGuard` via `x-api-key` header) for CRM/Accounting
- **Swagger docs:** Available at `/api/docs` when the server is running
- **ORM:** TypeORM with entity auto-discovery; `DB_SYNC=true` for dev auto-migration

### Frontend (Flutter)

- **File naming:** snake_case — `checkout_screen.dart`, `order_model.dart`
- **Structure:**
  ```
  lib/
  ├── screens/
  ├── widgets/
  ├── services/
  ├── models/
  └── providers/
  ```
- **State management:** Riverpod or BLoC pattern
- **Local storage:** Isar for offline-first data persistence

## Non-Functional Requirements

- **Performance:** Sub-100ms UI response for item selection; support 500+ receipts/day
- **Security:** JWT authentication, API Key for Open API, data encryption at rest
- **Reliability:** Atomic transactions — no data loss on crash; offline-first with sync queue
- **UX:** Minimalist, high contrast, touch-friendly — zero learning curve for staff

## Development Roadmap

| Sprint | Focus |
|--------|-------|
| 1 | Core POS UI + Isar Local DB + Offline Checkout |
| 2 | Printer/Scanner Integration + Local Background Sync to Cloud |
| 3 | Customer Facing Display (WebSocket) + Dynamic QR |
| 4 | BOM/Inventory Logic + Webhooks for External Systems |

## Commands

### Backend (NestJS)

```shell
cd backend

# Install dependencies
npm install

# Development server (with hot reload)
npm run start:dev

# Production build
npm run build
npm run start:prod

# Linting
npm run lint

# Unit tests
npm run test

# E2E tests (requires running PostgreSQL)
npm run test:e2e

# Format code
npm run format
```

### Infrastructure

```shell
cd backend

# Start PostgreSQL + Redis via Docker Compose
docker compose up -d

# Or use local services:
sudo service postgresql start
sudo service redis-server start

# Create database (first time only)
sudo -u postgres psql -c "CREATE USER pos_user WITH PASSWORD 'pos_password';"
sudo -u postgres psql -c "CREATE DATABASE pos_db OWNER pos_user;"
```

### Frontend (Flutter) — to be configured

```shell
# flutter pub get
# flutter run
# flutter test
# flutter analyze
```

### Environment Setup

Copy `backend/.env.example` to `backend/.env` and adjust values. Key variables:
- `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `DB_DATABASE` — PostgreSQL connection
- `JWT_SECRET` — secret for signing JWT tokens
- `OPEN_API_KEY` — API key for CRM/Accounting integration endpoints
- `DB_SYNC=true` — auto-create tables from entities (development only)

## Working with This Repo

- The `README.md` contains the full project specification — treat it as the source of truth for requirements.
- When implementing features, follow the module boundaries (A/B/C/D) defined in the architecture.
- All database tables use UUID primary keys.
- Offline-first is a core requirement — local operations must work without network connectivity.
- External integrations (CRM, Accounting) go through the Open API Gateway (Module D).
