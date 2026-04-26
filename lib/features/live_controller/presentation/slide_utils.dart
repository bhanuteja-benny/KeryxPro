import '../domain/slide.dart';

class SlideUtils {
  static List<Slide> parseLyrics(String lyrics, String songTitle, {bool isSong = true}) {
    if (lyrics.trim().isEmpty) return [Slide.blank(title: songTitle, isSong: isSong)];

    final stanzas = lyrics.split(RegExp(r'\n\s*\n')).where((s) => s.trim().isNotEmpty).toList();
    final List<Slide> slides = [];
    
    int verseCount = 0;
    int chorusCount = 0;
    int bridgeCount = 0;

    for (var i = 0; i < stanzas.length; i++) {
      String stanza = stanzas[i].trim();
      String shortcut = "";
      SlideType type = SlideType.other;
      String content = stanza;

      final firstLine = stanza.split('\n').first.trim();

      // Try to detect exact short brackets like [V1], [C], [1], [5-7]
      final shortBracketMatch = RegExp(r'^\[(.{1,5})\]$').firstMatch(firstLine);

      if (shortBracketMatch != null) {
        shortcut = shortBracketMatch.group(1)!.trim();
        
        // Remove the label line from content
        final firstNewlineIndex = stanza.indexOf('\n');
        if (firstNewlineIndex != -1) {
          content = stanza.substring(firstNewlineIndex + 1).trim();
        } else {
          content = ""; 
        }

        String firstChar = shortcut.isNotEmpty ? shortcut[0].toUpperCase() : '';
        if (firstChar == 'C') {
          type = SlideType.chorus;
        } else if (firstChar == 'B') {
          type = SlideType.bridge;
        } else if (firstChar == 'V') {
          type = SlideType.verse;
        } else if (RegExp(r'^\d').hasMatch(shortcut)) {
          // If it starts with a digit (e.g. [5] or [5-7]), treat as verse
          type = SlideType.verse;
        } else {
          type = SlideType.tag;
        }
      } else {
        // Fallback to detecting longer labels like [Chorus], Chorus:, Verse 1, etc.
        final labelMatch = RegExp(r'^\[?(\w+)\s*(\d*)\]?:?$', caseSensitive: false).firstMatch(firstLine);

        if (labelMatch != null) {
          String labelType = labelMatch.group(1)!.toLowerCase();
          String labelNum = labelMatch.group(2) ?? "";
          
          // Remove the label line from content
          final firstNewlineIndex = stanza.indexOf('\n');
          if (firstNewlineIndex != -1) {
            content = stanza.substring(firstNewlineIndex + 1).trim();
          } else {
            content = "";
          }

          if (labelType.contains('chorus')) {
            shortcut = "C$labelNum";
            type = SlideType.chorus;
          } else if (labelType.contains('bridge')) {
            shortcut = "B$labelNum";
            type = SlideType.bridge;
          } else if (labelType.contains('verse')) {
            shortcut = "V${labelNum.isEmpty ? ++verseCount : labelNum}";
            type = SlideType.verse;
          } else {
            shortcut = labelType.substring(0, 1).toUpperCase() + labelNum;
            type = SlideType.tag;
          }
        } else {
          // Fallback to sequential verse numbering if no label found
          // Only auto-prefix 'V' if it's a song
          shortcut = isSong ? "V${++verseCount}" : "${++verseCount}";
          type = SlideType.verse;
        }
      }

      // Trim each line to remove any leading spaces (common in OpenSong format)
      content = content.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).join('\n');

      slides.add(Slide(
        title: songTitle,
        shortcut: shortcut,
        content: content,
        type: type,
        isSong: isSong,
      ));
    }

    // Add blank slide at the end
    slides.add(Slide.blank(title: songTitle, isSong: isSong));

    return slides;
  }
}
