import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../features/live_controller/presentation/live_projector_providers.dart';
import '../../features/setlist/data/setlist_item.dart';
import '../../features/setlist/presentation/setlist_providers.dart';
import '../sync/media_sync_manager.dart';
import 'remote_config.dart';
import 'remote_models.dart';
import 'remote_service.dart';

final remoteConfigProvider = Provider<RemoteConfig>((ref) {
  throw UnimplementedError('RemoteConfig not initialized');
});

class RemoteSettingsNotifier extends StateNotifier<RemoteSettingsState> {
  final RemoteConfig _config;

  RemoteSettingsNotifier(this._config)
      : super(
          RemoteSettingsState(
            mode: _config.mode,
            machineName: _config.machineName,
            port: _config.port,
            discoveryEnabled: _config.discoveryEnabled,
            manualHost: _config.manualHost,
            imageByteFallbackEnabled: _config.imageByteFallbackEnabled,
            imageByteFallbackMaxBytes: _config.imageByteFallbackMaxBytes,
          ),
        );

  Future<void> updateMode(RemoteMode mode) async {
    state = state.copyWith(mode: mode);
    await _config.setMode(mode);
  }

  Future<void> updateMachineName(String value) async {
    final trimmed = value.trim();
    state = state.copyWith(machineName: trimmed.isEmpty ? 'Keryx Device' : trimmed);
    await _config.setMachineName(state.machineName);
  }

  Future<void> updatePort(int value) async {
    final safePort = value.clamp(1024, 65535);
    state = state.copyWith(port: safePort);
    await _config.setPort(safePort);
  }

  Future<void> updateDiscoveryEnabled(bool value) async {
    state = state.copyWith(discoveryEnabled: value);
    await _config.setDiscoveryEnabled(value);
  }

  Future<void> updateManualHost(String value) async {
    state = state.copyWith(manualHost: value.trim());
    await _config.setManualHost(value);
  }

  Future<void> updateImageByteFallbackEnabled(bool value) async {
    state = state.copyWith(imageByteFallbackEnabled: value);
    await _config.setImageByteFallbackEnabled(value);
  }

  Future<void> updateImageByteFallbackMaxBytes(int value) async {
    final safe = value.clamp(262144, 52428800);
    state = state.copyWith(imageByteFallbackMaxBytes: safe);
    await _config.setImageByteFallbackMaxBytes(safe);
  }
}

final remoteSettingsProvider =
    StateNotifierProvider<RemoteSettingsNotifier, RemoteSettingsState>((ref) {
  return RemoteSettingsNotifier(ref.read(remoteConfigProvider));
});

final remoteConnectionStateProvider =
    StateProvider<RemoteConnectionState>((ref) => RemoteConnectionState.idle);
final remoteLastSyncProvider = StateProvider<DateTime?>((ref) => null);
final remoteErrorProvider = StateProvider<String?>((ref) => null);
final remoteDiscoveredServersProvider =
    StateProvider<List<RemoteDiscoveredServer>>((ref) => const []);
final remoteIncomingRequestProvider =
    StateProvider<RemoteIncomingRequest?>((ref) => null);
final isApplyingRemoteChangesProvider = StateProvider<bool>((ref) => false);
final remoteClientConnectedNameProvider = StateProvider<String?>((ref) => null);

final remoteServiceProvider = Provider<RemoteService>((ref) {
  final service = RemoteService(ref);
  unawaited(service.initialize());
  ref.onDispose(service.dispose);
  return service;
});

