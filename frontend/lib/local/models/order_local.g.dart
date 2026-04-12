// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOrderLocalCollection on Isar {
  IsarCollection<OrderLocal> get orderLocals => this.collection();
}

const OrderLocalSchema = CollectionSchema(
  name: r'OrderLocal',
  id: -7888226103119407276,
  properties: {
    r'branchId': PropertySchema(
      id: 0,
      name: r'branchId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'discountAmount': PropertySchema(
      id: 2,
      name: r'discountAmount',
      type: IsarType.double,
    ),
    r'netAmount': PropertySchema(
      id: 3,
      name: r'netAmount',
      type: IsarType.double,
    ),
    r'orderNo': PropertySchema(id: 4, name: r'orderNo', type: IsarType.string),
    r'paymentStatus': PropertySchema(
      id: 5,
      name: r'paymentStatus',
      type: IsarType.string,
    ),
    r'remoteId': PropertySchema(
      id: 6,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'staffId': PropertySchema(id: 7, name: r'staffId', type: IsarType.string),
    r'syncStatusAcc': PropertySchema(
      id: 8,
      name: r'syncStatusAcc',
      type: IsarType.bool,
    ),
    r'syncedAt': PropertySchema(
      id: 9,
      name: r'syncedAt',
      type: IsarType.dateTime,
    ),
    r'totalAmount': PropertySchema(
      id: 10,
      name: r'totalAmount',
      type: IsarType.double,
    ),
    r'vatAmount': PropertySchema(
      id: 11,
      name: r'vatAmount',
      type: IsarType.double,
    ),
  },
  estimateSize: _orderLocalEstimateSize,
  serialize: _orderLocalSerialize,
  deserialize: _orderLocalDeserialize,
  deserializeProp: _orderLocalDeserializeProp,
  idName: r'id',
  indexes: {
    r'remoteId': IndexSchema(
      id: 6301175856541681032,
      name: r'remoteId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'remoteId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'orderNo': IndexSchema(
      id: -8490363104718318756,
      name: r'orderNo',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'orderNo',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'paymentStatus': IndexSchema(
      id: 7011973130100993011,
      name: r'paymentStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'paymentStatus',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'syncStatusAcc': IndexSchema(
      id: 7492566789395349404,
      name: r'syncStatusAcc',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syncStatusAcc',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _orderLocalGetId,
  getLinks: _orderLocalGetLinks,
  attach: _orderLocalAttach,
  version: '3.1.0+1',
);

int _orderLocalEstimateSize(
  OrderLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.branchId.length * 3;
  bytesCount += 3 + object.orderNo.length * 3;
  bytesCount += 3 + object.paymentStatus.length * 3;
  bytesCount += 3 + object.remoteId.length * 3;
  bytesCount += 3 + object.staffId.length * 3;
  return bytesCount;
}

void _orderLocalSerialize(
  OrderLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.branchId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDouble(offsets[2], object.discountAmount);
  writer.writeDouble(offsets[3], object.netAmount);
  writer.writeString(offsets[4], object.orderNo);
  writer.writeString(offsets[5], object.paymentStatus);
  writer.writeString(offsets[6], object.remoteId);
  writer.writeString(offsets[7], object.staffId);
  writer.writeBool(offsets[8], object.syncStatusAcc);
  writer.writeDateTime(offsets[9], object.syncedAt);
  writer.writeDouble(offsets[10], object.totalAmount);
  writer.writeDouble(offsets[11], object.vatAmount);
}

OrderLocal _orderLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OrderLocal();
  object.branchId = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.discountAmount = reader.readDouble(offsets[2]);
  object.id = id;
  object.netAmount = reader.readDouble(offsets[3]);
  object.orderNo = reader.readString(offsets[4]);
  object.paymentStatus = reader.readString(offsets[5]);
  object.remoteId = reader.readString(offsets[6]);
  object.staffId = reader.readString(offsets[7]);
  object.syncStatusAcc = reader.readBool(offsets[8]);
  object.syncedAt = reader.readDateTime(offsets[9]);
  object.totalAmount = reader.readDouble(offsets[10]);
  object.vatAmount = reader.readDouble(offsets[11]);
  return object;
}

P _orderLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _orderLocalGetId(OrderLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _orderLocalGetLinks(OrderLocal object) {
  return [];
}

void _orderLocalAttach(IsarCollection<dynamic> col, Id id, OrderLocal object) {
  object.id = id;
}

extension OrderLocalByIndex on IsarCollection<OrderLocal> {
  Future<OrderLocal?> getByRemoteId(String remoteId) {
    return getByIndex(r'remoteId', [remoteId]);
  }

  OrderLocal? getByRemoteIdSync(String remoteId) {
    return getByIndexSync(r'remoteId', [remoteId]);
  }

  Future<bool> deleteByRemoteId(String remoteId) {
    return deleteByIndex(r'remoteId', [remoteId]);
  }

  bool deleteByRemoteIdSync(String remoteId) {
    return deleteByIndexSync(r'remoteId', [remoteId]);
  }

  Future<List<OrderLocal?>> getAllByRemoteId(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'remoteId', values);
  }

  List<OrderLocal?> getAllByRemoteIdSync(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'remoteId', values);
  }

  Future<int> deleteAllByRemoteId(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'remoteId', values);
  }

  int deleteAllByRemoteIdSync(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'remoteId', values);
  }

  Future<Id> putByRemoteId(OrderLocal object) {
    return putByIndex(r'remoteId', object);
  }

  Id putByRemoteIdSync(OrderLocal object, {bool saveLinks = true}) {
    return putByIndexSync(r'remoteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRemoteId(List<OrderLocal> objects) {
    return putAllByIndex(r'remoteId', objects);
  }

  List<Id> putAllByRemoteIdSync(
    List<OrderLocal> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'remoteId', objects, saveLinks: saveLinks);
  }

  Future<OrderLocal?> getByOrderNo(String orderNo) {
    return getByIndex(r'orderNo', [orderNo]);
  }

  OrderLocal? getByOrderNoSync(String orderNo) {
    return getByIndexSync(r'orderNo', [orderNo]);
  }

  Future<bool> deleteByOrderNo(String orderNo) {
    return deleteByIndex(r'orderNo', [orderNo]);
  }

  bool deleteByOrderNoSync(String orderNo) {
    return deleteByIndexSync(r'orderNo', [orderNo]);
  }

  Future<List<OrderLocal?>> getAllByOrderNo(List<String> orderNoValues) {
    final values = orderNoValues.map((e) => [e]).toList();
    return getAllByIndex(r'orderNo', values);
  }

  List<OrderLocal?> getAllByOrderNoSync(List<String> orderNoValues) {
    final values = orderNoValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'orderNo', values);
  }

  Future<int> deleteAllByOrderNo(List<String> orderNoValues) {
    final values = orderNoValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'orderNo', values);
  }

  int deleteAllByOrderNoSync(List<String> orderNoValues) {
    final values = orderNoValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'orderNo', values);
  }

  Future<Id> putByOrderNo(OrderLocal object) {
    return putByIndex(r'orderNo', object);
  }

  Id putByOrderNoSync(OrderLocal object, {bool saveLinks = true}) {
    return putByIndexSync(r'orderNo', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOrderNo(List<OrderLocal> objects) {
    return putAllByIndex(r'orderNo', objects);
  }

  List<Id> putAllByOrderNoSync(
    List<OrderLocal> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'orderNo', objects, saveLinks: saveLinks);
  }
}

