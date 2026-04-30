import '../../songs/data/song.dart';

/// Represents a single item in a SetList at runtime.
/// Can be either a Song or an Image Slide.
sealed class SetlistItem {
  final bool isFavorite;
  const SetlistItem({this.isFavorite = false});

  SetlistItem copyWith({bool? isFavorite});
}

class SongSetlistItem extends SetlistItem {
  final Song song;
  const SongSetlistItem(this.song, {super.isFavorite});

  @override
  SongSetlistItem copyWith({bool? isFavorite}) {
    return SongSetlistItem(song, isFavorite: isFavorite ?? this.isFavorite);
  }
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
    super.isFavorite,
  });

  @override
  ImageSetlistItem copyWith({bool? isFavorite}) {
    return ImageSetlistItem(
      imagePath: imagePath,
      layout: layout,
      alignment: alignment,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get displayName => imagePath.split(RegExp(r'[/\\]')).last;
}
