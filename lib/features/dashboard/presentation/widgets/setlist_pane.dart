import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../setlist/data/setlist_item.dart';
import '../../../setlist/data/setlist_repository.dart';
import '../../../setlist/presentation/setlist_providers.dart';
import '../../../setlist/presentation/image_slide_dialog.dart';
import '../global_ui_providers.dart';
import '../../../live_controller/presentation/slide_utils.dart';
import '../../../live_controller/presentation/live_projector_providers.dart';

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
  void initState() {
    super.initState();
    _nameCtrl.addListener(() {
      // Need to defer this slightly as it might happen during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(activeSetlistNameProvider.notifier).state = 
            _nameCtrl.text.isEmpty ? null : _nameCtrl.text;
        }
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocusNode.dispose();
    _listFocusNode.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() {
    final items = ref.read(setlistProvider);
    if (items.isEmpty) return false;
    final currentSignature = generateSetlistSignature(items);
    final savedSignature = ref.read(activeSetlistSignatureProvider);
    return currentSignature != savedSignature;
  }

  // ── Save current session list ──────────────────────────────────────────
  Future<void> _saveSetlist() async {
    final items = ref.read(setlistProvider);
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save an empty list. Add at least one item.')),
      );
      return;
    }

    String? name = ref.read(activeSetlistNameProvider);
    
    if (name == null || name.trim().isEmpty) {
      name = await _promptForName();
      if (name == null || name.trim().isEmpty) return; // User cancelled
    }
    
    final repo = ref.read(setlistRepositoryProvider);
    await repo.saveByName(name.trim(), items);
    ref.read(activeSetlistNameProvider.notifier).state = name.trim();
    ref.read(activeSetlistSignatureProvider.notifier).state = generateSetlistSignature(items);
    ref.invalidate(savedSetlistNamesProvider);
    _nameCtrl.text = name.trim();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SetList "${name.trim()}" saved!')),
      );
    }
  }

  Future<String?> _promptForName() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D3E),
          title: const Text('Save SetList', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter SetList name',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () async {
                final input = ctrl.text.trim();
                if (input.isEmpty) return;
                
                final existing = await ref.read(savedSetlistNamesProvider.future);
                if (existing.contains(input)) {
                  if (ctx.mounted) {
                    final overwrite = await showDialog<bool>(
                      context: ctx,
                      builder: (innerCtx) => AlertDialog(
                        backgroundColor: const Color(0xFF2D2D3E),
                        title: const Text('Name Exists', style: TextStyle(color: Colors.white, fontSize: 16)),
                        content: const Text('SetList name already exists. Overwrite?', style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(innerCtx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
                          TextButton(onPressed: () => Navigator.pop(innerCtx, true), child: const Text('Overwrite', style: TextStyle(color: Colors.redAccent))),
                        ],
                      )
                    );
                    if (overwrite != true) return;
                  }
                }
                if (ctx.mounted) Navigator.pop(ctx, input);
              },
              child: const Text('Save', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      }
    );
  }

  // ── Load a saved setlist by name ───────────────────────────────────────
  Future<void> _loadSetlist(String name) async {
    if (_hasUnsavedChanges()) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF2D2D3E),
          title: const Text('Unsaved Changes', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: const Text('You have unsaved items. Do you want to clear them and load the selected list?', style: TextStyle(color: Colors.white70, fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Load Anyway', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        )
      );
      if (confirm != true) {
        // Reset text field if they cancelled
        _nameCtrl.text = ref.read(activeSetlistNameProvider) ?? '';
        return;
      }
    }

    final repo = ref.read(setlistRepositoryProvider);
    final items = await repo.loadByName(name);
    ref.read(setlistProvider.notifier).replaceAll(items);
    ref.read(activeSetlistNameProvider.notifier).state = name;
    ref.read(activeSetlistSignatureProvider.notifier).state = generateSetlistSignature(items);
    ref.read(setlistSelectionProvider.notifier).clear();
    _nameCtrl.text = name;
  }

  // ── Delete actions ──────────────────────────────────────────────
  void _deleteAction() {
    final selection = ref.read(setlistSelectionProvider);
    final items = ref.read(setlistProvider);
    final activeName = ref.read(activeSetlistNameProvider);
    
    if (selection.isNotEmpty) {
      ref.read(setlistProvider.notifier).removeAtIndices(selection);
      ref.read(setlistSelectionProvider.notifier).clear();
    } else if (items.isEmpty && activeName != null && activeName.trim().isNotEmpty) {
      _handleDeleteSetlistName(activeName.trim());
    }
  }

  Future<void> _handleDeleteSetlistName(String name) async {
    final savedNames = await ref.read(savedSetlistNamesProvider.future);
    final isSaved = savedNames.contains(name);

    if (isSaved) {
      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF2D2D3E),
          title: const Text('Delete SetList', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: const Text('Are you sure you want to delete setlist name?', style: TextStyle(color: Colors.white70, fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        )
      );

      if (confirm == true) {
        final repo = ref.read(setlistRepositoryProvider);
        await repo.deleteByName(name);
        ref.read(activeSetlistNameProvider.notifier).state = null;
        ref.read(activeSetlistSignatureProvider.notifier).state = '';
        _nameCtrl.clear();
        ref.invalidate(savedSetlistNamesProvider);
      }
    } else {
      // Not saved yet, just clear selection and textbox
      ref.read(activeSetlistNameProvider.notifier).state = null;
      ref.read(activeSetlistSignatureProvider.notifier).state = '';
      _nameCtrl.clear();
    }
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
      ref.read(setlistProvider.notifier).insertImage(
        result,
        selectedIndices: ref.read(setlistSelectionProvider),
        currentDisplayItemIndex: ref.read(currentDisplayItemIndexProvider),
      );
    }
  }

  // ── Clear all items ────────────────────────────────────────────────────
  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D3E),
        title: const Text('Clear SetList', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text('Are you sure you want to clear all items? This will not save changes.',
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(setlistProvider.notifier).clear();
      ref.read(setlistSelectionProvider.notifier).clear();
    }
  }

  // ── Toggle favorite status ─────────────────────────────────────────────
  void _toggleFavorite() {
    final selection = ref.read(setlistSelectionProvider);
    if (selection.isEmpty) return;
    ref.read(setlistProvider.notifier).toggleFavorite(selection);
  }

  // ── Refresh placeholder ────────────────────────────────────────────────
  void _refresh() {
    debugPrint('Refresh clicked');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refresh clicked'), duration: Duration(seconds: 1)),
    );
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
      final currentSelection = ref.read(setlistSelectionProvider);
      if (currentSelection.length == 1 && currentSelection.contains(index)) {
        sel.clear();
      } else {
        sel.selectSingle(index);
        // Scroll preview pane to first slide of tapped item
        _scrollToItem(index);
      }
    }
    _listFocusNode.requestFocus();
  }

  int _getSlideStartIndex(int index) {
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
    return slideStartIndex;
  }

  // ── Scroll slide list to item only if not visible ─────────────────────
  void _scrollToItem(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int slideStartIndex = _getSlideStartIndex(index);
      
      final scrollController = ref.read(slideListScrollControllerProvider);
      if (scrollController.hasClients) {
        const itemHeight = 28.0;
        final viewportHeight = scrollController.position.viewportDimension;
        final maxScroll = scrollController.position.maxScrollExtent;
        final centerOffset = (slideStartIndex * itemHeight) - (viewportHeight / 2) + (itemHeight / 2);
        
        scrollController.animateTo(
          centerOffset.clamp(0.0, maxScroll),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ── Segmented Control Style Button Helper ────────────────────────────
  Widget _segmentedButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    bool showBorder = true,
    bool isSelected = false,
  }) {
    return _SetlistToolbarButton(
      icon: icon,
      tooltip: tooltip,
      onPressed: onPressed,
      showBorder: showBorder,
      isSelected: isSelected,
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
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        
        if (event.logicalKey == LogicalKeyboardKey.tab) {
          ref.read(slideListFocusNodeProvider).requestFocus();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.enter) {
          final sel = ref.read(setlistSelectionProvider);
          if (sel.isNotEmpty) {
            // Find the lowest selected index
            final selectedIndex = sel.reduce((a, b) => a < b ? a : b);
            final slideIndex = _getSlideStartIndex(selectedIndex);
            ref.read(activeSlideIndexProvider.notifier).state = slideIndex;
            ref.read(setlistSelectionProvider.notifier).clear();
            return KeyEventResult.handled;
          }
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
                data: (names) => Theme(
                  data: Theme.of(context).copyWith(
                    iconButtonTheme: IconButtonThemeData(
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(24, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  child: DropdownMenu<String>(
                    controller: _nameCtrl,
                    focusNode: _nameFocusNode,
                    initialSelection: activeName,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    dropdownMenuEntries: names.map((n) => DropdownMenuEntry(value: n, label: n)).toList(),
                    onSelected: (name) {
                      if (name != null) _loadSetlist(name);
                    },
                    textStyle: const TextStyle(color: Colors.white, fontSize: 11),
                    inputDecorationTheme: InputDecorationTheme(
                      isDense: true,
                      constraints: const BoxConstraints(maxHeight: 28),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      filled: true,
                      fillColor: const Color(0xFF2D2D3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                    ),
                    hintText: 'SetList name…',
                    expandedInsets: EdgeInsets.zero,
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(const Color(0xFF2D2D3E)),
                    ),
                    trailingIcon: const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 20),
                    selectedTrailingIcon: const Icon(Icons.arrow_drop_up, color: Colors.white54, size: 20),
                  ),
                ),
                loading: () => const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator())),
                error: (e, _) => Center(child: Text('Error: $e')),
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
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = selection.contains(index);

                        final activeIndex = ref.watch(activeSlideIndexProvider);
                        final slides = ref.watch(currentSlidesProvider);
                        final slideToItemMapping = ref.watch(slideToSetlistItemIndexProvider);
                        
                        final currentActiveSlide = activeIndex < slides.length ? slides[activeIndex] : null;
                        final currentDisplayItemIndex = activeIndex < slideToItemMapping.length ? slideToItemMapping[activeIndex] : null;
                        
                        final isDisplaying = index == currentDisplayItemIndex && currentActiveSlide != null && !currentActiveSlide.isBlank;
                        
                        final isBlankActive = currentActiveSlide != null && currentActiveSlide.isBlank;
                        final aboveItemIndex = (isBlankActive && activeIndex > 0 && (activeIndex - 1) < slideToItemMapping.length)
                            ? slideToItemMapping[activeIndex - 1]
                            : null;
                        final isBorderBottomHighlighted = index == aboveItemIndex;

                        final bgColor = isSelected
                            ? Colors.deepPurpleAccent.withValues(alpha: 0.3)
                            : (isDisplaying ? Colors.blue.withValues(alpha: 0.2) : Colors.transparent);

                        return GestureDetector(
                          onTap: () {
                            final isCtrl = HardwareKeyboard.instance.isControlPressed;
                            final isShift = HardwareKeyboard.instance.isShiftPressed;
                            _onItemTap(index, isCtrl, isShift);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: Border(
                                bottom: BorderSide(
                                  color: isBorderBottomHighlighted ? Colors.blueAccent : Colors.white10,
                                  width: isBorderBottomHighlighted ? 3.0 : 1.0,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                if (isDisplaying)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 2),
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      size: 14,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                if (item.isFavorite)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(Icons.star_rounded,
                                        size: 12, color: Colors.amber.withValues(alpha: 0.8)),
                                  ),
                                if (item is SongSetlistItem)
                                  item.song.author == 'Bible'
                                      ? Image.asset(
                                          'assets/icons/scroll.png',
                                          width: 13,
                                          height: 13,
                                          color: Colors.indigoAccent,
                                        )
                                      : const Icon(
                                          Icons.music_note_rounded,
                                          size: 13,
                                          color: Colors.deepPurpleAccent,
                                        )
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

            // ── Bottom Toolbar (2x4 Segmented Control) ────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bar 1
                Row(
                  children: [
                    _segmentedButton(
                      icon: Icons.delete_rounded,
                      tooltip: items.isEmpty && activeName != null ? 'Delete SetList' : 'Delete Selected',
                      onPressed: (hasSelection || (items.isEmpty && activeName != null)) ? _deleteAction : null,
                    ),
                    _segmentedButton(
                      icon: Icons.arrow_upward_rounded,
                      tooltip: 'Move Up',
                      onPressed: canMoveUp ? _moveUp : null,
                    ),
                    _segmentedButton(
                      icon: Icons.arrow_downward_rounded,
                      tooltip: 'Move Down',
                      onPressed: canMoveDown ? _moveDown : null,
                    ),
                    _segmentedButton(
                      icon: Icons.save_rounded,
                      tooltip: 'Save SetList',
                      onPressed: _saveSetlist,
                      showBorder: false,
                    ),
                  ],
                ),
                // Horizontal separator between bars
                const Divider(height: 1, color: Colors.black12),
                // Bar 2
                Row(
                  children: [
                    _segmentedButton(
                      icon: Icons.block_rounded,
                      tooltip: 'Clear All',
                      onPressed: items.isNotEmpty ? _clearAll : null,
                    ),
                    _segmentedButton(
                      icon: Icons.add_photo_alternate_rounded,
                      tooltip: 'Add Image Slide',
                      onPressed: _addImage,
                    ),
                    _segmentedButton(
                      icon: Icons.star_rounded,
                      tooltip: 'Mark Item as Favorite',
                      onPressed: hasSelection ? _toggleFavorite : null,
                    ),
                    _segmentedButton(
                      icon: Icons.refresh,
                      tooltip: 'Refresh',
                      onPressed: null,
                      showBorder: false,
                      isSelected: false,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SetlistToolbarButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool showBorder;
  final bool isSelected;

  const _SetlistToolbarButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.showBorder = true,
    this.isSelected = false,
  });

  @override
  State<_SetlistToolbarButton> createState() => _SetlistToolbarButtonState();
}

class _SetlistToolbarButtonState extends State<_SetlistToolbarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isSelected
        ? (_isHovered ? const Color(0xFF3D3D5E) : const Color(0xFF2D2D4E))
        : (_isHovered ? const Color(0xFF3D3D4E) : const Color(0xFF2D2D3E));

    final iconColor = widget.isSelected
        ? Colors.blueAccent
        : const Color(0xFF757575);

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Tooltip(
          message: widget.tooltip,
          waitDuration: const Duration(milliseconds: 500),
          child: InkWell(
            onTap: widget.onPressed,
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                color: bgColor,
                border: widget.showBorder
                    ? const Border(
                        right: BorderSide(color: Colors.black12, width: 1),
                      )
                    : null,
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
