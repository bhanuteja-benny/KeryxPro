import 'dart:math';

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

/// Helper to compute groups for a block of Bible verses.
List<List<int>> _getGroups(List<Slide> slides, int start, int end, int maxVerses, int maxChars) {
  if (maxVerses <= 1) {
    return List.generate(end - start + 1, (i) => [start + i]);
  }

  List<List<int>> groups = [];
  int i = start;
  while (i <= end) {
    List<int> currentGroup = [i];
    int currentChars = slides[i].content.length;
    
    // Check next verses up to maxVerses
    for (int v = 1; v < maxVerses; v++) {
      if (i + v <= end) {
        int charsIfAddNext = currentChars + slides[i + v].content.length + 1; // +1 for space/newline
        if (maxChars <= 0 || charsIfAddNext <= maxChars) {
          currentGroup.add(i + v);
          currentChars = charsIfAddNext;
        } else {
          break; // Stop adding if chars exceeded
        }
      }
    }
    groups.add(currentGroup);
    i += currentGroup.length;
  }
  return groups;
}

/// Generic provider to calculate the active indices for a given monitor's settings
final _monitorActiveSlideIndicesProvider = Provider.family<List<int>, int>((ref, monitorIndex) {
  final slides = ref.watch(currentSlidesProvider);
  final index = ref.watch(activeSlideIndexProvider);
  final config = ref.watch(projectionProvider).config;

  if (slides.isEmpty || index < 0 || index >= slides.length) return [];

  final slide = slides[index];

  // Only group bible verses
  if (slide.isSong || slide.isBlank || slide.shortcut == 'IMG') {
    return [index];
  }

  int m1MaxVerses = config.monitor1MaxVerses;
  int m1MaxChars = config.monitor1MaxChars;
  int m2MaxVerses = config.monitor2MaxVerses;
  int m2MaxChars = config.monitor2MaxChars;

  // Apply Scenario 3 rule: if max verses are equal, apply the least of chars to both.
  if (m1MaxVerses == m2MaxVerses) {
    int effectiveMaxChars = 0;
    if (m1MaxChars <= 0 && m2MaxChars <= 0) {
      effectiveMaxChars = 0; // neither has limit
    } else if (m1MaxChars <= 0) {
      effectiveMaxChars = m2MaxChars;
    } else if (m2MaxChars <= 0) {
      effectiveMaxChars = m1MaxChars;
    } else {
      effectiveMaxChars = min(m1MaxChars, m2MaxChars);
    }
    m1MaxChars = effectiveMaxChars;
    m2MaxChars = effectiveMaxChars;
  }

  int maxVerses = monitorIndex == 1 ? m1MaxVerses : m2MaxVerses;
  int maxChars = monitorIndex == 1 ? m1MaxChars : m2MaxChars;

  if (maxVerses <= 1) return [index];

  // Find the boundaries of the current Bible block
  int start = index;
  int end = index;
  while (start > 0 && slides[start - 1].title == slide.title && !slides[start - 1].isSong && !slides[start - 1].isBlank) {
    start--;
  }
  while (end < slides.length - 1 && slides[end + 1].title == slide.title && !slides[end + 1].isSong && !slides[end + 1].isBlank) {
    end++;
  }

  final groups = _getGroups(slides, start, end, maxVerses, maxChars);
  return groups.firstWhere((g) => g.contains(index), orElse: () => [index]);
});

final m1ActiveSlideIndicesProvider = Provider<List<int>>((ref) {
  return ref.watch(_monitorActiveSlideIndicesProvider(1));
});

final m2ActiveSlideIndicesProvider = Provider<List<int>>((ref) {
  return ref.watch(_monitorActiveSlideIndicesProvider(2));
});

/// Computes the union of active slide indices for both monitors (used for background highlight).
final activeSlideIndicesProvider = Provider<List<int>>((ref) {
  final m1Indices = ref.watch(m1ActiveSlideIndicesProvider);
  final m2Indices = ref.watch(m2ActiveSlideIndicesProvider);
  
  final union = m1Indices.toSet().union(m2Indices.toSet()).toList();
  union.sort();
  return union;
});

/// Computes the active slide indices for the monitor with fewer max verses (used for left border highlight).
final borderActiveSlideIndicesProvider = Provider<List<int>>((ref) {
  final config = ref.watch(projectionProvider).config;
  
  if (config.monitor2MaxVerses < config.monitor1MaxVerses) {
    return ref.watch(m2ActiveSlideIndicesProvider);
  } else if (config.monitor1MaxVerses < config.monitor2MaxVerses) {
    return ref.watch(m1ActiveSlideIndicesProvider);
  } else {
    // If equal, M1 and M2 indices are identical anyway
    return ref.watch(m1ActiveSlideIndicesProvider);
  }
});

/// Holds the currently projected text for Monitor 1.
final m1ActiveSlideProvider = Provider<String?>((ref) {
  final slides = ref.watch(currentSlidesProvider);
  final indices = ref.watch(m1ActiveSlideIndicesProvider);
  final config = ref.watch(projectionProvider).config;

  if (indices.isEmpty || slides.isEmpty) return null;

  if (indices.length == 1) {
    return slides[indices.first].isBlank ? "" : slides[indices.first].content;
  }

  final joiner = config.monitor1Format.toLowerCase() == 'paragraph' ? ' ' : '\n';
  return indices.map((i) => slides[i].content).join(joiner);
});

