import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/local/models/order_local.dart';
import 'package:pos_frontend/models/order.dart';

void main() {
  group('Order', () {
    test('fromJson parses sync_status_acc from backend payload', () {
      final order = Order.fromJson({
        'id': 'order-1',
        'order_no': 'ORD-001',
        'branch_id': 'branch-1',
        'staff_id': 'staff-1',
        'total_amount': 100,
        'discount_amount': 0,
        'vat_amount': 7,
        'net_amount': 107,
        'payment_status': 'paid',
        'sync_status_acc': true,
        'created_at': '2026-04-13T09:00:00.000Z',
        'items': const [],
        'payments': const [],
      });

      expect(order.syncStatusAcc, isTrue);
    });

    test('OrderLocal.fromDomain uses syncStatusAcc from domain model', () {
      final order = Order.fromJson({
        'id': 'order-1',
        'order_no': 'ORD-001',
        'branch_id': 'branch-1',
        'staff_id': 'staff-1',
        'total_amount': 100,
        'discount_amount': 0,
        'vat_amount': 7,
        'net_amount': 107,
        'payment_status': 'paid',
        'sync_status_acc': false,
        'created_at': '2026-04-13T09:00:00.000Z',
        'items': const [],
        'payments': const [],
      });

      final local = OrderLocal.fromDomain(order);

      expect(local.syncStatusAcc, isFalse);
    });
  });
}
