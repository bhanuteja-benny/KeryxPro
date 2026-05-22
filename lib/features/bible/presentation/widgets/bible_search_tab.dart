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

class BibleSearchTab extends ConsumerStatefulWidget {
  const BibleSearchTab({super.key});

  @override
  ConsumerState<BibleSearchTab> createState() => _BibleSearchTabState();
}

class _BibleSearchTabState extends ConsumerState<BibleSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  int? _lastVerseToggled;

  final FocusNode _otFocusNode = FocusNode();
  final FocusNode _ntFocusNode = FocusNode();
  final FocusNode _chFocusNode = FocusNode();
  final FocusNode _addButtonFocusNode = FocusNode(debugLabel: 'BibleAddButton');

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
    super.dispose();
  }

  Future<void> _handleSearch(String query, WidgetRef ref) async {
    if (query.isEmpty) return;

    final regex = RegExp(r'^(\d?\s*[a-zA-Z\s]+?)\s*(\d+)[\:\;](\d+)(?:-(\d+))?(?:\s+([a-zA-Z0-9]+))?$');
    final match = regex.firstMatch(query.trim());

    if (match != null) {
      final bookStr = match.group(1)?.trim() ?? '';
      final chapterStr = match.group(2) ?? '';
      final verseStartStr = match.group(3) ?? '';
      final verseEndStr = match.group(4);
      final versionStr = match.group(5);

      final normalizedBook = BibleConstants.normalizeBookName(bookStr);
      if (normalizedBook != null) {
        final chapter = int.tryParse(chapterStr);
        if (chapter != null) {
          final startVerse = int.tryParse(verseStartStr);
          if (startVerse != null) {
            final endVerse = verseEndStr != null ? int.tryParse(verseEndStr) : startVerse;
            
            final versionsAsync = ref.read(bibleVersionsProvider);
            final versions = versionsAsync.valueOrNull ?? [];
            
            BibleVersion? targetVersion;
            if (versionStr != null) {
              targetVersion = versions.where((v) => v.abbreviation.toLowerCase() == versionStr.toLowerCase()).firstOrNull;
            }
            targetVersion ??= ref.read(selectedBibleVersionProvider) ?? versions.firstOrNull;

            if (targetVersion != null) {
              final isar = await ref.read(isarServiceProvider).db;
              final chapters = await isar.bibleVerses
                  .filter()
                  .bibleVersionIdEqualTo(targetVersion.id)
                  .bookNameEqualTo(normalizedBook)
                  .chapterNumberProperty()
                  .findAll();

              if (chapters.contains(chapter)) {
                final verses = await isar.bibleVerses
                    .filter()
                    .bibleVersionIdEqualTo(targetVersion.id)
                    .bookNameEqualTo(normalizedBook)
                    .chapterNumberEqualTo(chapter)
                    .verseNumberProperty()
                    .findAll();
                
                final verseNumbers = verses.toSet();
                bool versesValid = true;
                for (int i = startVerse; i <= (endVerse ?? startVerse); i++) {
                  if (!verseNumbers.contains(i)) {
                    versesValid = false;
                    break;
                  }
                }

                if (versesValid) {
                  // ALL VALID
                  if (targetVersion != ref.read(selectedBibleVersionProvider)) {
                    ref.read(selectedBibleVersionProvider.notifier).state = targetVersion;
                  }
                  ref.read(selectedBookProvider.notifier).state = normalizedBook;
                  ref.read(selectedChapterProvider.notifier).state = chapter;
                  
                  final Set<int> versesToSelect = {};
                  for (int i = startVerse; i <= (endVerse ?? startVerse); i++) {
                    versesToSelect.add(i);
                  }
                  ref.read(selectedVersesProvider.notifier).state = versesToSelect;
                  if (mounted) {
                    setState(() {
                      _lastVerseToggled = endVerse ?? startVerse;
                    });
                  }

                  ref.read(bibleVerseListFocusNodeProvider).requestFocus();
                  return; // SUCCESS
                }
              }
            }
          }
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reference not found'), duration: Duration(seconds: 2)),
      );
    }
    ref.read(selectedBookProvider.notifier).state = null;
    ref.read(selectedChapterProvider.notifier).state = null;
    ref.read(selectedVersesProvider.notifier).state = <int>{};
    ref.read(bibleSearchFocusNodeProvider).requestFocus();
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

    // Calculate the index where the new song's slides will start
    final previousSlides = ref.read(currentSlidesProvider);
    final nextIndex = previousSlides.length;

    final selection = ref.read(setlistSelectionProvider);
    final insertIndex = selection.isEmpty ? null : selection.reduce((a, b) => a < b ? a : b);

    ref.read(setlistProvider.notifier).insertSong(mockSong, insertIndex);

    // Auto-activate the newly added song and focus slides if goLive is true
    if (goLive) {
      ref.read(activeSlideIndexProvider.notifier).state = nextIndex;
      ref.read(slideListFocusNodeProvider).requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bibleVersionsAsync = ref.watch(bibleVersionsProvider);

    return Column(
      children: [
        // Top Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          color: Colors.black12,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  focusNode: ref.read(bibleSearchFocusNodeProvider),
                  onSubmitted: (val) {
                    _handleSearch(val, ref);
                  },
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    isDense: true,
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    hintText: 'Search (e.g. gen 1:3, John 3:1-5)',
                    prefixIcon: const Icon(Icons.search, size: 12),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
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

                    final selectedVersion = ref.watch(selectedBibleVersionProvider) ?? versions.first;

                    return Container(
                      height: 22,
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
            ],
          ),
        ),

        // List Boxes
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: _buildListBox(
                  title: 'OT',
                  focusNode: _otFocusNode,
                  items: BibleConstants.oldTestamentBooks,
                  selectedValue: ref.watch(selectedBookProvider),
                  onSelected: (val) {
                    ref.read(selectedBookProvider.notifier).state = val;
                    // Default select 1st chapter and 1st verse
                    ref.read(selectedChapterProvider.notifier).state = 1;
                    ref.read(selectedVersesProvider.notifier).state = {1};
                    setState(() => _lastVerseToggled = 1);
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
                  items: BibleConstants.newTestamentBooks,
                  selectedValue: ref.watch(selectedBookProvider),
                  onSelected: (val) {
                    ref.read(selectedBookProvider.notifier).state = val;
                    // Default select 1st chapter and 1st verse
                    ref.read(selectedChapterProvider.notifier).state = 1;
                    ref.read(selectedVersesProvider.notifier).state = {1};
                    setState(() => _lastVerseToggled = 1);
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
                  asyncItems: ref.watch(availableChaptersProvider),
                  selectedValue: ref.watch(selectedChapterProvider),
                  onSelected: (val) {
                    ref.read(selectedChapterProvider.notifier).state = val;
                    // Default select 1st verse
                    ref.read(selectedVersesProvider.notifier).state = {1};
                    setState(() => _lastVerseToggled = 1);
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
                } else if (currentIndex == -1 && items.isNotEmpty) {
                  onSelected(items[0]);
                }
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                final currentIndex = items.indexOf(selectedValue as dynamic);
                if (currentIndex > 0) {
                  onSelected(items[currentIndex - 1]);
                }
                return KeyEventResult.handled;
              }

              return KeyEventResult.ignored;
            },
            child: ListView.builder(
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
                  } else if (currentIndex == -1) {
                    onSelected(items[0]);
                  }
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  final currentIndex = items.indexOf(selectedValue as dynamic);
                  if (currentIndex > 0) {
                    onSelected(items[currentIndex - 1]);
                  }
                  return KeyEventResult.handled;
                }
              }

              return KeyEventResult.ignored;
            },
            child: asyncItems.when(
              data: (items) {
                return ListView.builder(
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
              },
              loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) => const Center(child: Text('Error', style: TextStyle(fontSize: 10))),
            ),
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
    VoidCallback? onEnter,
    VoidCallback? onTab,
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

              final items = asyncItems.valueOrNull;
              if (items != null && items.isNotEmpty) {
                if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  // Get the last selected item or the first one
                  final lastItem = _lastVerseToggled as T?;
                  final currentIndex = lastItem != null ? items.indexOf(lastItem) : -1;
                  if (currentIndex < items.length - 1) {
                    onSelected(items[currentIndex + 1], true, items);
                  }
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  final lastItem = _lastVerseToggled as T?;
                  final currentIndex = lastItem != null ? items.indexOf(lastItem) : -1;
                  if (currentIndex > 0) {
                    onSelected(items[currentIndex - 1], true, items);
                  }
                  return KeyEventResult.handled;
                }
              }

              return KeyEventResult.ignored;
            },
            child: asyncItems.when(
              data: (items) {
                return ListView.builder(
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
              },
              loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) => const Center(child: Text('Error', style: TextStyle(fontSize: 10))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewPane(WidgetRef ref) {
    final previewAsync = ref.watch(biblePreviewVersesProvider);
    final selectedVersion = ref.watch(selectedBibleVersionProvider);

    return Container(
      height: 250,
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
                        '$book $chapter (${verses.length} verses selected)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                    loading: () => const Text('Loading...', style: TextStyle(fontSize: 12, color: Colors.blueAccent)),
                    error: (_, __) => const Text('Error', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                  ),
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
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: previewAsync.when(
                  data: (verses) {
                    if (verses.isEmpty) return const Text('Select a verse to preview', style: TextStyle(color: Colors.white54, fontSize: 12));
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: verses.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                            children: [
                              TextSpan(text: '${v.verseNumber} ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                              TextSpan(text: v.text),
                            ],
                          ),
                        ),
                      )).toList(),
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
}
