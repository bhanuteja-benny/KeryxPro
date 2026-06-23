import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../songs/presentation/song_selection_providers.dart';
import '../../../live_controller/presentation/live_projector_providers.dart';
import '../../../live_controller/presentation/slide_utils.dart';
import '../../../live_controller/domain/slide.dart';
import 'slide_item_widget.dart';
import 'package:flutter/services.dart';
import '../global_ui_providers.dart';
import '../../../setlist/presentation/setlist_providers.dart';
import '../../../setlist/data/setlist_item.dart';
import '../../../songs/data/song.dart';
import '../../../bible/domain/bible_constants.dart';
import '../../../bible/data/bible.dart';
import '../../../bible/presentation/bible_providers.dart';
import '../../../../main.dart';

class PreviewPane extends ConsumerStatefulWidget {
  const PreviewPane({super.key});

  @override
  ConsumerState<PreviewPane> createState() => _PreviewPaneState();
}

class _PreviewPaneState extends ConsumerState<PreviewPane> {
  // We use nodes and controllers from the global provider now
  DateTime? _lastLeftPressTime;
  DateTime? _lastRightPressTime;
  String? _originalLeftBaseTitle;
  int? _originalLeftBaseVerse;
  String? _originalRightBaseTitle;
  int? _originalRightBaseVerse;
  int? _lastInsertedIndex;
  DateTime? _lastInsertionTime;

  bool get _canShiftNext {
    final slides = ref.read(currentSlidesProvider);
    final activeIndices = ref.read(activeSlideIndicesProvider);
    if (slides.isEmpty || activeIndices.isEmpty) return false;

    final setlist = ref.read(setlistProvider);
    final slideToItemMapping = ref.read(slideToSetlistItemIndexProvider);

    for (final idx in activeIndices) {
      if (idx < 0 || idx >= slideToItemMapping.length) continue;
      final itemIndex = slideToItemMapping[idx];
      if (itemIndex < 0 || itemIndex >= setlist.length) continue;
      final item = setlist[itemIndex];
      if (item is SongSetlistItem && item.song.author == 'Bible') {
        final firstSlideIndex = getSlideCountForItems(setlist, itemIndex - 1);
        final totalSlidesCount = getSlideCountForItems(setlist, itemIndex) - firstSlideIndex;
        final lastVerseIndex = firstSlideIndex + totalSlidesCount - 2;
        if (idx == lastVerseIndex) {
          return true;
        }
      }
    }
    return false;
  }

  bool get _canShiftPrev {
    final slides = ref.read(currentSlidesProvider);
    final activeIndices = ref.read(activeSlideIndicesProvider);
    if (slides.isEmpty || activeIndices.isEmpty) return false;

    final setlist = ref.read(setlistProvider);
    final slideToItemMapping = ref.read(slideToSetlistItemIndexProvider);

    for (final idx in activeIndices) {
      if (idx < 0 || idx >= slideToItemMapping.length) continue;
      final itemIndex = slideToItemMapping[idx];
      if (itemIndex < 0 || itemIndex >= setlist.length) continue;
      final item = setlist[itemIndex];
      if (item is SongSetlistItem && item.song.author == 'Bible') {
        final firstSlideIndex = getSlideCountForItems(setlist, itemIndex - 1);
        if (idx == firstSlideIndex) {
          return true;
        }
      }
    }
    return false;
  }

  String? _getSlideKey(int index, List<SetlistItem> setlist, List<int> slideToItemMapping) {
    if (index < 0 || index >= slideToItemMapping.length) return null;
    final itemIndex = slideToItemMapping[index];
    if (itemIndex < 0 || itemIndex >= setlist.length) return null;
    final item = setlist[itemIndex];
    final firstSlideIndex = getSlideCountForItems(setlist, itemIndex - 1);
    final relativeIndex = index - firstSlideIndex;
    return "${item.uniqueId}_$relativeIndex";
  }

