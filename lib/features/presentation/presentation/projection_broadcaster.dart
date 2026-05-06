import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import '../../live_controller/presentation/live_projector_providers.dart';
import '../../songs/presentation/song_selection_providers.dart';
import '../../settings/presentation/projection_provider.dart';

final projectionBroadcasterProvider = Provider<void>((ref) {
  // Listen for slide changes
  ref.listen(m1ActiveSlideProvider, (previous, next) {
    _broadcastContent(ref, next);
  });

  // Listen for title changes
  ref.listen(activeTitleProvider, (previous, next) {
    _broadcastContent(ref, ref.read(m1ActiveSlideProvider));
  });
});

void _broadcastContent(Ref ref, String? text) {
  final title = ref.read(activeTitleProvider);
  final isSong = ref.read(isSongActiveProvider);
  final state = ref.read(projectionProvider);
  
  // Only broadcast to Monitor 1 external window (Monitor 2 is inline via Riverpod)
  if (state.monitor1WindowId != null) {
    final args = {
      'text': text,
      'title': title,
      'isSong': isSong,
    };
    // The library's fromWindowId seems to expect a String in this setup
    WindowController.fromWindowId(state.monitor1WindowId!).invokeMethod('update_content', args);
  }
}
