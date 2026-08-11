import '../../features/setlist/data/setlist_item.dart';
import '../../features/songs/data/song.dart';

enum RemoteMode {
  off,
  client,
  server,
}

RemoteMode remoteModeFromString(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'client':
      return RemoteMode.client;
    case 'server':
      return RemoteMode.server;
    default:
      return RemoteMode.off;
  }
}

String remoteModeToString(RemoteMode mode) {
  switch (mode) {
    case RemoteMode.client:
      return 'client';
    case RemoteMode.server:
      return 'server';
    case RemoteMode.off:
      return 'off';
  }
}

enum RemoteConnectionState {
  idle,
  discovering,
  connecting,
  awaitingApproval,
  connected,
  disconnected,
  error,
}

class RemoteSettingsState {
  final RemoteMode mode;
  final String machineName;
  final int port;
  final bool discoveryEnabled;
  final String manualHost;
  final bool imageByteFallbackEnabled;
  final int imageByteFallbackMaxBytes;

  const RemoteSettingsState({
    required this.mode,
    required this.machineName,
    required this.port,
    required this.discoveryEnabled,
    required this.manualHost,
    required this.imageByteFallbackEnabled,
    required this.imageByteFallbackMaxBytes,
  });

  RemoteSettingsState copyWith({
    RemoteMode? mode,
    String? machineName,
    int? port,
    bool? discoveryEnabled,
    String? manualHost,
    bool? imageByteFallbackEnabled,
    int? imageByteFallbackMaxBytes,
  }) {
    return RemoteSettingsState(
      mode: mode ?? this.mode,
      machineName: machineName ?? this.machineName,
      port: port ?? this.port,
      discoveryEnabled: discoveryEnabled ?? this.discoveryEnabled,
      manualHost: manualHost ?? this.manualHost,
      imageByteFallbackEnabled:
          imageByteFallbackEnabled ?? this.imageByteFallbackEnabled,
      imageByteFallbackMaxBytes:
          imageByteFallbackMaxBytes ?? this.imageByteFallbackMaxBytes,
    );
  }
}

class RemoteDiscoveredServer {
  final String host;
  final int port;
  final String machineName;
  final DateTime lastSeenAt;

  const RemoteDiscoveredServer({
    required this.host,
    required this.port,
    required this.machineName,
    required this.lastSeenAt,
  });

  String get id => '$host:$port';

  RemoteDiscoveredServer copyWith({
    String? host,
    int? port,
    String? machineName,
    DateTime? lastSeenAt,
  }) {
    return RemoteDiscoveredServer(
      host: host ?? this.host,
      port: port ?? this.port,
      machineName: machineName ?? this.machineName,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }
}

class RemoteIncomingRequest {
  final String requestId;
  final String machineName;

  const RemoteIncomingRequest({
    required this.requestId,
    required this.machineName,
  });
}

Map<String, dynamic> serializeSetlistItem(SetlistItem item) {
  if (item is SongSetlistItem) {
    return {
      'type': 'song',
      'uniqueId': item.uniqueId,
      'isFavorite': item.isFavorite,
      'title': item.song.title,
      'author': item.song.author,
      'lyrics': item.song.lyrics,
      'backgroundUrl': item.song.backgroundUrl,
    };
  }

  if (item is ImageSetlistItem) {
    return {
      'type': 'image',
      'uniqueId': item.uniqueId,
      'isFavorite': item.isFavorite,
      'imagePath': item.imagePath,
      'layout': item.layout,
      'alignment': item.alignment,
    };
  }

  if (item is WindowSetlistItem) {
    return {
      'type': 'window',
      'uniqueId': item.uniqueId,
      'isFavorite': item.isFavorite,
      'windowHandle': item.windowHandle,
      'windowTitle': item.windowTitle,
      'processName': item.processName,
      'layout': item.layout,
      'contentOnly': item.contentOnly,
    };
  }

  return {
    'type': 'unknown',
    'uniqueId': item.uniqueId,
    'isFavorite': item.isFavorite,
  };
}

SetlistItem? deserializeSetlistItem(Map<String, dynamic> json) {
  final type = (json['type'] as String? ?? '').toLowerCase();
  final uniqueId = json['uniqueId'] as String?;
  final isFavorite = json['isFavorite'] as bool? ?? false;

  switch (type) {
    case 'song':
      final song = Song()
        ..title = json['title'] as String? ?? ''
        ..author = json['author'] as String?
        ..lyrics = json['lyrics'] as String? ?? ''
        ..backgroundUrl = json['backgroundUrl'] as String?;
      return SongSetlistItem(song, uniqueId: uniqueId, isFavorite: isFavorite);

    case 'image':
      return ImageSetlistItem(
        uniqueId: uniqueId,
        isFavorite: isFavorite,
        imagePath: json['imagePath'] as String? ?? '',
        layout: json['layout'] as String? ?? 'contain',
        alignment: json['alignment'] as String? ?? 'center',
      );

    case 'window':
      return WindowSetlistItem(
        uniqueId: uniqueId,
        isFavorite: isFavorite,
        windowHandle: json['windowHandle'] as String? ?? '',
        windowTitle: json['windowTitle'] as String? ?? 'Window',
        processName: json['processName'] as String? ?? '',
        layout: json['layout'] as String? ?? 'contain',
        contentOnly: json['contentOnly'] as bool? ?? false,
      );

    default:
      return null;
  }
}