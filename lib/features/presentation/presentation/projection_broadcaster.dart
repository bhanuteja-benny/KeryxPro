import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import '../../live_controller/presentation/live_projector_providers.dart';
import '../../songs/presentation/song_selection_providers.dart';
import '../../settings/presentation/projection_provider.dart';
import '../../dashboard/presentation/global_ui_providers.dart';

final projectionBroadcasterProvider = Provider<void>((ref) {
  // Listen for slide changes
  ref.listen(m1ActiveSlideProvider, (previous, next) {
    _broadcastContentM1(ref, next);
  });

  // Listen for title changes
  ref.listen(activeTitleProvider, (previous, next) {
    _broadcastContentM1(ref, ref.read(m1ActiveSlideProvider));
    _broadcastContentM2(ref, ref.read(m2ActiveSlideProvider));
  });

  // Listen for Monitor 2 slide changes
  ref.listen(m2ActiveSlideProvider, (previous, next) {
    _broadcastContentM2(ref, next);
  });

  // Listen for unfreeze to sync live windows
  ref.listen(isLiveScreenFrozenProvider, (previous, isFrozen) {
    if (previous == true && !isFrozen) {
      _broadcastContentM1(ref, ref.read(m1ActiveSlideProvider));
      _broadcastContentM2(ref, ref.read(m2ActiveSlideProvider));
    }
  });
});

void _broadcastContentM1(Ref ref, String? text) {
  if (ref.read(isLiveScreenFrozenProvider)) return;

  final title = ref.read(activeTitleProvider);
  final isSong = ref.read(isSongActiveProvider);
  final state = ref.read(projectionProvider);
  
  if (state.monitor1WindowId != null) {
    final args = {
      'text': text,
      'title': title,
      'isSong': isSong,
    };
    try {
      WindowController.fromWindowId(state.monitor1WindowId!).invokeMethod('update_content', args);
    } catch (e) {
      print('Error broadcasting to Monitor 1: $e');
    }
  }
}

void _broadcastContentM2(Ref ref, String? text) {
  if (ref.read(isLiveScreenFrozenProvider)) return;

  final title = ref.read(activeTitleProvider);
  final isSong = ref.read(isSongActiveProvider);
  final state = ref.read(projectionProvider);
  
  if (state.monitor2WindowId != null) {
    final args = {
      'text': text,
      'title': title,
      'isSong': isSong,
    };
    try {
      WindowController.fromWindowId(state.monitor2WindowId!).invokeMethod('update_content', args);
    } catch (e) {
      print('Error broadcasting to Monitor 2: $e');
    }
    ref.read(projectionProvider.notifier).resizeMonitor2Window(isSong);
  }
}
