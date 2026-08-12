import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../features/live_controller/presentation/live_projector_providers.dart';
import '../../features/setlist/data/setlist_item.dart';
import '../../features/setlist/presentation/setlist_providers.dart';
import '../sync/media_sync_manager.dart';
import 'remote_models.dart';
import 'remote_providers.dart';

class _PendingSocketRequest {
  final String requestId;
  final String machineName;
  final WebSocket socket;

  _PendingSocketRequest({
    required this.requestId,
    required this.machineName,
    required this.socket,
  });
}

class RemoteService {
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  HttpServer? _server;
  WebSocket? _serverClientSocket;
  WebSocket? _clientSocket;
  RawDatagramSocket? _discoveryServerSocket;
  RawDatagramSocket? _discoveryClientSocket;
  Timer? _discoveryBroadcastTimer;
  Timer? _discoveryCleanupTimer;

  final Map<String, _PendingSocketRequest> _pendingRequests = {};
  final Map<String, RemoteDiscoveredServer> _discovered = {};
  final List<Map<String, dynamic>> _outgoingActionQueue = [];

  String _sessionId = const Uuid().v4();
  int _revision = 0;
  Timer? _outgoingBatchTimer;

  RemoteService(this._ref);

  Future<void> initialize() async {
    await onSettingsChanged(_ref.read(remoteSettingsProvider));
  }