final remoteSyncBridgeProvider = Provider<void>((ref) {
  final service = ref.watch(remoteServiceProvider);

  ref.listen<RemoteSettingsState>(remoteSettingsProvider, (previous, next) {
    if (previous == null || previous.mode != next.mode || previous.port != next.port
        || previous.discoveryEnabled != next.discoveryEnabled || previous.machineName != next.machineName) {
      unawaited(service.onSettingsChanged(next));
    }
  });

  ref.listen<List<SetlistItem>>(setlistProvider, (previous, next) {
    if (ref.read(isApplyingRemoteChangesProvider)) return;
    if (ref.read(remoteSettingsProvider).mode != RemoteMode.server) return;
    if (previous == null) return;

    unawaited(() async {
      final actions = await _buildSetlistActions(ref, previous, next);
      if (actions.isEmpty) return;
      service.enqueueActions(actions);
    }());
  });

  ref.listen<int>(activeSlideIndexProvider, (previous, next) {
    if (previous == null) return;
    if (ref.read(isApplyingRemoteChangesProvider)) return;
    if (ref.read(remoteSettingsProvider).mode != RemoteMode.server) return;
    if (previous == next) return;

    final items = ref.read(setlistProvider);
    final mapping = ref.read(slideToSetlistItemIndexProvider);
    String? activeItemUniqueId;
    if (next >= 0 && next < mapping.length) {
      final idx = mapping[next];
      if (idx >= 0 && idx < items.length) {
        activeItemUniqueId = items[idx].uniqueId;
      }
    }

    service.enqueueActions([
      {
        'actionType': 'ACTIVE_SLIDE_CHANGED',
        'payload': {
          'activeSlideIndex': next,
          'activeItemUniqueId': activeItemUniqueId,
        },
      }
    ]);
  });
});

Future<List<Map<String, dynamic>>> _buildSetlistActions(
  Ref ref,
  List<SetlistItem> previous,
  List<SetlistItem> next,
) async {
  final prevIds = previous.map((e) => e.uniqueId).toList();
  final nextIds = next.map((e) => e.uniqueId).toList();

  if (_listEquals(prevIds, nextIds)) {
    return const [];
  }

  final prevSet = prevIds.toSet();
  final nextSet = nextIds.toSet();
  final deletedIds = prevIds.where((id) => !nextSet.contains(id)).toList();
  final addedIds = nextIds.where((id) => !prevSet.contains(id)).toList();

  final actions = <Map<String, dynamic>>[];

  if (deletedIds.isNotEmpty) {
    actions.add({
      'actionType': 'SETLIST_ITEM_DELETED',
      'payload': {
        'itemUniqueIds': deletedIds,
      },
    });
  }

  if (addedIds.isNotEmpty) {
    for (final id in addedIds) {
      final index = nextIds.indexOf(id);
      final item = next[index];
      actions.add({
        'actionType': 'SETLIST_ITEM_ADDED',
        'payload': {
          'insertIndex': index,
          'item': await _serializeSetlistItemWithOptionalImage(ref, item),
        },
      });
    }
  }

  final sharedPrev = prevIds.where(nextSet.contains).toList();
  final sharedNext = nextIds.where(prevSet.contains).toList();
  final sameRelativeOrder = _listEquals(sharedPrev, sharedNext);

  if (!sameRelativeOrder || (addedIds.isEmpty && deletedIds.isEmpty)) {
    actions.add({
      'actionType': 'SETLIST_ITEMS_REORDERED',
      'payload': {
        'orderedUniqueIds': nextIds,
      },
    });
  }

  if (actions.isEmpty) {
    actions.add({
      'actionType': 'SETLIST_ITEMS_REORDERED',
      'payload': {
        'orderedUniqueIds': nextIds,
      },
    });
  }

  return actions;
}

Future<Map<String, dynamic>> _serializeSetlistItemWithOptionalImage(
  Ref ref,
  SetlistItem item,
) async {
  final base = serializeSetlistItem(item);
  if (item is! ImageSetlistItem) return base;

  final settings = ref.read(remoteSettingsProvider);
  if (!settings.imageByteFallbackEnabled) return base;

  final mediaSync = ref.read(mediaSyncManagerProvider);
  final resolvedPath = mediaSync.resolveMediaPath(item.imagePath);
  if (resolvedPath.isEmpty) return base;

  final file = File(resolvedPath);
  if (!file.existsSync()) return base;

  final length = await file.length();
  if (length <= 0 || length > settings.imageByteFallbackMaxBytes) return base;

  try {
    final bytes = await file.readAsBytes();
    base['inlineImage'] = {
      'fileName': p.basename(resolvedPath),
      'mimeHint': _mimeHintFromPath(resolvedPath),
      'base64': base64Encode(bytes),
    };
  } catch (_) {
    // Inline image fallback is optional; ignore failures and continue with path-based sync.
  }

  return base;
}

String _mimeHintFromPath(String path) {
  final ext = p.extension(path).toLowerCase();
  if (ext == '.png') return 'image/png';
  if (ext == '.jpg' || ext == '.jpeg') return 'image/jpeg';
  if (ext == '.webp') return 'image/webp';
  if (ext == '.gif') return 'image/gif';
  return 'application/octet-stream';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}