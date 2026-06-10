import '../../songs/data/song.dart';
import 'package:uuid/uuid.dart';

/// Represents a single item in a SetList at runtime.
/// Can be either a Song or an Image Slide.
sealed class SetlistItem {
  final String uniqueId;
  final bool isFavorite;
  SetlistItem({String? uniqueId, this.isFavorite = false})
      : uniqueId = uniqueId ?? const Uuid().v4();

  SetlistItem copyWith({bool? isFavorite});
}

class SongSetlistItem extends SetlistItem {
  final Song song;
  SongSetlistItem(this.song, {super.uniqueId, super.isFavorite});

  @override
  SongSetlistItem copyWith({bool? isFavorite}) {
    return SongSetlistItem(
      song,
      uniqueId: uniqueId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ImageSetlistItem extends SetlistItem {
  final String imagePath;
  final String layout;     // 'stretch', 'fit', 'contain'
  final String alignment;  // 'topLeft', 'topCenter', 'topRight',
                           // 'centerLeft', 'center', 'centerRight',
                           // 'bottomLeft', 'bottomCenter', 'bottomRight'

  ImageSetlistItem({
    required this.imagePath,
    this.layout = 'contain',
    this.alignment = 'center',
    super.uniqueId,
    super.isFavorite,
  });

  @override
  ImageSetlistItem copyWith({bool? isFavorite}) {
    return ImageSetlistItem(
      imagePath: imagePath,
      layout: layout,
      alignment: alignment,
      uniqueId: uniqueId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get displayName => imagePath.split(RegExp(r'[/\\]')).last;
}