  Future<void> onSettingsChanged(RemoteSettingsState settings) async {
  await _stopAll();

  _clearRuntimeState();

  if (settings.mode == RemoteMode.server) {
    await _startServer(settings);
  } else if (settings.mode == RemoteMode.client) {
    _setConnectionState(RemoteConnectionState.discovering);
    if (settings.discoveryEnabled) {
      await _startClientDiscovery(settings);
    }
  }
}

Future<void> connectToServer({String? host, int? port}) async {
  final settings = _ref.read(remoteSettingsProvider);
  final targetHost = (host ?? settings.manualHost).trim();
  final targetPort = port ?? settings.port;

  if (targetHost.isEmpty) {
    _setError('No server host provided. Select a discovered server or configure manual host.');
    return;
  }

  await _closeClientSocket();

  _setConnectionState(RemoteConnectionState.connecting);
  _setError(null);

  try {
    final socket = await WebSocket.connect('ws://$targetHost:$targetPort');
    _clientSocket = socket;

    socket.listen(
      _handleClientMessage,
      onError: (Object error) {
        _setError('Connection error: $error');
        _setConnectionState(RemoteConnectionState.error);
      },
      onDone: () {
        _setConnectionState(RemoteConnectionState.disconnected);
        _ref.read(remoteClientConnectedNameProvider.notifier).state = null;
      },
      cancelOnError: true,
    );

    socket.add(jsonEncode({
      'type': 'HELLO',
      'machineName': settings.machineName,
    }));

    _setConnectionState(RemoteConnectionState.awaitingApproval);
  } catch (e) {
    _setError('Unable to connect to $targetHost:$targetPort ($e)');
    _setConnectionState(RemoteConnectionState.error);
  }
}

Future<void> disconnect() async {
  await _closeClientSocket();
  await _closeServerClientSocket();
  _setConnectionState(RemoteConnectionState.disconnected);
  _ref.read(remoteClientConnectedNameProvider.notifier).state = null;
}

Future<void> acceptPendingRequest(String requestId) async {
  final pending = _pendingRequests.remove(requestId);
  if (pending == null) return;

  await _closeServerClientSocket();
  _serverClientSocket = pending.socket;
  _ref.read(remoteIncomingRequestProvider.notifier).state = null;
  _ref.read(remoteClientConnectedNameProvider.notifier).state = pending.machineName;

  _setConnectionState(RemoteConnectionState.connected);

  pending.socket.add(jsonEncode({'type': 'ACCEPT'}));
  await _sendSessionSnapshot();
}

Future<void> rejectPendingRequest(String requestId) async {
  final pending = _pendingRequests.remove(requestId);
  if (pending == null) return;

  pending.socket.add(jsonEncode({'type': 'REJECT'}));
  await pending.socket.close();

  _ref.read(remoteIncomingRequestProvider.notifier).state = null;
}

Future<void> requestFreshSnapshot() async {
  final socket = _clientSocket;
  if (socket == null) return;

  socket.add(jsonEncode({'type': 'SNAPSHOT_REQUEST'}));
}

Future<void> sendActionBatch(List<Map<String, dynamic>> actions) async {
  await _sendActionBatchNow(actions);
}

void enqueueActions(List<Map<String, dynamic>> actions) {
  if (_ref.read(remoteSettingsProvider).mode != RemoteMode.server) return;
  if (actions.isEmpty) return;

  _outgoingActionQueue.addAll(actions);
  _outgoingBatchTimer?.cancel();
  _outgoingBatchTimer = Timer(const Duration(milliseconds: 80), () {
    unawaited(_flushQueuedActions());
  });
}

Future<void> _flushQueuedActions() async {
  if (_outgoingActionQueue.isEmpty) return;
  final actions = List<Map<String, dynamic>>.from(_outgoingActionQueue);
  _outgoingActionQueue.clear();
  await _sendActionBatchNow(actions);
}

Future<void> _sendActionBatchNow(List<Map<String, dynamic>> actions) async {
  if (_ref.read(remoteSettingsProvider).mode != RemoteMode.server) return;
  if (actions.isEmpty) return;

  final socket = _serverClientSocket;
  if (socket == null) return;

  _revision += 1;
  final message = {
    'type': 'ACTION_BATCH',
    'schemaVersion': 1,
    'sessionId': _sessionId,
    'messageId': _uuid.v4(),
    'revision': _revision,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'actions': actions,
  };

  socket.add(jsonEncode(message));
  _ref.read(remoteLastSyncProvider.notifier).state = DateTime.now();
}

Future<void> dispose() async {
  await _stopAll();
}

Future<void> _startServer(RemoteSettingsState settings) async {
  _setConnectionState(RemoteConnectionState.discovering);
  _setError(null);
  _sessionId = _uuid.v4();
  _revision = 0;

  try {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, settings.port);
    _server!.listen((HttpRequest request) async {
      if (!WebSocketTransformer.isUpgradeRequest(request)) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('WebSocket endpoint only')
          ..close();
        return;
      }

      final socket = await WebSocketTransformer.upgrade(request);
      socket.listen(
        (dynamic data) => _handleServerMessage(socket, data),
        onDone: () {
          if (identical(_serverClientSocket, socket)) {
            _serverClientSocket = null;
            _ref.read(remoteClientConnectedNameProvider.notifier).state = null;
            _setConnectionState(RemoteConnectionState.disconnected);
          }
        },
        onError: (Object error) {
          if (identical(_serverClientSocket, socket)) {
            _setError('Client socket error: $error');
            _setConnectionState(RemoteConnectionState.error);
          }
        },
        cancelOnError: true,
      );
    });

    try {
      await _startServerDiscovery(settings);
    } catch (e) {
      print('Warning: Server UDP discovery error: $e');
    }
    _setConnectionState(RemoteConnectionState.idle);
  } catch (e) {
    _setError('Failed to start server on port ${settings.port}: $e');
    _setConnectionState(RemoteConnectionState.error);
  }
}

Future<void> _startServerDiscovery(RemoteSettingsState settings) async {
  if (!settings.discoveryEnabled) return;

  final discoveryPort = settings.port + 1;
  try {
    _discoveryServerSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      discoveryPort,
      reuseAddress: true,
      reusePort: false,
    );
  } catch (e) {
    print('Warning: Server discovery socket bind error: $e');
    return;
  }

  _discoveryServerSocket!.listen((RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final dg = _discoveryServerSocket!.receive();
    if (dg == null) return;

    final text = utf8.decode(dg.data, allowMalformed: true).trim();
    if (text != 'KERYX_DISCOVER_V1') return;

    final response = jsonEncode({
      'type': 'KERYX_ANNOUNCE_V1',
      'machineName': settings.machineName,
      'port': settings.port,
    });

    try {
      _discoveryServerSocket!.send(
        utf8.encode(response),
        dg.address,
        dg.port,
      );
    } catch (_) {}
  });
}

