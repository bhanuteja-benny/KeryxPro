// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_setlist.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSavedSetlistCollection on Isar {
  IsarCollection<SavedSetlist> get savedSetlists => this.collection();
}

const SavedSetlistSchema = CollectionSchema(
  name: r'SavedSetlist',
  id: -1741556442742670559,
  properties: {
    r'favorites': PropertySchema(
      id: 0,
      name: r'favorites',
      type: IsarType.boolList,
    ),
    r'imageEntries': PropertySchema(
      id: 1,
      name: r'imageEntries',
      type: IsarType.stringList,
    ),
    r'itemOrder': PropertySchema(
      id: 2,
      name: r'itemOrder',
      type: IsarType.stringList,
    ),
    r'lastModified': PropertySchema(
      id: 3,
      name: r'lastModified',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'songIds': PropertySchema(
      id: 5,
      name: r'songIds',
      type: IsarType.longList,
    )
  },
  estimateSize: _savedSetlistEstimateSize,
  serialize: _savedSetlistSerialize,
  deserialize: _savedSetlistDeserialize,
  deserializeProp: _savedSetlistDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _savedSetlistGetId,
  getLinks: _savedSetlistGetLinks,
  attach: _savedSetlistAttach,
  version: '3.1.0+1',
);

int _savedSetlistEstimateSize(
  SavedSetlist object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.favorites.length;
  bytesCount += 3 + object.imageEntries.length * 3;
  {
    for (var i = 0; i < object.imageEntries.length; i++) {
      final value = object.imageEntries[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.itemOrder.length * 3;
  {
    for (var i = 0; i < object.itemOrder.length; i++) {
      final value = object.itemOrder[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.songIds.length * 8;
  return bytesCount;
}

void _savedSetlistSerialize(
  SavedSetlist object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBoolList(offsets[0], object.favorites);
  writer.writeStringList(offsets[1], object.imageEntries);
  writer.writeStringList(offsets[2], object.itemOrder);
  writer.writeDateTime(offsets[3], object.lastModified);
  writer.writeString(offsets[4], object.name);
  writer.writeLongList(offsets[5], object.songIds);
}

SavedSetlist _savedSetlistDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SavedSetlist();
  object.favorites = reader.readBoolList(offsets[0]) ?? [];
  object.id = id;
  object.imageEntries = reader.readStringList(offsets[1]) ?? [];
  object.itemOrder = reader.readStringList(offsets[2]) ?? [];
  object.lastModified = reader.readDateTime(offsets[3]);
  object.name = reader.readString(offsets[4]);
  object.songIds = reader.readLongList(offsets[5]) ?? [];
  return object;
}

P _savedSetlistDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolList(offset) ?? []) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLongList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _savedSetlistGetId(SavedSetlist object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _savedSetlistGetLinks(SavedSetlist object) {
  return [];
}

void _savedSetlistAttach(
    IsarCollection<dynamic> col, Id id, SavedSetlist object) {
  object.id = id;
}

extension SavedSetlistByIndex on IsarCollection<SavedSetlist> {
  Future<SavedSetlist?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  SavedSetlist? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<SavedSetlist?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<SavedSetlist?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(SavedSetlist object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(SavedSetlist object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<SavedSetlist> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<SavedSetlist> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension SavedSetlistQueryWhereSort
    on QueryBuilder<SavedSetlist, SavedSetlist, QWhere> {
  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhere> anyName() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'name'),
      );
    });
  }
}

extension SavedSetlistQueryWhere
    on QueryBuilder<SavedSetlist, SavedSetlist, QWhereClause> {
  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> idBetween(
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> nameGreaterThan(
    String name, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [name],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> nameLessThan(
    String name, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [],
        upper: [name],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> nameBetween(
    String lowerName,
    String upperName, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [lowerName],
        includeLower: includeLower,
        upper: [upperName],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> nameStartsWith(
      String NamePrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'name',
        lower: [NamePrefix],
        upper: ['$NamePrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [''],
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterWhereClause> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'name',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'name',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'name',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'name',
              upper: [''],
            ));
      }
    });
  }
}

extension SavedSetlistQueryFilter
    on QueryBuilder<SavedSetlist, SavedSetlist, QFilterCondition> {
  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      favoritesElementEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'favorites',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      favoritesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favorites',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      favoritesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favorites',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      favoritesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favorites',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      favoritesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favorites',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      favoritesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favorites',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      favoritesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favorites',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageEntries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageEntries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageEntries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageEntries',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageEntries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageEntries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageEntries',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageEntries',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageEntries',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageEntries',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageEntries',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageEntries',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageEntries',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageEntries',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageEntries',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      imageEntriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imageEntries',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemOrder',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemOrder',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemOrder',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemOrder',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemOrder',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemOrder',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      itemOrderLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemOrder',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      lastModifiedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastModified',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      lastModifiedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastModified',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      lastModifiedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastModified',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      lastModifiedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastModified',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition> nameContains(
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      songIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songIds',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      songIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'songIds',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      songIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'songIds',
        value: value,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      songIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'songIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      songIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      songIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      songIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      songIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      songIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterFilterCondition>
      songIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'songIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension SavedSetlistQueryObject
    on QueryBuilder<SavedSetlist, SavedSetlist, QFilterCondition> {}

extension SavedSetlistQueryLinks
    on QueryBuilder<SavedSetlist, SavedSetlist, QFilterCondition> {}

extension SavedSetlistQuerySortBy
    on QueryBuilder<SavedSetlist, SavedSetlist, QSortBy> {
  QueryBuilder<SavedSetlist, SavedSetlist, QAfterSortBy> sortByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.asc);
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterSortBy>
      sortByLastModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.desc);
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension SavedSetlistQuerySortThenBy
    on QueryBuilder<SavedSetlist, SavedSetlist, QSortThenBy> {
  QueryBuilder<SavedSetlist, SavedSetlist, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterSortBy> thenByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.asc);
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterSortBy>
      thenByLastModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.desc);
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension SavedSetlistQueryWhereDistinct
    on QueryBuilder<SavedSetlist, SavedSetlist, QDistinct> {
  QueryBuilder<SavedSetlist, SavedSetlist, QDistinct> distinctByFavorites() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'favorites');
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QDistinct> distinctByImageEntries() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageEntries');
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QDistinct> distinctByItemOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemOrder');
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QDistinct> distinctByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastModified');
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedSetlist, SavedSetlist, QDistinct> distinctBySongIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songIds');
    });
  }
}

extension SavedSetlistQueryProperty
    on QueryBuilder<SavedSetlist, SavedSetlist, QQueryProperty> {
  QueryBuilder<SavedSetlist, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SavedSetlist, List<bool>, QQueryOperations> favoritesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'favorites');
    });
  }

  QueryBuilder<SavedSetlist, List<String>, QQueryOperations>
      imageEntriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageEntries');
    });
  }

  QueryBuilder<SavedSetlist, List<String>, QQueryOperations>
      itemOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemOrder');
    });
  }

  QueryBuilder<SavedSetlist, DateTime, QQueryOperations>
      lastModifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModified');
    });
  }

  QueryBuilder<SavedSetlist, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<SavedSetlist, List<int>, QQueryOperations> songIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songIds');
    });
  }
}
