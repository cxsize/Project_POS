Project Specification: Lean & Fast Modular POS
Version: 1.0
Stack: Flutter (Mobile), Node.js/NestJS (Backend), PostgreSQL & Isar (DB)
Core Objective: High-speed retail checkout (500+ receipts/day) with Open API for CRM & Accounting.
1. System Architecture & Tech Stack
 * Frontend: Flutter (iOS/Android) - Optimized for Tablets.
 * State Management: Riverpod or BLoC.
 * Local Database (Offline-First): Isar Database (NoSQL for Flutter).
 * Backend API: Node.js (NestJS) / TypeScript.
 * Cloud Database: PostgreSQL.
 * Caching/Queue: Redis (for Background Sync & Webhooks).
 * Communication:
   * REST API (Client-Server)
   * WebSockets (POS to Customer Facing Display)
   * Webhooks (Server to External CRM/Accounting)
2. Core Functional Modules (Decoupled)
Module A: Core Checkout Engine
 * Fast Scan: Support Bluetooth/USB Barcode Scanners (HID Mode).
 * UI Performance: Sub-100ms response time for item selection.
 * Hardware: Integration with Thermal Printers (ESC/POS via Bluetooth/LAN/USB).
 * Offline Mode: Complete sale and print receipt without internet; Auto-sync when online.
Module B: Customer Facing Display (CFD)
 * Real-time Sync: Show cart items to customers via local network (Websockets).
 * Dynamic QR: Generate PromptPay/Thai QR with exact amount from API.
 * Branding: Standby mode for promotional images/videos.
Module C: Inventory & BOM (Bill of Materials)
 * Recipe Management: Link 1 Product to multiple Ingredients (e.g., 1 Cake = 200g Flour + 50g Butter).
 * Real-time Deduction: Deduct stock immediately upon sale sync.
Module D: Open API Gateway (Integration)
 * CRM API: Member lookup by phone, point earning/redemption.
 * Accounting API: Push Full Receipt Details (Line-items) to external accounting software.
3. Data Schema (Entity Relationship)
3.1 Inventory & Products
Table products {
  id uuid [pk]
  sku varchar [unique]
  name varchar
  base_price decimal
  category_id uuid
  is_active boolean
}

Table ingredients {
  id uuid [pk]
  name varchar
  unit varchar // grams, ml, pcs
  stock_qty decimal
  min_alert_qty decimal
}

Table recipes {
  id uuid [pk]
  product_id uuid
  ingredient_id uuid
  usage_qty decimal
}

3.2 Sales (Detailed for Accounting)
Table orders {
  id uuid [pk]
  order_no varchar [unique]
  branch_id uuid
  staff_id uuid
  total_amount decimal
  discount_amount decimal
  vat_amount decimal
  net_amount decimal
  payment_status enum // pending, paid, void
  sync_status_acc boolean
  created_at timestamp
}

Table order_items {
  id uuid [pk]
  order_id uuid
  product_id uuid
  qty integer
  unit_price decimal
  subtotal decimal
}

Table payments {
  id uuid [pk]
  order_id uuid
  method enum // cash, qr, credit_card
  amount_received decimal
  ref_no varchar // External Transaction ID
}

4. API Endpoints (Open API Focus)
CRM Integration
 * GET /api/v1/crm/member?phone={phone} -> Return member profile & points.
 * POST /api/v1/crm/points/earn -> Payload: {order_id, amount, customer_id}.
Accounting Integration (Transaction Level)
 * POST /api/v1/accounting/sync-receipt -> Push detailed JSON of orders + order_items.
5. Development Roadmap & Priorities
 * Sprint 1: Core POS UI + Isar Local DB + Offline Checkout.
 * Sprint 2: Printer/Scanner Integration + Local Background Sync to Cloud.
 * Sprint 3: Customer Facing Display (Websocket) + Dynamic QR.
 * Sprint 4: BOM/Inventory Logic + Webhooks for External Systems.
6. Non-Functional Requirements
 * Security: JWT Authentication, API Key for Open API, Data Encryption at Rest.
 * Reliability: Data must not be lost if the app crashes (Atomic Transactions).
 * UX: Minimalist, high contrast, touch-friendly (Target: 0 learning curve for staff).
End of Specification