  void _toggleBookmark() {
    final activeIndex = ref.read(activeSlideIndexProvider);
    final setlist = ref.read(setlistProvider);
    final slideToItemMapping = ref.read(slideToSetlistItemIndexProvider);
    final key = _getSlideKey(activeIndex, setlist, slideToItemMapping);
    if (key == null) return;

    final current = ref.read(slideBookmarksProvider);
    if (current.contains(key)) {
      ref.read(slideBookmarksProvider.notifier).state = current.difference({key});
    } else {
      ref.read(slideBookmarksProvider.notifier).state = current.union({key});
    }
  }

  void _navigateBookmark({required bool goUp}) {
    final bookmarks = ref.read(slideBookmarksProvider);
    if (bookmarks.isEmpty) return;

    final activeIndex = ref.read(activeSlideIndexProvider);
    final setlist = ref.read(setlistProvider);
    final slideToItemMapping = ref.read(slideToSetlistItemIndexProvider);
    final slides = ref.read(currentSlidesProvider);

    final List<int> bookmarkedIndices = [];
    for (int i = 0; i < slides.length; i++) {
      final key = _getSlideKey(i, setlist, slideToItemMapping);
      if (key != null && bookmarks.contains(key)) {
        bookmarkedIndices.add(i);
      }
    }

    if (bookmarkedIndices.isEmpty) return;

    if (goUp) {
      final prev = bookmarkedIndices.where((idx) => idx < activeIndex).toList();
      if (prev.isNotEmpty) {
        prev.sort((a, b) => b.compareTo(a));
        ref.read(activeSlideIndexProvider.notifier).state = prev.first;
      }
    } else {
      final next = bookmarkedIndices.where((idx) => idx > activeIndex).toList();
      if (next.isNotEmpty) {
        next.sort((a, b) => a.compareTo(b));
        ref.read(activeSlideIndexProvider.notifier).state = next.first;
      }
    }
  }

  void _focusScriptureInSearch() {
    final slides = ref.read(currentSlidesProvider);
    final activeIndex = ref.read(activeSlideIndexProvider);
    if (slides.isEmpty || activeIndex < 0 || activeIndex >= slides.length) return;
    final slide = slides[activeIndex];
    if (slide.isSong || slide.isBlank) return;

    ref.read(globalShortcutActionProvider).openBibleTab();
    ref.read(bibleSearchQueryProvider.notifier).state = slide.title;
  }

  void _handleLeftShift() {
    final now = DateTime.now();
    if (_lastLeftPressTime != null && now.difference(_lastLeftPressTime!) < const Duration(milliseconds: 500)) {
      _lastLeftPressTime = null;
      _performShift(stepCount: 2, forward: false);
    } else {
      _lastLeftPressTime = now;
      _performShift(stepCount: 1, forward: false);
    }
  }

  void _handleRightShift() {
    final now = DateTime.now();
    if (_lastRightPressTime != null && now.difference(_lastRightPressTime!) < const Duration(milliseconds: 500)) {
      _lastRightPressTime = null;
      _performShift(stepCount: 2, forward: true);
    } else {
      _lastRightPressTime = now;
      _performShift(stepCount: 1, forward: true);
    }
  }

