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
    '1 chron': '1 Chronicles', '2 chron': '2 Chronicles', '1 chr': '1 Chronicles', '2 chr': '2 Chronicles', '1 chro': '1 Chronicles', '2 chro': '2 Chronicles', '1 cho': '1 Chronicles', '2 cho': '2 Chronicles', 'cho': '1 Chronicles', 'chro': '1 Chronicles',
    'ezr': 'Ezra', 'neh': 'Nehemiah', 'est': 'Esther', 'job': 'Job', 'ps': 'Psalms', 'psa': 'Psalms', 'psalm': 'Psalms', 'psalms': 'Psalms', 'prov': 'Proverbs', 'pro': 'Proverbs',
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
    'rev': 'Revelation',
  };

  static const Map<String, String> defaultBookAliases = {
    // OT
    'Genesis': 'ఆదికాండము', 'Exodus': 'నిర్గమకాండము', 'Leviticus': 'లేవీయకాండము', 'Numbers': 'సంఖ్యాకాండము', 'Deuteronomy': 'ద్వితీయోపదేశకాండము',
    'Joshua': 'యెహోషువ', 'Judges': 'న్యాయాధిపతులు', 'Ruth': 'రూతు', '1 Samuel': '1 సమూయేలు', '2 Samuel': '2 సమూయేలు',
    '1 Kings': '1 రాజులు', '2 Kings': '2 రాజులు', '1 Chronicles': '1 దినవృత్తాంతములు', '2 Chronicles': '2 దినవృత్తాంతములు', 'Ezra': 'ఎజ్రా',
    'Nehemiah': 'నెహెమ్యా', 'Esther': 'ఎస్తెరు', 'Job': 'యోబు', 'Psalms': 'కీర్తనలు', 'Proverbs': 'సామెతలు',
    'Ecclesiastes': 'ప్రసంగి', 'Song of Solomon': 'పరమగీతము', 'Isaiah': 'యెషయా', 'Jeremiah': 'యిర్మియా', 'Lamentations': 'విలాపవాక్యములు',
    'Ezekiel': 'యెహెజ్కేలు', 'Daniel': 'దానియేలు', 'Hosea': 'హోషేయ', 'Joel': 'యోవేలు', 'Amos': 'ఆమోసు',
    'Obadiah': 'ఓబద్యా', 'Jonah': 'యోనా', 'Micah': 'మీకా', 'Nahum': 'నహూము', 'Habakkuk': 'హబక్కూకు',
    'Zephaniah': 'జెఫన్యా', 'Haggai': 'హగ్గయి', 'Zechariah': 'జెకర్యా', 'Malachi': 'మలాకీ',
    // NT
    'Matthew': 'మత్తయి', 'Mark': 'మార్కు', 'Luke': 'లూకా', 'John': 'యోహాను', 'Acts': 'అపొస్తలుల కార్యములు',
    'Romans': 'రోమీయులకు', '1 Corinthians': '1 కొరింథీయులకు', '2 Corinthians': '2 కొరింథీయులకు', 'Galatians': 'గలతీయులకు', 'Ephesians': 'ఎఫెసీయులకు',
    'Philippians': 'ఫిలిప్పీయులకు', 'Colossians': 'కొలొస్సయులకు', '1 Thessalonians': '1 థెస్సలొనీకయులకు', '2 Thessalonians': '2 థెస్సలొనీకయులకు',
    '1 Timothy': '1 తిమోతికి', '2 Timothy': '2 తిమోతికి', 'Titus': 'తీతుకు', 'Philemon': 'ఫిలేమోనుకు', 'Hebrews': 'హెబ్రీయులకు',
    'James': 'యాకోబు', '1 Peter': '1 పేతురు', '2 Peter': '2 పేతురు', '1 John': '1 యోహాను', '2 John': '2 యోహాను',
    '3 John': '3 యోహాను', 'Jude': 'యూదా', 'Revelation': 'ప్రకటన గ్రంథము',
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

    // 2. Default book alias match (reverse lookup)
    for (final entry in defaultBookAliases.entries) {
      if (entry.value.toLowerCase().replaceAll(' ', '') == lowerNoSpace) {
        return entry.key;
      }
    }

    // 3. Abbreviations map
    if (bookAbbreviations.containsKey(lower)) {
      return bookAbbreviations[lower];
    }
    for (var key in bookAbbreviations.keys) {
      if (key.replaceAll(' ', '') == lowerNoSpace) {
        return bookAbbreviations[key];
      }
    }

    // 4. Prefix match
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
