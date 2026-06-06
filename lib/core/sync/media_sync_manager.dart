import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'sync_service.dart';
import 'sync_config.dart';

final appDocumentsDirectoryPathProvider = Provider<String>((ref) {
  throw UnimplementedError('appDocumentsDirectoryPathProvider not overridden');
});

final mediaSyncManagerProvider = Provider<MediaSyncManager>((ref) {
  final config = ref.watch(syncConfigProvider);
  final docDirPath = ref.watch(appDocumentsDirectoryPathProvider);
  return MediaSyncManager(config, docDirPath);
});

class MediaSyncManager {
  static const String _syncMediaToken = '[SYNC_MEDIA]';
  static const String _localMediaToken = '[LOCAL_MEDIA]';
  final SyncConfig _config;
  final String _docDirPath;

  MediaSyncManager(this._config, this._docDirPath);

  bool get _isSyncConfigured {
    final path = _config.syncFolderPath;
    return path != null && Directory(path).existsSync();
  }

  Future<String> importBackgroundImage(String originalPath) async {
    return _importMedia(originalPath, 'Background Images');
  }

  Future<String> importImageSlide(String originalPath) async {
    return _importMedia(originalPath, 'Image Slides');
  }

  Future<String> _importMedia(String originalPath, String subFolder) async {
    final sourceFile = File(originalPath);
    if (!sourceFile.existsSync()) {
      return originalPath; // Fallback if file doesn't exist
    }

    String baseDir;
    bool isSyncPath = false;
    if (_isSyncConfigured) {
      baseDir = _config.syncFolderPath!;
      isSyncPath = true;
    } else {
      baseDir = p.join(_docDirPath, 'KeryxPro', 'LocalMedia');
    }

    final targetDir = Directory(p.join(baseDir, 'Media', subFolder));
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    // To prevent naming collisions across different machines, append timestamp
    final ext = p.extension(originalPath);
    final basename = p.basenameWithoutExtension(originalPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newFileName = '${basename}_$timestamp$ext';

    final targetFile = File(p.join(targetDir.path, newFileName));
    await sourceFile.copy(targetFile.path);

    if (isSyncPath) {
      return '$_syncMediaToken/$subFolder/$newFileName';
    } else {
      return '$_localMediaToken/$subFolder/$newFileName';
    }
  }

  String resolveMediaPath(String path) {
    if (path.startsWith(_syncMediaToken)) {
      if (!_isSyncConfigured) {
        // If the path is tokenized but the sync folder is no longer configured,
        // we can't resolve it. Return empty or the original to fail gracefully.
        return path;
      }
      
      final relativePath = path.substring(_syncMediaToken.length + 1); // +1 for the slash
      
      // Re-join with the current platform's separator
      return p.join(_config.syncFolderPath!, 'Media', p.normalize(relativePath));
    } else if (path.startsWith(_localMediaToken)) {
      final relativePath = path.substring(_localMediaToken.length + 1); // +1 for the slash
      return p.join(_docDirPath, 'KeryxPro', 'LocalMedia', 'Media', p.normalize(relativePath));
    }
    return path; // It's an absolute path
  }
}