/// Holds the currently projected text for Monitor 2.
final m2ActiveSlideProvider = Provider<String?>((ref) {
  final slides = ref.watch(currentSlidesProvider);
  final indices = ref.watch(m2ActiveSlideIndicesProvider);
  final config = ref.watch(projectionProvider).config;

  if (indices.isEmpty || slides.isEmpty) return null;

  if (indices.length == 1) {
    return slides[indices.first].isBlank ? "" : slides[indices.first].content;
  }

  final joiner = config.monitor2Format.toLowerCase() == 'paragraph' ? ' ' : '\n';
  return indices.map((i) => slides[i].content).join(joiner);
});

/// Holds the title of the currently projected slide.
final activeTitleProvider = Provider<String?>((ref) {
  final slides = ref.watch(currentSlidesProvider);
  final index = ref.watch(activeSlideIndexProvider);

  if (slides.isEmpty || index < 0 || index >= slides.length) return null;

  return slides[index].title;
});

/// Indicates if the currently projected slide is from a song.
final isSongActiveProvider = Provider<bool>((ref) {
  final slides = ref.watch(currentSlidesProvider);
  final index = ref.watch(activeSlideIndexProvider);

  if (slides.isEmpty || index < 0 || index >= slides.length) return false;

  return slides[index].isSong;
});

class SlideNavigationState {
  final int? nextPrimaryIndex;
  final int? prevPrimaryIndex;
  final int? nextSecondaryIndex;
  final int? prevSecondaryIndex;

  SlideNavigationState({
    this.nextPrimaryIndex,
    this.prevPrimaryIndex,
    this.nextSecondaryIndex,
    this.prevSecondaryIndex,
  });
}

/// Computes the target indices for keyboard navigation.
final slideNavigationProvider = Provider<SlideNavigationState>((ref) {
  final slides = ref.watch(currentSlidesProvider);
  final index = ref.watch(activeSlideIndexProvider);
  final config = ref.watch(projectionProvider).config;

  if (slides.isEmpty || index < 0 || index >= slides.length) {
    return SlideNavigationState();
  }

  final slide = slides[index];

  // If not a Bible verse, all nav arrows just move to next/prev index
  if (slide.isSong || slide.isBlank || slide.shortcut == 'IMG') {
    return SlideNavigationState(
      nextPrimaryIndex: index + 1 < slides.length ? index + 1 : null,
      prevPrimaryIndex: index - 1 >= 0 ? index - 1 : null,
      nextSecondaryIndex: index + 1 < slides.length ? index + 1 : null,
      prevSecondaryIndex: index - 1 >= 0 ? index - 1 : null,
    );
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

  int m1MaxVerses = config.monitor1MaxVerses;
  int m1MaxChars = config.monitor1MaxChars;
  int m2MaxVerses = config.monitor2MaxVerses;
  int m2MaxChars = config.monitor2MaxChars;

  if (m1MaxVerses == m2MaxVerses) {
    int effectiveMaxChars = 0;
    if (m1MaxChars <= 0 && m2MaxChars <= 0) {
      effectiveMaxChars = 0;
    } else if (m1MaxChars <= 0) {
      effectiveMaxChars = m2MaxChars;
    } else if (m2MaxChars <= 0) {
      effectiveMaxChars = m1MaxChars;
    } else {
      effectiveMaxChars = min(m1MaxChars, m2MaxChars);
    }
    m1MaxChars = effectiveMaxChars;
    m2MaxChars = effectiveMaxChars;
  }

  List<List<int>> m1Groups = _getGroups(slides, start, end, m1MaxVerses, m1MaxChars);
  List<List<int>> m2Groups = _getGroups(slides, start, end, m2MaxVerses, m2MaxChars);

  List<List<int>> primaryGroups;
  List<List<int>> secondaryGroups;

  if (m1MaxVerses >= m2MaxVerses) {
    primaryGroups = m1Groups;
    secondaryGroups = m2Groups;
  } else {
    primaryGroups = m2Groups;
    secondaryGroups = m1Groups;
  }

  int? getNext(List<List<int>> groups) {
    int groupIdx = groups.indexWhere((g) => g.contains(index));
    if (groupIdx >= 0 && groupIdx + 1 < groups.length) {
      return groups[groupIdx + 1].first;
    }
    // If no more groups in this block, move to the next slide (if it exists)
    return index + 1 < slides.length ? end + 1 : null;
  }

  int? getPrev(List<List<int>> groups) {
    int groupIdx = groups.indexWhere((g) => g.contains(index));
    if (groupIdx > 0) {
      return groups[groupIdx - 1].first;
    }
    // If no previous groups in this block, move to the previous slide (if it exists)
    return index - 1 >= 0 ? start - 1 : null;
  }

  return SlideNavigationState(
    nextPrimaryIndex: getNext(primaryGroups),
    prevPrimaryIndex: getPrev(primaryGroups),
    nextSecondaryIndex: getNext(secondaryGroups),
    prevSecondaryIndex: getPrev(secondaryGroups),
  );
});
