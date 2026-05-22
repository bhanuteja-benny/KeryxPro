// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBibleVersionCollection on Isar {
  IsarCollection<BibleVersion> get bibleVersions => this.collection();
}

const BibleVersionSchema = CollectionSchema(
  name: r'BibleVersion',
  id: -9208477595926227821,
  properties: {
    r'abbreviation': PropertySchema(
      id: 0,
      name: r'abbreviation',
      type: IsarType.string,
    ),
    r'language': PropertySchema(
      id: 1,
      name: r'language',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'syncId': PropertySchema(
      id: 3,
      name: r'syncId',
      type: IsarType.string,
    )
  },
  estimateSize: _bibleVersionEstimateSize,
  serialize: _bibleVersionSerialize,
  deserialize: _bibleVersionDeserialize,
  deserializeProp: _bibleVersionDeserializeProp,
  idName: r'id',
  indexes: {
    r'syncId': IndexSchema(
      id: 7538593479801827566,
      name: r'syncId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'syncId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'abbreviation': IndexSchema(
      id: 8242173811669365471,
      name: r'abbreviation',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'abbreviation',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _bibleVersionGetId,
  getLinks: _bibleVersionGetLinks,
  attach: _bibleVersionAttach,
  version: '3.1.0+1',
);

int _bibleVersionEstimateSize(
  BibleVersion object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.abbreviation.length * 3;
  bytesCount += 3 + object.language.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.syncId.length * 3;
  return bytesCount;
}

void _bibleVersionSerialize(
  BibleVersion object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.abbreviation);
  writer.writeString(offsets[1], object.language);
  writer.writeString(offsets[2], object.name);
  writer.writeString(offsets[3], object.syncId);
}

BibleVersion _bibleVersionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BibleVersion();
  object.abbreviation = reader.readString(offsets[0]);
  object.id = id;
  object.language = reader.readString(offsets[1]);
  object.name = reader.readString(offsets[2]);
  object.syncId = reader.readString(offsets[3]);
  return object;
}

P _bibleVersionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bibleVersionGetId(BibleVersion object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bibleVersionGetLinks(BibleVersion object) {
  return [];
}

void _bibleVersionAttach(
    IsarCollection<dynamic> col, Id id, BibleVersion object) {
  object.id = id;
}

extension BibleVersionByIndex on IsarCollection<BibleVersion> {
  Future<BibleVersion?> getBySyncId(String syncId) {
    return getByIndex(r'syncId', [syncId]);
  }

  BibleVersion? getBySyncIdSync(String syncId) {
    return getByIndexSync(r'syncId', [syncId]);
  }

  Future<bool> deleteBySyncId(String syncId) {
    return deleteByIndex(r'syncId', [syncId]);
  }

  bool deleteBySyncIdSync(String syncId) {
    return deleteByIndexSync(r'syncId', [syncId]);
  }

  Future<List<BibleVersion?>> getAllBySyncId(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'syncId', values);
  }

  List<BibleVersion?> getAllBySyncIdSync(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'syncId', values);
  }

  Future<int> deleteAllBySyncId(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'syncId', values);
  }

  int deleteAllBySyncIdSync(List<String> syncIdValues) {
    final values = syncIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'syncId', values);
  }

  Future<Id> putBySyncId(BibleVersion object) {
    return putByIndex(r'syncId', object);
  }

  Id putBySyncIdSync(BibleVersion object, {bool saveLinks = true}) {
    return putByIndexSync(r'syncId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySyncId(List<BibleVersion> objects) {
    return putAllByIndex(r'syncId', objects);
  }

  List<Id> putAllBySyncIdSync(List<BibleVersion> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'syncId', objects, saveLinks: saveLinks);
  }

  Future<BibleVersion?> getByAbbreviation(String abbreviation) {
    return getByIndex(r'abbreviation', [abbreviation]);
  }

  BibleVersion? getByAbbreviationSync(String abbreviation) {
    return getByIndexSync(r'abbreviation', [abbreviation]);
  }

  Future<bool> deleteByAbbreviation(String abbreviation) {
    return deleteByIndex(r'abbreviation', [abbreviation]);
  }

  bool deleteByAbbreviationSync(String abbreviation) {
    return deleteByIndexSync(r'abbreviation', [abbreviation]);
  }

  Future<List<BibleVersion?>> getAllByAbbreviation(
      List<String> abbreviationValues) {
    final values = abbreviationValues.map((e) => [e]).toList();
    return getAllByIndex(r'abbreviation', values);
  }

  List<BibleVersion?> getAllByAbbreviationSync(
      List<String> abbreviationValues) {
    final values = abbreviationValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'abbreviation', values);
  }

  Future<int> deleteAllByAbbreviation(List<String> abbreviationValues) {
    final values = abbreviationValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'abbreviation', values);
  }

  int deleteAllByAbbreviationSync(List<String> abbreviationValues) {
    final values = abbreviationValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'abbreviation', values);
  }

  Future<Id> putByAbbreviation(BibleVersion object) {
    return putByIndex(r'abbreviation', object);
  }

  Id putByAbbreviationSync(BibleVersion object, {bool saveLinks = true}) {
    return putByIndexSync(r'abbreviation', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByAbbreviation(List<BibleVersion> objects) {
    return putAllByIndex(r'abbreviation', objects);
  }

  List<Id> putAllByAbbreviationSync(List<BibleVersion> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'abbreviation', objects, saveLinks: saveLinks);
  }
}

