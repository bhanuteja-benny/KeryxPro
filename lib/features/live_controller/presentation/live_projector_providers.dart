import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../songs/presentation/song_selection_providers.dart';
import '../domain/slide.dart';
import 'slide_utils.dart';

/// Holds the list of parsed slides for all songs in the setlist.
final currentSlidesProvider = Provider<List<Slide>>((ref) {
  final setlist = ref.watch(setlistProvider);
  if (setlist.isEmpty) return [];
  
  final List<Slide> allSlides = [];
  for (final song in setlist) {
    final isSong = song.author != 'Bible';
    allSlides.addAll(SlideUtils.parseLyrics(song.lyrics, song.title, isSong: isSong));
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
