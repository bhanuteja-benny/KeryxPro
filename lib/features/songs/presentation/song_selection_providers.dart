import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../data/song.dart';

/// The song currently being previewed in the library bottom pane.
final previewSongProvider = StateProvider<Song?>((ref) => null);

/// Indicates whether the song editor pane should be visible.
final isSongEditorOpenProvider = StateProvider<bool>((ref) => false);

/// The song currently being edited, or null if adding a new song.
final songBeingEditedProvider = StateProvider<Song?>((ref) => null);

// Note: SetlistNotifier and setlistProvider have been moved to
// lib/features/setlist/presentation/setlist_providers.dart
