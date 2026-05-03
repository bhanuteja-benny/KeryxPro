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
    r'monitor1Format': PropertySchema(
      id: 0,
      name: r'monitor1Format',
      type: IsarType.string,
    ),
    r'monitor1MaxChars': PropertySchema(
      id: 1,
      name: r'monitor1MaxChars',
      type: IsarType.long,
    ),
    r'monitor1MaxVerses': PropertySchema(
      id: 2,
      name: r'monitor1MaxVerses',
      type: IsarType.long,
    ),
    r'monitor1PresetId': PropertySchema(
      id: 3,
      name: r'monitor1PresetId',
      type: IsarType.long,
    ),
    r'monitor2Format': PropertySchema(
      id: 4,
      name: r'monitor2Format',
      type: IsarType.string,
    ),
    r'monitor2MaxChars': PropertySchema(
      id: 5,
      name: r'monitor2MaxChars',
      type: IsarType.long,
    ),
    r'monitor2MaxVerses': PropertySchema(
      id: 6,
      name: r'monitor2MaxVerses',
      type: IsarType.long,
    ),
    r'monitor2PresetId': PropertySchema(
      id: 7,
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
  bytesCount += 3 + object.monitor1Format.length * 3;
  bytesCount += 3 + object.monitor2Format.length * 3;
  return bytesCount;
}

void _projectionConfigSerialize(
  ProjectionConfig object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.monitor1Format);
  writer.writeLong(offsets[1], object.monitor1MaxChars);
  writer.writeLong(offsets[2], object.monitor1MaxVerses);
  writer.writeLong(offsets[3], object.monitor1PresetId);
  writer.writeString(offsets[4], object.monitor2Format);
  writer.writeLong(offsets[5], object.monitor2MaxChars);
  writer.writeLong(offsets[6], object.monitor2MaxVerses);
  writer.writeLong(offsets[7], object.monitor2PresetId);
}

ProjectionConfig _projectionConfigDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProjectionConfig();
  object.id = id;
  object.monitor1Format = reader.readString(offsets[0]);
  object.monitor1MaxChars = reader.readLong(offsets[1]);
  object.monitor1MaxVerses = reader.readLong(offsets[2]);
  object.monitor1PresetId = reader.readLongOrNull(offsets[3]);
  object.monitor2Format = reader.readString(offsets[4]);
  object.monitor2MaxChars = reader.readLong(offsets[5]);
  object.monitor2MaxVerses = reader.readLong(offsets[6]);
  object.monitor2PresetId = reader.readLongOrNull(offsets[7]);
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
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
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
      monitor1FormatEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitor1Format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1FormatGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monitor1Format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1FormatLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monitor1Format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1FormatBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monitor1Format',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1FormatStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'monitor1Format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1FormatEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'monitor1Format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1FormatContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'monitor1Format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1FormatMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'monitor1Format',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1FormatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitor1Format',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1FormatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'monitor1Format',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1MaxCharsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitor1MaxChars',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1MaxCharsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monitor1MaxChars',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1MaxCharsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monitor1MaxChars',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1MaxCharsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monitor1MaxChars',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1MaxVersesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitor1MaxVerses',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1MaxVersesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monitor1MaxVerses',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1MaxVersesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monitor1MaxVerses',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor1MaxVersesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monitor1MaxVerses',
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
      monitor2FormatEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitor2Format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2FormatGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monitor2Format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2FormatLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monitor2Format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2FormatBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monitor2Format',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2FormatStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'monitor2Format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2FormatEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'monitor2Format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2FormatContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'monitor2Format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2FormatMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'monitor2Format',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2FormatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitor2Format',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2FormatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'monitor2Format',
        value: '',
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2MaxCharsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitor2MaxChars',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2MaxCharsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monitor2MaxChars',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2MaxCharsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monitor2MaxChars',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2MaxCharsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monitor2MaxChars',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2MaxVersesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monitor2MaxVerses',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2MaxVersesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monitor2MaxVerses',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2MaxVersesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monitor2MaxVerses',
        value: value,
      ));
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterFilterCondition>
      monitor2MaxVersesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monitor2MaxVerses',
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
      sortByMonitor1Format() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1Format', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor1FormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1Format', Sort.desc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor1MaxChars() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1MaxChars', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor1MaxCharsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1MaxChars', Sort.desc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor1MaxVerses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1MaxVerses', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor1MaxVersesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1MaxVerses', Sort.desc);
    });
  }

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
      sortByMonitor2Format() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2Format', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor2FormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2Format', Sort.desc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor2MaxChars() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2MaxChars', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor2MaxCharsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2MaxChars', Sort.desc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor2MaxVerses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2MaxVerses', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      sortByMonitor2MaxVersesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2MaxVerses', Sort.desc);
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
      thenByMonitor1Format() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1Format', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor1FormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1Format', Sort.desc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor1MaxChars() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1MaxChars', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor1MaxCharsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1MaxChars', Sort.desc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor1MaxVerses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1MaxVerses', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor1MaxVersesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor1MaxVerses', Sort.desc);
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
      thenByMonitor2Format() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2Format', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor2FormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2Format', Sort.desc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor2MaxChars() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2MaxChars', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor2MaxCharsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2MaxChars', Sort.desc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor2MaxVerses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2MaxVerses', Sort.asc);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QAfterSortBy>
      thenByMonitor2MaxVersesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monitor2MaxVerses', Sort.desc);
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
      distinctByMonitor1Format({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitor1Format',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QDistinct>
      distinctByMonitor1MaxChars() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitor1MaxChars');
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QDistinct>
      distinctByMonitor1MaxVerses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitor1MaxVerses');
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QDistinct>
      distinctByMonitor1PresetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitor1PresetId');
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QDistinct>
      distinctByMonitor2Format({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitor2Format',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QDistinct>
      distinctByMonitor2MaxChars() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitor2MaxChars');
    });
  }

  QueryBuilder<ProjectionConfig, ProjectionConfig, QDistinct>
      distinctByMonitor2MaxVerses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monitor2MaxVerses');
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

  QueryBuilder<ProjectionConfig, String, QQueryOperations>
      monitor1FormatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitor1Format');
    });
  }

  QueryBuilder<ProjectionConfig, int, QQueryOperations>
      monitor1MaxCharsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitor1MaxChars');
    });
  }

  QueryBuilder<ProjectionConfig, int, QQueryOperations>
      monitor1MaxVersesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitor1MaxVerses');
    });
  }

  QueryBuilder<ProjectionConfig, int?, QQueryOperations>
      monitor1PresetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitor1PresetId');
    });
  }

  QueryBuilder<ProjectionConfig, String, QQueryOperations>
      monitor2FormatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitor2Format');
    });
  }

  QueryBuilder<ProjectionConfig, int, QQueryOperations>
      monitor2MaxCharsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitor2MaxChars');
    });
  }

  QueryBuilder<ProjectionConfig, int, QQueryOperations>
      monitor2MaxVersesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitor2MaxVerses');
    });
  }

  QueryBuilder<ProjectionConfig, int?, QQueryOperations>
      monitor2PresetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monitor2PresetId');
    });
  }
}
