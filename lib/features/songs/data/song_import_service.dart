import 'dart:io';
import 'package:xml/xml.dart';
import 'song.dart';

class SongImportService {
  /// Parses a list of file paths and returns a list of Song objects.
  static Future<List<Song>> parseOpenSongFiles(List<String> filePaths) async {
    final List<Song> parsedSongs = [];

    for (final path in filePaths) {
      try {
        final file = File(path);
        if (!await file.exists()) continue;

        final content = await file.readAsString();
        
        // Simple check if it might be an XML OpenSong file
        if (!content.contains('<song>')) continue;

        final document = XmlDocument.parse(content);
        final songElement = document.getElement('song');
        
        if (songElement == null) continue;

        final title = songElement.getElement('title')?.innerText.trim() ?? 'Unknown Title';
        final author = songElement.getElement('author')?.innerText.trim();
        final lyricsRaw = songElement.getElement('lyrics')?.innerText ?? '';

        // Clean lyrics by stripping lines that start with '.' (which indicates chords in OpenSong)
        final cleanLyrics = lyricsRaw.split('\n').where((line) {
          // In OpenSong, lines with chords often start with a period, sometimes followed by spaces
          return !line.trimLeft().startsWith('.');
        }).join('\n').trim();

        if (cleanLyrics.isEmpty && title == 'Unknown Title') {
          continue; // Skip completely empty invalid files
        }

        final song = Song()
          ..title = title
          ..author = author?.isEmpty == true ? null : author
          ..lyrics = cleanLyrics;

        parsedSongs.add(song);
      } catch (e) {
        // Skip files that fail to parse
        print('Error parsing $path: $e');
      }
    }

    return parsedSongs;
  }
}
