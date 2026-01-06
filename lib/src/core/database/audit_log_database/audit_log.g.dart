// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAuditLogIsarCollection on Isar {
  IsarCollection<AuditLogIsar> get auditLogIsars => this.collection();
}

const AuditLogIsarSchema = CollectionSchema(
  name: r'AuditLogIsar',
  id: 4166618817517721040,
  properties: {
    r'actionType': PropertySchema(
      id: 0,
      name: r'actionType',
      type: IsarType.string,
    ),
    r'createdDate': PropertySchema(
      id: 1,
      name: r'createdDate',
      type: IsarType.dateTime,
    ),
    r'employee': PropertySchema(
      id: 2,
      name: r'employee',
      type: IsarType.object,
      target: r'EmployeeIsar',
    ),
    r'itemId': PropertySchema(
      id: 3,
      name: r'itemId',
      type: IsarType.string,
    ),
    r'logType': PropertySchema(
      id: 4,
      name: r'logType',
      type: IsarType.string,
    ),
    r'newValue': PropertySchema(
      id: 5,
      name: r'newValue',
      type: IsarType.string,
    ),
    r'oldValue': PropertySchema(
      id: 6,
      name: r'oldValue',
      type: IsarType.string,
    )
  },
  estimateSize: _auditLogIsarEstimateSize,
  serialize: _auditLogIsarSerialize,
  deserialize: _auditLogIsarDeserialize,
  deserializeProp: _auditLogIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'EmployeeIsar': EmployeeIsarSchema},
  getId: _auditLogIsarGetId,
  getLinks: _auditLogIsarGetLinks,
  attach: _auditLogIsarAttach,
  version: '3.1.0+1',
);

int _auditLogIsarEstimateSize(
  AuditLogIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.actionType.length * 3;
  bytesCount += 3 +
      EmployeeIsarSchema.estimateSize(
          object.employee, allOffsets[EmployeeIsar]!, allOffsets);
  {
    final value = object.itemId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.logType.length * 3;
  {
    final value = object.newValue;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.oldValue;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _auditLogIsarSerialize(
  AuditLogIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actionType);
  writer.writeDateTime(offsets[1], object.createdDate);
  writer.writeObject<EmployeeIsar>(
    offsets[2],
    allOffsets,
    EmployeeIsarSchema.serialize,
    object.employee,
  );
  writer.writeString(offsets[3], object.itemId);
  writer.writeString(offsets[4], object.logType);
  writer.writeString(offsets[5], object.newValue);
  writer.writeString(offsets[6], object.oldValue);
}

AuditLogIsar _auditLogIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AuditLogIsar();
  object.actionType = reader.readString(offsets[0]);
  object.createdDate = reader.readDateTime(offsets[1]);
  object.employee = reader.readObjectOrNull<EmployeeIsar>(
        offsets[2],
        EmployeeIsarSchema.deserialize,
        allOffsets,
      ) ??
      EmployeeIsar();
  object.id = id;
  object.itemId = reader.readStringOrNull(offsets[3]);
  object.logType = reader.readString(offsets[4]);
  object.newValue = reader.readStringOrNull(offsets[5]);
  object.oldValue = reader.readStringOrNull(offsets[6]);
  return object;
}

P _auditLogIsarDeserializeProp<P>(
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
      return (reader.readObjectOrNull<EmployeeIsar>(
            offset,
            EmployeeIsarSchema.deserialize,
            allOffsets,
          ) ??
          EmployeeIsar()) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _auditLogIsarGetId(AuditLogIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _auditLogIsarGetLinks(AuditLogIsar object) {
  return [];
}

void _auditLogIsarAttach(
    IsarCollection<dynamic> col, Id id, AuditLogIsar object) {
  object.id = id;
}

extension AuditLogIsarQueryWhereSort
    on QueryBuilder<AuditLogIsar, AuditLogIsar, QWhere> {
  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AuditLogIsarQueryWhere
    on QueryBuilder<AuditLogIsar, AuditLogIsar, QWhereClause> {
  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AuditLogIsarQueryFilter
    on QueryBuilder<AuditLogIsar, AuditLogIsar, QFilterCondition> {
  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      actionTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      actionTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      actionTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      actionTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      actionTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      actionTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      actionTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      actionTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actionType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      actionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionType',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      actionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actionType',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      createdDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      createdDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      createdDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      createdDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      itemIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'itemId',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      itemIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'itemId',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition> itemIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      itemIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      itemIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition> itemIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      itemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      itemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      itemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition> itemIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      itemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      itemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemId',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      logTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      logTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'logType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      logTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'logType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      logTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'logType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      logTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'logType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      logTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'logType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      logTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'logType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      logTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'logType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      logTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logType',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      logTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'logType',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      newValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'newValue',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      newValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'newValue',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      newValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      newValueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      newValueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      newValueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      newValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      newValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      newValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'newValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      newValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'newValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      newValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      newValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'newValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      oldValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'oldValue',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      oldValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'oldValue',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      oldValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oldValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      oldValueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'oldValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      oldValueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'oldValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      oldValueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'oldValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      oldValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'oldValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      oldValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'oldValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      oldValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'oldValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      oldValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'oldValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      oldValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oldValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition>
      oldValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'oldValue',
        value: '',
      ));
    });
  }
}

