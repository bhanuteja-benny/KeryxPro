import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import '../../features/settings/data/app_settings.dart';

class LoggerService {
  static Future<void> logError(Object error, StackTrace? stackTrace) async {
    try {
      final isar = Isar.getInstance();
      if (isar != null) {
        final settings = await isar.appSettings.where().findFirst();
        if (settings == null || !settings.isErrorLoggingEnabled) {
          return; // Logging is disabled
        }
      } else {
        return; // DB not initialized
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDocDir.path}${Platform.pathSeparator}KeryxPro');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      
      final logFile = File('${logDir.path}${Platform.pathSeparator}error.log');

      final timestamp = DateTime.now().toIso8601String();
      final logMessage = '[$timestamp]\nError: $error\nStackTrace:\n$stackTrace\n----------------------------------------\n';

      await logFile.writeAsString(logMessage, mode: FileMode.append);
    } catch (e) {
      // Silently fail if logging fails to avoid recursive errors
      debugPrint('Failed to log error: $e');
    }
  }
}
