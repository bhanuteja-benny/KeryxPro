import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/bible_constants.dart';
import '../bible_providers.dart';
import '../bible_search_providers.dart';
import '../../data/bible.dart';
import '../../../dashboard/presentation/global_ui_providers.dart';
import '../../../live_controller/presentation/live_projector_providers.dart';
import '../../../songs/data/song.dart';
import '../../../songs/presentation/song_selection_providers.dart';
import '../../../setlist/presentation/setlist_providers.dart';
import '../../../setlist/data/setlist_item.dart';
import '../../../../main.dart';
import 'package:isar/isar.dart';

class _ParsedBibleReference {
  final String bookName;
  final int chapter;
  final int startVerse;
  final int endVerse;
  final String? versionStr;

  _ParsedBibleReference({
    required this.bookName,
    required this.chapter,
    required this.startVerse,
    required this.endVerse,
    this.versionStr,
  });
}

class BibleSearchTab extends ConsumerStatefulWidget {
  const BibleSearchTab({super.key});

  @override
  ConsumerState<BibleSearchTab> createState() => _BibleSearchTabState();
}

class _BibleSearchTabState extends ConsumerState<BibleSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  int? _lastVerseToggled;
  bool _isDualVersionMode = false;
  bool _isButtonViewMode = false;
  String _selectedButtonViewTab = 'Books';
  BibleVersion? _secondaryBibleVersion;

  final FocusNode _otFocusNode = FocusNode();
  final FocusNode _ntFocusNode = FocusNode();
  final FocusNode _chFocusNode = FocusNode();
  final FocusNode _addButtonFocusNode = FocusNode(debugLabel: 'BibleAddButton');

  bool _showVerseTextList = false;
  final ScrollController _buttonVerseTextScrollController = ScrollController();
  final Map<int, GlobalKey> _buttonVerseKeys = {};

  void _scrollToSelectedVerse(int verseNumber, [List<int>? totalVerses]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;

        if (totalVerses != null && totalVerses.isNotEmpty && _buttonVerseTextScrollController.hasClients) {
          final index = totalVerses.indexOf(verseNumber);
          if (index != -1) {
            final maxExtent = _buttonVerseTextScrollController.position.maxScrollExtent;
            final targetOffset = (index / totalVerses.length) * maxExtent;
            _buttonVerseTextScrollController.jumpTo(targetOffset);
          }
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final key = _buttonVerseKeys[verseNumber];
          if (key?.currentContext != null) {
            Scrollable.ensureVisible(
              key!.currentContext!,
              alignment: 0.1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          }
        });
      });
    });
  }

  final ScrollController _otScrollController = ScrollController();
  final ScrollController _ntScrollController = ScrollController();
  final ScrollController _chScrollController = ScrollController();
  final ScrollController _vsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bibleSearchFocusNodeProvider).onKeyEvent = (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
          _addButtonFocusNode.requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _otFocusNode.dispose();
    _ntFocusNode.dispose();
    _chFocusNode.dispose();
    _addButtonFocusNode.dispose();
    _otScrollController.dispose();
    _ntScrollController.dispose();
    _chScrollController.dispose();
    _vsScrollController.dispose();
    super.dispose();
  }

  void _scrollToEnsureVisible(ScrollController controller, int index) {
    if (!controller.hasClients) return;
    final itemTop = index * 24.0;
    final itemBottom = itemTop + 24.0;
    final viewportTop = controller.position.pixels;
    final viewportBottom = viewportTop + controller.position.viewportDimension;

    if (itemTop < viewportTop) {
      controller.jumpTo(itemTop);
    } else if (itemBottom > viewportBottom) {
      controller.jumpTo(itemBottom - controller.position.viewportDimension);
    }
  }

  Future<List<_ParsedBibleReference>> _parseBibleReferenceQueries(String input, WidgetRef ref) async {
  final List<_ParsedBibleReference> results = [];
  if (input.trim().isEmpty) return results;

  final rawTokens = input.split(RegExp(r'[;,]'));

  String? currentBook;
  int? currentChapter;

  final isar = await ref.read(isarServiceProvider).db;

  for (String rawToken in rawTokens) {
    String tokenText = rawToken.trim();
    if (tokenText.isEmpty) continue;

    String? tokenVersionStr;

    final versionMatch = RegExp(r'^(.*?)\s+([a-zA-Z0-9]{2,6})$').firstMatch(tokenText);
    if (versionMatch != null) {
      final candidateText = versionMatch.group(1)!.trim();
      final candidateVer = versionMatch.group(2)!.trim();

      final lowerVer = candidateVer.toLowerCase();
      if (!['a', 'f', 'l'].contains(lowerVer) &&
          !RegExp(r'^\d*[fl]\d*$').hasMatch(lowerVer) &&
          BibleConstants.normalizeBookName(tokenText) == null) {
        tokenText = candidateText;
        tokenVersionStr = candidateVer;
      }
    }

    String? bookStr;
    int? chapter;
    String? verseExpr;

    final fullRefMatch = RegExp(r'^(\d?\s*[a-zA-Z\s]+?)\s*(\d+)[\:\;]([a-zA-Z0-9\-]+)$').firstMatch(tokenText);
    final chVerseMatch = RegExp(r'^(\d+)[\:\;]([a-zA-Z0-9\-]+)$').firstMatch(tokenText);
    final bookChMatch = RegExp(r'^(\d?\s*[a-zA-Z\s]+?)\s*(\d+)$').firstMatch(tokenText);
    final verseOnlyMatch = RegExp(r'^([a-zA-Z0-9\-]+)$').firstMatch(tokenText);

    if (fullRefMatch != null) {
      final normBook = BibleConstants.normalizeBookName(fullRefMatch.group(1)!.trim());
      final ch = int.tryParse(fullRefMatch.group(2)!);
      if (normBook != null && ch != null) {
        bookStr = normBook;
        chapter = ch;
        verseExpr = fullRefMatch.group(3)!;
      }
    } else if (chVerseMatch != null && currentBook != null) {
      final ch = int.tryParse(chVerseMatch.group(1)!);
      if (ch != null) {
        bookStr = currentBook;
        chapter = ch;
        verseExpr = chVerseMatch.group(2)!;
      }
    } else if (bookChMatch != null && BibleConstants.normalizeBookName(bookChMatch.group(1)!.trim()) != null) {
      final normBook = BibleConstants.normalizeBookName(bookChMatch.group(1)!.trim());
      final ch = int.tryParse(bookChMatch.group(2)!);
      if (normBook != null && ch != null) {
        bookStr = normBook;
        chapter = ch;
        verseExpr = 'a';
      }
    } else if (verseOnlyMatch != null && currentBook != null && currentChapter != null) {
      bookStr = currentBook;
      chapter = currentChapter;
      verseExpr = verseOnlyMatch.group(1)!;
    }

    if (bookStr == null || chapter == null || verseExpr == null) {
      continue;
    }

    currentBook = bookStr;
    currentChapter = chapter;

    final versionsAsync = ref.read(bibleVersionsProvider);
    final versions = versionsAsync.valueOrNull ?? [];
    BibleVersion? targetVersion;
    if (tokenVersionStr != null) {
      targetVersion = versions.where((v) => v.abbreviation.toLowerCase() == tokenVersionStr!.toLowerCase()).firstOrNull;
    }
    targetVersion ??= ref.read(selectedBibleVersionProvider) ?? versions.firstOrNull;

    int totalVerses = 0;
    if (targetVersion != null) {
      final verseNums = await isar.bibleVerses
          .filter()
          .bibleVersionIdEqualTo(targetVersion.id)
          .bookNameEqualTo(bookStr)
          .chapterNumberEqualTo(chapter)
          .verseNumberProperty()
          .findAll();
      if (verseNums.isNotEmpty) {
        totalVerses = verseNums.reduce((a, b) => a > b ? a : b);
      }
    }

    if (totalVerses == 0) continue;

    final lowerExpr = verseExpr.trim().toLowerCase();
    int? startVerse;
    int? endVerse;

    if (lowerExpr == 'a') {
      startVerse = 1;
      endVerse = totalVerses;
    } else if (RegExp(r'^(\d*)f(\d*)$').hasMatch(lowerExpr)) {
      final m = RegExp(r'^(\d*)f(\d*)$').firstMatch(lowerExpr)!;
      final numStr = m.group(1)!.isNotEmpty ? m.group(1)! : (m.group(2)!.isNotEmpty ? m.group(2)! : '1');
      final n = int.tryParse(numStr) ?? 1;
      startVerse = 1;
      endVerse = n.clamp(1, totalVerses);
    } else if (RegExp(r'^(\d*)l(\d*)$').hasMatch(lowerExpr)) {
      final m = RegExp(r'^(\d*)l(\d*)$').firstMatch(lowerExpr)!;
      final numStr = m.group(1)!.isNotEmpty ? m.group(1)! : (m.group(2)!.isNotEmpty ? m.group(2)! : '1');
      final n = int.tryParse(numStr) ?? 1;
      startVerse = (totalVerses - n + 1).clamp(1, totalVerses);
      endVerse = totalVerses;
    } else if (RegExp(r'^(\d+)-(\d+)$').hasMatch(lowerExpr)) {
      final m = RegExp(r'^(\d+)-(\d+)$').firstMatch(lowerExpr)!;
      startVerse = int.tryParse(m.group(1)!);
      endVerse = int.tryParse(m.group(2)!);
    } else if (RegExp(r'^(\d+)$').hasMatch(lowerExpr)) {
      startVerse = int.tryParse(lowerExpr);
      endVerse = startVerse;
    }

    if (startVerse != null && endVerse != null && startVerse <= endVerse && startVerse >= 1 && endVerse <= totalVerses) {
      results.add(_ParsedBibleReference(
        bookName: bookStr,
        chapter: chapter,
        startVerse: startVerse,
        endVerse: endVerse,
        versionStr: tokenVersionStr,
      ));
    }
  }

  return results;
}

