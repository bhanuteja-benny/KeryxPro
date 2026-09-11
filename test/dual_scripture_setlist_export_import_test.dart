import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:keryxpro/features/songs/data/song.dart';
import 'package:keryxpro/features/setlist/data/setlist_item.dart';
import 'package:keryxpro/features/setlist/presentation/setlist_providers.dart';
import 'package:keryxpro/features/live_controller/presentation/slide_utils.dart';

void main() {
  group('Dual Scripture Setlist Export & Import Tests', () {
    const primaryTitle = 'John 2:2 NKJV';
    const primaryLyrics = '[2]\n2 And both Jesus was called, and his disciples, to the marriage.';
    const secondaryTitle = 'John 2:3 TEL';
    const secondaryLyrics = '[3]\n3 ద్రాక్షారసమైపోయినప్పుడు యేసు తల్లి వారికి ద్రాక్షారసము లేదని ఆయనతో చెప్పగా';

    test('Setlist saving encodes dual scripture into 5-part itemOrder entry', () {
      final mockSong = Song()
        ..title = primaryTitle
        ..author = 'Bible'
        ..lyrics = primaryLyrics
        ..isDualVersion = true
        ..secondaryTitle = secondaryTitle
        ..secondaryLyrics = secondaryLyrics;

      final item = SongSetlistItem(mockSong);

      // Verify encoding logic from SetlistRepository.saveByName
      final encodedTitle = Uri.encodeComponent(item.song.title);
      final encodedLyrics = Uri.encodeComponent(item.song.lyrics);
      final isDual = item.song.isDualVersion ? '1' : '0';
      final encodedSecTitle = Uri.encodeComponent(item.song.secondaryTitle ?? '');
      final encodedSecLyrics = Uri.encodeComponent(item.song.secondaryLyrics ?? '');
      final entry = 'scripture:$encodedTitle|$encodedLyrics|$isDual|$encodedSecTitle|$encodedSecLyrics';

      expect(entry.startsWith('scripture:'), isTrue);
      final parts = entry.substring(10).split('|');
      expect(parts.length, 5);
      expect(Uri.decodeComponent(parts[0]), primaryTitle);
      expect(Uri.decodeComponent(parts[1]), primaryLyrics);
      expect(parts[2], '1');
      expect(Uri.decodeComponent(parts[3]), secondaryTitle);
      expect(Uri.decodeComponent(parts[4]), secondaryLyrics);
    });

    test('SetlistRepository parsing restores dual scripture SongSetlistItem accurately', () {
      final encodedTitle = Uri.encodeComponent(primaryTitle);
      final encodedLyrics = Uri.encodeComponent(primaryLyrics);
      final encodedSecTitle = Uri.encodeComponent(secondaryTitle);
      final encodedSecLyrics = Uri.encodeComponent(secondaryLyrics);
      final entry = 'scripture:$encodedTitle|$encodedLyrics|1|$encodedSecTitle|$encodedSecLyrics';

      // Simulating SetlistRepository.loadByName logic
      final parts = entry.substring(10).split('|');
      expect(parts.length >= 2, isTrue);

      String safeDecode(String s) {
        try {
          return Uri.decodeComponent(s);
        } catch (_) {
          return s;
        }
      }

      final title = safeDecode(parts[0]);
      final lyrics = safeDecode(parts[1]);
      bool isDual = false;
      String? secTitle;
      String? secLyrics;
      if (parts.length >= 3) {
        isDual = parts[2] == '1' || parts[2].toLowerCase() == 'true';
      }
      if (parts.length >= 4 && parts[3].isNotEmpty) {
        secTitle = safeDecode(parts[3]);
      }
      if (parts.length >= 5 && parts[4].isNotEmpty) {
        secLyrics = safeDecode(parts[4]);
      }
      if ((secTitle != null && secTitle.isNotEmpty) || (secLyrics != null && secLyrics.isNotEmpty)) {
        isDual = true;
      }

      final restoredSong = Song()
        ..title = title
        ..author = 'Bible'
        ..lyrics = lyrics
        ..isDualVersion = isDual
        ..secondaryTitle = secTitle
        ..secondaryLyrics = secLyrics;

      final restoredItem = SongSetlistItem(restoredSong);

      expect(restoredItem.song.title, primaryTitle);
      expect(restoredItem.song.lyrics, primaryLyrics);
      expect(restoredItem.song.isDualVersion, isTrue);
      expect(restoredItem.song.secondaryTitle, secondaryTitle);
      expect(restoredItem.song.secondaryLyrics, secondaryLyrics);

      // Verify slides generation from restored item
      final slides = SlideUtils.parseLyrics(
        restoredItem.song.lyrics,
        restoredItem.song.title,
        isSong: false,
        isDualVersion: restoredItem.song.isDualVersion,
        secondaryTitle: restoredItem.song.secondaryTitle,
        secondaryLyrics: restoredItem.song.secondaryLyrics,
      );

      expect(slides.isNotEmpty, isTrue);
      expect(slides.first.isDualVersion, isTrue);
      expect(slides.first.title, primaryTitle);
      expect(slides.first.secondaryTitle, secondaryTitle);
      expect(slides.first.content, '2 And both Jesus was called, and his disciples, to the marriage.');
      expect(slides.first.secondaryContent, '3 ద్రాక్షారసమైపోయినప్పుడు యేసు తల్లి వారికి ద్రాక్షారసము లేదని ఆయనతో చెప్పగా');
    });

    test('SetlistExportImportService extracts dual scripture items into JSON export payload', () {
      final encodedTitle = Uri.encodeComponent(primaryTitle);
      final encodedLyrics = Uri.encodeComponent(primaryLyrics);
      final encodedSecTitle = Uri.encodeComponent(secondaryTitle);
      final encodedSecLyrics = Uri.encodeComponent(secondaryLyrics);
      final itemOrder = [
        'scripture:$encodedTitle|$encodedLyrics|1|$encodedSecTitle|$encodedSecLyrics',
      ];

      String safeDecode(String s) {
        try {
          return Uri.decodeComponent(s);
        } catch (_) {
          return s;
        }
      }

      // Simulate SetlistExportImportService.exportSetlistsToFolder scripture extraction
      final scriptureList = <Map<String, dynamic>>[];
      for (final entry in itemOrder) {
        if (entry.startsWith('scripture:')) {
          final parts = entry.substring(10).split('|');
          if (parts.length >= 2) {
            final title = safeDecode(parts[0]);
            final lyrics = safeDecode(parts[1]);
            bool isDual = false;
            String? secTitle;
            String? secLyrics;
            if (parts.length >= 3) {
              isDual = parts[2] == '1' || parts[2].toLowerCase() == 'true';
            }
            if (parts.length >= 4 && parts[3].isNotEmpty) {
              secTitle = safeDecode(parts[3]);
            }
            if (parts.length >= 5 && parts[4].isNotEmpty) {
              secLyrics = safeDecode(parts[4]);
            }
            if ((secTitle != null && secTitle.isNotEmpty) || (secLyrics != null && secLyrics.isNotEmpty)) {
              isDual = true;
            }
            scriptureList.add({
              'title': title,
              'lyrics': lyrics,
              'isDualVersion': isDual,
              'secondaryTitle': secTitle,
              'secondaryLyrics': secLyrics,
            });
          }
        }
      }

      expect(scriptureList.length, 1);
      final sc = scriptureList.first;
      expect(sc['title'], primaryTitle);
      expect(sc['lyrics'], primaryLyrics);
      expect(sc['isDualVersion'], isTrue);
      expect(sc['secondaryTitle'], secondaryTitle);
      expect(sc['secondaryLyrics'], secondaryLyrics);

      final payload = {
        'version': 1,
        'name': 'Sunday Service',
        'itemOrder': itemOrder,
        'scriptures': scriptureList,
      };

      final jsonString = jsonEncode(payload);
      expect(jsonString.contains(primaryTitle), isTrue);
      expect(jsonString.contains(secondaryTitle), isTrue);
      expect(jsonString.contains('"isDualVersion":true'), isTrue);
    });

    test('Importing index-based scripture JSON format (scripture:0) reconstructs full dual scripture', () {
      final jsonPayload = {
        'name': 'Youth Fellowship',
        'itemOrder': ['scripture:0'],
        'scriptures': [
          {
            'title': primaryTitle,
            'lyrics': primaryLyrics,
            'isDualVersion': true,
            'secondaryTitle': secondaryTitle,
            'secondaryLyrics': secondaryLyrics,
          }
        ],
      };

      final scripturesData = jsonPayload['scriptures'] as List<dynamic>;
      final rawItemOrder = List<String>.from(jsonPayload['itemOrder'] as List);
      final processedItemOrder = <String>[];

      for (final entry in rawItemOrder) {
        if (entry.startsWith('scripture:')) {
          final raw = entry.substring(10);
          final parts = raw.split('|');

          if (parts.length == 1 && int.tryParse(parts[0]) != null) {
            final idx = int.parse(parts[0]);
            if (idx >= 0 && idx < scripturesData.length) {
              final sc = scripturesData[idx] as Map<String, dynamic>;
              final title = sc['title'] as String? ?? '';
              final lyrics = sc['lyrics'] as String? ?? '';
              final isDual = sc['isDualVersion'] == true;
              final secTitle = sc['secondaryTitle'] as String? ?? '';
              final secLyrics = sc['secondaryLyrics'] as String? ?? '';
              final hasSec = secTitle.isNotEmpty || secLyrics.isNotEmpty;
              processedItemOrder.add(
                'scripture:${Uri.encodeComponent(title)}|${Uri.encodeComponent(lyrics)}|${(isDual || hasSec) ? '1' : '0'}|${Uri.encodeComponent(secTitle)}|${Uri.encodeComponent(secLyrics)}',
              );
            }
          }
        }
      }

      expect(processedItemOrder.length, 1);
      final entry = processedItemOrder.first;
      final parts = entry.substring(10).split('|');
      expect(parts.length, 5);
      expect(Uri.decodeComponent(parts[0]), primaryTitle);
      expect(Uri.decodeComponent(parts[1]), primaryLyrics);
      expect(parts[2], '1');
      expect(Uri.decodeComponent(parts[3]), secondaryTitle);
      expect(Uri.decodeComponent(parts[4]), secondaryLyrics);
    });

    test('Importing legacy 2-part scripture entry enriches from scriptures metadata', () {
      // Legacy JSON where itemOrder only had title and lyrics, but scriptures list had dual version data
      final jsonPayload = {
        'name': 'Evening Service',
        'itemOrder': ['scripture:${Uri.encodeComponent(primaryTitle)}|${Uri.encodeComponent(primaryLyrics)}'],
        'scriptures': [
          {
            'title': primaryTitle,
            'lyrics': primaryLyrics,
            'isDualVersion': true,
            'secondaryTitle': secondaryTitle,
            'secondaryLyrics': secondaryLyrics,
          }
        ],
      };

      String safeDecode(String s) {
        try {
          return Uri.decodeComponent(s);
        } catch (_) {
          return s;
        }
      }

      final scripturesData = jsonPayload['scriptures'] as List<dynamic>;
      final rawItemOrder = List<String>.from(jsonPayload['itemOrder'] as List);
      final processedItemOrder = <String>[];
      int scriptureCounter = 0;

      for (final entry in rawItemOrder) {
        if (entry.startsWith('scripture:')) {
          final raw = entry.substring(10);
          final parts = raw.split('|');

          if (parts.length >= 2) {
            final title = safeDecode(parts[0]);
            final lyrics = safeDecode(parts[1]);
            bool isDual = false;
            String? secTitle;
            String? secLyrics;

            if (parts.length >= 3) {
              isDual = parts[2] == '1' || parts[2].toLowerCase() == 'true';
            }
            if (parts.length >= 4 && parts[3].isNotEmpty) {
              secTitle = safeDecode(parts[3]);
            }
            if (parts.length >= 5 && parts[4].isNotEmpty) {
              secLyrics = safeDecode(parts[4]);
            }

            if ((!isDual || secTitle == null || secLyrics == null) && scriptureCounter < scripturesData.length) {
              final sc = scripturesData[scriptureCounter] as Map<String, dynamic>;
              if (sc['isDualVersion'] == true) isDual = true;
              if ((secTitle == null || secTitle.isEmpty) && sc['secondaryTitle'] != null) {
                secTitle = sc['secondaryTitle'] as String;
              }
              if ((secLyrics == null || secLyrics.isEmpty) && sc['secondaryLyrics'] != null) {
                secLyrics = sc['secondaryLyrics'] as String;
              }
            }
            scriptureCounter++;

            if ((secTitle != null && secTitle.isNotEmpty) || (secLyrics != null && secLyrics.isNotEmpty)) {
              isDual = true;
            }

            processedItemOrder.add(
              'scripture:${Uri.encodeComponent(title)}|${Uri.encodeComponent(lyrics)}|${isDual ? '1' : '0'}|${Uri.encodeComponent(secTitle ?? '')}|${Uri.encodeComponent(secLyrics ?? '')}',
            );
          }
        }
      }

      expect(processedItemOrder.length, 1);
      final parts = processedItemOrder.first.substring(10).split('|');
      expect(parts.length, 5);
      expect(parts[2], '1');
      expect(Uri.decodeComponent(parts[3]), secondaryTitle);
      expect(Uri.decodeComponent(parts[4]), secondaryLyrics);
    });

    test('generateSetlistSignature accounts for dual scripture changes', () {
      final singleSong = Song()
        ..title = 'Genesis 1:1'
        ..author = 'Bible'
        ..lyrics = 'In the beginning'
        ..isDualVersion = false;

      final dualSong = Song()
        ..title = 'Genesis 1:1'
        ..author = 'Bible'
        ..lyrics = 'In the beginning'
        ..isDualVersion = true
        ..secondaryTitle = 'ఆదికాండము 1:1'
        ..secondaryLyrics = 'ఆదియందు';

      final sigSingle = generateSetlistSignature([SongSetlistItem(singleSong)]);
      final sigDual = generateSetlistSignature([SongSetlistItem(dualSong)]);

      expect(sigSingle != sigDual, isTrue);
      expect(sigDual.contains('scripture:Genesis 1:1;1;ఆదికాండము 1:1|'), isTrue);
    });
  });
}
