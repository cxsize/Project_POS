import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/models/cart_item.dart';
import 'package:pos_frontend/models/category.dart';
import 'package:pos_frontend/models/order.dart';
import 'package:pos_frontend/models/order_item.dart';
import 'package:pos_frontend/models/payment.dart';
import 'package:pos_frontend/models/printer_config.dart';
import 'package:pos_frontend/models/product.dart';
import 'package:pos_frontend/models/receipt_document.dart';
import 'package:pos_frontend/models/user.dart';
import 'package:pos_frontend/services/printer/printer_receipt_builder.dart';
import 'package:pos_frontend/services/printer/printer_service.dart';
import 'package:pos_frontend/services/printer/printer_settings_store.dart';

void main() {
  test('prints through the configured transport', () async {
    final store = InMemoryPrinterSettingsStore(
      const PrinterConfig(
        connectionType: PrinterConnectionType.lan,
        paperSize: ReceiptPaperSize.mm80,
        host: '192.168.1.100',
        port: 9100,
        isEnabled: true,
      ),
    );
    final builder = FakePrinterReceiptBuilder();
    final transport = FakePrinterTransport();
    final service = PrinterService(
      settingsStore: store,
      receiptBuilder: builder,
      transports: {PrinterConnectionType.lan: transport},
    );

    await service.printSaleReceipt(
      order: _order,
      cartItems: [_cartItem],
      user: _user,
      changeAmount: 9.05,
    );

    expect(builder.receivedDocument, isNotNull);
    expect(builder.receivedConfig?.host, '192.168.1.100');
    expect(transport.lastConfig?.host, '192.168.1.100');
    expect(transport.lastBytes, [1, 2, 3, 4]);
  });

  test('throws when printer is not configured', () async {
    final service = PrinterService(
      settingsStore: InMemoryPrinterSettingsStore(PrinterConfig.empty),
      receiptBuilder: FakePrinterReceiptBuilder(),
      transports: const {},
    );

    await expectLater(
      () => service.printSaleReceipt(
        order: _order,
        cartItems: [_cartItem],
        user: _user,
      ),
      throwsA(isA<PrinterException>()),
    );
  });
}

class InMemoryPrinterSettingsStore implements PrinterSettingsStore {
  InMemoryPrinterSettingsStore(this._config);

  PrinterConfig? _config;

  @override
  Future<void> clear() async {
    _config = null;
  }

  @override
  Future<PrinterConfig?> read() async => _config;

  @override
  Future<void> write(PrinterConfig config) async {
    _config = config;
  }
}

class FakePrinterReceiptBuilder extends PrinterReceiptBuilder {
  ReceiptDocument? receivedDocument;
  PrinterConfig? receivedConfig;

  @override
  Future<List<int>> buildReceipt({
    required ReceiptDocument document,
    required PrinterConfig printerConfig,
  }) async {
    receivedDocument = document;
    receivedConfig = printerConfig;
    return [1, 2, 3, 4];
  }
}

class FakePrinterTransport implements PrinterTransport {
  List<int>? lastBytes;
  PrinterConfig? lastConfig;

  @override
  Future<void> print(List<int> bytes, PrinterConfig config) async {
    lastBytes = bytes;
    lastConfig = config;
  }
}

final _category = Category(id: 'cat-1', name: 'Coffee');

final _product = Product(
  id: 'prod-1',
  sku: 'LATTE-001',
  name: 'Iced Latte',
  basePrice: 85,
  categoryId: _category.id,
  category: _category,
);

final _cartItem = CartItem(product: _product);

final _order = Order(
  id: 'order-1',
  orderNo: 'POS-0001',
  branchId: 'branch-1',
  staffId: 'user-1',
  totalAmount: 85,
  discountAmount: 0,
  vatAmount: 5.95,
  netAmount: 90.95,
  paymentStatus: 'paid',
  syncStatusAcc: false,
  createdAt: DateTime.utc(2026, 4, 12, 10, 30),
  items: [
    OrderItem(
      id: 'item-1',
      orderId: 'order-1',
      productId: 'prod-1',
      qty: 1,
      unitPrice: 85,
      subtotal: 85,
    ),
  ],
  payments: [
    Payment(
      id: 'payment-1',
      orderId: 'order-1',
      method: 'cash',
      amountReceived: 100,
    ),
  ],
);

final _user = User(
  id: 'user-1',
  username: 'cashier1',
  fullName: 'Cashier One',
  role: 'cashier',
  branchId: 'branch-1',
);