Future<void> _handleSearch(String query, WidgetRef ref) async {
  if (query.trim().isEmpty) return;

  final queries = await _parseBibleReferenceQueries(query, ref);

  if (queries.isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reference not found'), duration: Duration(seconds: 2)),
      );
    }
    ref.read(selectedBookProvider.notifier).state = null;
    ref.read(selectedChapterProvider.notifier).state = null;
    ref.read(selectedVersesProvider.notifier).state = <int>{};
    ref.read(bibleSearchFocusNodeProvider).requestFocus();
    return;
  }

  final isar = await ref.read(isarServiceProvider).db;
  final versionsAsync = ref.read(bibleVersionsProvider);
  final versions = versionsAsync.valueOrNull ?? [];

  if (queries.length == 1) {
    final q = queries.first;
    BibleVersion? targetVersion;
    if (q.versionStr != null) {
      targetVersion = versions.where((v) => v.abbreviation.toLowerCase() == q.versionStr!.toLowerCase()).firstOrNull;
    }
    targetVersion ??= ref.read(selectedBibleVersionProvider) ?? versions.firstOrNull;

    if (targetVersion != null) {
      if (targetVersion != ref.read(selectedBibleVersionProvider)) {
        ref.read(selectedBibleVersionProvider.notifier).state = targetVersion;
      }
      ref.read(selectedBookProvider.notifier).state = q.bookName;
      ref.read(selectedChapterProvider.notifier).state = q.chapter;

      final Set<int> versesToSelect = {};
      for (int i = q.startVerse; i <= q.endVerse; i++) {
        versesToSelect.add(i);
      }
      ref.read(selectedVersesProvider.notifier).state = versesToSelect;
      ref.read(secondarySelectedVersesProvider.notifier).state = Set<int>.from(versesToSelect);
      if (mounted) {
        setState(() {
          _lastVerseToggled = q.endVerse;
          if (_isButtonViewMode) {
            _selectedButtonViewTab = 'Verses';
            _showVerseTextList = true;
          }
        });
        if (_isButtonViewMode) {
          final verses = ref.read(availableVersesProvider).valueOrNull ?? [];
          _scrollToSelectedVerse(q.startVerse, verses);
        }
      }

      ref.read(bibleVerseListFocusNodeProvider).requestFocus();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (BibleConstants.oldTestamentBooks.contains(q.bookName)) {
          final index = BibleConstants.oldTestamentBooks.indexOf(q.bookName);
          _scrollToEnsureVisible(_otScrollController, index);
        } else if (BibleConstants.newTestamentBooks.contains(q.bookName)) {
          final index = BibleConstants.newTestamentBooks.indexOf(q.bookName);
          _scrollToEnsureVisible(_ntScrollController, index);
        }

        Future.delayed(const Duration(milliseconds: 100), () {
          final chItems = ref.read(availableChaptersProvider).valueOrNull ?? [];
          final chIndex = chItems.indexOf(q.chapter);
          if (chIndex != -1) _scrollToEnsureVisible(_chScrollController, chIndex);
          
          final vsItems = ref.read(availableVersesProvider).valueOrNull ?? [];
          final vsIndex = vsItems.indexOf(q.startVerse);
          if (vsIndex != -1) _scrollToEnsureVisible(_vsScrollController, vsIndex);
        });
      });

      return;
    }
  } else {
    for (final q in queries) {
      BibleVersion? targetVersion;
      if (q.versionStr != null) {
        targetVersion = versions.where((v) => v.abbreviation.toLowerCase() == q.versionStr!.toLowerCase()).firstOrNull;
      }
      targetVersion ??= ref.read(selectedBibleVersionProvider) ?? versions.firstOrNull;

      if (targetVersion != null) {
        final chapterVerses = await isar.bibleVerses
            .filter()
            .bibleVersionIdEqualTo(targetVersion.id)
            .bookNameEqualTo(q.bookName)
            .chapterNumberEqualTo(q.chapter)
            .findAll();

        final selectedVerses = chapterVerses
            .where((v) => v.verseNumber >= q.startVerse && v.verseNumber <= q.endVerse)
            .toList()
          ..sort((a, b) => a.verseNumber.compareTo(b.verseNumber));

        if (selectedVerses.isNotEmpty) {
          _addToSetlist(selectedVerses, targetVersion, ref, goLive: false);
        }
      }
    }

    final lastQ = queries.last;
    BibleVersion? lastVersion;
    if (lastQ.versionStr != null) {
      lastVersion = versions.where((v) => v.abbreviation.toLowerCase() == lastQ.versionStr!.toLowerCase()).firstOrNull;
    }
    lastVersion ??= ref.read(selectedBibleVersionProvider) ?? versions.firstOrNull;

    if (lastVersion != null) {
      if (lastVersion != ref.read(selectedBibleVersionProvider)) {
        ref.read(selectedBibleVersionProvider.notifier).state = lastVersion;
      }
      ref.read(selectedBookProvider.notifier).state = lastQ.bookName;
      ref.read(selectedChapterProvider.notifier).state = lastQ.chapter;

      final Set<int> versesToSelect = {};
      for (int i = lastQ.startVerse; i <= lastQ.endVerse; i++) {
        versesToSelect.add(i);
      }
      ref.read(selectedVersesProvider.notifier).state = versesToSelect;
    }
  }
}

