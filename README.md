# Project POS

Flutter POS frontend + NestJS backend for tablet-based checkout, order payment, and order history.

## What Is Working

- Login with JWT authentication
- Cashier flow: browse products, search by SKU/name, add items to cart, create order, receive payment
- Admin flow: open order history and inspect order details
- Product catalog caching in local Isar database
- Swagger API docs on the backend
- Seed script for demo users, categories, products, ingredients, and recipes

## Repository Structure

- `frontend/` Flutter application
- `backend/` NestJS API and database seed script

## Quick Start

### 1. Start local services

```bash
cd backend
docker compose up -d
```

This starts:

- PostgreSQL on `localhost:5432`
- Redis on `localhost:6379`

### 2. Configure the backend

```bash
cd backend
cp .env.example .env
npm ci
npm run seed
npm run start:dev
```

Backend defaults:

- API base URL: `http://localhost:3000/api/v1`
- Swagger docs: `http://localhost:3000/api/docs`

### 3. Configure and run the frontend

The frontend already reads its API base URL from [`frontend/.env`](frontend/.env).

```bash
cd frontend
flutter pub get
flutter run
```

## Demo Accounts

Seeded by `npm run seed`:

- `admin` / `admin123`
- `cashier1` / `cashier123`

Role behavior in the current app:

- `cashier` goes to the checkout screen after login
- non-cashier users go to order history after login

## How To Use The App

### Cashier flow

1. Login with `cashier1 / cashier123`
2. Wait for the product catalog to load
3. Add products by:
   - tapping product tiles
   - typing in the search box
   - scanning a barcode/SKU and pressing Enter
4. Review the cart on the right side
5. Adjust quantity with the cart controls
6. Press `Checkout`
7. On the payment screen:
   - choose `Cash`, `QR`, or `Card`
   - confirm the amount received
   - optionally enter a reference number for QR or card
8. Press `Confirm Payment`
9. If payment completes, the app shows change and resets for a new order

### Admin flow

1. Login with `admin / admin123`
2. The app opens `Order History`
3. Tap an order to see items, totals, VAT, and payment entries

### Useful actions in the checkout screen

- `Refresh Catalog` reloads categories and products from the backend
- `Order History` opens the order list
- `Logout` clears the session and returns to login

## Notes For Developers

- Backend API prefix is `/api/v1`
- Frontend expects the backend on `http://localhost:3000/api/v1` unless `frontend/.env` is changed
- The frontend caches products and saved orders in Isar
- Current documentation is written against the code in this repository branch, not the broader Notion roadmap

## Helpful Commands

### Backend

```bash
cd backend
npm run start:dev
npm test -- --runInBand
npm run build
```

### Frontend

```bash
cd frontend
flutter analyze
flutter test
flutter run
```