  Future<void> _performShift({required int stepCount, required bool forward}) async {
    final canShift = forward ? _canShiftNext : _canShiftPrev;
    if (!canShift) return;

    final now = DateTime.now();
    final bool isRecentReplacement = stepCount == 2 &&
        _lastInsertedIndex != null &&
        _lastInsertionTime != null &&
        now.difference(_lastInsertionTime!) < const Duration(milliseconds: 600);

    String baseTitle;
    int baseVerse;
    int? forceInsertAtIndex;

    if (isRecentReplacement) {
      if (forward) {
        if (_originalRightBaseTitle == null || _originalRightBaseVerse == null) return;
        baseTitle = _originalRightBaseTitle!;
        baseVerse = _originalRightBaseVerse!;
      } else {
        if (_originalLeftBaseTitle == null || _originalLeftBaseVerse == null) return;
        baseTitle = _originalLeftBaseTitle!;
        baseVerse = _originalLeftBaseVerse!;
      }
      forceInsertAtIndex = _lastInsertedIndex;
      ref.read(setlistProvider.notifier).removeAtIndices({forceInsertAtIndex!});
      _lastInsertedIndex = null;
    } else {
      final slides = ref.read(currentSlidesProvider);
      final activeIndices = ref.read(activeSlideIndicesProvider);
      if (slides.isEmpty || activeIndices.isEmpty) return;

      int baseIndex;
      if (forward) {
        baseIndex = activeIndices.reduce((a, b) => a > b ? a : b);
      } else {
        baseIndex = activeIndices.reduce((a, b) => a < b ? a : b);
      }

      if (baseIndex < 0 || baseIndex >= slides.length) return;
      final slide = slides[baseIndex];
      if (slide.isSong || slide.isBlank) return;
      baseTitle = slide.title;
      baseVerse = int.tryParse(slide.shortcut) ?? 0;

      if (forward) {
        _originalRightBaseTitle = baseTitle;
        _originalRightBaseVerse = baseVerse;
      } else {
        _originalLeftBaseTitle = baseTitle;
        _originalLeftBaseVerse = baseVerse;
      }
    }

    final match = RegExp(r'^(.+?)\s+(\d+):([\d\-,]+)\s+([a-zA-Z0-9]+)$').firstMatch(baseTitle.trim());
    if (match == null) return;
    final bookName = match.group(1)!;
    final chapter = int.tryParse(match.group(2)!);
    final versionAbbr = match.group(4)!;
    if (chapter == null || baseVerse == 0) return;

    final versionsAsync = ref.read(bibleVersionsProvider);
    final versions = versionsAsync.valueOrNull ?? [];
    final version = versions.firstWhere(
      (v) => v.abbreviation.toLowerCase() == versionAbbr.toLowerCase(),
      orElse: () => versions.first,
    );

    final targetVerses = await _calculateTargetVerses(
      book: bookName,
      chapter: chapter,
      verse: baseVerse,
      versionId: version.id,
      stepCount: stepCount,
      forward: forward,
    );
    if (targetVerses.isEmpty) return;

    targetVerses.sort((a, b) => a.verseNumber.compareTo(b.verseNumber));
    final verseRange = targetVerses.length == 1 
        ? '${targetVerses.first.verseNumber}' 
        : '${targetVerses.first.verseNumber}-${targetVerses.last.verseNumber}';
        
    final targetBook = targetVerses.first.bookName;
    final targetChapter = targetVerses.first.chapterNumber;
    final newTitle = '$targetBook $targetChapter:$verseRange ${version.abbreviation}';

    final lyricsBuffer = StringBuffer();
    for (final v in targetVerses) {
      lyricsBuffer.writeln('[${v.verseNumber}]');
      lyricsBuffer.writeln('${v.verseNumber} ${v.text.trim()}');
      lyricsBuffer.writeln();
    }

    final mockSong = Song()
      ..title = newTitle
      ..author = 'Bible'
      ..lyrics = lyricsBuffer.toString().trim();

    final insertAt = ref.read(setlistProvider.notifier).insertSong(
      mockSong,
      goLive: true,
      selectedIndices: ref.read(setlistSelectionProvider),
      currentDisplayItemIndex: ref.read(currentDisplayItemIndexProvider),
      insertAtIndex: forceInsertAtIndex,
    );

    _lastInsertedIndex = insertAt;
    _lastInsertionTime = DateTime.now();
    final nextIndex = getSlideCountForItems(ref.read(setlistProvider), insertAt - 1);
    ref.read(activeSlideIndexProvider.notifier).state = nextIndex;
    ref.read(slideListFocusNodeProvider).requestFocus();
  }