Future<bool> _addReferenceLineToSetlist(String line, WidgetRef ref) async {
  final queries = await _parseBibleReferenceQueries(line, ref);
  if (queries.isEmpty) return false;

  final isar = await ref.read(isarServiceProvider).db;
  final versionsAsync = ref.read(bibleVersionsProvider);
  final versions = versionsAsync.valueOrNull ?? [];
  if (versions.isEmpty) return false;

  bool addedAny = false;

  for (final q in queries) {
    BibleVersion? targetVersion;
    if (q.versionStr != null) {
      targetVersion = versions.where((v) => v.abbreviation.toLowerCase() == q.versionStr!.toLowerCase()).firstOrNull;
    }
    targetVersion ??= ref.read(selectedBibleVersionProvider) ?? versions.firstOrNull;

    if (targetVersion == null) continue;

    final chapterVerses = await isar.bibleVerses
        .filter()
        .bibleVersionIdEqualTo(targetVersion.id)
        .bookNameEqualTo(q.bookName)
        .chapterNumberEqualTo(q.chapter)
        .findAll();

    final selectedVerses = chapterVerses
        .where((v) => v.verseNumber >= q.startVerse && v.verseNumber <= q.endVerse)
        .toList()
      ..sort((a, b) => a.verseNumber.compareTo(b.verseNumber));

    if (selectedVerses.length == (q.endVerse - q.startVerse + 1)) {
      _addToSetlist(selectedVerses, targetVersion, ref, goLive: false);
      addedAny = true;
    }
  }

  return addedAny;
}

