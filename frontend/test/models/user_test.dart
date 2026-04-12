import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/models/user.dart';

void main() {
  group('User.fromJwtPayload', () {
    test('maps full_name and branch_id from JWT payload', () {
      final user = User.fromJwtPayload({
        'sub': 'user-1',
        'username': 'cashier1',
        'full_name': 'Cashier One',
        'role': 'cashier',
        'branch_id': 'branch-1',
      });

      expect(user.id, 'user-1');
      expect(user.username, 'cashier1');
      expect(user.fullName, 'Cashier One');
      expect(user.role, 'cashier');
      expect(user.branchId, 'branch-1');
    });

    test('falls back to username when name fields are absent', () {
      final user = User.fromJwtPayload({
        'sub': 'user-2',
        'username': 'manager1',
        'role': 'manager',
      });

      expect(user.fullName, 'manager1');
      expect(user.branchId, isNull);
    });
  });
}
