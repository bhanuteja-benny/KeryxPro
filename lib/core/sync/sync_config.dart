import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SyncConfig {
  static const String _keyMachineId = 'sync_machine_id';
  static const String _keySyncFolder = 'sync_folder_path';
  static const String _keySyncEnabled = 'sync_enabled';

  final SharedPreferences _prefs;

  SyncConfig(this._prefs) {
    if (_prefs.getString(_keyMachineId) == null) {
      _prefs.setString(_keyMachineId, const Uuid().v4());
    }
  }

  static Future<SyncConfig> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SyncConfig(prefs);
  }

  String get machineId => _prefs.getString(_keyMachineId)!;

  String? get syncFolderPath => _prefs.getString(_keySyncFolder);
  Future<void> setSyncFolderPath(String? path) async {
    if (path == null) {
      await _prefs.remove(_keySyncFolder);
    } else {
      await _prefs.setString(_keySyncFolder, path);
    }
  }

  bool get syncEnabled => _prefs.getBool(_keySyncEnabled) ?? false;
  Future<void> setSyncEnabled(bool enabled) async {
    await _prefs.setBool(_keySyncEnabled, enabled);
  }
}
