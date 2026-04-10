import 'dart:convert';

import 'local_types.dart';

class SyncQueueLocal {
  final String id;
  final LocalEntityType entityType;
  final LocalSyncOperation operation;
  final String entityId;
  final String payloadJson;
  final LocalSyncStatus status;
  final int attempts;
  final String? lastError;
  final int priority;
  final String? correlationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextAttemptAt;

  const SyncQueueLocal({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.entityId,
    required this.payloadJson,
    this.status = LocalSyncStatus.pending,
    this.attempts = 0,
    this.lastError,
    this.priority = 0,
    this.correlationId,
    required this.createdAt,
    required this.updatedAt,
    this.nextAttemptAt,
  });

  factory SyncQueueLocal.fromPayload({
    required String id,
    required LocalEntityType entityType,
    required LocalSyncOperation operation,
    required String entityId,
    required Map<String, dynamic> payload,
    LocalSyncStatus status = LocalSyncStatus.pending,
    int attempts = 0,
    String? lastError,
    int priority = 0,
    String? correlationId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? nextAttemptAt,
  }) {
    return SyncQueueLocal(
      id: id,
      entityType: entityType,
      operation: operation,
      entityId: entityId,
      payloadJson: jsonEncode(payload),
      status: status,
      attempts: attempts,
      lastError: lastError,
      priority: priority,
      correlationId: correlationId,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      nextAttemptAt: nextAttemptAt,
    );
  }

  factory SyncQueueLocal.fromMap(Map<String, dynamic> map) {
    return SyncQueueLocal(
      id: map['id'] as String,
      entityType: decodeLocalEntityType(
        map['entity_type'] as String? ?? 'product',
      ),
      operation: decodeLocalSyncOperation(
        map['operation'] as String? ?? 'upsert',
      ),
      entityId: map['entity_id'] as String,
      payloadJson: map['payload_json'] as String? ?? '{}',
      status: decodeLocalSyncStatus(map['status'] as String? ?? 'pending'),
      attempts: map['attempts'] as int? ?? 0,
      lastError: map['last_error'] as String?,
      priority: map['priority'] as int? ?? 0,
      correlationId: map['correlation_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      nextAttemptAt: map['next_attempt_at'] == null
          ? null
          : DateTime.parse(map['next_attempt_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_type': encodeLocalEntityType(entityType),
      'operation': encodeLocalSyncOperation(operation),
      'entity_id': entityId,
      'payload_json': payloadJson,
      'status': encodeLocalSyncStatus(status),
      'attempts': attempts,
      'last_error': lastError,
      'priority': priority,
      'correlation_id': correlationId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'next_attempt_at': nextAttemptAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> get decodedPayload {
    final decoded = jsonDecode(payloadJson);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{};
  }

  SyncQueueLocal copyWith({
    String? id,
    LocalEntityType? entityType,
    LocalSyncOperation? operation,
    String? entityId,
    String? payloadJson,
    LocalSyncStatus? status,
    int? attempts,
    String? lastError,
    int? priority,
    String? correlationId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? nextAttemptAt,
  }) {
    return SyncQueueLocal(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      operation: operation ?? this.operation,
      entityId: entityId ?? this.entityId,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      priority: priority ?? this.priority,
      correlationId: correlationId ?? this.correlationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    );
  }
}