extension OrderLocalQueryWhereSort
    on QueryBuilder<OrderLocal, OrderLocal, QWhere> {
  QueryBuilder<OrderLocal, OrderLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhere> anySyncStatusAcc() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'syncStatusAcc'),
      );
    });
  }
}

extension OrderLocalQueryWhere
    on QueryBuilder<OrderLocal, OrderLocal, QWhereClause> {
  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> remoteIdEqualTo(
    String remoteId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'remoteId', value: [remoteId]),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> remoteIdNotEqualTo(
    String remoteId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [],
                upper: [remoteId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [remoteId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [remoteId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [],
                upper: [remoteId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> orderNoEqualTo(
    String orderNo,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'orderNo', value: [orderNo]),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> orderNoNotEqualTo(
    String orderNo,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'orderNo',
                lower: [],
                upper: [orderNo],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'orderNo',
                lower: [orderNo],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'orderNo',
                lower: [orderNo],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'orderNo',
                lower: [],
                upper: [orderNo],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> paymentStatusEqualTo(
    String paymentStatus,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'paymentStatus',
          value: [paymentStatus],
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause>
  paymentStatusNotEqualTo(String paymentStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paymentStatus',
                lower: [],
                upper: [paymentStatus],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paymentStatus',
                lower: [paymentStatus],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paymentStatus',
                lower: [paymentStatus],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'paymentStatus',
                lower: [],
                upper: [paymentStatus],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause> syncStatusAccEqualTo(
    bool syncStatusAcc,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'syncStatusAcc',
          value: [syncStatusAcc],
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterWhereClause>
  syncStatusAccNotEqualTo(bool syncStatusAcc) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncStatusAcc',
                lower: [],
                upper: [syncStatusAcc],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncStatusAcc',
                lower: [syncStatusAcc],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncStatusAcc',
                lower: [syncStatusAcc],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncStatusAcc',
                lower: [],
                upper: [syncStatusAcc],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension OrderLocalQueryFilter
    on QueryBuilder<OrderLocal, OrderLocal, QFilterCondition> {
  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> branchIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'branchId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  branchIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'branchId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> branchIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'branchId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> branchIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'branchId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  branchIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'branchId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> branchIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'branchId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> branchIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'branchId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> branchIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'branchId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  branchIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'branchId', value: ''),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  branchIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'branchId', value: ''),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  discountAmountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'discountAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  discountAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'discountAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  discountAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'discountAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  discountAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'discountAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> netAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'netAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  netAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'netAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> netAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'netAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> netAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'netAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> orderNoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'orderNo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  orderNoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'orderNo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> orderNoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'orderNo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> orderNoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'orderNo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> orderNoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'orderNo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> orderNoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'orderNo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> orderNoContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'orderNo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> orderNoMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'orderNo',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> orderNoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'orderNo', value: ''),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  orderNoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'orderNo', value: ''),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentStatusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'paymentStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'paymentStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'paymentStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'paymentStatus',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentStatusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'paymentStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentStatusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'paymentStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'paymentStatus',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'paymentStatus',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'paymentStatus', value: ''),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  paymentStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'paymentStatus', value: ''),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remoteIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  remoteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remoteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remoteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remoteId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  remoteIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remoteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remoteIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> remoteIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remoteId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> staffIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'staffId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  staffIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'staffId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> staffIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'staffId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> staffIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'staffId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> staffIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'staffId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> staffIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'staffId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> staffIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'staffId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> staffIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'staffId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> staffIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'staffId', value: ''),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  staffIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'staffId', value: ''),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  syncStatusAccEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncStatusAcc', value: value),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> syncedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncedAt', value: value),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  syncedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> syncedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> syncedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  totalAmountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'totalAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  totalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  totalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  totalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> vatAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'vatAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition>
  vatAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'vatAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> vatAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'vatAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterFilterCondition> vatAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'vatAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }
}

extension OrderLocalQueryObject
    on QueryBuilder<OrderLocal, OrderLocal, QFilterCondition> {}

extension OrderLocalQueryLinks
    on QueryBuilder<OrderLocal, OrderLocal, QFilterCondition> {}

extension OrderLocalQuerySortBy
    on QueryBuilder<OrderLocal, OrderLocal, QSortBy> {
  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByBranchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByBranchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy>
  sortByDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByNetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByNetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByOrderNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNo', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByOrderNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNo', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByPaymentStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentStatus', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByPaymentStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentStatus', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortBySyncStatusAcc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusAcc', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortBySyncStatusAccDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusAcc', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByVatAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vatAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> sortByVatAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vatAmount', Sort.desc);
    });
  }
}

