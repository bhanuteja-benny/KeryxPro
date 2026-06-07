class BibleConstants {
  static const List<String> oldTestamentBooks = [
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua', 'Judges', 'Ruth',
    '1 Samuel', '2 Samuel', '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra',
    'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon',
    'Isaiah', 'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
    'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi'
  ];

  static const List<String> newTestamentBooks = [
    'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans', '1 Corinthians', '2 Corinthians',
    'Galatians', 'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians',
    '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter',
    '1 John', '2 John', '3 John', 'Jude', 'Revelation'
  ];

  static final Map<String, String> bookAbbreviations = {
    'gen': 'Genesis', 'ex': 'Exodus', 'exo': 'Exodus', 'lev': 'Leviticus', 'num': 'Numbers', 'deut': 'Deuteronomy', 'dt': 'Deuteronomy',
    'josh': 'Joshua', 'judg': 'Judges', 'jdg': 'Judges', 'rut': 'Ruth', 'rth': 'Ruth',
    '1 sam': '1 Samuel', '2 sam': '2 Samuel', '1 kgs': '1 Kings', '2 kgs': '2 Kings',
    '1 chron': '1 Chronicles', '2 chron': '2 Chronicles', '1 chr': '1 Chronicles', '2 chr': '2 Chronicles',
    'ezr': 'Ezra', 'neh': 'Nehemiah', 'est': 'Esther', 'job': 'Job', 'ps': 'Psalms', 'psa': 'Psalms', 'prov': 'Proverbs', 'pro': 'Proverbs',
    'ecc': 'Ecclesiastes', 'song': 'Song of Solomon', 'sos': 'Song of Solomon',
    'isa': 'Isaiah', 'jer': 'Jeremiah', 'lam': 'Lamentations', 'eze': 'Ezekiel', 'dan': 'Daniel',
    'hos': 'Hosea', 'joe': 'Joel', 'amo': 'Amos', 'oba': 'Obadiah', 'jon': 'Jonah', 'mic': 'Micah',
    'nah': 'Nahum', 'hab': 'Habakkuk', 'zeph': 'Zephaniah', 'zep': 'Zephaniah', 'hag': 'Haggai', 'zech': 'Zechariah', 'zec': 'Zechariah', 'mal': 'Malachi',
    'mat': 'Matthew', 'matt': 'Matthew', 'mt': 'Matthew', 'mar': 'Mark', 'mk': 'Mark', 'luk': 'Luke', 'lk': 'Luke',
    'joh': 'John', 'jn': 'John', 'act': 'Acts', 'rom': 'Romans',
    '1 cor': '1 Corinthians', '2 cor': '2 Corinthians', 'gal': 'Galatians', 'eph': 'Ephesians',
    'phil': 'Philippians', 'php': 'Philippians', 'col': 'Colossians',
    '1 thess': '1 Thessalonians', '1 th': '1 Thessalonians', '2 thess': '2 Thessalonians', '2 th': '2 Thessalonians',
    '1 tim': '1 Timothy', '2 tim': '2 Timothy', 'tit': 'Titus', 'phile': 'Philemon', 'phm': 'Philemon',
    'heb': 'Hebrews', 'jam': 'James', 'jas': 'James', '1 pet': '1 Peter', '2 pet': '2 Peter',
    '1 joh': '1 John', '1 jn': '1 John', '2 joh': '2 John', '2 jn': '2 John', '3 joh': '3 John', '3 jn': '3 John',
    'jud': 'Jude', 'rev': 'Revelation',
  };

  static String? normalizeBookName(String input) {
    String lower = input.toLowerCase().trim();
    String lowerNoSpace = lower.replaceAll(' ', '');

    // 1. Exact match (ignoring spaces)
    for (String book in oldTestamentBooks) {
      if (book.toLowerCase().replaceAll(' ', '') == lowerNoSpace) return book;
    }
    for (String book in newTestamentBooks) {
      if (book.toLowerCase().replaceAll(' ', '') == lowerNoSpace) return book;
    }

    // 2. Abbreviations map
    if (bookAbbreviations.containsKey(lower)) {
      return bookAbbreviations[lower];
    }
    for (var key in bookAbbreviations.keys) {
      if (key.replaceAll(' ', '') == lowerNoSpace) {
        return bookAbbreviations[key];
      }
    }

    // 3. Prefix match
    for (String book in oldTestamentBooks) {
      if (book.toLowerCase().replaceAll(' ', '').startsWith(lowerNoSpace)) return book;
    }
    for (String book in newTestamentBooks) {
      if (book.toLowerCase().replaceAll(' ', '').startsWith(lowerNoSpace)) return book;
    }

    return null; // Not found
  }

  static const Map<String, int> bookChapterCounts = {
    // OT
    'Genesis': 50, 'Exodus': 40, 'Leviticus': 27, 'Numbers': 36, 'Deuteronomy': 34, 'Joshua': 24, 'Judges': 21, 'Ruth': 4,
    '1 Samuel': 31, '2 Samuel': 24, '1 Kings': 22, '2 Kings': 25, '1 Chronicles': 29, '2 Chronicles': 36, 'Ezra': 10,
    'Nehemiah': 13, 'Esther': 10, 'Job': 42, 'Psalms': 150, 'Proverbs': 31, 'Ecclesiastes': 12, 'Song of Solomon': 8,
    'Isaiah': 66, 'Jeremiah': 52, 'Lamentations': 5, 'Ezekiel': 48, 'Daniel': 12, 'Hosea': 14, 'Joel': 3, 'Amos': 9,
    'Obadiah': 1, 'Jonah': 4, 'Micah': 7, 'Nahum': 3, 'Habakkuk': 3, 'Zephaniah': 3, 'Haggai': 2, 'Zechariah': 14, 'Malachi': 4,
    // NT
    'Matthew': 28, 'Mark': 16, 'Luke': 24, 'John': 21, 'Acts': 28, 'Romans': 16, '1 Corinthians': 16, '2 Corinthians': 13,
    'Galatians': 6, 'Ephesians': 6, 'Philippians': 4, 'Colossians': 4, '1 Thessalonians': 5, '2 Thessalonians': 3,
    '1 Timothy': 6, '2 Timothy': 4, 'Titus': 3, 'Philemon': 1, 'Hebrews': 13, 'James': 5, '1 Peter': 5, '2 Peter': 3,
    '1 John': 5, '2 John': 1, '3 John': 1, 'Jude': 1, 'Revelation': 22,
  };

  static int getChapterCount(String bookName) {
    final normalized = normalizeBookName(bookName);
    return bookChapterCounts[normalized] ?? 0;
  }
}
