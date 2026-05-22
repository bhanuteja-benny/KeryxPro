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
}
