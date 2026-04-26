// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projection_config.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProjectionConfigCollection on Isar {
  IsarCollection<ProjectionConfig> get projectionConfigs => this.collection();
}

const ProjectionConfigSchema = CollectionSchema(
  name: r'ProjectionConfig',
  id: 165188516322480360,
  properties: {
    r'monitor1PresetId': PropertySchema(
      id: 0,
      name: r'monitor1PresetId',
      type: IsarType.long,
    ),
    r'monitor2PresetId': PropertySchema(
      id: 1,
      name: r'monitor2PresetId',
      type: IsarType.long,
    )
  },
  estimateSize: _projectionConfigEstimateSize,
  serialize: _projectionConfigSerialize,
  deserialize: _projectionConfigDeserialize,
  deserializeProp: _projectionConfigDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _projectionConfigGetId,
  getLinks: _projectionConfigGetLinks,
  attach: _projectionConfigAttach,
  version: '3.1.0+1',
);

int _projectionConfigEstimateSize(
  ProjectionConfig object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _projectionConfigSerialize(
  ProjectionConfig object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.monitor1PresetId);
  writer.writeLong(offsets[1], object.monitor2PresetId);
}

ProjectionConfig _projectionConfigDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProjectionConfig();
  object.id = id;
  object.monitor1PresetId = reader.readLongOrNull(offsets[0]);
  object.monitor2PresetId = reader.readLongOrNull(offsets[1]);
  return object;
}

P _projectionConfigDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _projectionConfigGetId(ProjectionConfig object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _projectionConfigGetLinks(ProjectionConfig object) {
  return [];
}

void _projectionConfigAttach(
    IsarCollection<dynamic> col, Id id, ProjectionConfig object) {
  object.id = id;
}

extension ProjectionConfigQueryWhereSort
    on QueryBuilder<ProjectionConfig, ProjectionConfig, QWhere> {
  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProjectionConfigQueryWhere
    on QueryBuilder<ProjectionConfig, ProjectionConfig, QWhereClause> {
  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterWhereClause> idBetween(
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

extension ProjectionConfigQueryFilter
    on QueryBuilder<ProjectionConfig, ProjectionConfig, QFilterCondition> {
  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1PresetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'monitor1PresetId',
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1PresetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'monitor1PresetId',
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1PresetIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitor1PresetId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1PresetIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monitor1PresetId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1PresetIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monitor1PresetId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1PresetIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monitor1PresetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2PresetIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'monitor2PresetId',
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2PresetIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'monitor2PresetId',
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2PresetIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitor2PresetId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2PresetIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monitor2PresetId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2PresetIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monitor2PresetId',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2PresetIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monitor2PresetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProjectionConfigQueryObject
    on QueryBuilder<ProjectionConfig, ProjectionConfig, QFilterCondition> {}

extension ProjectionConfigQueryLinks
    on QueryBuilder<ProjectionConfig, ProjectionConfig, QFilterCondition> {}

extension ProjectionConfigQuerySortBy
    on QueryBuilder<ProjectionConfig, ProjectionConfig, QSortBy> {
  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor1PresetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1PresetId', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor1PresetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1PresetId', Sort.desc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor2PresetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2PresetId', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor2PresetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2PresetId', Sort.desc);
    });
  }
}

extension ProjectionConfigQuerySortThenBy
    on QueryBuilder<ProjectionConfig, ProjectionConfig, QSortThenBy> {
  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor1PresetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1PresetId', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor1PresetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1PresetId', Sort.desc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor2PresetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2PresetId', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor2PresetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2PresetId', Sort.desc);
    });
  }
}

extension ProjectionConfigQueryWhereDistinct
    on QueryBuilder<ProjectionConfig, ProjectionConfig, QDistinct> {
  QueryBuilder<ProjectionConfig, ProjectionConfig, QDistinct>
      distinctByMonitor1PresetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitor1PresetId');
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QDistinct>
      distinctByMonitor2PresetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitor2PresetId');
    });
  }
}

extension ProjectionConfigQueryProperty
    on QueryBuilder<ProjectionConfig, ProjectionConfig, QQueryProperty> {
  QueryBuilder<ProjectionConfig, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProjectionConfig, int?, QQueryOperations>
      monitor1PresetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitor1PresetId');
    });
  }

  QueryBuilder<ProjectionConfig, int?, QQueryOperations>
      monitor2PresetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitor2PresetId');
    });
  }
}