Future<void> _startClientDiscovery(RemoteSettingsState settings) async {
  final discoveryPort = settings.port + 1;

  try {
    _discoveryClientSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
      reuseAddress: true,
      reusePort: false,
    );
  } catch (e) {
    print('Warning: Client discovery socket bind error: $e');
    return;
  }

  try {
    _discoveryClientSocket!.broadcastEnabled = true;
  } catch (_) {}

  _discoveryClientSocket!.listen((RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final dg = _discoveryClientSocket!.receive();
    if (dg == null) return;

    try {
      final payload = jsonDecode(utf8.decode(dg.data)) as Map<String, dynamic>;
      if (payload['type'] != 'KERYX_ANNOUNCE_V1') return;
      final port = payload['port'] as int? ?? settings.port;
      final machineName = payload['machineName'] as String? ?? 'Keryx Server';
      final host = dg.address.address;

      final entry = RemoteDiscoveredServer(
        host: host,
        port: port,
        machineName: machineName,
        lastSeenAt: DateTime.now(),
      );
      _discovered[entry.id] = entry;
      _publishDiscovered();
    } catch (_) {
      // Ignore malformed discovery payloads.
    }
  });

  _discoveryBroadcastTimer = Timer.periodic(const Duration(seconds: 3), (_) {
    try {
      _discoveryClientSocket?.send(
        utf8.encode('KERYX_DISCOVER_V1'),
        InternetAddress('255.255.255.255'),
        discoveryPort,
      );
    } catch (_) {}
  });

  _discoveryCleanupTimer = Timer.periodic(const Duration(seconds: 5), (_) {
    final now = DateTime.now();
    _discovered.removeWhere((_, value) => now.difference(value.lastSeenAt) > const Duration(seconds: 10));
    _publishDiscovered();
  });

  try {
    _discoveryClientSocket!.send(
      utf8.encode('KERYX_DISCOVER_V1'),
      InternetAddress('255.255.255.255'),
      discoveryPort,
    );
  } catch (_) {}
}

Future<void> _sendSessionSnapshot() async {
  final socket = _serverClientSocket;
  if (socket == null) return;

  final setlist = _ref.read(setlistProvider);
  final payload = {
    'type': 'SESSION_SNAPSHOT',
    'schemaVersion': 1,
    'sessionId': _sessionId,
    'revision': _revision,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'setlist': setlist.map(serializeSetlistItem).toList(),
    'activeSlideIndex': _ref.read(activeSlideIndexProvider),
  };

  socket.add(jsonEncode(payload));
  _ref.read(remoteLastSyncProvider.notifier).state = DateTime.now();
}

void _handleServerMessage(WebSocket socket, dynamic data) {
  Map<String, dynamic> message;
  try {
    message = jsonDecode(data as String) as Map<String, dynamic>;
  } catch (_) {
    return;
  }

  final type = message['type'] as String?;
  if (type == 'HELLO') {
    final machineName = message['machineName'] as String? ?? 'Unknown Client';
    final requestId = _uuid.v4();
    _pendingRequests[requestId] = _PendingSocketRequest(
      requestId: requestId,
      machineName: machineName,
      socket: socket,
    );
    _ref.read(remoteIncomingRequestProvider.notifier).state = RemoteIncomingRequest(
      requestId: requestId,
      machineName: machineName,
    );
    return;
  }

  if (type == 'SNAPSHOT_REQUEST') {
    _sendSessionSnapshot();
  }
}