extension AuditLogIsarQueryObject
    on QueryBuilder<AuditLogIsar, AuditLogIsar, QFilterCondition> {
  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterFilterCondition> employee(
      FilterQuery<EmployeeIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'employee');
    });
  }
}

extension AuditLogIsarQueryLinks
    on QueryBuilder<AuditLogIsar, AuditLogIsar, QFilterCondition> {}

extension AuditLogIsarQuerySortBy
    on QueryBuilder<AuditLogIsar, AuditLogIsar, QSortBy> {
  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> sortByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy>
      sortByActionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.desc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> sortByCreatedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdDate', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy>
      sortByCreatedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdDate', Sort.desc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> sortByLogType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logType', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> sortByLogTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logType', Sort.desc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> sortByNewValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newValue', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> sortByNewValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newValue', Sort.desc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> sortByOldValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oldValue', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> sortByOldValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oldValue', Sort.desc);
    });
  }
}

extension AuditLogIsarQuerySortThenBy
    on QueryBuilder<AuditLogIsar, AuditLogIsar, QSortThenBy> {
  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> thenByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy>
      thenByActionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.desc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> thenByCreatedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdDate', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy>
      thenByCreatedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdDate', Sort.desc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> thenByLogType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logType', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> thenByLogTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logType', Sort.desc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> thenByNewValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newValue', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> thenByNewValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newValue', Sort.desc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> thenByOldValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oldValue', Sort.asc);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QAfterSortBy> thenByOldValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oldValue', Sort.desc);
    });
  }
}

extension AuditLogIsarQueryWhereDistinct
    on QueryBuilder<AuditLogIsar, AuditLogIsar, QDistinct> {
  QueryBuilder<AuditLogIsar, AuditLogIsar, QDistinct> distinctByActionType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QDistinct> distinctByCreatedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdDate');
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QDistinct> distinctByItemId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QDistinct> distinctByLogType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QDistinct> distinctByNewValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuditLogIsar, AuditLogIsar, QDistinct> distinctByOldValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'oldValue', caseSensitive: caseSensitive);
    });
  }
}

extension AuditLogIsarQueryProperty
    on QueryBuilder<AuditLogIsar, AuditLogIsar, QQueryProperty> {
  QueryBuilder<AuditLogIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AuditLogIsar, String, QQueryOperations> actionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionType');
    });
  }

  QueryBuilder<AuditLogIsar, DateTime, QQueryOperations> createdDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdDate');
    });
  }

  QueryBuilder<AuditLogIsar, EmployeeIsar, QQueryOperations>
      employeeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'employee');
    });
  }

  QueryBuilder<AuditLogIsar, String?, QQueryOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemId');
    });
  }

  QueryBuilder<AuditLogIsar, String, QQueryOperations> logTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logType');
    });
  }

  QueryBuilder<AuditLogIsar, String?, QQueryOperations> newValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newValue');
    });
  }

  QueryBuilder<AuditLogIsar, String?, QQueryOperations> oldValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'oldValue');
    });
  }
}
