import 'package:flutter_test/flutter_test.dart';
import 'package:keryxpro/features/settings/data/presentation_settings.dart';
import 'package:keryxpro/features/live_controller/presentation/slide_utils.dart';
import 'package:keryxpro/features/bible/domain/bible_constants.dart';

void main() {
  group('Phase 58 Chapter Display Options Tests', () {
    test('PresentationSettings default chapter options', () {
      final settings = PresentationSettings();
      expect(settings.chapterShowActual, isTrue);
      expect(settings.chapterShowAlias, isFalse);
      expect(settings.chapterShowNone, isFalse);
      expect(settings.showChapter, isTrue);

      expect(settings.dualChapterShowActual, isTrue);
      expect(settings.dualChapterShowAlias, isFalse);
      expect(settings.dualChapterShowNone, isFalse);
      expect(settings.showDualChapter, isTrue);
    });

    test('PresentationSettings showChapter setter toggles None and Actual correctly', () {
      final settings = PresentationSettings();
      settings.showChapter = false;
      expect(settings.chapterShowNone, isTrue);
      expect(settings.chapterShowActual, isFalse);
      expect(settings.chapterShowAlias, isFalse);

      settings.showChapter = true;
      expect(settings.chapterShowNone, isFalse);
      expect(settings.chapterShowActual, isTrue);
    });

    test('toMap and fromMap serialization of 6 chapter options', () {
      final settings = PresentationSettings()
        ..chapterShowActual = true
        ..chapterShowAlias = true
        ..chapterShowNone = false
        ..dualChapterShowActual = false
        ..dualChapterShowAlias = true
        ..dualChapterShowNone = false;

      final map = settings.toMap();
      expect(map['chapterShowActual'], isTrue);
      expect(map['chapterShowAlias'], isTrue);
      expect(map['chapterShowNone'], isFalse);
      expect(map['dualChapterShowActual'], isFalse);
      expect(map['dualChapterShowAlias'], isTrue);
      expect(map['dualChapterShowNone'], isFalse);

      final restored = PresentationSettings.fromMap(map);
      expect(restored.chapterShowActual, isTrue);
      expect(restored.chapterShowAlias, isTrue);
      expect(restored.chapterShowNone, isFalse);
      expect(restored.dualChapterShowActual, isFalse);
      expect(restored.dualChapterShowAlias, isTrue);
      expect(restored.dualChapterShowNone, isFalse);
    });

    test('fromMap backward compatibility for legacy showChapter boolean', () {
      final legacyMap = <String, dynamic>{
        'showChapter': false,
        'showDualChapter': true,
      };

      final restored = PresentationSettings.fromMap(legacyMap);
      expect(restored.chapterShowNone, isTrue);
      expect(restored.chapterShowActual, isFalse);

      expect(restored.dualChapterShowNone, isFalse);
      expect(restored.dualChapterShowActual, isTrue);
    });

    test('SlideUtils._computeDisplayTitle formats titles with alias correctly', () {
      final computedVerse = SlideUtils.parseLyrics(
        'In the beginning...',
        'John 3:16 KJV',
        isSong: false,
        bookAlias: 'యోహాను',
      ).first;
      expect(computedVerse.title, equals('John 3:16 KJV'));
      expect(computedVerse.displayTitle, equals('యోహాను 3:16 KJV'));

      final computedChapterOnly = SlideUtils.parseLyrics(
        'In the beginning...',
        'John 3',
        isSong: false,
        bookAlias: 'యోహాను',
      ).first;
      expect(computedChapterOnly.title, equals('John 3'));
      expect(computedChapterOnly.displayTitle, equals('యోహాను 3'));
    });

    test('BibleConstants.defaultBookAliases contains standard book mappings', () {
      final genAlias = BibleConstants.defaultBookAliases['Genesis'];
      expect(genAlias, equals('ఆదికాండము'));

      final johnAlias = BibleConstants.defaultBookAliases['John'];
      expect(johnAlias, equals('యోహాను'));

      final normalizedTelugu = BibleConstants.normalizeBookName('యోహాను');
      expect(normalizedTelugu, equals('John'));
    });
  });
}