extension BibleVersionQueryWhereSort
    on QueryBuilder<BibleVersion, BibleVersion, QWhere> {
  QueryBuilder<BibleVersion, BibleVersion, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BibleVersionQueryWhere
    on QueryBuilder<BibleVersion, BibleVersion, QWhereClause> {
  QueryBuilder<BibleVersion, BibleVersion, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<BibleVersion, BibleVersion, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterWhereClause> idBetween(
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

  QueryBuilder<BibleVersion, BibleVersion, QAfterWhereClause> syncIdEqualTo(
      String syncId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncId',
        value: [syncId],
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterWhereClause> syncIdNotEqualTo(
      String syncId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [],
              upper: [syncId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [syncId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [syncId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncId',
              lower: [],
              upper: [syncId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterWhereClause>
      abbreviationEqualTo(String abbreviation) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'abbreviation',
        value: [abbreviation],
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterWhereClause>
      abbreviationNotEqualTo(String abbreviation) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'abbreviation',
              lower: [],
              upper: [abbreviation],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'abbreviation',
              lower: [abbreviation],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'abbreviation',
              lower: [abbreviation],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'abbreviation',
              lower: [],
              upper: [abbreviation],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BibleVersionQueryFilter
    on QueryBuilder<BibleVersion, BibleVersion, QFilterCondition> {
  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      abbreviationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'abbreviation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      abbreviationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'abbreviation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      abbreviationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'abbreviation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      abbreviationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'abbreviation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      abbreviationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'abbreviation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      abbreviationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'abbreviation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      abbreviationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'abbreviation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      abbreviationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'abbreviation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      abbreviationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'abbreviation',
        value: '',
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      abbreviationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'abbreviation',
        value: '',
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      languageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      languageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      languageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      languageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'language',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      languageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'language',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> syncIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      syncIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      syncIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> syncIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      syncIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      syncIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      syncIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition> syncIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      syncIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncId',
        value: '',
      ));
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterFilterCondition>
      syncIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncId',
        value: '',
      ));
    });
  }
}

extension BibleVersionQueryObject
    on QueryBuilder<BibleVersion, BibleVersion, QFilterCondition> {}

extension BibleVersionQueryLinks
    on QueryBuilder<BibleVersion, BibleVersion, QFilterCondition> {}

extension BibleVersionQuerySortBy
    on QueryBuilder<BibleVersion, BibleVersion, QSortBy> {
  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> sortByAbbreviation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'abbreviation', Sort.asc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy>
      sortByAbbreviationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'abbreviation', Sort.desc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> sortBySyncId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.asc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> sortBySyncIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.desc);
    });
  }
}

