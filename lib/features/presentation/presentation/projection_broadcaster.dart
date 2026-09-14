import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import '../../live_controller/presentation/live_projector_providers.dart';
import '../../songs/presentation/song_selection_providers.dart';
import '../../settings/presentation/projection_provider.dart';
import '../../dashboard/presentation/global_ui_providers.dart';

final projectionBroadcasterProvider = Provider<void>((ref) {
  // Listen for slide or title changes on Monitor 1
  ref.listen(m1ActiveSlideProvider, (previous, next) {
    _broadcastContentM1(ref, next);
  });
  ref.listen(m1ActiveTitleProvider, (previous, next) {
    _broadcastContentM1(ref, ref.read(m1ActiveSlideProvider));
  });

  // Listen for slide or title changes on Monitor 2
  ref.listen(m2ActiveSlideProvider, (previous, next) {
    _broadcastContentM2(ref, next);
  });
  ref.listen(m2ActiveTitleProvider, (previous, next) {
    _broadcastContentM2(ref, ref.read(m2ActiveSlideProvider));
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

  final title = ref.read(m1ActiveTitleProvider);
  final isSong = ref.read(isSongActiveProvider);
  final isDualVersion = ref.read(isDualVersionActiveProvider);
  final state = ref.read(projectionProvider);
  
  if (state.monitor1WindowId != null) {
    final args = {
      'text': text,
      'title': title,
      'isSong': isSong,
      'isDualVersion': isDualVersion,
    };
    WindowController.fromWindowId(state.monitor1WindowId!)
        .invokeMethod('update_content', args)
        .catchError((e, stack) {
      print('[KeryxPro-v3] Error broadcasting to Monitor 1 (async): $e\n$stack');
    });
  }
}

void _broadcastContentM2(Ref ref, String? text) {
  if (ref.read(isLiveScreenFrozenProvider)) return;

  final title = ref.read(m2ActiveTitleProvider);
  final isSong = ref.read(isSongActiveProvider);
  final isDualVersion = ref.read(isDualVersionActiveProvider);
  final state = ref.read(projectionProvider);
  
  if (state.monitor2WindowId != null) {
    final args = {
      'text': text,
      'title': title,
      'isSong': isSong,
      'isDualVersion': isDualVersion,
    };
    WindowController.fromWindowId(state.monitor2WindowId!)
        .invokeMethod('update_content', args)
        .catchError((e, stack) {
      print('[KeryxPro-v3] Error broadcasting to Monitor 2 (async): $e\n$stack');
    });
  }
}
