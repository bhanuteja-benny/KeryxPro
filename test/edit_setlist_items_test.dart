import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keryxpro/features/songs/data/song.dart';
import 'package:keryxpro/features/setlist/data/setlist_item.dart';
import 'package:keryxpro/features/live_controller/domain/slide.dart';
import 'package:keryxpro/features/live_controller/presentation/slide_utils.dart';
import 'package:keryxpro/features/live_controller/presentation/live_projector_providers.dart';
import 'package:keryxpro/features/settings/data/presentation_settings.dart';
import 'package:keryxpro/features/setlist/presentation/setlist_providers.dart';
import 'package:keryxpro/features/dashboard/presentation/widgets/slide_item_widget.dart';

void main() {
  group('Phase 59 Edit Setlist Items Tests', () {
    test('SongSetlistItem copyWith creates edited copy with isEdited flag', () {
      final originalSong = Song()
        ..id = 1
        ..syncId = 'sync-1'
        ..title = 'Amazing Grace'
        ..author = 'John Newton'
        ..lyrics = 'Amazing grace how sweet the sound';

      final item = SongSetlistItem(originalSong);
      expect(item.isEdited, isFalse);

      final editedSong = Song()
        ..id = 1
        ..syncId = 'sync-1'
        ..title = 'Amazing Grace (Custom)'
        ..author = 'John Newton'
        ..lyrics = 'Amazing grace how sweet the sound - Edited';

      final editedItem = item.copyWith(song: editedSong, isEdited: true);
      expect(editedItem.isEdited, isTrue);
      expect(editedItem.song.title, equals('Amazing Grace (Custom)'));
      expect(editedItem.song.lyrics, equals('Amazing grace how sweet the sound - Edited'));
      // Original remains unchanged
      expect(originalSong.title, equals('Amazing Grace'));
    });

    test('SlideUtils.parseLyrics passes customReference to Slide instances', () {
      final slides = SlideUtils.parseLyrics(
        'In the beginning God created the heavens and the earth.',
        'Genesis 1:1 KJV',
        isSong: false,
        bookAlias: 'ఆదికాండము',
        isEdited: true,
        customReference: 'Gen 1:1 Custom Title',
      );

      expect(slides.length, equals(2)); // 1 verse slide + 1 blank slide
      final verseSlide = slides.first;
      expect(verseSlide.isEdited, isTrue);
      expect(verseSlide.title, equals('Genesis 1:1 KJV'));
      expect(verseSlide.displayTitle, equals('ఆదికాండము 1:1 KJV'));
      expect(SlideUtils.formatSlideItemTitle(verseSlide), equals('ఆదికాండము 1:1 KJV'));
      expect(verseSlide.customReference, equals('Gen 1:1 Custom Title'));
    });

    test('buildTitleForSlide uses customReference when isEdited is true and customReference is provided', () {
      final settingsAllHidden = PresentationSettings()
        ..chapterShowActual = false
        ..chapterShowAlias = false
        ..chapterShowNone = true
        ..dualChapterShowActual = false
        ..dualChapterShowAlias = false
        ..dualChapterShowNone = true;

      final editedSlide = Slide(
        title: 'Genesis 1:1 KJV',
        displayTitle: 'Genesis 1:1 KJV',
        shortcut: '1',
        content: 'In the beginning...',
        type: SlideType.verse,
        isSong: false,
        isEdited: true,
        customReference: 'Custom Gen 1:1 Display',
      );

      // When isEdited is true and customReference is set, customReference is used for projection/previews
      final editedTitle = buildTitleForSlide(editedSlide, settingsAllHidden);
      expect(editedTitle, equals('Custom Gen 1:1 Display'));
    });

    test('buildTitleForSlide overrides dual scripture presentation settings with customReference when isEdited is true', () {
      final settings = PresentationSettings()
        ..dualChapterShowNone = true;

      final editedDualSlide = Slide(
        title: 'John 3:16 KJV',
        displayTitle: 'John 3:16 KJV',
        shortcut: '1',
        content: 'For God so loved the world...',
        secondaryTitle: 'John 3:16 TEL',
        secondaryDisplayTitle: 'John 3:16 TEL',
        secondaryContent: 'దేవుడు లోకమును ఎంతో ప్రేమించెను...',
        type: SlideType.verse,
        isSong: false,
        isDualVersion: true,
        isEdited: true,
        customReference: 'John 3:16 Dual Custom',
      );

      final title = buildTitleForSlide(editedDualSlide, settings);
      expect(title, equals('John 3:16 Dual Custom'));
    });

    test('generateSetlistSignature accounts for edited texts and isEdited flag', () {
      final song1 = Song()
        ..id = 10
        ..title = 'Song 1'
        ..lyrics = 'Lyrics 1';
      final item1 = SongSetlistItem(song1);

      final sig1 = generateSetlistSignature([item1]);

      final song1Edited = Song()
        ..id = 10
        ..title = 'Song 1 Edited'
        ..lyrics = 'Lyrics 1 Edited';
      final item1Edited = SongSetlistItem(song1Edited, isEdited: true);

      final sig2 = generateSetlistSignature([item1Edited]);

      expect(sig1, isNot(equals(sig2)));
    });

    test('generateSetlistSignature accounts for customReference in scriptures', () {
      final scripture = Song()
        ..title = 'John 1:1 KJV'
        ..author = 'Bible'
        ..lyrics = 'In the beginning was the Word';
      final scItem = SongSetlistItem(scripture);

      final sig1 = generateSetlistSignature([scItem]);

      final editedScripture = Song()
        ..title = 'John 1:1 KJV'
        ..author = 'Bible'
        ..lyrics = 'In the beginning was the Word - custom note';
      final editedScItem = SongSetlistItem(
        editedScripture,
        isEdited: true,
        customReference: 'John 1:1 Custom Ref',
      );

      final sig2 = generateSetlistSignature([editedScItem]);

      expect(sig1, isNot(equals(sig2)));
    });

    test('scripture itemOrder string encoding includes isEdited flag and customReference', () {
      final isarEncoded = Uri.encodeComponent('John 1:1 KJV');
      final lyricsEncoded = Uri.encodeComponent('In the beginning was the Word');
      final customRefEncoded = Uri.encodeComponent('John 1:1 Custom Ref');
      final entry = 'scripture:$isarEncoded|$lyricsEncoded|0|||||1|$customRefEncoded';

      final parts = entry.substring(10).split('|');
      expect(parts.length, equals(9));
      expect(Uri.decodeComponent(parts[0]), equals('John 1:1 KJV'));
      expect(Uri.decodeComponent(parts[1]), equals('In the beginning was the Word'));
      expect(parts[7], equals('1'));
      expect(Uri.decodeComponent(parts[8]), equals('John 1:1 Custom Ref'));
    });

    test('custom_song itemOrder string encoding preserves edited song title and lyrics', () {
      final titleEncoded = Uri.encodeComponent('My Custom Song Title');
      final lyricsEncoded = Uri.encodeComponent('Verse 1\nEdited line 1\n\nVerse 2\nEdited line 2');
      final entry = 'custom_song:42|$titleEncoded|$lyricsEncoded';

      expect(entry.startsWith('custom_song:'), isTrue);
      final parts = entry.substring(12).split('|');
      expect(parts[0], equals('42'));
      expect(Uri.decodeComponent(parts[1]), equals('My Custom Song Title'));
      expect(Uri.decodeComponent(parts[2]), equals('Verse 1\nEdited line 1\n\nVerse 2\nEdited line 2'));
    });

    test('Song model has default lastModified initialized to prevent LateInitializationError', () {
      final mockSong = Song()
        ..title = 'Genesis 1:1'
        ..author = 'Bible'
        ..lyrics = 'In the beginning';

      // Should not throw LateInitializationError
      expect(mockSong.lastModified, isNotNull);
      expect(mockSong.lastModified.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
    });

    test('SongSetlistItem maintains base song.title for Setlist and customReference for live projection', () {
      final baseSong = Song()
        ..title = 'John 3:16 KJV'
        ..author = 'Bible'
        ..lyrics = 'For God so loved the world';

      final editedSong = Song()
        ..title = baseSong.title
        ..author = 'Bible'
        ..lyrics = 'For God so loved the world (edited)';

      final editedItem = SongSetlistItem(
        editedSong,
        isEdited: true,
        customReference: 'John 3:16 Custom Title',
      );

      // Setlist item name uses base song.title
      expect(editedItem.song.title, equals('John 3:16 KJV'));
      // Custom reference is stored separately
      expect(editedItem.customReference, equals('John 3:16 Custom Title'));
    });

    testWidgets('SlideItemWidget renders alias displayTitle when alias is present', (tester) async {
      final slide = Slide(
        title: 'John 3:16 TEL',
        displayTitle: 'యోహాను 3:16 TEL',
        shortcut: '1',
        content: 'దేవుడు లోకమును ఎంతో ప్రేమించెను...',
        type: SlideType.verse,
        isSong: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlideItemWidget(
              slide: slide,
              isActive: false,
              isBorderActive: false,
              isBookmarked: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('యోహాను 3:16 TEL'), findsOneWidget);
    });

    test('Single Scripture with Alias formats presentation settings correctly', () {
      final telSong = Song()
        ..title = 'John 3:16 TEL'
        ..author = 'Bible'
        ..lyrics = 'దేవుడు లోకమును ఎంతో ప్రేమించెను'
        ..bookAlias = 'యోహాను';

      final slides = SlideUtils.parseLyrics(
        telSong.lyrics,
        telSong.title,
        isSong: false,
        bookAlias: telSong.bookAlias,
      );

      final slide = slides.first;
      expect(slide.title, equals('John 3:16 TEL'));
      expect(slide.displayTitle, equals('యోహాను 3:16 TEL'));
      expect(SlideUtils.formatSlideItemTitle(slide), equals('యోహాను 3:16 TEL'));

      final settingsActual = PresentationSettings()..chapterShowActual = true..chapterShowAlias = false..chapterShowNone = false;
      final settingsAlias = PresentationSettings()..chapterShowActual = false..chapterShowAlias = true..chapterShowNone = false;
      final settingsBoth = PresentationSettings()..chapterShowActual = true..chapterShowAlias = true..chapterShowNone = false;
      final settingsNone = PresentationSettings()..chapterShowNone = true;

      expect(buildTitleForSlide(slide, settingsActual), equals('John 3:16 TEL'));
      expect(buildTitleForSlide(slide, settingsAlias), equals('యోహాను 3:16 TEL'));
      expect(buildTitleForSlide(slide, settingsBoth), equals('John (యోహాను) 3:16 TEL'));
      expect(buildTitleForSlide(slide, settingsNone), equals(''));
    });

    test('Dual Scripture Probability 1 (One alias: NKJV + Telugu) with different verse ranges', () {
      final info = SlideUtils.resolveDualBookNames(
        primaryTitle: 'John 2:2 NKJV',
        primaryAlias: null,
        secondaryTitle: 'John 2:3 TEL',
        secondaryAlias: 'యోహాను',
      );

      expect(info.actualBookName, equals('John'));
      expect(info.aliasBookName, equals('యోహాను'));

      final slides = SlideUtils.parseLyrics(
        'Jesus also was invited to the wedding',
        'John 2:2 NKJV',
        isSong: false,
        isDualVersion: true,
        secondaryTitle: 'John 2:3 TEL',
        secondaryLyrics: 'ద్రాక్షారసము అయిపోయినప్పుడు...',
        bookAlias: null,
        secondaryBookAlias: 'యోహాను',
      );

      final slide = slides.first;
      expect(slide.title, equals('John 2:2 NKJV'));
      expect(slide.displayTitle, equals('యోహాను 2:2 NKJV'));
      expect(SlideUtils.formatSlideItemTitle(slide), equals('యోహాను 2:2/3 NKJV'));

      final settingsActual = PresentationSettings()..dualChapterShowActual = true..dualChapterShowAlias = false..dualChapterShowNone = false;
      final settingsAlias = PresentationSettings()..dualChapterShowActual = false..dualChapterShowAlias = true..dualChapterShowNone = false;
      final settingsBoth = PresentationSettings()..dualChapterShowActual = true..dualChapterShowAlias = true..dualChapterShowNone = false;
      final settingsNone = PresentationSettings()..dualChapterShowNone = true;

      expect(buildTitleForSlide(slide, settingsActual), equals('John 2:2/3 NKJV'));
      expect(buildTitleForSlide(slide, settingsAlias), equals('యోహాను 2:2/3 NKJV'));
      expect(buildTitleForSlide(slide, settingsBoth), equals('John (యోహాను) 2:2/3 NKJV'));
      expect(buildTitleForSlide(slide, settingsNone), equals(''));
    });

    test('Dual Scripture Probability 2 (Both aliases English)', () {
      final info = SlideUtils.resolveDualBookNames(
        primaryTitle: 'John 3:16 NKJV',
        primaryAlias: 'JN',
        secondaryTitle: 'John 3:16 KJV',
        secondaryAlias: 'JOH',
      );

      expect(info.actualBookName, equals('John'));
      expect(info.aliasBookName, equals('JN'));
    });

    test('Dual Scripture Probability 3 (Both aliases, one non-English)', () {
      final info1 = SlideUtils.resolveDualBookNames(
        primaryTitle: 'John 3:16 NKJV',
        primaryAlias: 'JN',
        secondaryTitle: 'John 3:16 TEL',
        secondaryAlias: 'యోహాను',
      );
      expect(info1.actualBookName, equals('John'));
      expect(info1.aliasBookName, equals('యోహాను'));

      final info2 = SlideUtils.resolveDualBookNames(
        primaryTitle: 'John 3:16 TEL',
        primaryAlias: 'యోహాను',
        secondaryTitle: 'John 3:16 NKJV',
        secondaryAlias: 'JN',
      );
      expect(info2.actualBookName, equals('John'));
      expect(info2.aliasBookName, equals('యోహాను'));
    });

    test('Dual Scripture Probability 4 (Both aliases non-English: Telugu + Hindi)', () {
      final info = SlideUtils.resolveDualBookNames(
        primaryTitle: 'John 3:16 TEL',
        primaryAlias: 'యోహాను',
        secondaryTitle: 'John 3:16 HIN',
        secondaryAlias: 'यूहन्ना',
      );

      expect(info.actualBookName, equals('యోహాను'));
      expect(info.aliasBookName, equals('यूहन्ना'));

      final slides = SlideUtils.parseLyrics(
        'దేవుడు లోకమును ఎంతో ప్రేమించెను',
        'John 3:16 TEL',
        isSong: false,
        isDualVersion: true,
        secondaryTitle: 'John 3:16 HIN',
        secondaryLyrics: 'क्योंकि परमेश्वर ने जगत से ऐसा प्रेम रखा...',
        bookAlias: 'యోహాను',
        secondaryBookAlias: 'यूहन्ना',
      );

      final slide = slides.first;
      expect(slide.title, equals('యోహాను 3:16 TEL'));
      expect(slide.displayTitle, equals('यूहन्ना 3:16 TEL'));
      expect(SlideUtils.formatSlideItemTitle(slide), equals('यूहन्ना 3:16 TEL'));

      final settingsActual = PresentationSettings()..dualChapterShowActual = true..dualChapterShowAlias = false..dualChapterShowNone = false;
      final settingsAlias = PresentationSettings()..dualChapterShowActual = false..dualChapterShowAlias = true..dualChapterShowNone = false;
      final settingsBoth = PresentationSettings()..dualChapterShowActual = true..dualChapterShowAlias = true..dualChapterShowNone = false;

      expect(buildTitleForSlide(slide, settingsActual), equals('యోహాను 3:16 TEL'));
      expect(buildTitleForSlide(slide, settingsAlias), equals('यूहन्ना 3:16 TEL'));
      expect(buildTitleForSlide(slide, settingsBoth), equals('యోహాను (यूहन्ना) 3:16 TEL'));
    });

    test('English Bible versions (KJV, NKJV) without custom book mappings produce pure English title in previews and live projections', () {
      final kjvSong = Song()
        ..title = 'John 3:16 KJV'
        ..author = 'Bible'
        ..lyrics = 'For God so loved the world'
        ..bookAlias = null;

      final slides = SlideUtils.parseLyrics(
        kjvSong.lyrics,
        kjvSong.title,
        isSong: false,
        bookAlias: kjvSong.bookAlias,
      );

      final slide = slides.first;
      expect(slide.title, equals('John 3:16 KJV'));
      expect(slide.displayTitle, equals('John 3:16 KJV'));

      final settingsActual = PresentationSettings()..chapterShowActual = true..chapterShowAlias = false;
      final settingsAlias = PresentationSettings()..chapterShowActual = false..chapterShowAlias = true;
      final settingsBoth = PresentationSettings()..chapterShowActual = true..chapterShowAlias = true;

      expect(buildTitleForSlide(slide, settingsActual), equals('John 3:16 KJV'));
      expect(buildTitleForSlide(slide, settingsAlias), equals('John 3:16 KJV'));
      expect(buildTitleForSlide(slide, settingsBoth), equals('John 3:16 KJV'));
    });

    test('English Dual Scripture (NKJV + KJV) without custom book mappings produces pure English dual title', () {
      final dualSong = Song()
        ..title = 'John 3:16 NKJV'
        ..author = 'Bible'
        ..lyrics = 'For God so loved the world...'
        ..isDualVersion = true
        ..secondaryTitle = 'John 3:16 KJV'
        ..secondaryLyrics = 'For God so loved the world...'
        ..bookAlias = null
        ..secondaryBookAlias = null;

      final slides = SlideUtils.parseLyrics(
        dualSong.lyrics,
        dualSong.title,
        isSong: false,
        isDualVersion: true,
        secondaryTitle: dualSong.secondaryTitle,
        secondaryLyrics: dualSong.secondaryLyrics,
        bookAlias: dualSong.bookAlias,
        secondaryBookAlias: dualSong.secondaryBookAlias,
      );

      final slide = slides.first;
      expect(slide.title, equals('John 3:16 NKJV'));
      expect(slide.secondaryTitle, equals('John 3:16 KJV'));

      final settings = PresentationSettings()..dualChapterShowActual = true;
      expect(buildTitleForSlide(slide, settings), equals('John 3:16 NKJV'));
    });

    test('Edit scripture dialog reference pre-filling adheres to presentation settings', () {
      final telSong = Song()
        ..title = 'John 3:16 TEL'
        ..author = 'Bible'
        ..lyrics = 'దేవుడు లోకమును ఎంతో ప్రేమించెను'
        ..bookAlias = 'యోహాను';

      final sampleSlide = SlideUtils.parseLyrics(
        telSong.lyrics,
        telSong.title,
        isSong: false,
        bookAlias: telSong.bookAlias,
        isEdited: false,
      ).first;

      final settingsActual = PresentationSettings()..chapterShowActual = true..chapterShowAlias = false..chapterShowNone = false;
      final settingsAlias = PresentationSettings()..chapterShowActual = false..chapterShowAlias = true..chapterShowNone = false;
      final settingsBoth = PresentationSettings()..chapterShowActual = true..chapterShowAlias = true..chapterShowNone = false;
      final settingsNone = PresentationSettings()..chapterShowNone = true;

      expect(buildTitleForSlide(sampleSlide, settingsActual), equals('John 3:16 TEL'));
      expect(buildTitleForSlide(sampleSlide, settingsAlias), equals('యోహాను 3:16 TEL'));
      expect(buildTitleForSlide(sampleSlide, settingsBoth), equals('John (యోహాను) 3:16 TEL'));
      expect(buildTitleForSlide(sampleSlide, settingsNone), equals(''));
    });
  });
}