extension BibleVersionQuerySortThenBy
    on QueryBuilder<BibleVersion, BibleVersion, QSortThenBy> {
  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> thenByAbbreviation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'abbreviation', Sort.asc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy>
      thenByAbbreviationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'abbreviation', Sort.desc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> thenBySyncId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.asc);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QAfterSortBy> thenBySyncIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.desc);
    });
  }
}

extension BibleVersionQueryWhereDistinct
    on QueryBuilder<BibleVersion, BibleVersion, QDistinct> {
  QueryBuilder<BibleVersion, BibleVersion, QDistinct> distinctByAbbreviation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'abbreviation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BibleVersion, BibleVersion, QDistinct> distinctBySyncId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncId', caseSensitive: caseSensitive);
    });
  }
}

extension BibleVersionQueryProperty
    on QueryBuilder<BibleVersion, BibleVersion, QQueryProperty> {
  QueryBuilder<BibleVersion, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BibleVersion, String, QQueryOperations> abbreviationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'abbreviation');
    });
  }

  QueryBuilder<BibleVersion, String, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<BibleVersion, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<BibleVersion, String, QQueryOperations> syncIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBibleVerseCollection on Isar {
  IsarCollection<BibleVerse> get bibleVerses => this.collection();
}

const BibleVerseSchema = CollectionSchema(
  name: r'BibleVerse',
  id: 7966111860672727516,
  properties: {
    r'bibleVersionId': PropertySchema(
      id: 0,
      name: r'bibleVersionId',
      type: IsarType.long,
    ),
    r'bookName': PropertySchema(
      id: 1,
      name: r'bookName',
      type: IsarType.string,
    ),
    r'chapterNumber': PropertySchema(
      id: 2,
      name: r'chapterNumber',
      type: IsarType.long,
    ),
    r'text': PropertySchema(
      id: 3,
      name: r'text',
      type: IsarType.string,
    ),
    r'verseNumber': PropertySchema(
      id: 4,
      name: r'verseNumber',
      type: IsarType.long,
    )
  },
  estimateSize: _bibleVerseEstimateSize,
  serialize: _bibleVerseSerialize,
  deserialize: _bibleVerseDeserialize,
  deserializeProp: _bibleVerseDeserializeProp,
  idName: r'id',
  indexes: {
    r'bibleVersionId': IndexSchema(
      id: -458113002389487870,
      name: r'bibleVersionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bibleVersionId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'bookName': IndexSchema(
      id: -1933582217000277918,
      name: r'bookName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookName',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'chapterNumber': IndexSchema(
      id: -7659654328869413098,
      name: r'chapterNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'chapterNumber',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'verseNumber': IndexSchema(
      id: 4187590259546384965,
      name: r'verseNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'verseNumber',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'text': IndexSchema(
      id: 5145922347574273553,
      name: r'text',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'text',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _bibleVerseGetId,
  getLinks: _bibleVerseGetLinks,
  attach: _bibleVerseAttach,
  version: '3.1.0+1',
);

int _bibleVerseEstimateSize(
  BibleVerse object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bookName.length * 3;
  bytesCount += 3 + object.text.length * 3;
  return bytesCount;
}

void _bibleVerseSerialize(
  BibleVerse object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bibleVersionId);
  writer.writeString(offsets[1], object.bookName);
  writer.writeLong(offsets[2], object.chapterNumber);
  writer.writeString(offsets[3], object.text);
  writer.writeLong(offsets[4], object.verseNumber);
}

BibleVerse _bibleVerseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BibleVerse();
  object.bibleVersionId = reader.readLong(offsets[0]);
  object.bookName = reader.readString(offsets[1]);
  object.chapterNumber = reader.readLong(offsets[2]);
  object.id = id;
  object.text = reader.readString(offsets[3]);
  object.verseNumber = reader.readLong(offsets[4]);
  return object;
}

P _bibleVerseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bibleVerseGetId(BibleVerse object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bibleVerseGetLinks(BibleVerse object) {
  return [];
}

void _bibleVerseAttach(IsarCollection<dynamic> col, Id id, BibleVerse object) {
  object.id = id;
}

extension BibleVerseQueryWhereSort
    on QueryBuilder<BibleVerse, BibleVerse, QWhere> {
  QueryBuilder<BibleVerse, BibleVerse, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhere> anyBibleVersionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bibleVersionId'),
      );
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhere> anyBookName() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bookName'),
      );
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhere> anyChapterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'chapterNumber'),
      );
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhere> anyVerseNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'verseNumber'),
      );
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhere> anyText() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'text'),
      );
    });
  }
}

