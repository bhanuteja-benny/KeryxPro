import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../setlist/data/setlist_item.dart';
import '../../setlist/presentation/setlist_providers.dart';
import '../domain/slide.dart';
import 'slide_utils.dart';

import '../../settings/presentation/projection_provider.dart';

/// Holds the list of parsed slides for all items in the setlist.
final currentSlidesProvider = Provider<List<Slide>>((ref) {
  final setlist = ref.watch(setlistProvider);
  if (setlist.isEmpty) return [];

  final List<Slide> allSlides = [];
  for (final item in setlist) {
    switch (item) {
      case SongSetlistItem(:final song, :final isFavorite):
        final isSong = song.author != 'Bible';
        allSlides.addAll(SlideUtils.parseLyrics(song.lyrics, song.title, isSong: isSong, isFavorite: isFavorite));
      case ImageSetlistItem(:final imagePath, :final layout, :final alignment, :final isFavorite):
        // Image items produce one special "image" slide
        allSlides.add(Slide(
          title: imagePath.split(RegExp(r'[/\\]')).last,
          shortcut: 'IMG',
          content: 'IMAGE:$imagePath|$layout|$alignment',
          type: SlideType.other,
          isBlank: false,
          isSong: false,
          isFavorite: isFavorite,
        ));
    }
  }
  return allSlides;
});

/// Holds the index of the currently active slide.
final activeSlideIndexProvider = StateProvider<int>((ref) => 0);

/// Computes the list of active slide indices based on grouping settings.
final activeSlideIndicesProvider = Provider<List<int>>((ref) {
  final slides = ref.watch(currentSlidesProvider);
  final index = ref.watch(activeSlideIndexProvider);
  final config = ref.watch(projectionProvider).config;

  if (slides.isEmpty || index < 0 || index >= slides.length) return [];

  final slide = slides[index];

  // Only group bible verses (not songs, images, or blanks)
  if (slide.isSong || slide.isBlank || slide.shortcut == 'IMG' || config.monitor1MaxVerses <= 1) {
    return [index];
  }

  // Find the boundaries of the current Bible block
  int start = index;
  int end = index;
  while (start > 0 && slides[start - 1].title == slide.title && !slides[start - 1].isSong && !slides[start - 1].isBlank) {
    start--;
  }
  while (end < slides.length - 1 && slides[end + 1].title == slide.title && !slides[end + 1].isSong && !slides[end + 1].isBlank) {
    end++;
  }

  // Partition the block into sub-groups flowing from top verse
  List<List<int>> groups = [];
  int i = start;
  while (i <= end) {
    List<int> currentGroup = [i];
    int currentChars = slides[i].content.length;
    
    if (config.monitor1MaxVerses >= 2 && i + 1 <= end) {
      int charsIfAddNext = currentChars + slides[i+1].content.length + 1; // +1 for space or newline
      if (config.monitor1MaxChars <= 0 || charsIfAddNext <= config.monitor1MaxChars) {
        currentGroup.add(i + 1);
        currentChars = charsIfAddNext;
        
        if (config.monitor1MaxVerses == 3 && i + 2 <= end) {
          int charsIfAddThird = currentChars + slides[i+2].content.length + 1;
          if (config.monitor1MaxChars <= 0 || charsIfAddThird <= config.monitor1MaxChars) {
            currentGroup.add(i + 2);
          }
        }
      }
    }
    
    groups.add(currentGroup);
    i += currentGroup.length;
  }

  // Return the group that contains the activeIndex
  for (final group in groups) {
    if (group.contains(index)) {
      return group;
    }
  }

  return [index]; // Fallback
});

/// Holds the currently projected text snippet/slide.
final activeSlideProvider = Provider<String?>((ref) {
  final slides = ref.watch(currentSlidesProvider);
  final indices = ref.watch(activeSlideIndicesProvider);
  final config = ref.watch(projectionProvider).config;

  if (indices.isEmpty || slides.isEmpty) return null;

  if (indices.length == 1) {
    return slides[indices.first].isBlank ? "" : slides[indices.first].content;
  }

  // Combine contents
  final joiner = config.monitor1Format.toLowerCase() == 'paragraph' ? ' ' : '\n';
  return indices.map((i) => slides[i].content).join(joiner);
});

/// Holds the title of the currently projected slide.
final activeTitleProvider = Provider<String?>((ref) {
  final slides = ref.watch(currentSlidesProvider);
  final indices = ref.watch(activeSlideIndicesProvider);

  if (indices.isEmpty || slides.isEmpty) return null;

  return slides[indices.first].title;
});

/// Indicates if the currently projected slide is from a song.
final isSongActiveProvider = Provider<bool>((ref) {
  final slides = ref.watch(currentSlidesProvider);
  final indices = ref.watch(activeSlideIndicesProvider);

  if (indices.isEmpty || slides.isEmpty) return false;

  return slides[indices.first].isSong;
});
