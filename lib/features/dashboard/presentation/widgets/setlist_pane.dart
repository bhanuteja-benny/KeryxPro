import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../setlist/data/setlist_item.dart';
import '../../../setlist/data/setlist_repository.dart';
import '../../../setlist/presentation/setlist_providers.dart';
import '../../../setlist/presentation/image_slide_dialog.dart';
import '../global_ui_providers.dart';
import '../../../live_controller/presentation/slide_utils.dart';

class SetlistPane extends ConsumerStatefulWidget {
  const SetlistPane({super.key});

  @override
  ConsumerState<SetlistPane> createState() => _SetlistPaneState();
}

class _SetlistPaneState extends ConsumerState<SetlistPane> {
  final TextEditingController _nameCtrl = TextEditingController(text: '');
  final FocusNode _nameFocusNode = FocusNode(debugLabel: 'SetlistNameField');
  final FocusNode _listFocusNode = FocusNode(debugLabel: 'SetlistListPane');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocusNode.dispose();
    _listFocusNode.dispose();
    super.dispose();
  }

  // ── Save current session list ──────────────────────────────────────────
  Future<void> _saveSetlist() async {
    final name = ref.read(activeSetlistNameProvider);
    if (name == null || name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a setlist name first.')),
      );
      return;
    }
    final items = ref.read(setlistProvider);
    final repo = ref.read(setlistRepositoryProvider);
    await repo.saveByName(name.trim(), items);
    ref.invalidate(savedSetlistNamesProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SetList "$name" saved!')),
      );
    }
  }

  // ── Load a saved setlist by name ───────────────────────────────────────
  Future<void> _loadSetlist(String name) async {
    final repo = ref.read(setlistRepositoryProvider);
    final items = await repo.loadByName(name);
    ref.read(setlistProvider.notifier).replaceAll(items);
    ref.read(activeSetlistNameProvider.notifier).state = name;
    ref.read(setlistSelectionProvider.notifier).clear();
    _nameCtrl.text = name;
  }

  // ── Delete selected items ──────────────────────────────────────────────
  void _deleteSelected() {
    final selection = ref.read(setlistSelectionProvider);
    if (selection.isEmpty) return;
    ref.read(setlistProvider.notifier).removeAtIndices(selection);
    ref.read(setlistSelectionProvider.notifier).clear();
  }

  // ── Move selected items ────────────────────────────────────────────────
  void _moveUp() {
    final selection = ref.read(setlistSelectionProvider);
    if (selection.isEmpty || selection.contains(0)) return;
    ref.read(setlistProvider.notifier).moveUp(selection);
    final newSelection = selection.map((i) => i - 1).toSet();
    ref.read(setlistSelectionProvider.notifier).selectBatch(newSelection);
  }

  void _moveDown() {
    final selection = ref.read(setlistSelectionProvider);
    final items = ref.read(setlistProvider);
    if (selection.isEmpty || selection.contains(items.length - 1)) return;
    ref.read(setlistProvider.notifier).moveDown(selection);
    final newSelection = selection.map((i) => i + 1).toSet();
    ref.read(setlistSelectionProvider.notifier).selectBatch(newSelection);
  }

  // ── Add image slide ────────────────────────────────────────────────────
  Future<void> _addImage() async {
    final result = await showDialog<ImageSetlistItem>(
      context: context,
      builder: (context) => const ImageSlideDialog(),
    );
    if (result != null) {
      ref.read(setlistProvider.notifier).addImage(result);
    }
  }

  // ── Handle item tap (single / Ctrl / Shift) ───────────────────────────
  void _onItemTap(int index, bool ctrl, bool shift) {
    final sel = ref.read(setlistSelectionProvider.notifier);
    final items = ref.read(setlistProvider);
    if (ctrl) {
      sel.toggleCtrl(index);
    } else if (shift) {
      sel.selectShift(index, items.length);
    } else {
      sel.selectSingle(index);
      // Scroll preview pane to first slide of tapped item
      _scrollToItem(index);
    }
    _listFocusNode.requestFocus();
  }

  // ── Scroll slide list to item ──────────────────────────────────────────
  void _scrollToItem(int index) {
    final items = ref.read(setlistProvider);
    int slideStartIndex = 0;
    for (int i = 0; i < index; i++) {
      final item = items[i];
      if (item is SongSetlistItem) {
        final slides = SlideUtils.parseLyrics(item.song.lyrics, item.song.title);
        slideStartIndex += slides.length;
      } else if (item is ImageSetlistItem) {
        slideStartIndex += 1; // Image = 1 slide
      }
    }
    final scrollController = ref.read(slideListScrollControllerProvider);
    if (scrollController.hasClients) {
      scrollController.animateTo(
        slideStartIndex * 28.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ── Toolbar icon button helper ─────────────────────────────────────────
  Widget _toolbarIcon({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: onPressed != null ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null ? Colors.white70 : Colors.white24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(setlistProvider);
    final selection = ref.watch(setlistSelectionProvider);
    final activeName = ref.watch(activeSetlistNameProvider);
    final savedNamesAsync = ref.watch(savedSetlistNamesProvider);

    final hasSelection = selection.isNotEmpty;
    final canMoveUp = hasSelection && !selection.contains(0);
    final canMoveDown = hasSelection && !selection.contains(items.length - 1);

    return Focus(
      focusNode: _listFocusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
          ref.read(slideListFocusNodeProvider).requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        color: const Color(0xFF1E1E2E),
        child: Column(
          children: [
            // ── Header with name field ──────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              color: Colors.black26,
              child: savedNamesAsync.when(
                data: (names) => RawAutocomplete<String>(
                  textEditingController: _nameCtrl,
                  focusNode: _nameFocusNode,
                  optionsBuilder: (value) {
                    if (value.text.isEmpty) return names;
                    return names.where(
                      (n) => n.toLowerCase().contains(value.text.toLowerCase()),
                    );
                  },
                  onSelected: (name) => _loadSetlist(name),
                  fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                      decoration: InputDecoration(
                        hintText: 'SetList name…',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        filled: true,
                        fillColor: const Color(0xFF2D2D3E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: activeName != null
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 14, color: Colors.white38),
                                onPressed: () {
                                  _nameCtrl.clear();
                                  ref.read(activeSetlistNameProvider.notifier).state = null;
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            : null,
                      ),
                      onChanged: (v) {
                        ref.read(activeSetlistNameProvider.notifier).state = v.isEmpty ? null : v;
                      },
                      onSubmitted: (v) {
                        if (names.contains(v.trim())) {
                          _loadSetlist(v.trim());
                        } else {
                          ref.read(activeSetlistNameProvider.notifier).state = v.trim().isEmpty ? null : v.trim();
                        }
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: const Color(0xFF2D2D3E),
                        elevation: 4,
                        borderRadius: BorderRadius.circular(6),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, i) {
                              final name = options.elementAt(i);
                              return InkWell(
                                onTap: () => onSelected(name),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  child: Text(name,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (_, __) => const Text('Error loading lists',
                    style: TextStyle(color: Colors.redAccent, fontSize: 11)),
              ),
            ),

            // ── Item List ───────────────────────────────────────────────
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'No items.\nAdd songs or images.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white24, fontSize: 11),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Colors.white10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = selection.contains(index);

                        return GestureDetector(
                          onTap: () {
                            final isCtrl = HardwareKeyboard.instance.isControlPressed;
                            final isShift = HardwareKeyboard.instance.isShiftPressed;
                            _onItemTap(index, isCtrl, isShift);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            color: isSelected
                                ? Colors.deepPurpleAccent.withValues(alpha: 0.3)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            child: Row(
                              children: [
                                if (item is SongSetlistItem)
                                  const Icon(Icons.music_note_rounded,
                                      size: 13, color: Colors.deepPurpleAccent)
                                else
                                  const Icon(Icons.image_rounded,
                                      size: 13, color: Colors.tealAccent),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                  item is SongSetlistItem ? item.song.title : (item as ImageSetlistItem).displayName,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Number badge
                                Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                      color: Colors.white24, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // ── Bottom Toolbar (icon-only, 3x2) ────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF16162A),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 2,
                runSpacing: 2,
                children: [
                  // Row 1
                  _toolbarIcon(
                    icon: Icons.save_rounded,
                    tooltip: 'Save SetList',
                    onPressed: activeName != null ? _saveSetlist : null,
                  ),
                  _toolbarIcon(
                    icon: Icons.delete_rounded,
                    tooltip: 'Delete Selected',
                    onPressed: hasSelection ? _deleteSelected : null,
                  ),
                  _toolbarIcon(
                    icon: Icons.arrow_upward_rounded,
                    tooltip: 'Move Up',
                    onPressed: canMoveUp ? _moveUp : null,
                  ),
                  // Row 2
                  _toolbarIcon(
                    icon: Icons.arrow_downward_rounded,
                    tooltip: 'Move Down',
                    onPressed: canMoveDown ? _moveDown : null,
                  ),
                  _toolbarIcon(
                    icon: Icons.sync_rounded,
                    tooltip: 'Sync (Coming Soon)',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sync — Coming Soon!')),
                      );
                    },
                  ),
                  _toolbarIcon(
                    icon: Icons.add_photo_alternate_rounded,
                    tooltip: 'Add Image Slide',
                    onPressed: _addImage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