  Future<List<BibleVerse>> _calculateTargetVerses({
    required String book,
    required int chapter,
    required int verse,
    required int versionId,
    required int stepCount,
    required bool forward,
  }) async {
    final isar = await ref.read(isarServiceProvider).db;
    final allBooks = [...BibleConstants.oldTestamentBooks, ...BibleConstants.newTestamentBooks];
    final currentBookIndex = allBooks.indexWhere((b) => b.toLowerCase() == book.toLowerCase());
    if (currentBookIndex == -1) return [];

    Future<BibleVerse?> stepOne(String b, int c, int v) async {
      if (forward) {
        final next = await isar.bibleVerses
            .filter()
            .bibleVersionIdEqualTo(versionId)
            .bookNameEqualTo(b)
            .chapterNumberEqualTo(c)
            .verseNumberEqualTo(v + 1)
            .findFirst();
        if (next != null) return next;
        
        final nextCh = await isar.bibleVerses
            .filter()
            .bibleVersionIdEqualTo(versionId)
            .bookNameEqualTo(b)
            .chapterNumberEqualTo(c + 1)
            .sortByVerseNumber()
            .findAll();
        if (nextCh.isNotEmpty) return nextCh.first;
        
        int nextBkIdx = allBooks.indexWhere((x) => x.toLowerCase() == b.toLowerCase()) + 1;
        while (nextBkIdx < allBooks.length) {
          final nextBk = allBooks[nextBkIdx];
          final firstVerses = await isar.bibleVerses
              .filter()
              .bibleVersionIdEqualTo(versionId)
              .bookNameEqualTo(nextBk)
              .chapterNumberEqualTo(1)
              .sortByVerseNumber()
              .findAll();
          if (firstVerses.isNotEmpty) return firstVerses.first;
          nextBkIdx++;
        }
        return null;
      } else {
        if (v - 1 >= 1) {
          final prev = await isar.bibleVerses
              .filter()
              .bibleVersionIdEqualTo(versionId)
              .bookNameEqualTo(b)
              .chapterNumberEqualTo(c)
              .verseNumberEqualTo(v - 1)
              .findFirst();
          if (prev != null) return prev;
        }
        if (c - 1 >= 1) {
          final prevCh = await isar.bibleVerses
              .filter()
              .bibleVersionIdEqualTo(versionId)
              .bookNameEqualTo(b)
              .chapterNumberEqualTo(c - 1)
              .sortByVerseNumber()
              .findAll();
          if (prevCh.isNotEmpty) return prevCh.last;
        }
        int prevBkIdx = allBooks.indexWhere((x) => x.toLowerCase() == b.toLowerCase()) - 1;
        while (prevBkIdx >= 0) {
          final prevBk = allBooks[prevBkIdx];
          final lastCh = BibleConstants.getChapterCount(prevBk);
          for (int ch = lastCh; ch >= 1; ch--) {
            final lastChVerses = await isar.bibleVerses
                .filter()
                .bibleVersionIdEqualTo(versionId)
                .bookNameEqualTo(prevBk)
                .chapterNumberEqualTo(ch)
                .sortByVerseNumber()
                .findAll();
            if (lastChVerses.isNotEmpty) return lastChVerses.last;
          }
          prevBkIdx--;
        }
        return null;
      }
    }

    final firstNext = await stepOne(book, chapter, verse);
    if (firstNext == null) return [];
    if (stepCount == 1) return [firstNext];
    final secondNext = await stepOne(firstNext.bookName, firstNext.chapterNumber, firstNext.verseNumber);
    if (secondNext == null) return [firstNext];
    if (secondNext.bookName != firstNext.bookName || secondNext.chapterNumber != firstNext.chapterNumber) {
      return [firstNext];
    }
    return [firstNext, secondNext];
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final slides = ref.read(currentSlidesProvider);
    final activeIndices = ref.read(activeSlideIndicesProvider);
    final navState = ref.read(slideNavigationProvider);
    
    if (slides.isEmpty || activeIndices.isEmpty) return KeyEventResult.ignored;

    final isCtrl = HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;

    if (isCtrl) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _navigateBookmark(goUp: true);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _navigateBookmark(goUp: false);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (_canShiftPrev) {
          _handleLeftShift();
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (_canShiftNext) {
          _handleRightShift();
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyB) {
        _toggleBookmark();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        _focusScriptureInSearch();
        return KeyEventResult.handled;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (navState.nextPrimaryIndex != null) {
        ref.read(activeSlideIndexProvider.notifier).state = navState.nextPrimaryIndex!;
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (navState.prevPrimaryIndex != null) {
        ref.read(activeSlideIndexProvider.notifier).state = navState.prevPrimaryIndex!;
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (navState.nextSecondaryIndex != null) {
        ref.read(activeSlideIndexProvider.notifier).state = navState.nextSecondaryIndex!;
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (navState.prevSecondaryIndex != null) {
        ref.read(activeSlideIndexProvider.notifier).state = navState.prevSecondaryIndex!;
      }
      return KeyEventResult.handled;
    } else if (_isDigit(event.logicalKey)) {
      final currentIndex = activeIndices.first;
      final digit = _getDigit(event.logicalKey);
      _cycleShortcuts(digit, slides, currentIndex);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.keyV) {
      final currentIndex = activeIndices.first;
      _cycleShortcuts('V', slides, currentIndex);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.keyC) {
      final currentIndex = activeIndices.first;
      _cycleShortcuts('C', slides, currentIndex);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.keyB) {
      final currentIndex = activeIndices.first;
      _cycleShortcuts('B', slides, currentIndex);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      final currentIndex = activeIndices.first;
      final currentTitle = slides[currentIndex].title;
      for (int i = currentIndex + 1; i < slides.length; i++) {
        if (slides[i].title != currentTitle) {
          ref.read(activeSlideIndexProvider.notifier).state = i;
          break;
        }
      }
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.tab) {
      final currentIndex = activeIndices.first;
      for (int i = currentIndex + 1; i < slides.length; i++) {
        if (slides[i].isBlank) {
          ref.read(activeSlideIndexProvider.notifier).state = i;
          break;
        }
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool _isDigit(LogicalKeyboardKey key) {
    return key.keyId >= LogicalKeyboardKey.digit1.keyId && key.keyId <= LogicalKeyboardKey.digit9.keyId;
  }

  String _getDigit(LogicalKeyboardKey key) {
    return (key.keyId - LogicalKeyboardKey.digit0.keyId).toString();
  }

  void _cycleShortcuts(String pattern, List<Slide> slides, int currentIndex) {
    final currentSlide = slides[currentIndex];
    
    // logic: If we are on a blank slide, jump to the first match in the NEXT song
    if (currentSlide.isBlank) {
      if (currentIndex < slides.length - 1) {
        // The blank slide marks the end of a song. The next song starts at currentIndex + 1.
        final nextSongTitle = slides[currentIndex + 1].title;
        for (int i = currentIndex + 1; i < slides.length; i++) {
          // If we hit a different title, we've passed the "immediate next song"
          if (slides[i].title != nextSongTitle) break; 
          
          if (slides[i].shortcut.toUpperCase().contains(pattern.toUpperCase())) {
            ref.read(activeSlideIndexProvider.notifier).state = i;
            return;
          }
        }
      }
      return; // No match found in the next song or no next song exists
    }

    // logic: Normal cycling within the SAME song only
    final currentSongTitle = currentSlide.title;
    final indices = <int>[];
    for (int i = 0; i < slides.length; i++) {
      if (slides[i].title == currentSongTitle && 
          slides[i].shortcut.toUpperCase().contains(pattern.toUpperCase())) {
        indices.add(i);
      }
    }

    if (indices.isEmpty) return;

    // Find the next index in the cycle (same song only)
    int nextIndex = indices.first;
    for (final idx in indices) {
      if (idx > currentIndex) {
        nextIndex = idx;
        break;
      }
    }

    ref.read(activeSlideIndexProvider.notifier).state = nextIndex;
  }

  @override
  Widget build(BuildContext context) {
    final setlist = ref.watch(setlistProvider);
    final focusNode = ref.read(slideListFocusNodeProvider);
    final scrollController = ref.read(slideListScrollControllerProvider);

    if (setlist.isEmpty) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Text(
            'Slides\n(Add songs to setlist to see slides)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final activeIndex = ref.watch(activeSlideIndexProvider);
    final activeIndices = ref.watch(activeSlideIndicesProvider);
    final borderActiveIndices = ref.watch(borderActiveSlideIndicesProvider);
    final slides = ref.watch(currentSlidesProvider);

    // Scroll to active index and center it
    ref.listen(activeSlideIndexProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          final slides = ref.read(currentSlidesProvider);
          if (next >= 0 && next < slides.length) {
            final viewportHeight = scrollController.position.viewportDimension;
            final maxScroll = scrollController.position.maxScrollExtent;
            
            double targetTop = 0.0;
            for (int i = 0; i < next; i++) {
              targetTop += slides[i].isBlank ? 24.0 : 28.0;
            }
            double targetHeight = slides[next].isBlank ? 24.0 : 28.0;
            final centerOffset = targetTop - (viewportHeight / 2) + (targetHeight / 2);
            
            scrollController.animateTo(
              centerOffset.clamp(0.0, maxScroll),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    });

    // Auto-focus when a new song is added to the setlist
    ref.listen(setlistProvider, (previous, next) {
      if (previous != null && next.length > previous.length) {
        // A song was added, shift focus to slides
        focusNode.requestFocus();
      }
    });

    final slideToItemMapping = ref.watch(slideToSetlistItemIndexProvider);
    final currentSlide = activeIndex >= 0 && activeIndex < slides.length ? slides[activeIndex] : null;
    final isCurrentSlideScripture = currentSlide != null && !currentSlide.isSong && !currentSlide.isBlank;
    
    final currentSlideKey = _getSlideKey(activeIndex, setlist, slideToItemMapping);
    final isCurrentSlideBookmarked = currentSlideKey != null && ref.watch(slideBookmarksProvider).contains(currentSlideKey);

    return Focus(
      focusNode: focusNode,
      autofocus: false,
      onKeyEvent: (node, event) {
        return _handleKeyEvent(event);
      },
      child: GestureDetector(
        onTap: () => focusNode.requestFocus(),
        child: Container(
          color: Colors.grey[900],
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.black26,
                width: double.infinity,
                child: Row(
                  children: [
                    const Text(
                      'Slides',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.white54),
                    ),
                    if (focusNode.hasFocus) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard, size: 12, color: Colors.blueAccent),
                    ],
                    const Spacer(),
                    
                    // Bookmark Set: Up Arrow, Bookmark, Down Arrow
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2E),
                        border: Border.all(color: Colors.white10),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _HeaderIconButton(
                            icon: Icons.keyboard_arrow_up_rounded,
                            tooltip: 'Go to previous bookmark (Ctrl + Up)',
                            onPressed: ref.watch(slideBookmarksProvider).isEmpty
                                ? null
                                : () => _navigateBookmark(goUp: true),
                          ),
                          _HeaderIconButton(
                            icon: isCurrentSlideBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            tooltip: 'Toggle bookmark (Ctrl + B)',
                            onPressed: _toggleBookmark,
                            isSelected: isCurrentSlideBookmarked,
                          ),
                          _HeaderIconButton(
                            icon: Icons.keyboard_arrow_down_rounded,
                            tooltip: 'Go to next bookmark (Ctrl + Down)',
                            onPressed: ref.watch(slideBookmarksProvider).isEmpty
                                ? null
                                : () => _navigateBookmark(goUp: false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Scripture Set: Double Left, Single Left, Scripture Scroll, Single Right, Double Right
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2E),
                        border: Border.all(color: Colors.white10),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _HeaderIconButton(
                            icon: Icons.keyboard_double_arrow_left_rounded,
                            tooltip: 'Add previous two verses (Ctrl + Double Left)',
                            onPressed: _canShiftPrev ? () => _performShift(stepCount: 2, forward: false) : null,
                          ),
                          _HeaderIconButton(
                            icon: Icons.keyboard_arrow_left_rounded,
                            tooltip: 'Add previous verse (Ctrl + Left)',
                            onPressed: _canShiftPrev ? () => _performShift(stepCount: 1, forward: false) : null,
                          ),
                          _HeaderIconButton(
                            tooltip: 'Focus Scripture in Bible Search (Ctrl + S)',
                            onPressed: isCurrentSlideScripture ? _focusScriptureInSearch : null,
                            child: Image.asset(
                              'assets/icons/scroll.png',
                              width: 13,
                              height: 13,
                              color: isCurrentSlideScripture ? Colors.indigoAccent : Colors.white24,
                            ),
                          ),
                          _HeaderIconButton(
                            icon: Icons.keyboard_arrow_right_rounded,
                            tooltip: 'Add next verse (Ctrl + Right)',
                            onPressed: _canShiftNext ? () => _performShift(stepCount: 1, forward: true) : null,
                          ),
                          _HeaderIconButton(
                            icon: Icons.keyboard_double_arrow_right_rounded,
                            tooltip: 'Add next two verses (Ctrl + Double Right)',
                            onPressed: _canShiftNext ? () => _performShift(stepCount: 2, forward: true) : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    final isActive = activeIndices.contains(index);
                    final isBorderActive = borderActiveIndices.contains(index);

                    final slideItemIndex = index < slideToItemMapping.length ? slideToItemMapping[index] : null;
                    final selectedItems = ref.watch(setlistSelectionProvider);
                    final isItemCurrentlySelected = slideItemIndex != null && selectedItems.contains(slideItemIndex);
                    
                    final currentDisplayItemIndex = activeIndex < slideToItemMapping.length ? slideToItemMapping[activeIndex] : null;
                    final isPurpleHighlighted = isItemCurrentlySelected && slideItemIndex != currentDisplayItemIndex && !slide.isBlank;

                    final slideKey = _getSlideKey(index, setlist, slideToItemMapping);
                    final isBookmarked = slideKey != null && ref.watch(slideBookmarksProvider).contains(slideKey);

                    return SlideItemWidget(
                      slide: slide,
                      isActive: isActive,
                      isBorderActive: isBorderActive,
                      isBookmarked: isBookmarked,
                      isPurpleHighlighted: isPurpleHighlighted,
                      onTap: () {
                        ref.read(activeSlideIndexProvider.notifier).state = index;
                        focusNode.requestFocus();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatefulWidget {
  final IconData? icon;
  final Widget? child;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isSelected;

  const _HeaderIconButton({
    super.key,
    this.icon,
    this.child,
    required this.tooltip,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    
    return Tooltip(
      message: widget.tooltip,
      textStyle: const TextStyle(fontSize: 10, color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? Colors.blue.withOpacity(0.25)
                  : (_isHovered && enabled ? Colors.white.withOpacity(0.08) : Colors.transparent),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: widget.child ?? Icon(
              widget.icon,
              size: 14,
              color: enabled
                  ? (widget.isSelected ? Colors.blueAccent : Colors.white70)
                  : Colors.white24,
            ),
          ),
        ),
      ),
    );
  }
}
