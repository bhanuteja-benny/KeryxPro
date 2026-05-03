import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../songs/presentation/song_selection_providers.dart';
import '../../../live_controller/presentation/live_projector_providers.dart';
import '../../../live_controller/presentation/slide_utils.dart';
import '../../../live_controller/domain/slide.dart';
import 'slide_item_widget.dart';
import 'package:flutter/services.dart';
import '../global_ui_providers.dart';
import '../../../setlist/presentation/setlist_providers.dart';

class PreviewPane extends ConsumerStatefulWidget {
  const PreviewPane({super.key});

  @override
  ConsumerState<PreviewPane> createState() => _PreviewPaneState();
}

class _PreviewPaneState extends ConsumerState<PreviewPane> {
  // We use nodes and controllers from the global provider now

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final slides = ref.read(currentSlidesProvider);
    final activeIndices = ref.read(activeSlideIndicesProvider);
    final navState = ref.read(slideNavigationProvider);
    
    if (slides.isEmpty || activeIndices.isEmpty) return KeyEventResult.ignored;

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

    // Scroll to active index
    ref.listen(activeSlideIndexProvider, (previous, next) {
      if (scrollController.hasClients) {
        final targetOffset = next * 28.0; // 28 is the new height of SlideItemWidget
        scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });

    // Auto-focus when a new song is added to the setlist
    ref.listen(setlistProvider, (previous, next) {
      if (previous != null && next.length > previous.length) {
        // A song was added, shift focus to slides
        focusNode.requestFocus();
      }
    });

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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: Colors.black26,
                width: double.infinity,
                child: Row(
                  children: [
                    const Text(
                      'Slides',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.white54),
                    ),
                    const Spacer(),
                    if (focusNode.hasFocus)
                      const Icon(Icons.keyboard, size: 12, color: Colors.blueAccent),
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
                    
                    return SlideItemWidget(
                      slide: slide,
                      isActive: isActive,
                      isBorderActive: isBorderActive,
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
