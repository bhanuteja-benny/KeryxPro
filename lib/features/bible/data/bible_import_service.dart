import 'dart:io';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;
import 'bible.dart';

class BibleImportResult {
  final BibleVersion version;
  final List<BibleVerse> verses;

  BibleImportResult({required this.version, required this.verses});
}

class BibleImportService {
  /// Parses a given XML file and returns a BibleImportResult
  static Future<BibleImportResult?> parseBibleFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      
      // Determine format
      if (content.contains('<XMLBIBLE')) {
        return _parseZefaniaFormat(content, p.basenameWithoutExtension(filePath));
      } else if (content.contains('<bible>')) {
        return _parseOpenSongFormat(content, p.basenameWithoutExtension(filePath));
      }

    } catch (e) {
      print('Error parsing Bible file $filePath: $e');
    }
    return null;
  }

  static BibleImportResult _parseOpenSongFormat(String content, String fallbackName) {
    final document = XmlDocument.parse(content);
    final bibleElement = document.getElement('bible');
    
    // Extract version info if available, otherwise use filename
    // OpenSong XML doesn't strictly standardise version info in the XML, but sometimes it's there
    String versionAbbrev = fallbackName;
    String versionName = fallbackName;

    final versionInfo = BibleVersion()
      ..abbreviation = versionAbbrev
      ..name = versionName
      ..language = 'Unknown';

    final List<BibleVerse> verses = [];

    if (bibleElement != null) {
      final books = bibleElement.findElements('b');
      for (final book in books) {
        final bookName = book.getAttribute('n') ?? 'Unknown Book';
        
        final chapters = book.findElements('c');
        for (final chapter in chapters) {
          final chapterNumStr = chapter.getAttribute('n');
          final chapterNum = int.tryParse(chapterNumStr ?? '') ?? 0;

          final verseNodes = chapter.findElements('v');
          for (final verse in verseNodes) {
            final verseNumStr = verse.getAttribute('n');
            final verseNum = int.tryParse(verseNumStr ?? '') ?? 0;
            final text = verse.innerText.trim();

            if (text.isNotEmpty) {
              verses.add(BibleVerse()
                ..bookName = bookName
                ..chapterNumber = chapterNum
                ..verseNumber = verseNum
                ..text = text);
            }
          }
        }
      }
    }

    return BibleImportResult(version: versionInfo, verses: verses);
  }

  static BibleImportResult _parseZefaniaFormat(String content, String fallbackName) {
    final document = XmlDocument.parse(content);
    final bibleElement = document.getElement('XMLBIBLE');

    String versionAbbrev = fallbackName;
    String versionName = fallbackName;
    
    // Zefania might have an INFORMATION tag
    final infoNode = bibleElement?.getElement('INFORMATION');
    if (infoNode != null) {
      final identifier = infoNode.getElement('identifier')?.innerText;
      final title = infoNode.getElement('title')?.innerText;
      final language = infoNode.getElement('language')?.innerText;
      
      if (identifier != null && identifier.isNotEmpty) versionAbbrev = identifier;
      if (title != null && title.isNotEmpty) versionName = title;
    }

    final versionInfo = BibleVersion()
      ..abbreviation = versionAbbrev
      ..name = versionName
      ..language = 'Unknown';

    final List<BibleVerse> verses = [];

    if (bibleElement != null) {
      final books = bibleElement.findElements('BIBLEBOOK');
      for (final book in books) {
        final bookName = book.getAttribute('bname') ?? 'Unknown Book';
        
        final chapters = book.findElements('CHAPTER');
        for (final chapter in chapters) {
          final chapterNumStr = chapter.getAttribute('cnumber');
          final chapterNum = int.tryParse(chapterNumStr ?? '') ?? 0;

          final verseNodes = chapter.findElements('VERS');
          for (final verse in verseNodes) {
            final verseNumStr = verse.getAttribute('vnumber');
            final verseNum = int.tryParse(verseNumStr ?? '') ?? 0;
            final text = verse.innerText.trim();

            if (text.isNotEmpty) {
              verses.add(BibleVerse()
                ..bookName = bookName
                ..chapterNumber = chapterNum
                ..verseNumber = verseNum
                ..text = text);
            }
          }
        }
      }
    }

    return BibleImportResult(version: versionInfo, verses: verses);
  }
}
