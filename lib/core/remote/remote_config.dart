import 'package:shared_preferences/shared_preferences.dart';

import 'remote_models.dart';

class RemoteConfig {
  static const String _keyMode = 'remote_mode';
  static const String _keyMachineName = 'remote_machine_name';
  static const String _keyPort = 'remote_port';
  static const String _keyDiscoveryEnabled = 'remote_discovery_enabled';
  static const String _keyManualHost = 'remote_manual_host';
  static const String _keyImageByteFallbackEnabled =
      'remote_image_byte_fallback_enabled';
  static const String _keyImageByteFallbackMaxBytes =
      'remote_image_byte_fallback_max_bytes';

  final SharedPreferences _prefs;

  RemoteConfig(this._prefs);

  static Future<RemoteConfig> init() async {
    final prefs = await SharedPreferences.getInstance();
    return RemoteConfig(prefs);
  }

  RemoteMode get mode => remoteModeFromString(_prefs.getString(_keyMode));
  Future<void> setMode(RemoteMode mode) async {
    await _prefs.setString(_keyMode, remoteModeToString(mode));
  }

String get machineName =>
      (_prefs.getString(_keyMachineName) ?? 'Keryx Device').trim().isEmpty
          ? 'Keryx Device'
          : (_prefs.getString(_keyMachineName) ?? 'Keryx Device').trim();
  Future<void> setMachineName(String value) async {
    await _prefs.setString(_keyMachineName, value.trim());
  }

  int get port {
    final value = _prefs.getInt(_keyPort) ?? 7689;
    if (value < 1024 || value > 65535) return 7689;
    return value;
  }

  Future<void> setPort(int value) async {
    await _prefs.setInt(_keyPort, value);
  }

  bool get discoveryEnabled => _prefs.getBool(_keyDiscoveryEnabled) ?? true;
  Future<void> setDiscoveryEnabled(bool value) async {
    await _prefs.setBool(_keyDiscoveryEnabled, value);
  }

  String get manualHost => (_prefs.getString(_keyManualHost) ?? '').trim();
  Future<void> setManualHost(String value) async {
    await _prefs.setString(_keyManualHost, value.trim());
  }

bool get imageByteFallbackEnabled =>
      _prefs.getBool(_keyImageByteFallbackEnabled) ?? false;
  Future<void> setImageByteFallbackEnabled(bool value) async {
    await _prefs.setBool(_keyImageByteFallbackEnabled, value);
  }

  int get imageByteFallbackMaxBytes {
    final value = _prefs.getInt(_keyImageByteFallbackMaxBytes) ?? 5242880;
    if (value < 262144 || value > 52428800) return 5242880;
    return value;
  }

  Future<void> setImageByteFallbackMaxBytes(int value) async {
    await _prefs.setInt(_keyImageByteFallbackMaxBytes, value);
  }
}