void _handleClientMessage(dynamic data) {
  Map<String, dynamic> message;
  try {
    message = jsonDecode(data as String) as Map<String, dynamic>;
  } catch (_) {
    return;
  }

  final type = message['type'] as String?;
  switch (type) {
    case 'ACCEPT':
      _setConnectionState(RemoteConnectionState.connected);
      _setError(null);
      break;
    case 'REJECT':
      _setConnectionState(RemoteConnectionState.disconnected);
      _setError('Connection request was rejected by the Server.');
      break;
    case 'SESSION_SNAPSHOT':
      _applySessionSnapshot(message);
      break;
    case 'ACTION_BATCH':
      unawaited(_applyActionBatch(message));
      break;
  }
}

void _applySessionSnapshot(Map<String, dynamic> message) {
  final setlistRaw = message['setlist'] as List<dynamic>? ?? const [];
  final items = <SetlistItem>[];
  for (final raw in setlistRaw) {
    if (raw is! Map<String, dynamic>) continue;
    final parsed = deserializeSetlistItem(raw);
    if (parsed != null) {
      items.add(parsed);
    }
  }

  final activeSlideIndex = message['activeSlideIndex'] as int? ?? 0;

  _ref.read(isApplyingRemoteChangesProvider.notifier).state = true;
  try {
    _ref.read(setlistProvider.notifier).replaceAll(items);
    _ref.read(setlistSelectionProvider.notifier).clear();
    final safeIndex = items.isEmpty
        ? 0
        : (activeSlideIndex.clamp(0, _ref.read(currentSlidesProvider).length - 1) as int);
    _ref.read(activeSlideIndexProvider.notifier).state = safeIndex;
    _ref.read(remoteLastSyncProvider.notifier).state = DateTime.now();
    _setConnectionState(RemoteConnectionState.connected);
    _setError(null);
  } catch (e) {
    _setError('Failed to apply SESSION_SNAPSHOT: $e');
    _setConnectionState(RemoteConnectionState.error);
  } finally {
    _ref.read(isApplyingRemoteChangesProvider.notifier).state = false;
  }
}

