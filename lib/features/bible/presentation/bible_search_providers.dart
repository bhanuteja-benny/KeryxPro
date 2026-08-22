import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../main.dart';
import '../data/bible.dart';
import '../domain/bible_constants.dart';

final selectedBibleVersionProvider = StateProvider<BibleVersion?>((ref) => null);
final secondaryBibleVersionProvider = StateProvider<BibleVersion?>((ref) => null);
final isDualVersionModeProvider = StateProvider<bool>((ref) => false);
final selectedBookProvider = StateProvider<String?>((ref) => null);
final selectedChapterProvider = StateProvider<int?>((ref) => null);
final selectedVersesProvider = StateProvider<Set<int>>((ref) => {});
final secondarySelectedVersesProvider = StateProvider<Set<int>>((ref) => {});

/// Fetches the available chapters for the selected book and version.
final availableChaptersProvider = FutureProvider<List<int>>((ref) async {
  final version = ref.watch(selectedBibleVersionProvider);
  final book = ref.watch(selectedBookProvider);
  
  if (version == null || book == null) return [];

  final chapterCount = BibleConstants.getChapterCount(book);
  if (chapterCount > 0) {
    return List.generate(chapterCount, (i) => i + 1);
  }
  
  return [];
});

/// Fetches the available verses for the selected chapter, book, and version(s).
final availableVersesProvider = FutureProvider<List<int>>((ref) async {
  final version = ref.watch(selectedBibleVersionProvider);
  final book = ref.watch(selectedBookProvider);
  final chapter = ref.watch(selectedChapterProvider);
  final isDual = ref.watch(isDualVersionModeProvider);
  final secondaryVersion = ref.watch(secondaryBibleVersionProvider);
  
  if (version == null || book == null || chapter == null) return [];

  final isar = await ref.read(isarServiceProvider).db;
  
  final verses = await isar.bibleVerses
      .filter()
      .bibleVersionIdEqualTo(version.id)
      .bookNameEqualTo(book)
      .chapterNumberEqualTo(chapter)
      .verseNumberProperty()
      .findAll();
      
  final uniqueVerses = verses.toSet();

  if (isDual && secondaryVersion != null && secondaryVersion.id != version.id) {
    final secondaryVerses = await isar.bibleVerses
        .filter()
        .bibleVersionIdEqualTo(secondaryVersion.id)
        .bookNameEqualTo(book)
        .chapterNumberEqualTo(chapter)
        .verseNumberProperty()
        .findAll();
    uniqueVerses.addAll(secondaryVerses);
  }

  final result = uniqueVerses.toList()..sort();
  return result;
});

/// Fetches the actual verse text for the selected verses to show in the preview.
final biblePreviewVersesProvider = FutureProvider<List<BibleVerse>>((ref) async {
  final version = ref.watch(selectedBibleVersionProvider);
  final book = ref.watch(selectedBookProvider);
  final chapter = ref.watch(selectedChapterProvider);
  final verses = ref.watch(selectedVersesProvider);
  
  if (version == null || book == null || chapter == null || verses.isEmpty) return [];

  final isar = await ref.read(isarServiceProvider).db;
  
  final result = await isar.bibleVerses
      .filter()
      .bibleVersionIdEqualTo(version.id)
      .bookNameEqualTo(book)
      .chapterNumberEqualTo(chapter)
      .anyOf(verses.toList(), (q, int v) => q.verseNumberEqualTo(v))
      .sortByVerseNumber()
      .findAll();
      
  return result;
});

final bibleVersesForSelectionProvider = FutureProvider.family<
    List<BibleVerse>,
    ({int versionId, String book, int chapter, Set<int> verses})>((ref, selection) async {
  if (selection.verses.isEmpty) return [];

  final isar = await ref.read(isarServiceProvider).db;

  return isar.bibleVerses
      .filter()
      .bibleVersionIdEqualTo(selection.versionId)
      .bookNameEqualTo(selection.book)
      .chapterNumberEqualTo(selection.chapter)
      .anyOf(selection.verses.toList(), (q, int verse) => q.verseNumberEqualTo(verse))
      .sortByVerseNumber()
      .findAll();
});

/// Fetches all verses of the currently selected chapter, book, and version sorted by verseNumber.
final chapterAllVersesProvider = FutureProvider<List<BibleVerse>>((ref) async {
  final version = ref.watch(selectedBibleVersionProvider);
  final book = ref.watch(selectedBookProvider);
  final chapter = ref.watch(selectedChapterProvider);
  
  if (version == null || book == null || chapter == null) return [];

  final isar = await ref.read(isarServiceProvider).db;
  
  return isar.bibleVerses
      .filter()
      .bibleVersionIdEqualTo(version.id)
      .bookNameEqualTo(book)
      .chapterNumberEqualTo(chapter)
      .sortByVerseNumber()
      .findAll();
});

/// Fetches all verses of a specified chapter, book, and version ID sorted by verseNumber.
final chapterAllVersesForVersionProvider = FutureProvider.family<
    List<BibleVerse>,
    ({int versionId, String book, int chapter})>((ref, args) async {
  final isar = await ref.read(isarServiceProvider).db;
  
  return isar.bibleVerses
      .filter()
      .bibleVersionIdEqualTo(args.versionId)
      .bookNameEqualTo(args.book)
      .chapterNumberEqualTo(args.chapter)
      .sortByVerseNumber()
      .findAll();
});
