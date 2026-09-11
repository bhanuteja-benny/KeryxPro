import 'package:flutter_test/flutter_test.dart';
import 'package:keryxpro/features/songs/data/song.dart';
import 'package:keryxpro/features/setlist/data/setlist_item.dart';
import 'package:keryxpro/features/live_controller/presentation/slide_utils.dart';

void main() {
  group('Dual Scripture Tests', () {
    test('SlideUtils.parseLyrics pairs primary and secondary verses for dual scripture', () {
      const primaryTitle = 'Genesis 1:1-2 NIV';
      const secondaryTitle = 'Genesis 1:1-2 TEL';

      const primaryLyrics = '''
[1]
1 In the beginning God created the heavens and the earth.

[2]
2 Now the earth was formless and empty.
''';

      const secondaryLyrics = '''
[1]
1 ఆదియందు దేవుడు భూమ్యాకాశములను సృజించెను.

[2]
2 భూమి నిరాకారముగాను శూన్యముగాను ఉండెను.
''';

      final slides = SlideUtils.parseLyrics(
        primaryLyrics,
        primaryTitle,
        isSong: false,
        isDualVersion: true,
        secondaryTitle: secondaryTitle,
        secondaryLyrics: secondaryLyrics,
      );

      // 2 verse slides + 1 blank slide at end
      expect(slides.length, 3);

      // Slide 1
      expect(slides[0].isDualVersion, isTrue);
      expect(slides[0].title, primaryTitle);
      expect(slides[0].secondaryTitle, secondaryTitle);
      expect(slides[0].content, '1 In the beginning God created the heavens and the earth.');
      expect(slides[0].secondaryContent, '1 ఆదియందు దేవుడు భూమ్యాకాశములను సృజించెను.');

      // Slide 2
      expect(slides[1].isDualVersion, isTrue);
      expect(slides[1].title, primaryTitle);
      expect(slides[1].secondaryTitle, secondaryTitle);
      expect(slides[1].content, '2 Now the earth was formless and empty.');
      expect(slides[1].secondaryContent, '2 భూమి నిరాకారముగాను శూన్యముగాను ఉండెను.');

      // Slide 3: Blank slide
      expect(slides[2].isBlank, isTrue);
    });

    test('SongSetlistItem preserves dual version flags for imported dual verses', () {
      final song = Song()
        ..title = 'John 3:16 NIV'
        ..author = 'Bible'
        ..lyrics = '[16]\n16 For God so loved the world'
        ..isDualVersion = true
        ..secondaryTitle = 'John 3:16 KJV'
        ..secondaryLyrics = '[16]\n16 For God so loved the world';

      final setlistItem = SongSetlistItem(song);

      expect(setlistItem.song.isDualVersion, isTrue);
      expect(setlistItem.song.secondaryTitle, 'John 3:16 KJV');
      expect(setlistItem.song.secondaryLyrics, '[16]\n16 For God so loved the world');
    });

    test('SlideUtils.parseLyrics displays secondary text when different verse numbers are selected (e.g. John 2:2 NKJV and John 2:3 Telugu)', () {
      const primaryTitle = 'John 2:2 NKJV';
      const secondaryTitle = 'John 2:3 TEL';

      const primaryLyrics = '''
[2]
2 And both Jesus was called, and his disciples, to the marriage.
''';

      const secondaryLyrics = '''
[3]
3 ద్రాక్షారసమైపోయినప్పుడు యేసు తల్లి వారికి ద్రాక్షారసము లేదని ఆయనతో చెప్పగా
''';

      final slides = SlideUtils.parseLyrics(
        primaryLyrics,
        primaryTitle,
        isSong: false,
        isDualVersion: true,
        secondaryTitle: secondaryTitle,
        secondaryLyrics: secondaryLyrics,
      );

      // 1 verse slide + 1 blank slide
      expect(slides.length, 2);

      // Slide 0 has both primary John 2:2 and secondary John 2:3 Telugu
      expect(slides[0].isDualVersion, isTrue);
      expect(slides[0].title, 'John 2:2 NKJV');
      expect(slides[0].secondaryTitle, 'John 2:3 TEL');
      expect(slides[0].content, '2 And both Jesus was called, and his disciples, to the marriage.');
      expect(slides[0].secondaryContent, '3 ద్రాక్షారసమైపోయినప్పుడు యేసు తల్లి వారికి ద్రాక్షారసము లేదని ఆయనతో చెప్పగా');

      // Slide 1 is blank
      expect(slides[1].isBlank, isTrue);
    });

    test('SlideUtils.parseLyrics preserves extra secondary verses when secondary has more verses than primary', () {
      const primaryTitle = 'John 2:2 NKJV';
      const secondaryTitle = 'John 2:2-3 TEL';

      const primaryLyrics = '''
[2]
2 And both Jesus was called, and his disciples, to the marriage.
''';

      const secondaryLyrics = '''
[2]
2 వివాహమునకు యేసును ఆయన శిష్యులును పిలువబడిరి.

[3]
3 ద్రాక్షారసమైపోయినప్పుడు యేసు తల్లి వారికి ద్రాక్షారసము లేదని ఆయనతో చెప్పగా
''';

      final slides = SlideUtils.parseLyrics(
        primaryLyrics,
        primaryTitle,
        isSong: false,
        isDualVersion: true,
        secondaryTitle: secondaryTitle,
        secondaryLyrics: secondaryLyrics,
      );

      // 2 verse slides + 1 blank slide
      expect(slides.length, 3);

      // Slide 0: Primary verse 2 + Secondary verse 2
      expect(slides[0].isDualVersion, isTrue);
      expect(slides[0].content, '2 And both Jesus was called, and his disciples, to the marriage.');
      expect(slides[0].secondaryContent, '2 వివాహమునకు యేసును ఆయన శిష్యులును పిలువబడిరి.');

      // Slide 1: Primary empty + Secondary verse 3
      expect(slides[1].isDualVersion, isTrue);
      expect(slides[1].content, '');
      expect(slides[1].secondaryContent, '3 ద్రాక్షారసమైపోయినప్పుడు యేసు తల్లి వారికి ద్రాక్షారసము లేదని ఆయనతో చెప్పగా');

      // Slide 2 is blank
      expect(slides[2].isBlank, isTrue);
    });
  });
}
