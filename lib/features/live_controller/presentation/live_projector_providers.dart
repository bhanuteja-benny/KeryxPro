import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../setlist/data/setlist_item.dart';
import '../../setlist/presentation/setlist_providers.dart';
import '../domain/slide.dart';
import 'slide_utils.dart';

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

/// Holds the currently projected text snippet/slide.
/// Now derived from currentSlidesProvider and activeSlideIndexProvider.
final activeSlideProvider = Provider<String?>((ref) {
  final slides = ref.watch(currentSlidesProvider);
  final index = ref.watch(activeSlideIndexProvider);

  if (slides.isEmpty || index < 0 || index >= slides.length) return null;

  final slide = slides[index];
  return slide.isBlank ? "" : slide.content;
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
