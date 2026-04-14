# Project POS Frontend

Flutter client for the POS workflow.

## Current User Flows

- Login with username and password
- Cashier checkout flow
- Product search by name or SKU
- Barcode input through the search field
- Payment by cash, QR, or card
- Order history view
- Local product/order persistence with Isar

## Prerequisites

- Flutter 3.x
- Dart 3.x
- Running backend API on `http://localhost:3000/api/v1`

## Environment

The app reads the API URL from [`frontend/.env`](.env).

Current default:

```env
API_BASE_URL=http://localhost:3000/api/v1
```

## Run The App

```bash
cd frontend
flutter pub get
flutter run
```

## Test Accounts

- `cashier1 / cashier123`
- `admin / admin123`

## App Behavior

### Login

- Cashier users are routed to the checkout screen
- Other roles are routed to order history
- Session restore runs automatically on app startup

### Checkout screen

- Search box supports:
  - product name
  - SKU
  - barcode scanner input in HID mode
- Press Enter after scanner input to match a SKU directly
- Tap any product tile to add it to the cart
- Cart supports increment, decrement, and remove
- `Refresh Catalog` reloads products and categories from the API

### Payment screen

- Payment methods:
  - `cash`
  - `qr`
  - `credit_card`
- For QR and card, the operator can enter an optional reference number
- Successful payment shows change and resets the flow for a new sale

### Order history

- Lists submitted orders
- Tapping an order opens item lines, totals, VAT, and payment records

## Development Commands

```bash
flutter analyze
flutter test
```

## Main Files

- [`frontend/lib/main.dart`](lib/main.dart)
- [`frontend/lib/screens/login_screen.dart`](lib/screens/login_screen.dart)
- [`frontend/lib/screens/checkout_screen.dart`](lib/screens/checkout_screen.dart)
- [`frontend/lib/screens/payment_screen.dart`](lib/screens/payment_screen.dart)
- [`frontend/lib/screens/order_history_screen.dart`](lib/screens/order_history_screen.dart)
- [`frontend/lib/services/auth_service.dart`](lib/services/auth_service.dart)
- [`frontend/lib/services/product_service.dart`](lib/services/product_service.dart)
- [`frontend/lib/services/order_service.dart`](lib/services/order_service.dart)