extension BibleVerseQueryWhere
    on QueryBuilder<BibleVerse, BibleVerse, QWhereClause> {
  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> idBetween(
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

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> bibleVersionIdEqualTo(
      int bibleVersionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bibleVersionId',
        value: [bibleVersionId],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause>
      bibleVersionIdNotEqualTo(int bibleVersionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bibleVersionId',
              lower: [],
              upper: [bibleVersionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bibleVersionId',
              lower: [bibleVersionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bibleVersionId',
              lower: [bibleVersionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bibleVersionId',
              lower: [],
              upper: [bibleVersionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause>
      bibleVersionIdGreaterThan(
    int bibleVersionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bibleVersionId',
        lower: [bibleVersionId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause>
      bibleVersionIdLessThan(
    int bibleVersionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bibleVersionId',
        lower: [],
        upper: [bibleVersionId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> bibleVersionIdBetween(
    int lowerBibleVersionId,
    int upperBibleVersionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bibleVersionId',
        lower: [lowerBibleVersionId],
        includeLower: includeLower,
        upper: [upperBibleVersionId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> bookNameEqualTo(
      String bookName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookName',
        value: [bookName],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> bookNameNotEqualTo(
      String bookName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookName',
              lower: [],
              upper: [bookName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookName',
              lower: [bookName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookName',
              lower: [bookName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookName',
              lower: [],
              upper: [bookName],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> bookNameGreaterThan(
    String bookName, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookName',
        lower: [bookName],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> bookNameLessThan(
    String bookName, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookName',
        lower: [],
        upper: [bookName],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> bookNameBetween(
    String lowerBookName,
    String upperBookName, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookName',
        lower: [lowerBookName],
        includeLower: includeLower,
        upper: [upperBookName],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> bookNameStartsWith(
      String BookNamePrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookName',
        lower: [BookNamePrefix],
        upper: ['$BookNamePrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> bookNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookName',
        value: [''],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> bookNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'bookName',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'bookName',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'bookName',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'bookName',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> chapterNumberEqualTo(
      int chapterNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'chapterNumber',
        value: [chapterNumber],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause>
      chapterNumberNotEqualTo(int chapterNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterNumber',
              lower: [],
              upper: [chapterNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterNumber',
              lower: [chapterNumber],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterNumber',
              lower: [chapterNumber],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterNumber',
              lower: [],
              upper: [chapterNumber],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause>
      chapterNumberGreaterThan(
    int chapterNumber, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterNumber',
        lower: [chapterNumber],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> chapterNumberLessThan(
    int chapterNumber, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterNumber',
        lower: [],
        upper: [chapterNumber],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> chapterNumberBetween(
    int lowerChapterNumber,
    int upperChapterNumber, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'chapterNumber',
        lower: [lowerChapterNumber],
        includeLower: includeLower,
        upper: [upperChapterNumber],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> verseNumberEqualTo(
      int verseNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'verseNumber',
        value: [verseNumber],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> verseNumberNotEqualTo(
      int verseNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'verseNumber',
              lower: [],
              upper: [verseNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'verseNumber',
              lower: [verseNumber],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'verseNumber',
              lower: [verseNumber],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'verseNumber',
              lower: [],
              upper: [verseNumber],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause>
      verseNumberGreaterThan(
    int verseNumber, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'verseNumber',
        lower: [verseNumber],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> verseNumberLessThan(
    int verseNumber, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'verseNumber',
        lower: [],
        upper: [verseNumber],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> verseNumberBetween(
    int lowerVerseNumber,
    int upperVerseNumber, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'verseNumber',
        lower: [lowerVerseNumber],
        includeLower: includeLower,
        upper: [upperVerseNumber],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> textEqualTo(
      String text) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'text',
        value: [text],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> textNotEqualTo(
      String text) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'text',
              lower: [],
              upper: [text],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'text',
              lower: [text],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'text',
              lower: [text],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'text',
              lower: [],
              upper: [text],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> textGreaterThan(
    String text, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'text',
        lower: [text],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> textLessThan(
    String text, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'text',
        lower: [],
        upper: [text],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> textBetween(
    String lowerText,
    String upperText, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'text',
        lower: [lowerText],
        includeLower: includeLower,
        upper: [upperText],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> textStartsWith(
      String TextPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'text',
        lower: [TextPrefix],
        upper: ['$TextPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'text',
        value: [''],
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterWhereClause> textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'text',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'text',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'text',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'text',
              upper: [''],
            ));
      }
    });
  }
}

extension BibleVerseQueryFilter
    on QueryBuilder<BibleVerse, BibleVerse, QFilterCondition> {
  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      bibleVersionIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bibleVersionId',
        value: value,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      bibleVersionIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bibleVersionId',
        value: value,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      bibleVersionIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bibleVersionId',
        value: value,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      bibleVersionIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bibleVersionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> bookNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      bookNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> bookNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> bookNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      bookNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bookName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> bookNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bookName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> bookNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bookName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> bookNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bookName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      bookNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookName',
        value: '',
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      bookNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bookName',
        value: '',
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      chapterNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      chapterNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      chapterNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      chapterNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'text',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> textContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> textMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'text',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition> textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      verseNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verseNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      verseNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'verseNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      verseNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'verseNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterFilterCondition>
      verseNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'verseNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BibleVerseQueryObject
    on QueryBuilder<BibleVerse, BibleVerse, QFilterCondition> {}

extension BibleVerseQueryLinks
    on QueryBuilder<BibleVerse, BibleVerse, QFilterCondition> {}

extension BibleVerseQuerySortBy
    on QueryBuilder<BibleVerse, BibleVerse, QSortBy> {
  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> sortByBibleVersionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bibleVersionId', Sort.asc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy>
      sortByBibleVersionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bibleVersionId', Sort.desc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> sortByBookName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookName', Sort.asc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> sortByBookNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookName', Sort.desc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> sortByChapterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.asc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> sortByChapterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.desc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> sortByVerseNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verseNumber', Sort.asc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> sortByVerseNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verseNumber', Sort.desc);
    });
  }
}

extension BibleVerseQuerySortThenBy
    on QueryBuilder<BibleVerse, BibleVerse, QSortThenBy> {
  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> thenByBibleVersionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bibleVersionId', Sort.asc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy>
      thenByBibleVersionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bibleVersionId', Sort.desc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> thenByBookName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookName', Sort.asc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> thenByBookNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookName', Sort.desc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> thenByChapterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.asc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> thenByChapterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterNumber', Sort.desc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> thenByVerseNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verseNumber', Sort.asc);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QAfterSortBy> thenByVerseNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verseNumber', Sort.desc);
    });
  }
}

extension BibleVerseQueryWhereDistinct
    on QueryBuilder<BibleVerse, BibleVerse, QDistinct> {
  QueryBuilder<BibleVerse, BibleVerse, QDistinct> distinctByBibleVersionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bibleVersionId');
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QDistinct> distinctByBookName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QDistinct> distinctByChapterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterNumber');
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QDistinct> distinctByText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BibleVerse, BibleVerse, QDistinct> distinctByVerseNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verseNumber');
    });
  }
}

extension BibleVerseQueryProperty
    on QueryBuilder<BibleVerse, BibleVerse, QQueryProperty> {
  QueryBuilder<BibleVerse, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BibleVerse, int, QQueryOperations> bibleVersionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bibleVersionId');
    });
  }

  QueryBuilder<BibleVerse, String, QQueryOperations> bookNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookName');
    });
  }

  QueryBuilder<BibleVerse, int, QQueryOperations> chapterNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterNumber');
    });
  }

  QueryBuilder<BibleVerse, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<BibleVerse, int, QQueryOperations> verseNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verseNumber');
    });
  }
}