Future<void> _showImportVersesDialog(WidgetRef ref) async {
  final result = await showDialog<({int added, int notFound})>(
    context: context,
    builder: (dialogContext) => _ImportVersesDialog(
      onAdd: (lines) async {
        int addedCount = 0;
        int notFoundCount = 0;
        for (final line in lines) {
          final added = await _addReferenceLineToSetlist(line, ref);
          if (added) {
            addedCount++;
          } else {
            notFoundCount++;
          }
        }
        return (added: addedCount, notFound: notFoundCount);
      },
    ),
  );

  if (!mounted || result == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${result.added} references added, ${result.notFound} not found'),
      duration: const Duration(seconds: 2),
    ),
  );
}
  
  void _addToSetlist(List<BibleVerse> verses, BibleVersion version, WidgetRef ref, {bool goLive = true}) {
    if (verses.isEmpty) return;

    final book = verses.first.bookName;
    final chapter = verses.first.chapterNumber;
    
    // Sort just in case
    verses.sort((a, b) => a.verseNumber.compareTo(b.verseNumber));
    
    // Determine the verse range string
    String verseRange;
    if (verses.length == 1) {
      verseRange = verses.first.verseNumber.toString();
    } else {
      // Check if contiguous
      bool contiguous = true;
      for (int i = 1; i < verses.length; i++) {
        if (verses[i].verseNumber != verses[i-1].verseNumber + 1) {
          contiguous = false;
          break;
        }
      }
      
      if (contiguous) {
        verseRange = '${verses.first.verseNumber}-${verses.last.verseNumber}';
      } else {
        verseRange = verses.map((v) => v.verseNumber).join(',');
      }
    }

    final title = '$book $chapter:$verseRange ${version.abbreviation}';
    
    // Format lyrics with [V] tags so SlideUtils treats them as individual verses
    final lyricsBuffer = StringBuffer();
    for (var v in verses) {
      if (v.text.trim().isEmpty) continue;
      // Use verse number as shortcut and include it in text
      lyricsBuffer.writeln('[${v.verseNumber}]');
      lyricsBuffer.writeln('${v.verseNumber} ${v.text.trim()}');
      lyricsBuffer.writeln(); // Empty line between verses
    }

    final lyrics = lyricsBuffer.toString().trim();
    if (lyrics.isEmpty) return;

    final mockSong = Song()
      ..title = title
      ..author = 'Bible'
      ..lyrics = lyrics;

    final insertAt = ref.read(setlistProvider.notifier).insertSong(
      mockSong,
      goLive: goLive,
      selectedIndices: ref.read(setlistSelectionProvider),
      currentDisplayItemIndex: ref.read(currentDisplayItemIndexProvider),
    );

    // Auto-activate the newly added song and focus slides if goLive is true
    if (goLive) {
      final nextIndex = getSlideCountForItems(ref.read(setlistProvider), insertAt - 1);
      ref.read(activeSlideIndexProvider.notifier).state = nextIndex;
      ref.read(slideListFocusNodeProvider).requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bibleVersionsAsync = ref.watch(bibleVersionsProvider);
    final selectedVersion = ref.watch(selectedBibleVersionProvider);
    final bibleVersions = bibleVersionsAsync.valueOrNull ?? [];
    final secondaryVersion = _isDualVersionMode
        ? _secondaryBibleVersion ?? bibleVersions.where((version) => version.id != selectedVersion?.id).firstOrNull
        : null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(isDualVersionModeProvider) != _isDualVersionMode) {
        ref.read(isDualVersionModeProvider.notifier).state = _isDualVersionMode;
      }
      if (ref.read(secondaryBibleVersionProvider) != secondaryVersion) {
        ref.read(secondaryBibleVersionProvider.notifier).state = secondaryVersion;
      }
    });

    ref.listen<String?>(bibleSearchQueryProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        _searchController.text = next;
        _handleSearch(next, ref);
        // Ensure focus remains in the search textbox
        ref.read(bibleSearchFocusNodeProvider).requestFocus();
        Future.microtask(() {
          ref.read(bibleSearchQueryProvider.notifier).state = null;
        });
      }
    });

    return Column(
      children: [
        // Top Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          color: Colors.black12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: _isDualVersionMode ? 2 : 3,
                child: TextField(
                  controller: _searchController,
                  focusNode: ref.read(bibleSearchFocusNodeProvider),
                  textAlignVertical: TextAlignVertical.center,
                  onSubmitted: (val) {
                    _handleSearch(val, ref);
                  },
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    isDense: true,
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    hintText: 'Search (e.g. gen 1:3, John 3:1-5)',
                    prefixIcon: const Icon(Icons.search, size: 14),
prefixIconConstraints: const BoxConstraints.tightFor(width: 28, height: 28),
suffixIcon: SizedBox(
  width: 56,
  height: 28,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
        icon: const Icon(Icons.file_download_outlined, size: 14),
        tooltip: 'Import Verses',
        onPressed: () => _showImportVersesDialog(ref),
      ),
      IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
        icon: const Icon(Icons.filter_2_outlined, size: 14),
        tooltip: 'Dual Version Mode',
        onPressed: () {
  setState(() {
    _isDualVersionMode = !_isDualVersionMode;
  });
},
      ),
    ],
  ),
),
suffixIconConstraints: const BoxConstraints.tightFor(width: 56, height: 28),
                    filled: true,
                    fillColor: Colors.black26,
                  border: OutlineInputBorder(
  borderRadius: BorderRadius.circular(4),
  borderSide: BorderSide.none,
),
                ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 1,
                child: bibleVersionsAsync.when(
                  data: (versions) {
                    if (versions.isEmpty) {
                      return const Center(child: Text('No Bibles', style: TextStyle(fontSize: 10, color: Colors.grey)));
                    }
                    
                    // Auto-select first version if none selected
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (ref.read(selectedBibleVersionProvider) == null) {
                        ref.read(selectedBibleVersionProvider.notifier).state = versions.first;
                      }
                    });

                    final currentSelected = ref.watch(selectedBibleVersionProvider);
                    final selectedVersion = versions.firstWhere(
                      (v) => currentSelected != null && (v.id == currentSelected.id || (v.abbreviation.isNotEmpty && v.abbreviation == currentSelected.abbreviation)),
                      orElse: () => versions.first,
                    );

                    return Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<BibleVersion>(
                          value: selectedVersion,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, size: 14),
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                          onChanged: (version) {
                            ref.read(selectedBibleVersionProvider.notifier).state = version;
                          },
                          items: versions.map((v) {
                            return DropdownMenuItem(
                              value: v,
                              child: Text(v.abbreviation, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))),
                  error: (e, st) => const Text('Error', style: TextStyle(fontSize: 10)),
                ),
              ),
              if (_isDualVersionMode) ...[
  const SizedBox(width: 4),
  Expanded(
    flex: 1,
    child: bibleVersionsAsync.when(
      data: (versions) {
        if (versions.isEmpty) {
          return const Center(child: Text('No Bibles', style: TextStyle(fontSize: 10, color: Colors.grey)));
        }

        final currentSelected = ref.watch(selectedBibleVersionProvider);
        final selectedVersion = versions.firstWhere(
          (v) => currentSelected != null && (v.id == currentSelected.id || (v.abbreviation.isNotEmpty && v.abbreviation == currentSelected.abbreviation)),
          orElse: () => versions.first,
        );
        final secondaryVersion = versions.firstWhere(
          (v) => _secondaryBibleVersion != null && (v.id == _secondaryBibleVersion!.id || (v.abbreviation.isNotEmpty && v.abbreviation == _secondaryBibleVersion!.abbreviation)),
          orElse: () => versions.firstWhere(
            (version) => version != selectedVersion,
            orElse: () => selectedVersion,
          ),
        );
        
        return Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<BibleVersion>(
              value: secondaryVersion,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 14),
              style: const TextStyle(fontSize: 11, color: Colors.white),
              onChanged: (version) {
                setState(() {
                  _secondaryBibleVersion = version;
                });
              },
              items: versions.map((version) {
                return DropdownMenuItem(
                  value: version,
                  child: Text(version.abbreviation, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Center(child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))),
      error: (e, st) => const Text('Error', style: TextStyle(fontSize: 10)),
      ),
    ),
                ],
            ],
          ),
        ),

        // List Boxes
        if(!_isButtonViewMode)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: _buildListBox(
                  title: 'OT',
                  focusNode: _otFocusNode,
                  scrollController: _otScrollController,
                  items: BibleConstants.oldTestamentBooks,
                  selectedValue: ref.watch(selectedBookProvider),
                  onSelected: (val) {
                    ref.read(selectedBookProvider.notifier).state = val;
                    // Default select 1st chapter and 1st verse
                    ref.read(selectedChapterProvider.notifier).state = 1;
                    ref.read(selectedVersesProvider.notifier).state = {1};
                    ref.read(secondarySelectedVersesProvider.notifier).state = {1};
                    setState(() => _lastVerseToggled = 1);
                    if (_chScrollController.hasClients) _chScrollController.jumpTo(0);
                    if (_vsScrollController.hasClients) _vsScrollController.jumpTo(0);
                  },
                  onEnter: () {
                    final preview = ref.read(biblePreviewVersesProvider).valueOrNull;
                    final version = ref.read(selectedBibleVersionProvider);
                    if (preview != null && preview.isNotEmpty && version != null) {
                      _addToSetlist(preview, version, ref, goLive: true);
                    }
                  },
                ),
              ),
              const VerticalDivider(width: 1, color: Colors.black),
              Expanded(
                flex: 4,
                child: _buildListBox(
                  title: 'NT',
                  focusNode: _ntFocusNode,
                  scrollController: _ntScrollController,
                  items: BibleConstants.newTestamentBooks,
                  selectedValue: ref.watch(selectedBookProvider),
                  onSelected: (val) {
                    ref.read(selectedBookProvider.notifier).state = val;
                    // Default select 1st chapter and 1st verse
                    ref.read(selectedChapterProvider.notifier).state = 1;
                    ref.read(selectedVersesProvider.notifier).state = {1};
                    ref.read(secondarySelectedVersesProvider.notifier).state = {1};
                    setState(() => _lastVerseToggled = 1);
                    if (_chScrollController.hasClients) _chScrollController.jumpTo(0);
                    if (_vsScrollController.hasClients) _vsScrollController.jumpTo(0);
                  },
                  onEnter: () {
                    final preview = ref.read(biblePreviewVersesProvider).valueOrNull;
                    final version = ref.read(selectedBibleVersionProvider);
                    if (preview != null && preview.isNotEmpty && version != null) {
                      _addToSetlist(preview, version, ref, goLive: true);
                    }
                  },
                ),
              ),
              const VerticalDivider(width: 1, color: Colors.black),
              Expanded(
                flex: 2,
                child: _buildAsyncListBox(
                  title: 'Ch',
                  focusNode: _chFocusNode,
                  scrollController: _chScrollController,
                  asyncItems: ref.watch(availableChaptersProvider),
                  selectedValue: ref.watch(selectedChapterProvider),
                  onSelected: (val) {
                    ref.read(selectedChapterProvider.notifier).state = val;
                    // Default select 1st verse
                    ref.read(selectedVersesProvider.notifier).state = {1};
                    ref.read(secondarySelectedVersesProvider.notifier).state = {1};
                    setState(() => _lastVerseToggled = 1);
                    if (_vsScrollController.hasClients) _vsScrollController.jumpTo(0);
                  },
                  onEnter: () {
                    final preview = ref.read(biblePreviewVersesProvider).valueOrNull;
                    final version = ref.read(selectedBibleVersionProvider);
                    if (preview != null && preview.isNotEmpty && version != null) {
                      _addToSetlist(preview, version, ref, goLive: true);
                    }
                  },
                ),
              ),
              const VerticalDivider(width: 1, color: Colors.black),
              Expanded(
                flex: 2,
                child: _buildMultiSelectAsyncListBox<int>(
                  title: 'Vs',
                  focusNode: ref.read(bibleVerseListFocusNodeProvider),
                  scrollController: _vsScrollController,
                  asyncItems: ref.watch(availableVersesProvider),
                  selectedValues: ref.watch(selectedVersesProvider),
                  onEnter: () {
                    final preview = ref.read(biblePreviewVersesProvider).valueOrNull;
                    final version = ref.read(selectedBibleVersionProvider);
                    if (preview != null && preview.isNotEmpty && version != null) {
                      _addToSetlist(preview, version, ref, goLive: true);
                    }
                  },
                  onTab: () {
                    _addButtonFocusNode.requestFocus();
                  },
                  onSelectAll: () {
                    final items = ref.read(availableVersesProvider).valueOrNull;
                    if (items != null && items.isNotEmpty) {
                      final allVersesSet = items.toSet();
                      ref.read(selectedVersesProvider.notifier).state = allVersesSet;
                      ref.read(secondarySelectedVersesProvider.notifier).state = Set<int>.from(allVersesSet);
                    }
                  },
                  onSelected: (val, isSelected, allItems) {
                  final current = Set<int>.from(ref.read(selectedVersesProvider));
                  
                  final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
                  final isControlPressed = HardwareKeyboard.instance.isControlPressed;

                  if (isShiftPressed && _lastVerseToggled != null && allItems.contains(_lastVerseToggled)) {
                    // Shift+Click: Range selection (additive)
                    final start = allItems.indexOf(_lastVerseToggled!);
                    final end = allItems.indexOf(val);
                    final rangeStart = start < end ? start : end;
                    final rangeEnd = start < end ? end : start;
                    
                    for (int i = rangeStart; i <= rangeEnd; i++) {
                      current.add(allItems[i]);
                    }
                  } else if (isControlPressed) {
                    // Ctrl+Click: Toggle selection
                    if (current.contains(val)) {
                      current.remove(val);
                    } else {
                      current.add(val);
                    }
                  } else {
                    // Normal Click: Select only this one
                    current.clear();
                    current.add(val);
                  }
                  
                  _lastVerseToggled = val;
                  ref.read(selectedVersesProvider.notifier).state = current;
                },
              ),
            ),
          ],
        ),
      ),

        // Preview Pane
        if(_isButtonViewMode)
            Expanded(child: _buildPreviewPane(ref))
        else
            _buildPreviewPane(ref),
      ],
    );
  }

  Widget _buildListBox<T>({
    required String title,
    required List<T> items,
    required T? selectedValue,
    required Function(T) onSelected,
    required FocusNode focusNode,
    ScrollController? scrollController,
    VoidCallback? onEnter,
  }) {
    return Column(
      children: [
        Container(
          color: Colors.black38,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
        ),
        Expanded(
          child: Focus(
            focusNode: focusNode,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;

              if (event.logicalKey == LogicalKeyboardKey.enter && onEnter != null) {
                onEnter();
                return KeyEventResult.handled;
              }

              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                final currentIndex = items.indexOf(selectedValue as dynamic);
                if (currentIndex < items.length - 1) {
                  onSelected(items[currentIndex + 1]);
                  if (scrollController != null) _scrollToEnsureVisible(scrollController, currentIndex + 1);
                } else if (currentIndex == -1 && items.isNotEmpty) {
                  onSelected(items[0]);
                  if (scrollController != null) _scrollToEnsureVisible(scrollController, 0);
                }
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                final currentIndex = items.indexOf(selectedValue as dynamic);
                if (currentIndex > 0) {
                  onSelected(items[currentIndex - 1]);
                  if (scrollController != null) _scrollToEnsureVisible(scrollController, currentIndex - 1);
                }
                return KeyEventResult.handled;
              }

              return KeyEventResult.ignored;
            },
            child: ListView.builder(
              controller: scrollController,
              itemExtent: 24.0,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item == selectedValue;
                return InkWell(
                  onTap: () {
                    onSelected(item);
                    focusNode.requestFocus();
                  },
                  child: Container(
                    color: isSelected ? Colors.blueAccent.withValues(alpha: 0.3) : Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Text(item.toString(), style: const TextStyle(fontSize: 11)),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAsyncListBox<T>({
    required String title,
    required AsyncValue<List<T>> asyncItems,
    required T? selectedValue,
    required Function(T) onSelected,
    required FocusNode focusNode,
    ScrollController? scrollController,
    VoidCallback? onEnter,
  }) {
    return Column(
      children: [
        Container(
          color: Colors.black38,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
        ),
        Expanded(
          child: Focus(
            focusNode: focusNode,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;

              if (event.logicalKey == LogicalKeyboardKey.enter && onEnter != null) {
                onEnter();
                return KeyEventResult.handled;
              }

              final items = asyncItems.valueOrNull;
              if (items != null && items.isNotEmpty) {
                if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  final currentIndex = items.indexOf(selectedValue as dynamic);
                  if (currentIndex < items.length - 1) {
                    onSelected(items[currentIndex + 1]);
                    if (scrollController != null) _scrollToEnsureVisible(scrollController, currentIndex + 1);
                  } else if (currentIndex == -1) {
                    onSelected(items[0]);
                    if (scrollController != null) _scrollToEnsureVisible(scrollController, 0);
                  }
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  final currentIndex = items.indexOf(selectedValue as dynamic);
                  if (currentIndex > 0) {
                    onSelected(items[currentIndex - 1]);
                    if (scrollController != null) _scrollToEnsureVisible(scrollController, currentIndex - 1);
                  }
                  return KeyEventResult.handled;
                }
              }

              return KeyEventResult.ignored;
            },
            child: () {
              final items = asyncItems.valueOrNull;
              if (items != null) {
                return ListView.builder(
                  controller: scrollController,
                  itemExtent: 24.0,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == selectedValue;
                    return InkWell(
                      onTap: () {
                        onSelected(item);
                        focusNode.requestFocus();
                      },
                      child: Container(
                        color: isSelected ? Colors.blueAccent.withValues(alpha: 0.3) : Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Text(item.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                      ),
                    );
                  },
                );
              }
              if (asyncItems.isLoading) {
                return const SizedBox.shrink();
              }
              return const Center(child: Text('Error', style: TextStyle(fontSize: 10)));
            }(),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectAsyncListBox<T>({
    required String title,
    required AsyncValue<List<T>> asyncItems,
    required Set<T> selectedValues,
    required Function(T, bool, List<T>) onSelected,
    FocusNode? focusNode,
    ScrollController? scrollController,
    VoidCallback? onEnter,
    VoidCallback? onTab,
    VoidCallback? onSelectAll,
  }) {
    return Column(
      children: [
        Container(
          color: Colors.black38,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
        ),
        Expanded(
          child: Focus(
            focusNode: focusNode,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;

              if (event.logicalKey == LogicalKeyboardKey.enter && onEnter != null) {
                onEnter();
                return KeyEventResult.handled;
              }

              if (event.logicalKey == LogicalKeyboardKey.tab && onTab != null) {
                onTab();
                return KeyEventResult.handled;
              }

              if (HardwareKeyboard.instance.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyA) {
                if (onSelectAll != null) {
                  onSelectAll();
                  return KeyEventResult.handled;
                }
              }

              final items = asyncItems.valueOrNull;
              if (items != null && items.isNotEmpty) {
                if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  // Get the last selected item or the first one
                  final lastItem = _lastVerseToggled as T?;
                  final currentIndex = lastItem != null ? items.indexOf(lastItem) : -1;
                  if (currentIndex < items.length - 1) {
                    onSelected(items[currentIndex + 1], true, items);
                    if (scrollController != null) _scrollToEnsureVisible(scrollController, currentIndex + 1);
                  }
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  final lastItem = _lastVerseToggled as T?;
                  final currentIndex = lastItem != null ? items.indexOf(lastItem) : -1;
                  if (currentIndex > 0) {
                    onSelected(items[currentIndex - 1], true, items);
                    if (scrollController != null) _scrollToEnsureVisible(scrollController, currentIndex - 1);
                  }
                  return KeyEventResult.handled;
                }
              }

              return KeyEventResult.ignored;
            },
            child: () {
              final items = asyncItems.valueOrNull;
              if (items != null) {
                return ListView.builder(
                  controller: scrollController,
                  itemExtent: 24.0,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = selectedValues.contains(item);
                    return InkWell(
                      onTap: () {
                        onSelected(item, !isSelected, items);
                        focusNode?.requestFocus();
                      },
                      child: Container(
                        color: isSelected ? Colors.blueAccent.withValues(alpha: 0.3) : Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Text(item.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                      ),
                    );
                  },
                );
              }
              if (asyncItems.isLoading) {
                return const SizedBox.shrink();
              }
              return const Center(child: Text('Error', style: TextStyle(fontSize: 10)));
            }(),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewPane(WidgetRef ref) {
    final previewAsync = ref.watch(biblePreviewVersesProvider);
    final selectedVersion = ref.watch(selectedBibleVersionProvider);
    final bibleVersions = ref.watch(bibleVersionsProvider).valueOrNull ?? [];
final selectedBook = ref.watch(selectedBookProvider);
final selectedChapter = ref.watch(selectedChapterProvider);
final selectedVerses = ref.watch(selectedVersesProvider);
    final secondarySelectedVerses = ref.watch(secondarySelectedVersesProvider);
    final secondaryVersion = _isDualVersionMode
        ? _secondaryBibleVersion ?? bibleVersions.where((version) => version.id != selectedVersion?.id).firstOrNull
        : null;
    final canShowSecondary = secondaryVersion != null &&
        secondaryVersion.id != selectedVersion?.id &&
        selectedBook != null &&
        selectedChapter != null &&
        secondarySelectedVerses.isNotEmpty;
    final secondaryPreviewAsync = canShowSecondary
        ? ref.watch(
            bibleVersesForSelectionProvider((
              versionId: secondaryVersion.id,
              book: selectedBook,
              chapter: selectedChapter,
              verses: secondarySelectedVerses,
            )),
          )
        : const AsyncValue<List<BibleVerse>>.data([]);

    return Container(
      height: _isButtonViewMode ? null : 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: const Border(top: BorderSide(color: Colors.blueAccent, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: Colors.black26,
            child: Row(
              children: [
                Expanded(
                  child: previewAsync.when(
                    data: (verses) {
                      if (verses.isEmpty) return const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent));
                      
                      final book = verses.first.bookName;
                      final chapter = verses.first.chapterNumber;
                      return Text(
                        '$book $chapter',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                    loading: () => const Text('Loading...', style: TextStyle(fontSize: 12, color: Colors.blueAccent)),
                    error: (_, __) => const Text('Error', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                  ),
                ),
                Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints.tightFor(width: 28, height: 20),
  icon: Icon(_isButtonViewMode ? Icons.view_week_sharp : Icons.apps, size: 18),
  color: Colors.blueAccent,
  tooltip: _isButtonViewMode ? 'List View Mode' : 'Button View Mode',
  onPressed: () {
    setState(() {
        _isButtonViewMode = !_isButtonViewMode;
    });
  }
),
    ElevatedButton.icon(
      focusNode: _addButtonFocusNode,
      onPressed: () {
        final verses = previewAsync.valueOrNull;
        if (verses == null || verses.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No verse selected'), duration: Duration(seconds: 2))
          );
          return;
        }
        if (selectedVersion != null) {
          _addToSetlist(verses, selectedVersion, ref, goLive: false);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        minimumSize: const Size(0, 24),
        textStyle: const TextStyle(fontSize: 11),
      ),
      icon: const Icon(Icons.add, size: 12),
      label: const Text('Add'),
    ),
    const SizedBox(width: 4),
    ElevatedButton.icon(
      onPressed: () {
        final verses = previewAsync.valueOrNull;
        if (verses == null || verses.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No verse selected'), duration: Duration(seconds: 2))
          );
          return;
        }
        if (selectedVersion != null) {
          _addToSetlist(verses, selectedVersion, ref, goLive: true);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        minimumSize: const Size(0, 24),
        textStyle: const TextStyle(fontSize: 11),
      ),
      icon: const Icon(Icons.play_arrow, size: 12),
      label: const Text('Show'),
    ),
  ],
)
              ],
            ),
          ),
          Expanded(
            child: _isButtonViewMode
                ? _buildButtonViewPane(ref)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: previewAsync.when(
                        data: (verses) {
                          if (verses.isEmpty) return const Text('Select a verse to preview', style: TextStyle(color: Colors.white54, fontSize: 12));
                          
                          return secondaryPreviewAsync.when(
                            data: (secondaryVerses) => _buildPreviewVerses(
                              verses,
                              canShowSecondary ? selectedVersion : null,
                              secondaryVerses,
                              canShowSecondary ? secondaryVersion : null,
                            ),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, __) => Text(
                              'Error loading secondary verses: $e',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, __) => Text('Error loading verses: $e', style: const TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static const Map<String, String> _buttonBookToCanonical = {
    'Gen': 'Genesis',
    'Exo': 'Exodus',
    'Lev': 'Leviticus',
    'Num': 'Numbers',
    'Deut': 'Deuteronomy',
    'Josh': 'Joshua',
    'Judg': 'Judges',
    'Ruth': 'Ruth',
    '1 Sam': '1 Samuel',
    '2 Sam': '2 Samuel',
    '1 Kin': '1 Kings',
    '2 Kin': '2 Kings',
    '1 Chr': '1 Chronicles',
    '2 Chr': '2 Chronicles',
    'Ezra': 'Ezra',
    'Neh': 'Nehemiah',
    'Esth': 'Esther',
    'Job': 'Job',
    'Psa': 'Psalms',
    'Pro': 'Proverbs',
    'Eccl': 'Ecclesiastes',
    'Songs': 'Song of Solomon',
    'Isa': 'Isaiah',
    'Jer': 'Jeremiah',
    'Lam': 'Lamentations',
    'Eze': 'Ezekiel',
    'Dan': 'Daniel',
    'Hos': 'Hosea',
    'Joel': 'Joel',
    'Amos': 'Amos',
    'Obad': 'Obadiah',
    'Jona': 'Jonah',
    'Mica': 'Micah',
    'Nah': 'Nahum',
    'Hab': 'Habakkuk',
    'Zeph': 'Zephaniah',
    'Hag': 'Haggai',
    'Zech': 'Zechariah',
    'Mal': 'Malachi',
    'Mat': 'Matthew',
    'Mark': 'Mark',
    'Luke': 'Luke',
    'John': 'John',
    'Acts': 'Acts',
    'Rom': 'Romans',
    '1 Cor': '1 Corinthians',
    '2 Cor': '2 Corinthians',
    'Gal': 'Galatians',
    'Eph': 'Ephesians',
    'Philp': 'Philippians',
    'Col': 'Colossians',
    '1 Thes': '1 Thessalonians',
    '2 Thes': '2 Thessalonians',
    '1 Tim': '1 Timothy',
    '2 Tim': '2 Timothy',
    'Titus': 'Titus',
    'Philm': 'Philemon',
    'Heb': 'Hebrews',
    'Jam': 'James',
    '1 Pet': '1 Peter',
    '2 Pet': '2 Peter',
    '1 Jhn': '1 John',
    '2 Jhn': '2 John',
    '3 Jhn': '3 John',
    'Jude': 'Jude',
    'Rev': 'Revelation',
  };

  Widget _buildButtonViewPane(WidgetRef ref) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          color: Colors.black26,
          child: Row(
            children: [
              _buildTabSegmentButton('Books'),
              const SizedBox(width: 4),
              _buildTabSegmentButton('Chapters'),
              const SizedBox(width: 4),
              _buildTabSegmentButton('Verses'),
            ],
          ),
        ),
        Expanded(
          child: (_selectedButtonViewTab == 'Verses' && _showVerseTextList)
              ? Padding(
                  padding: const EdgeInsets.all(4),
                  child: _buildButtonVersesView(ref),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: double.infinity,
                    child: _selectedButtonViewTab == 'Books'
                        ? _buildButtonBooksView(ref)
                        : _selectedButtonViewTab == 'Chapters'
                            ? _buildButtonChaptersView(ref)
                            : _buildButtonVersesView(ref),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTabSegmentButton(String title) {
    final isSelected = _selectedButtonViewTab == title;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blueAccent : Colors.black45,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 4),
          minimumSize: const Size(0, 24),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: () {
          setState(() {
            _selectedButtonViewTab = title;
            if (title == 'Verses') {
              _showVerseTextList = false;
            }
          });
        },
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonBooksView(WidgetRef ref) {
    final selectedBook = ref.watch(selectedBookProvider);
    const otRows = [
      ['Gen', 'Exo', 'Lev', 'Num', 'Deut'],
      ['Josh', 'Judg', 'Ruth', '1 Sam', '2 Sam'],
      ['1 Kin', '2 Kin', '1 Chr', '2 Chr'],
      ['Ezra', 'Neh', 'Esth'],
      ['Job', 'Psa', 'Pro', 'Eccl', 'Songs'],
      ['Isa', 'Jer', 'Lam', 'Eze', 'Dan'],
      ['Hos', 'Joel', 'Amos', 'Obad'],
      ['Jona', 'Mica', 'Nah', 'Hab'],
      ['Zeph', 'Hag', 'Zech', 'Mal'],
    ];

    const ntRows = [
      ['Mat', 'Mark', 'Luke', 'John'],
      ['Acts', 'Rom', '1 Cor', '2 Cor'],
      ['Gal', 'Eph', 'Philp', 'Col'],
      ['1 Thes', '2 Thes', '1 Tim', '2 Tim'],
      ['Titus', 'Philm', 'Heb', 'Jam'],
      ['1 Pet', '2 Pet', '1 Jhn', '2 Jhn', '3 Jhn'],
      ['Jude', 'Rev'],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4.0, left: 2.0),
          child: Text(
            'Old Testament',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
        ),
        ...otRows.map((row) => _buildBookButtonRow(row, selectedBook, ref, isOT: true)),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.only(bottom: 4.0, left: 2.0),
          child: Text(
            'New Testament',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
        ),
        ...ntRows.map((row) => _buildBookButtonRow(row, selectedBook, ref, isOT: false)),
      ],
    );
  }

  Widget _buildTactilePillButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    Color? selectedColor,
    double height = 24,
    double fontSize = 10.5,
  }) {
    final isGreen = selectedColor == const Color(0xFF88C025) || selectedColor == const Color(0xFF8DB82E);

    final List<Color> gradientColors;
    final Color textColor;

    if (isSelected) {
      if (isGreen) {
        gradientColors = const [Color(0xFF9EC433), Color(0xFF6F981C)];
        textColor = const Color(0xFF1E2B00);
      } else {
        gradientColors = const [Color(0xFF4FB5D7), Color(0xFF3690B2)];
        textColor = const Color(0xFF0F2B3B);
      }
    } else {
      gradientColors = const [Color(0xFFACAFB5), Color(0xFF878A90)];
      textColor = const Color(0xFF1E2023);
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            offset: const Offset(0, 2),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            offset: const Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookButtonRow(List<String> books, String? selectedBook, WidgetRef ref, {required bool isOT}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: books.map((abbrev) {
          final canonical = _buttonBookToCanonical[abbrev];
          final isSelected = canonical != null && canonical == selectedBook;
          final selectedColor = isOT ? const Color(0xFF88C025) : const Color(0xFF4FB5D7);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: _buildTactilePillButton(
                text: abbrev,
                isSelected: isSelected,
                selectedColor: selectedColor,
                onTap: () {
                  if (canonical != null) {
                    ref.read(selectedBookProvider.notifier).state = canonical;
                    ref.read(selectedChapterProvider.notifier).state = 1;
                    ref.read(selectedVersesProvider.notifier).state = {1};
                    ref.read(secondarySelectedVersesProvider.notifier).state = {1};
                    setState(() {
                      _lastVerseToggled = 1;
                      _selectedButtonViewTab = 'Chapters';
                      _showVerseTextList = false;
                    });
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumberGridRows({
    required List<int> numbers,
    required bool Function(int) isSelected,
    required void Function(int) onTap,
  }) {
    const int itemsPerRow = 5;
    final rows = <List<int>>[];
    for (int i = 0; i < numbers.length; i += itemsPerRow) {
      rows.add(numbers.sublist(i, (i + itemsPerRow > numbers.length) ? numbers.length : i + itemsPerRow));
    }

    return Column(
      children: rows.map((rowItems) {
        final children = <Widget>[];
        for (final n in rowItems) {
          final sel = isSelected(n);
          children.add(
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: _buildTactilePillButton(
                  text: '$n',
                  isSelected: sel,
                  selectedColor: const Color(0xFF4FB5D7),
                  onTap: () => onTap(n),
                ),
              ),
            ),
          );
        }
        while (children.length < itemsPerRow) {
          children.add(const Expanded(child: SizedBox()));
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(children: children),
        );
      }).toList(),
    );
  }

  Widget _buildButtonChaptersView(WidgetRef ref) {
    final selectedBook = ref.watch(selectedBookProvider);
    if (selectedBook == null) {
      return const Center(
        child: Text('Select a book first', style: TextStyle(color: Colors.white54, fontSize: 12)),
      );
    }
    final chaptersAsync = ref.watch(availableChaptersProvider);
    return chaptersAsync.when(
      data: (chapters) {
        final selectedChapter = ref.watch(selectedChapterProvider);
        return _buildNumberGridRows(
          numbers: chapters,
          isSelected: (ch) => ch == selectedChapter,
          onTap: (ch) {
            ref.read(selectedChapterProvider.notifier).state = ch;
            ref.read(selectedVersesProvider.notifier).state = {1};
            ref.read(secondarySelectedVersesProvider.notifier).state = {1};
            setState(() {
              _lastVerseToggled = 1;
              _selectedButtonViewTab = 'Verses';
              _showVerseTextList = false;
            });
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading chapters: $e', style: const TextStyle(color: Colors.redAccent)),
    );
  }

  Widget _buildButtonVersesView(WidgetRef ref) {
    final selectedChapter = ref.watch(selectedChapterProvider);
    if (selectedChapter == null) {
      return const Center(
        child: Text('Select a chapter first', style: TextStyle(color: Colors.white54, fontSize: 12)),
      );
    }

    if (_showVerseTextList) {
      return _buildButtonVersesTextView(ref);
    }

    final versesAsync = ref.watch(availableVersesProvider);
    return versesAsync.when(
      data: (verses) {
        final selectedVerses = ref.watch(selectedVersesProvider);
        return _buildNumberGridRows(
          numbers: verses,
          isSelected: (vs) => selectedVerses.contains(vs),
          onTap: (vs) {
            final current = {vs};
            _lastVerseToggled = vs;
            ref.read(selectedVersesProvider.notifier).state = current;
            ref.read(secondarySelectedVersesProvider.notifier).state = Set<int>.from(current);
            setState(() {
              _showVerseTextList = true;
            });
            _scrollToSelectedVerse(vs, verses);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading verses: $e', style: const TextStyle(color: Colors.redAccent)),
    );
  }

  Widget _buildButtonVersesTextView(WidgetRef ref) {
    final allVersesAsync = ref.watch(chapterAllVersesProvider);
    final selectedVerses = ref.watch(selectedVersesProvider);
    final secondarySelectedVerses = ref.watch(secondarySelectedVersesProvider);
    final primaryVerses = allVersesAsync.valueOrNull ?? [];

    final selectedVersion = ref.watch(selectedBibleVersionProvider);
    final bibleVersions = ref.watch(bibleVersionsProvider).valueOrNull ?? [];
    final selectedBook = ref.watch(selectedBookProvider);
    final selectedChapter = ref.watch(selectedChapterProvider);

    final secondaryVersion = _isDualVersionMode
        ? _secondaryBibleVersion ?? bibleVersions.where((version) => version.id != selectedVersion?.id).firstOrNull
        : null;

    final canShowSecondary = _isDualVersionMode &&
        secondaryVersion != null &&
        secondaryVersion.id != selectedVersion?.id &&
        selectedBook != null &&
        selectedChapter != null;

    final secondaryVersesAsync = canShowSecondary
        ? ref.watch(
            chapterAllVersesForVersionProvider((
              versionId: secondaryVersion.id,
              book: selectedBook,
              chapter: selectedChapter,
            )),
          )
        : const AsyncValue<List<BibleVerse>>.data([]);

    if (allVersesAsync.isLoading || (canShowSecondary && secondaryVersesAsync.isLoading)) {
      return const Center(child: CircularProgressIndicator());
    }

    final secondaryVerses = secondaryVersesAsync.valueOrNull ?? [];

    final primaryMap = {for (final v in primaryVerses) v.verseNumber: v};
    final secondaryMap = {for (final v in secondaryVerses) v.verseNumber: v};
    final allVerseNumbers = {...primaryMap.keys, ...secondaryMap.keys}.toList()..sort();

    final flatVerseItems = <({int verseNumber, BibleVerse verse, bool isSecondary})>[];

    for (final vsNum in allVerseNumbers) {
      final primaryVerse = primaryMap[vsNum];
      if (primaryVerse != null) {
        flatVerseItems.add((verseNumber: vsNum, verse: primaryVerse, isSecondary: false));
      }
      final secondaryVerse = secondaryMap[vsNum];
      if (canShowSecondary && secondaryVerse != null) {
        flatVerseItems.add((verseNumber: vsNum, verse: secondaryVerse, isSecondary: true));
      }
    }

    return Focus(
      focusNode: ref.read(bibleVerseListFocusNodeProvider),
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        if (event.logicalKey == LogicalKeyboardKey.enter) {
          final preview = ref.read(biblePreviewVersesProvider).valueOrNull;
          final version = ref.read(selectedBibleVersionProvider);
          if (preview != null && preview.isNotEmpty && version != null) {
            _addToSetlist(preview, version, ref, goLive: true);
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: ListView.separated(
        controller: _buttonVerseTextScrollController,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        itemCount: flatVerseItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white12),
        itemBuilder: (context, index) {
          final rowItem = flatVerseItems[index];
          final vsNum = rowItem.verseNumber;
          final isSelected = rowItem.isSecondary
              ? secondarySelectedVerses.contains(vsNum)
              : selectedVerses.contains(vsNum);

          _buttonVerseKeys.putIfAbsent(vsNum, () => GlobalKey());
          final isFirstOfVerseNumber = !rowItem.isSecondary || primaryMap[vsNum] == null;

          return InkWell(
            key: isFirstOfVerseNumber ? _buttonVerseKeys[vsNum] : null,
            onTap: () {
              _handleButtonVerseTextSelection(vsNum, allVerseNumbers, isSecondary: rowItem.isSecondary);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.35),
                      border: Border.all(color: Colors.blueAccent, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : const BoxDecoration(
                      color: Colors.transparent,
                    ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, height: 1.4),
                  children: [
                    TextSpan(
                      text: '${rowItem.verse.verseNumber} ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.lightBlueAccent : Colors.blueAccent,
                      ),
                    ),
                    TextSpan(
                      text: rowItem.verse.text.trim(),
                      style: TextStyle(
                        color: rowItem.isSecondary
                            ? const Color.fromARGB(255, 205, 181, 143)
                            : (isSelected ? Colors.white : Colors.white70),
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleButtonVerseTextSelection(int val, List<int> allItems, {bool isSecondary = false}) {
    final primaryCurrent = Set<int>.from(ref.read(selectedVersesProvider));
    final secondaryCurrent = Set<int>.from(ref.read(secondarySelectedVersesProvider));
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
    final isControlPressed = HardwareKeyboard.instance.isControlPressed;

    if (isShiftPressed && _lastVerseToggled != null && allItems.contains(_lastVerseToggled)) {
      // Shift+Click: Range selection
      final start = allItems.indexOf(_lastVerseToggled!);
      final end = allItems.indexOf(val);
      final rangeStart = start < end ? start : end;
      final rangeEnd = start < end ? end : start;

      for (int i = rangeStart; i <= rangeEnd; i++) {
        primaryCurrent.add(allItems[i]);
        secondaryCurrent.add(allItems[i]);
      }
      ref.read(selectedVersesProvider.notifier).state = primaryCurrent;
      ref.read(secondarySelectedVersesProvider.notifier).state = secondaryCurrent;
    } else if (isControlPressed) {
      // Ctrl+Click: Independent toggle for specific version row
      if (_isDualVersionMode && isSecondary) {
        if (secondaryCurrent.contains(val)) {
          secondaryCurrent.remove(val);
        } else {
          secondaryCurrent.add(val);
        }
        ref.read(secondarySelectedVersesProvider.notifier).state = secondaryCurrent;
      } else {
        if (primaryCurrent.contains(val)) {
          primaryCurrent.remove(val);
        } else {
          primaryCurrent.add(val);
        }
        if (!_isDualVersionMode) {
          ref.read(secondarySelectedVersesProvider.notifier).state = Set<int>.from(primaryCurrent);
        }
        ref.read(selectedVersesProvider.notifier).state = primaryCurrent;
      }
    } else {
      // Normal Click: Reset and select val for both primary and secondary
      primaryCurrent.clear();
      primaryCurrent.add(val);
      secondaryCurrent.clear();
      secondaryCurrent.add(val);
      ref.read(selectedVersesProvider.notifier).state = primaryCurrent;
      ref.read(secondarySelectedVersesProvider.notifier).state = secondaryCurrent;
    }

    _lastVerseToggled = val;
  }

  Widget _buildPreviewVerses(
  List<BibleVerse> primaryVerses,
  BibleVersion? primaryVersion,
  List<BibleVerse> secondaryVerses,
  BibleVersion? secondaryVersion,
) {
  final primaryByNumber = {for (final verse in primaryVerses) verse.verseNumber: verse};
  final secondaryByNumber = {for (final verse in secondaryVerses) verse.verseNumber: verse};
  final verseNumbers = {...primaryByNumber.keys, ...secondaryByNumber.keys}.toList()..sort();
  final rows = <Widget>[];

  for (final verseNumber in verseNumbers) {
    final primaryVerse = primaryByNumber[verseNumber];
    if (primaryVerse != null) {
      rows.add(_buildPreviewVerseRow(primaryVerse, primaryVersion?.abbreviation));
    }

    final secondaryVerse = secondaryByNumber[verseNumber];
    if (secondaryVerse != null) {
      rows.add(_buildPreviewVerseRow(secondaryVerse, secondaryVersion?.abbreviation, isSecondary: true));
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: rows,
  );
  }

  Widget _buildPreviewVerseRow(BibleVerse verse, String? versionAbbreviation, {bool isSecondary = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
        children: [
          // if (versionAbbreviation != null)
          //   TextSpan(
          //     text: '[$versionAbbreviation] ',
          //     style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white54),
          //     ),
          TextSpan(
            text: '${verse.verseNumber} ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          TextSpan(
  text: '${verse.text} ',
  style: TextStyle(fontWeight: FontWeight.bold, color: isSecondary ? const Color.fromARGB(255, 205, 181, 143) : Colors.white70),
),
        ],
      ),
    ),
  );
  }
}

typedef _ImportVersesCallback = Future<({int added, int notFound})> Function(List<String> lines);

class _ImportVersesDialog extends StatefulWidget {
  const _ImportVersesDialog({required this.onAdd});

  final _ImportVersesCallback onAdd;

  @override
  State<_ImportVersesDialog> createState() => _ImportVersesDialogState();
}

class _ImportVersesDialogState extends State<_ImportVersesDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Verses'),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: _controller,
          autofocus: true,
          minLines: 6,
          maxLines: 10,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isAdding ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isAdding
              ? null
              : () async {
                  setState(() => _isAdding = true);
                  final lines = _controller.text
                      .split('\n')
                      .map((l) => l.trim())
                      .where((l) => l.isNotEmpty)
                      .toList();
                  final result = await widget.onAdd(lines);
                  if (!mounted) return;
                  Navigator.of(context).pop(result);
                },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
