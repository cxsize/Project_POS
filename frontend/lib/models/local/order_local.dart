import '../order.dart';
import '../order_item.dart';
import '../payment.dart';
import 'local_types.dart';
import 'order_item_local.dart';
import 'payment_local.dart';

class OrderLocal {
  final String id;
  final String orderNo;
  final String branchId;
  final String staffId;
  final double totalAmount;
  final double discountAmount;
  final double vatAmount;
  final double netAmount;
  final String paymentStatus;
  final bool syncStatusAcc;
  final LocalSyncStatus localSyncStatus;
  final String? syncError;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> itemIds;
  final List<String> paymentIds;

  OrderLocal({
    required this.id,
    required this.orderNo,
    required this.branchId,
    required this.staffId,
    required this.totalAmount,
    required this.discountAmount,
    required this.vatAmount,
    required this.netAmount,
    required this.paymentStatus,
    this.syncStatusAcc = false,
    this.localSyncStatus = LocalSyncStatus.pending,
    this.syncError,
    required this.createdAt,
    required this.updatedAt,
    List<String> itemIds = const [],
    List<String> paymentIds = const [],
  }) : itemIds = List.unmodifiable(itemIds),
       paymentIds = List.unmodifiable(paymentIds);

  factory OrderLocal.fromOrder(
    Order order, {
    Iterable<OrderItemLocal> items = const [],
    Iterable<PaymentLocal> payments = const [],
    bool syncStatusAcc = false,
    LocalSyncStatus localSyncStatus = LocalSyncStatus.pending,
    String? syncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderLocal(
      id: order.id,
      orderNo: order.orderNo,
      branchId: order.branchId,
      staffId: order.staffId,
      totalAmount: order.totalAmount,
      discountAmount: order.discountAmount,
      vatAmount: order.vatAmount,
      netAmount: order.netAmount,
      paymentStatus: order.paymentStatus,
      syncStatusAcc: syncStatusAcc,
      localSyncStatus: localSyncStatus,
      syncError: syncError,
      createdAt: createdAt ?? order.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      itemIds: items.map((item) => item.id).toList(growable: false),
      paymentIds: payments.map((payment) => payment.id).toList(growable: false),
    );
  }

  factory OrderLocal.fromMap(Map<String, dynamic> map) {
    return OrderLocal(
      id: map['id'] as String,
      orderNo: map['order_no'] as String,
      branchId: map['branch_id'] as String,
      staffId: map['staff_id'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      discountAmount: (map['discount_amount'] as num).toDouble(),
      vatAmount: (map['vat_amount'] as num).toDouble(),
      netAmount: (map['net_amount'] as num).toDouble(),
      paymentStatus: map['payment_status'] as String,
      syncStatusAcc: map['sync_status_acc'] as bool? ?? false,
      localSyncStatus: decodeLocalSyncStatus(
        map['local_sync_status'] as String? ?? 'pending',
      ),
      syncError: map['sync_error'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      itemIds: (map['item_ids'] as List<dynamic>? ?? const []).cast<String>(),
      paymentIds: (map['payment_ids'] as List<dynamic>? ?? const [])
          .cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_no': orderNo,
      'branch_id': branchId,
      'staff_id': staffId,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'vat_amount': vatAmount,
      'net_amount': netAmount,
      'payment_status': paymentStatus,
      'sync_status_acc': syncStatusAcc,
      'local_sync_status': encodeLocalSyncStatus(localSyncStatus),
      'sync_error': syncError,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'item_ids': itemIds,
      'payment_ids': paymentIds,
    };
  }

  Order toOrder({
    List<OrderItem> items = const [],
    List<Payment> payments = const [],
  }) {
    return Order(
      id: id,
      orderNo: orderNo,
      branchId: branchId,
      staffId: staffId,
      totalAmount: totalAmount,
      discountAmount: discountAmount,
      vatAmount: vatAmount,
      netAmount: netAmount,
      paymentStatus: paymentStatus,
      createdAt: createdAt,
      items: items,
      payments: payments,
    );
  }

  OrderLocal copyWith({
    String? id,
    String? orderNo,
    String? branchId,
    String? staffId,
    double? totalAmount,
    double? discountAmount,
    double? vatAmount,
    double? netAmount,
    String? paymentStatus,
    bool? syncStatusAcc,
    LocalSyncStatus? localSyncStatus,
    String? syncError,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? itemIds,
    List<String>? paymentIds,
  }) {
    return OrderLocal(
      id: id ?? this.id,
      orderNo: orderNo ?? this.orderNo,
      branchId: branchId ?? this.branchId,
      staffId: staffId ?? this.staffId,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      netAmount: netAmount ?? this.netAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      syncStatusAcc: syncStatusAcc ?? this.syncStatusAcc,
      localSyncStatus: localSyncStatus ?? this.localSyncStatus,
      syncError: syncError ?? this.syncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itemIds: itemIds ?? this.itemIds,
      paymentIds: paymentIds ?? this.paymentIds,
    );
  }
}
