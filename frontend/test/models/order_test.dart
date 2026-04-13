import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/models/order.dart';

void main() {
  group('Order.fromJson', () {
    test('maps sync_status_acc from API response', () {
      final order = Order.fromJson({
        'id': '1f67fb34-8fa1-44dd-87eb-edf2ddf27396',
        'order_no': 'ORD-001',
        'branch_id': 'branch-1',
        'staff_id': 'staff-1',
        'total_amount': 100,
        'discount_amount': 0,
        'vat_amount': 7,
        'net_amount': 107,
        'payment_status': 'paid',
        'sync_status_acc': true,
        'created_at': DateTime.utc(2026, 4, 13).toIso8601String(),
        'items': const [],
        'payments': const [],
      });

      expect(order.syncStatusAcc, isTrue);
    });
  });
}
