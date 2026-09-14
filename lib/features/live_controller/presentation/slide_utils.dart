import '../domain/slide.dart';

class SlideUtils {
  static String _cleanStanzaContent(String stanza) {
    final trimmed = stanza.trim();
    if (trimmed.isEmpty) return "";
    final firstLine = trimmed.split('\n').first.trim();
    if (RegExp(r'^\[.+\]$').hasMatch(firstLine) ||
        RegExp(r'^\[?(\w+)\s*(\d*)\]?:?$', caseSensitive: false).hasMatch(firstLine)) {
      final idx = trimmed.indexOf('\n');
      if (idx != -1) {
        return trimmed
            .substring(idx + 1)
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .join('\n');
      } else {
        return "";
      }
    }
    return trimmed
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n');
  }

  static String? _computeDisplayTitle(String? originalTitle, String? bookAlias) {
    if (originalTitle == null || originalTitle.isEmpty) return null;
    if (bookAlias == null || bookAlias.trim().isEmpty) return originalTitle;

    final match = RegExp(r'^(.+?)(\s+\d+.*)$').firstMatch(originalTitle.trim());
    if (match != null) {
      return '$bookAlias${match.group(2)}';
    }
    return originalTitle;
  }

  static List<Slide> parseLyrics(
    String lyrics,
    String songTitle, {
    bool isSong = true,
    bool isFavorite = false,
    bool isDualVersion = false,
    String? secondaryTitle,
    String? secondaryLyrics,
    String? bookAlias,
    String? secondaryBookAlias,
  }) {
    final computedDisplayTitle = !isSong ? _computeDisplayTitle(songTitle, bookAlias) : songTitle;
    final computedSecDisplayTitle = !isSong ? _computeDisplayTitle(secondaryTitle, secondaryBookAlias) : secondaryTitle;

    if (lyrics.trim().isEmpty && (secondaryLyrics == null || secondaryLyrics.trim().isEmpty)) {
      return [
        Slide.blank(
          title: songTitle,
          displayTitle: computedDisplayTitle,
          isSong: isSong,
          isFavorite: isFavorite,
        )
      ];
    }

    final stanzas = lyrics.split(RegExp(r'\n\s*\n')).where((s) => s.trim().isNotEmpty).toList();
    final secondaryStanzas = (secondaryLyrics ?? '')
        .split(RegExp(r'\n\s*\n'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final List<Slide> slides = [];
    
    int verseCount = 0;

    final count = isDualVersion && secondaryStanzas.length > stanzas.length
        ? secondaryStanzas.length
        : stanzas.length;

    for (var i = 0; i < count; i++) {
      String stanza = i < stanzas.length ? stanzas[i].trim() : '';
      String shortcut = "";
      SlideType type = SlideType.other;
      String content = stanza;

      if (stanza.isNotEmpty) {
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
      } else if (i < secondaryStanzas.length) {
        final secStanza = secondaryStanzas[i].trim();
        final firstLine = secStanza.split('\n').first.trim();
        final shortBracketMatch = RegExp(r'^\[(.{1,5})\]$').firstMatch(firstLine);
        if (shortBracketMatch != null) {
          shortcut = shortBracketMatch.group(1)!.trim();
          type = SlideType.verse;
        } else {
          shortcut = "${++verseCount}";
          type = SlideType.verse;
        }
      }

      // Trim each line to remove any leading spaces (common in OpenSong format)
      content = content.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).join('\n');

      String? secContent;
      if (isDualVersion && i < secondaryStanzas.length) {
        secContent = _cleanStanzaContent(secondaryStanzas[i]);
      }

      slides.add(Slide(
        title: songTitle,
        displayTitle: computedDisplayTitle,
        shortcut: shortcut,
        content: content,
        type: type,
        isSong: isSong,
        isFavorite: isFavorite,
        isDualVersion: isDualVersion,
        secondaryTitle: secondaryTitle,
        secondaryDisplayTitle: computedSecDisplayTitle,
        secondaryContent: secContent,
      ));
    }

    // Add blank slide at the end
    slides.add(Slide.blank(
      title: songTitle,
      displayTitle: computedDisplayTitle,
      isSong: isSong,
      isFavorite: isFavorite,
    ));

    return slides;
  }
}
