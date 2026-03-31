# CLAUDE.md — Project POS

## Project Overview

**Lean & Fast Modular POS** — a high-speed retail checkout system targeting 500+ receipts/day with Open API integration for CRM and Accounting.

**Current state:** Specification/planning phase. No source code has been implemented yet. See `README.md` for the full project specification.

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
- **Structure:** Feature-based modules under `src/`
  ```
  src/
  ├── orders/
  │   ├── orders.module.ts
  │   ├── orders.controller.ts
  │   ├── orders.service.ts
  │   ├── dto/
  │   └── entities/
  ├── products/
  ├── inventory/
  ├── crm/
  ├── accounting/
  └── auth/
  ```
- **Naming:** camelCase for variables/methods, PascalCase for classes/interfaces, UPPER_SNAKE_CASE for constants
- **DTOs** for request validation, **entities** for database models
- **Authentication:** JWT for internal endpoints, API Key for open API endpoints

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

> **Note:** Build, test, and lint commands will be added here once the project is scaffolded.

```shell
# Backend (NestJS) — to be configured
# npm install
# npm run start:dev
# npm run test
# npm run lint

# Frontend (Flutter) — to be configured
# flutter pub get
# flutter run
# flutter test
# flutter analyze
```

## Working with This Repo

- The `README.md` contains the full project specification — treat it as the source of truth for requirements.
- When implementing features, follow the module boundaries (A/B/C/D) defined in the architecture.
- All database tables use UUID primary keys.
- Offline-first is a core requirement — local operations must work without network connectivity.
- External integrations (CRM, Accounting) go through the Open API Gateway (Module D).