extension OrderLocalQuerySortThenBy
    on QueryBuilder<OrderLocal, OrderLocal, QSortThenBy> {
  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByBranchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByBranchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy>
  thenByDiscountAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discountAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByNetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByNetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByOrderNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNo', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByOrderNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNo', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByPaymentStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentStatus', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByPaymentStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentStatus', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenBySyncStatusAcc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusAcc', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenBySyncStatusAccDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatusAcc', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByVatAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vatAmount', Sort.asc);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QAfterSortBy> thenByVatAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vatAmount', Sort.desc);
    });
  }
}

extension OrderLocalQueryWhereDistinct
    on QueryBuilder<OrderLocal, OrderLocal, QDistinct> {
  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByBranchId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'branchId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByDiscountAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discountAmount');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByNetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'netAmount');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByOrderNo({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderNo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByPaymentStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'paymentStatus',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByRemoteId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByStaffId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'staffId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctBySyncStatusAcc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatusAcc');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }

  QueryBuilder<OrderLocal, OrderLocal, QDistinct> distinctByVatAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vatAmount');
    });
  }
}

extension OrderLocalQueryProperty
    on QueryBuilder<OrderLocal, OrderLocal, QQueryProperty> {
  QueryBuilder<OrderLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OrderLocal, String, QQueryOperations> branchIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'branchId');
    });
  }

  QueryBuilder<OrderLocal, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<OrderLocal, double, QQueryOperations> discountAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discountAmount');
    });
  }

  QueryBuilder<OrderLocal, double, QQueryOperations> netAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'netAmount');
    });
  }

  QueryBuilder<OrderLocal, String, QQueryOperations> orderNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderNo');
    });
  }

  QueryBuilder<OrderLocal, String, QQueryOperations> paymentStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentStatus');
    });
  }

  QueryBuilder<OrderLocal, String, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<OrderLocal, String, QQueryOperations> staffIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'staffId');
    });
  }

  QueryBuilder<OrderLocal, bool, QQueryOperations> syncStatusAccProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatusAcc');
    });
  }

  QueryBuilder<OrderLocal, DateTime, QQueryOperations> syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }

  QueryBuilder<OrderLocal, double, QQueryOperations> totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }

  QueryBuilder<OrderLocal, double, QQueryOperations> vatAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vatAmount');
    });
  }
}
