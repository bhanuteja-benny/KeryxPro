import '../../songs/data/song.dart';

/// Represents a single item in a SetList at runtime.
/// Can be either a Song or an Image Slide.
sealed class SetlistItem {
  const SetlistItem();
}

class SongSetlistItem extends SetlistItem {
  final Song song;
  const SongSetlistItem(this.song);
}

class ImageSetlistItem extends SetlistItem {
  final String imagePath;
  final String layout;     // 'stretch', 'fit', 'contain'
  final String alignment;  // 'topLeft', 'topCenter', 'topRight',
                           // 'centerLeft', 'center', 'centerRight',
                           // 'bottomLeft', 'bottomCenter', 'bottomRight'

  const ImageSetlistItem({
    required this.imagePath,
    this.layout = 'contain',
    this.alignment = 'center',
  });

  String get displayName => imagePath.split(RegExp(r'[/\\]')).last;
}