Future<void> _applyActionBatch(Map<String, dynamic> message) async {
  final actions = message['actions'] as List<dynamic>? ?? const [];

  _ref.read(isApplyingRemoteChangesProvider.notifier).state = true;
  try {




    Map<String, dynamic>? deferredSlideChangePayload;
    
    for (final raw in actions) {
      if (raw is! Map<String, dynamic>) continue;
      final type = raw['actionType'] as String?;
      final payload = raw['payload'] as Map<String, dynamic>? ?? const {};

      switch (type) {
        case 'SETLIST_ITEM_ADDED':
          final insertIndex = payload['insertIndex'] as int? ?? _ref.read(setlistProvider).length;
          final itemMap = payload['item'] as Map<String, dynamic>?;
          if (itemMap != null) {
            await _materializeInlineImageIfPresent(itemMap);
            final item = deserializeSetlistItem(itemMap);
            if (item != null) {
              _ref.read(setlistProvider.notifier).insertItemAt(insertIndex, item);
            }
          }
          break;

        case 'SETLIST_ITEM_DELETED':
          final ids = (payload['itemUniqueIds'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toList();
          _ref.read(setlistProvider.notifier).removeByUniqueIds(ids);
          break;

        case 'SETLIST_ITEMS_REORDERED':
          final ids = (payload['orderedUniqueIds'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toList();
          _ref.read(setlistProvider.notifier).reorderByUniqueIds(ids);
          break;

        case 'ACTIVE_SLIDE_CHANGED':

          deferredSlideChangePayload = payload;
          break;
      }
    }


    if (deferredSlideChangePayload != null) {
          final requested = deferredSlideChangePayload['activeSlideIndex'] as int? ?? 0;
          final slideCount = _ref.read(currentSlidesProvider).length;
          if (slideCount == 0) {
            _ref.read(activeSlideIndexProvider.notifier).state = 0;
          } else {
            final safe = requested.clamp(0, slideCount - 1) as int;
            _ref.read(activeSlideIndexProvider.notifier).state = safe;
          }
      }
    

    _ref.read(setlistSelectionProvider.notifier).clear();
    _ref.read(remoteLastSyncProvider.notifier).state = DateTime.now();
    _setError(null);
  } catch (e) {
    _setError('Failed to apply remote action batch: $e');
    _setConnectionState(RemoteConnectionState.error);
  } finally {
    _ref.read(isApplyingRemoteChangesProvider.notifier).state = false;
  }
}

void _publishDiscovered() {
  final list = _discovered.values.toList()
    ..sort((a, b) => b.lastSeenAt.compareTo(a.lastSeenAt));
  _ref.read(remoteDiscoveredServersProvider.notifier).state = list;
}

void _setConnectionState(RemoteConnectionState state) {
  _ref.read(remoteConnectionStateProvider.notifier).state = state;
}

void _setError(String? message) {
  _ref.read(remoteErrorProvider.notifier).state = message;
}

void _clearRuntimeState() {
  _ref.read(remoteErrorProvider.notifier).state = null;
  _ref.read(remoteDiscoveredServersProvider.notifier).state = const [];
  _ref.read(remoteIncomingRequestProvider.notifier).state = null;
  _ref.read(remoteClientConnectedNameProvider.notifier).state = null;
  _discovered.clear();
  _outgoingActionQueue.clear();
}

Future<void> _materializeInlineImageIfPresent(Map<String, dynamic> itemMap) async {
  final type = (itemMap['type'] as String? ?? '').toLowerCase();
  if (type != 'image') return;

  final inlineImage = itemMap['inlineImage'];
  if (inlineImage is! Map<String, dynamic>) return;
  final base64Data = inlineImage['base64'] as String?;
  if (base64Data == null || base64Data.isEmpty) return;

  try {
    final bytes = base64Decode(base64Data);
    if (bytes.isEmpty) return;

    final docDirPath = _ref.read(appDocumentsDirectoryPathProvider);
    final fileName = (inlineImage['fileName'] as String?)?.trim();
    final ext = p.extension(fileName ?? '').toLowerCase();
    final safeExt = (ext == '.png' || ext == '.jpg' || ext == '.jpeg' || ext == '.webp' || ext == '.gif')
        ? ext
        : '.img';

    final targetDir = Directory(
      p.join(docDirPath, 'KeryxPro', 'RemoteMedia', 'Image Slides'),
    );
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final uniqueId = (itemMap['uniqueId'] as String?) ?? _uuid.v4();
    final targetPath = p.join(targetDir.path, 'remote_$uniqueId$safeExt');
    final targetFile = File(targetPath);
    await targetFile.writeAsBytes(bytes, flush: true);

    itemMap['imagePath'] = targetPath;
  } catch (_) {
    // Ignore inline image decode/write errors and keep original imagePath.
  }
}

Future<void> _closeClientSocket() async {
  await _clientSocket?.close();
  _clientSocket = null;
}

Future<void> _closeServerClientSocket() async {
  await _serverClientSocket?.close();
  _serverClientSocket = null;
}

Future<void> _stopAll() async {
  _outgoingBatchTimer?.cancel();
  _outgoingBatchTimer = null;

  for (final pending in _pendingRequests.values) {
    await pending.socket.close();
  }
  _pendingRequests.clear();

  await _closeClientSocket();
  await _closeServerClientSocket();

  await _server?.close(force: true);
  _server = null;

  _discoveryBroadcastTimer?.cancel();
  _discoveryBroadcastTimer = null;

  _discoveryCleanupTimer?.cancel();
  _discoveryCleanupTimer = null;

  _discoveryServerSocket?.close();
  _discoveryServerSocket = null;

  _discoveryClientSocket?.close();
  _discoveryClientSocket = null;
}
}
