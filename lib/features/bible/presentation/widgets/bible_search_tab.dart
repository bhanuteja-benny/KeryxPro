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

class BibleSearchTab extends ConsumerStatefulWidget {
  const BibleSearchTab({super.key});

  @override
  ConsumerState<BibleSearchTab> createState() => _BibleSearchTabState();
}

class _BibleSearchTabState extends ConsumerState<BibleSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  int? _lastVerseToggled;

  void _handleSearch(String query, WidgetRef ref) {
    if (query.isEmpty) return;

    // Regex to match "book chapter:verse-verse" e.g., "1 pet 2:12-14", "gen 1:3", "John 3:1"
    final regex = RegExp(r'^(\d?\s*[a-zA-Z\s]+)\s+(\d+):(\d+)(?:-(\d+))?$');
    final match = regex.firstMatch(query.trim());

    if (match != null) {
      final bookStr = match.group(1)?.trim() ?? '';
      final chapterStr = match.group(2) ?? '';
      final verseStartStr = match.group(3) ?? '';
      final verseEndStr = match.group(4);

      final normalizedBook = BibleConstants.normalizeBookName(bookStr);
      if (normalizedBook != null) {
        ref.read(selectedBookProvider.notifier).state = normalizedBook;
        
        final chapter = int.tryParse(chapterStr);
        if (chapter != null) {
          ref.read(selectedChapterProvider.notifier).state = chapter;
          
          final startVerse = int.tryParse(verseStartStr);
          if (startVerse != null) {
            final endVerse = verseEndStr != null ? int.tryParse(verseEndStr) : startVerse;
            
            final Set<int> versesToSelect = {};
            if (endVerse != null && endVerse >= startVerse) {
              for (int i = startVerse; i <= endVerse; i++) {
                versesToSelect.add(i);
              }
            } else {
              versesToSelect.add(startVerse);
            }
            ref.read(selectedVersesProvider.notifier).state = versesToSelect;
          }
        }
      }
    }
  }

  void _addToSetlist(List<BibleVerse> verses, BibleVersion version, WidgetRef ref) {
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

    ref.read(setlistProvider.notifier).addSong(mockSong);

    // Auto-activate the newly added song and focus slides
    ref.read(activeSlideIndexProvider.notifier).state = nextIndex;
    ref.read(slideListFocusNodeProvider).requestFocus();
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
                    // Shift focus to Verse listbox after search
                    ref.read(bibleVerseListFocusNodeProvider).requestFocus();
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
                  items: BibleConstants.oldTestamentBooks,
                  selectedValue: ref.watch(selectedBookProvider),
                  onSelected: (val) {
                    ref.read(selectedBookProvider.notifier).state = val;
                    // Default select 1st chapter and 1st verse
                    ref.read(selectedChapterProvider.notifier).state = 1;
                    ref.read(selectedVersesProvider.notifier).state = {1};
                  },
                  onEnter: () {
                    final preview = ref.read(biblePreviewVersesProvider).valueOrNull;
                    final version = ref.read(selectedBibleVersionProvider);
                    if (preview != null && preview.isNotEmpty && version != null) {
                      _addToSetlist(preview, version, ref);
                    }
                  },
                ),
              ),
              const VerticalDivider(width: 1, color: Colors.black),
              Expanded(
                flex: 4,
                child: _buildListBox(
                  title: 'NT',
                  items: BibleConstants.newTestamentBooks,
                  selectedValue: ref.watch(selectedBookProvider),
                  onSelected: (val) {
                    ref.read(selectedBookProvider.notifier).state = val;
                    // Default select 1st chapter and 1st verse
                    ref.read(selectedChapterProvider.notifier).state = 1;
                    ref.read(selectedVersesProvider.notifier).state = {1};
                  },
                  onEnter: () {
                    final preview = ref.read(biblePreviewVersesProvider).valueOrNull;
                    final version = ref.read(selectedBibleVersionProvider);
                    if (preview != null && preview.isNotEmpty && version != null) {
                      _addToSetlist(preview, version, ref);
                    }
                  },
                ),
              ),
              const VerticalDivider(width: 1, color: Colors.black),
              Expanded(
                flex: 2,
                child: _buildAsyncListBox(
                  title: 'Ch',
                  asyncItems: ref.watch(availableChaptersProvider),
                  selectedValue: ref.watch(selectedChapterProvider),
                  onSelected: (val) {
                    ref.read(selectedChapterProvider.notifier).state = val;
                    // Default select 1st verse
                    ref.read(selectedVersesProvider.notifier).state = {1};
                  },
                  onEnter: () {
                    final preview = ref.read(biblePreviewVersesProvider).valueOrNull;
                    final version = ref.read(selectedBibleVersionProvider);
                    if (preview != null && preview.isNotEmpty && version != null) {
                      _addToSetlist(preview, version, ref);
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
                      _addToSetlist(preview, version, ref);
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
        _buildPreviewPane(ref),
      ],
    );
  }

  Widget _buildListBox<T>({
    required String title,
    required List<T> items,
    required T? selectedValue,
    required Function(T) onSelected,
    VoidCallback? onEnter,
  }) {
    final focusNode = FocusNode();
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
    VoidCallback? onEnter,
  }) {
    final focusNode = FocusNode();
    return Column(
      children: [
        Container(
          color: Colors.black38,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
        ),
        Expanded(
          child: asyncItems.when(
            data: (items) {
              return Focus(
                focusNode: focusNode,
                onKeyEvent: (node, event) {
                  if (event is! KeyDownEvent) return KeyEventResult.ignored;
                  if (event.logicalKey == LogicalKeyboardKey.enter && onEnter != null) {
                    onEnter();
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
                        child: Text(item.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
            error: (_, __) => const Center(child: Text('Error', style: TextStyle(fontSize: 10))),
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
          child: asyncItems.when(
            data: (items) {
              return Focus(
                focusNode: focusNode,
                onKeyEvent: (node, event) {
                  if (event is! KeyDownEvent) return KeyEventResult.ignored;
                  if (event.logicalKey == LogicalKeyboardKey.enter && onEnter != null) {
                    onEnter();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: ListView.builder(
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
                ),
              );
            },
            loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
            error: (_, __) => const Center(child: Text('Error', style: TextStyle(fontSize: 10))),
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
                  onPressed: previewAsync.valueOrNull?.isNotEmpty == true && selectedVersion != null
                      ? () {
                          _addToSetlist(previewAsync.value!, selectedVersion, ref);
                        }
                      : null,
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
