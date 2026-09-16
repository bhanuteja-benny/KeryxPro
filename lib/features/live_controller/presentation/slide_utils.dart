import '../domain/slide.dart';

class DualScriptureBookInfo {
  final String actualBookName;
  final String? aliasBookName;
  const DualScriptureBookInfo({required this.actualBookName, this.aliasBookName});
}

class SlideUtils {
  static bool isTextEnglish(String? text) {
    if (text == null || text.trim().isEmpty) return true;
    return RegExp(r'^[\x00-\x7F]+$').hasMatch(text.trim());
  }

  static DualScriptureBookInfo resolveDualBookNames({
    required String primaryTitle,
    String? primaryAlias,
    String? secondaryTitle,
    String? secondaryAlias,
  }) {
    final match1 = RegExp(r'^(.+?)(\s+\d+.*)$').firstMatch(primaryTitle.trim());
    final primaryActual = match1 != null ? match1.group(1)! : primaryTitle.trim();

    String? secondaryActual;
    if (secondaryTitle != null && secondaryTitle.trim().isNotEmpty) {
      final match2 = RegExp(r'^(.+?)(\s+\d+.*)$').firstMatch(secondaryTitle.trim());
      secondaryActual = match2 != null ? match2.group(1)! : secondaryTitle.trim();
    }

    final pAlias = (primaryAlias != null && primaryAlias.trim().isNotEmpty) ? primaryAlias.trim() : null;
    final sAlias = (secondaryAlias != null && secondaryAlias.trim().isNotEmpty) ? secondaryAlias.trim() : null;

    // Case A: Neither has alias
    if (pAlias == null && sAlias == null) {
      return DualScriptureBookInfo(actualBookName: primaryActual, aliasBookName: null);
    }

    // Case B: Only one has alias (Probability 1)
    if (pAlias != null && sAlias == null) {
      return DualScriptureBookInfo(actualBookName: primaryActual, aliasBookName: pAlias);
    }
    if (pAlias == null && sAlias != null) {
      return DualScriptureBookInfo(actualBookName: primaryActual, aliasBookName: sAlias);
    }

    // Case C: Both have alias
    final bool isPEnglish = isTextEnglish(pAlias);
    final bool isSEnglish = isTextEnglish(sAlias);

    if (isPEnglish && isSEnglish) {
      // Probability 2: Both English -> primary actual and primary alias
      return DualScriptureBookInfo(actualBookName: primaryActual, aliasBookName: pAlias);
    } else if (isPEnglish && !isSEnglish) {
      // Probability 3: English actual and non-English alias
      return DualScriptureBookInfo(actualBookName: primaryActual, aliasBookName: sAlias);
    } else if (!isPEnglish && isSEnglish) {
      // Probability 3: English actual and non-English alias
      return DualScriptureBookInfo(actualBookName: secondaryActual ?? primaryActual, aliasBookName: pAlias);
    } else {
      // Probability 4: Both non-English -> primary alias as actual, secondary alias as alias
      return DualScriptureBookInfo(actualBookName: pAlias ?? primaryActual, aliasBookName: sAlias);
    }
  }

  static String formatDualTitle(String primaryTitle, String secondaryTitle) {
    final regex = RegExp(r'^(.+?\s+\d+:)([^\s]+)\s*(.*)$');
    final match1 = regex.firstMatch(primaryTitle.trim());
    final match2 = regex.firstMatch(secondaryTitle.trim());

    if (match1 != null && match2 != null) {
      final prefix1 = match1.group(1)!;
      final verse1 = match1.group(2)!;
      final version1 = match1.group(3)!;
      final verse2 = match2.group(2)!;

      if (verse1 != verse2) {
        final space = version1.isNotEmpty ? ' ' : '';
        return '$prefix1$verse1/$verse2$space$version1';
      }
    }

    return primaryTitle;
  }

  static String formatSlideItemTitle(Slide slide) {
    final primary = slide.displayTitle ?? slide.title;
    if (slide.isDualVersion && !slide.isSong && slide.secondaryTitle != null) {
      final secondary = slide.secondaryDisplayTitle ?? slide.secondaryTitle!;
      return formatDualTitle(primary, secondary);
    }
    return primary;
  }

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
    bool isEdited = false,
    String? customReference,
  }) {
    String effectiveTitle = songTitle;
    String? computedDisplayTitle;
    String? computedSecDisplayTitle;

    if (isSong) {
      computedDisplayTitle = songTitle;
      computedSecDisplayTitle = secondaryTitle;
    } else if (isDualVersion) {
      final info = resolveDualBookNames(
        primaryTitle: songTitle,
        primaryAlias: bookAlias,
        secondaryTitle: secondaryTitle,
        secondaryAlias: secondaryBookAlias,
      );
      effectiveTitle = _computeDisplayTitle(songTitle, info.actualBookName) ?? songTitle;
      if (info.aliasBookName != null) {
        computedDisplayTitle = _computeDisplayTitle(songTitle, info.aliasBookName);
      } else {
        computedDisplayTitle = effectiveTitle;
      }
      computedSecDisplayTitle = _computeDisplayTitle(secondaryTitle, secondaryBookAlias);
    } else {
      computedDisplayTitle = _computeDisplayTitle(songTitle, bookAlias);
      computedSecDisplayTitle = _computeDisplayTitle(secondaryTitle, secondaryBookAlias);
    }

    if (lyrics.trim().isEmpty && (secondaryLyrics == null || secondaryLyrics.trim().isEmpty)) {
      return [
        Slide.blank(
          title: effectiveTitle,
          displayTitle: computedDisplayTitle,
          isSong: isSong,
          isFavorite: isFavorite,
          isEdited: isEdited,
          customReference: customReference,
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
        title: effectiveTitle,
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
        isEdited: isEdited,
        customReference: customReference,
      ));
    }

    // Add blank slide at the end
    slides.add(Slide.blank(
      title: effectiveTitle,
      displayTitle: computedDisplayTitle,
      isSong: isSong,
      isFavorite: isFavorite,
      isEdited: isEdited,
      customReference: customReference,
    ));

    return slides;
  }
}
