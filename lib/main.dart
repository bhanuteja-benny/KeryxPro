import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:path_provider/path_provider.dart';

import 'core/database/isar_service.dart';
import 'features/dashboard/presentation/pages/main_dashboard_page.dart';
import 'features/settings/data/presentation_settings.dart';
import 'features/presentation/presentation/widgets/projector_view.dart';
import 'core/sync/sync_config.dart';
import 'core/sync/sync_service.dart';
import 'core/sync/media_sync_manager.dart';
import 'core/error/logger_service.dart';
import 'core/remote/remote_config.dart';
import 'core/remote/remote_providers.dart';
import 'dart:ui';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSizeBytes = 500 * 1024 * 1024; // 500 MB max image cache size

  // Global Error Handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    LoggerService.logError(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    LoggerService.logError(error, stack);
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Return an invisible widget instead of the Red Screen of Death
    return const SizedBox.shrink();
  };

  final appDocDir = await getApplicationDocumentsDirectory();
  final appDocDirPath = appDocDir.path;

  // If this is a spawned sub-window, handle projector UI
  if (args.firstOrNull == 'multi_window') {
    // NOTE: Do NOT call windowManager.ensureInitialized() here.
    // window_manager is auto-registered for sub-windows via RegisterPlugins.
    // Calling ensureInitialized() conflicts with desktop_multi_window's channel.
    final windowController = await WindowController.fromCurrentEngine();
    final syncConfig = await SyncConfig.init();
    runApp(
      ProviderScope(
        overrides: [
          syncConfigProvider.overrideWithValue(syncConfig),
          appDocumentsDirectoryPathProvider.overrideWithValue(appDocDirPath),
        ],
        child: ProjectorApp(windowController: windowController),
      ),
    );
    return;
  }

  // Initialize primary dashboard window
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Init foundational services
  final isarService = IsarService();
  final syncConfig = await SyncConfig.init();
  final remoteConfig = await RemoteConfig.init();

  runApp(
    ProviderScope(
      overrides: [
        isarServiceProvider.overrideWithValue(isarService),
        syncConfigProvider.overrideWithValue(syncConfig),
        remoteConfigProvider.overrideWithValue(remoteConfig),
        appDocumentsDirectoryPathProvider.overrideWithValue(appDocDirPath),
      ],
      child: const DashboardApp(),
    ),
  );
}

final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError('IsarService not initialized');
});

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KeryxPro Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainDashboardPage(),
    );
  }
}



class ProjectorApp extends StatefulWidget {
  final WindowController windowController;
  const ProjectorApp({super.key, required this.windowController});

  @override
  State<ProjectorApp> createState() => _ProjectorAppState();
}

class _ProjectorAppState extends State<ProjectorApp> {
  String? _activeSlideText;
  String? _titleText;
  bool _isSong = true;
  bool _isDualVersion = false;
  PresentationSettings _settings = PresentationSettings();
  int? _presetId;
  int? _monitorIndex;
  String? _mainWindowId;

Size? _getTargetWindowSize() {
  // If content type is still unknown, avoid forcing a fallback size.
  if (_activeSlideText == null) return null;

  final isBlank = _activeSlideText == '';
  final isWindowSlide = _activeSlideText?.startsWith('WINDOW:') ?? false;

  final ratio = isBlank
      ? _settings.blankAspectRatio
      : (isWindowSlide
          ? _settings.windowAspectRatio
          : (_isDualVersion
              ? _settings.dualScriptureAspectRatio
              : (_isSong ? _settings.songAspectRatio : _settings.scriptureAspectRatio)));

  switch (ratio) {
    case '4:3':
      return const Size(960, 720);
    case '4:1':
      return const Size(1200, 300);
    case 'Custom':
      final w = isBlank
          ? _settings.blankCustomWidth
          : (isWindowSlide
              ? _settings.windowCustomWidth
              : (_isDualVersion
                  ? _settings.dualScriptureCustomWidth
                  : (_isSong ? _settings.songCustomWidth : _settings.scriptureCustomWidth)));
      final h = isBlank
          ? _settings.blankCustomHeight
          : (isWindowSlide
              ? _settings.windowCustomHeight
              : (_isDualVersion
                  ? _settings.dualScriptureCustomHeight
                  : (_isSong ? _settings.songCustomHeight : _settings.scriptureCustomHeight)));
      if (w > 0 && h > 0) {
        return Size(w, h);
      }
      return const Size(1280, 720);
    case '16:9':
    default:
      return const Size(1280, 720);
  }
}

Future<void> _applyCurrentWindowSizeIfNeeded({
  int attempts = 1,
  Duration retryDelay = const Duration(milliseconds: 80),
}) async {
  if (_monitorIndex != 2) return;

  final size = _getTargetWindowSize();
  if (size == null) return;

  final bool isBlank = _activeSlideText == "";
  final bool isWindowSlide = _activeSlideText?.startsWith('WINDOW:') ?? false;
  final isTransparent = isBlank
      ? _settings.isBlankTransparent
      : (isWindowSlide ? _settings.isWindowTransparent : (_isDualVersion ? _settings.isDualScriptureTransparent : (_isSong ? _settings.isSongTransparent : _settings.isScriptureTransparent)));

  for (var i = 0; i < attempts; i++) {
    try {
      const channel = MethodChannel('keryx/window');
      await channel.invokeMethod('configure_current_window', {
        'w': size.width,
        'h': size.height,
        'monitorIndex': 2,
        'transparent': isTransparent,
      });
      return;
    } catch (_) {
      if (i == attempts - 1) {
        try {
          await windowManager.setSize(size);
        } catch (_) {}
        return;
      }
      await Future.delayed(retryDelay);
    }
  }
}

void _scheduleMonitor2SizeStabilization() {
  if (_monitorIndex != 2) return;
  Future.delayed(const Duration(milliseconds: 250), () {
    _applyCurrentWindowSizeIfNeeded(attempts: 2, retryDelay: const Duration(milliseconds: 80));
  }); // Future.delayed
  Future.delayed(const Duration(milliseconds: 700), () {
    _applyCurrentWindowSizeIfNeeded(attempts: 2, retryDelay: const Duration(milliseconds: 80));
  }); // Future.delayed
  Future.delayed(const Duration(milliseconds: 1300), () {
    _applyCurrentWindowSizeIfNeeded(attempts: 2, retryDelay: const Duration(milliseconds: 80));
  }); // Future.delayed
}

  @override
  void initState() {
    super.initState();
    // Parse initial arguments passed during window creation
    _initWindow();

    // Setup listener for updates from the main window
    widget.windowController.setWindowMethodHandler((MethodCall call) async {
      if (call.method == 'update_content') {
        final args = call.arguments as Map?;
        if (args != null) {
          final isSong = args['isSong'] as bool? ?? true;
          final isDualVersion = args['isDualVersion'] as bool? ?? false;
          setState(() {
            _activeSlideText = args['text'] as String?;
            _titleText = args['title'] as String?;
            _isSong = isSong;
            _isDualVersion = isDualVersion;
          });
          await _applyCurrentWindowSizeIfNeeded(attempts: 3);
          _scheduleMonitor2SizeStabilization();
        }
      } else if (call.method == 'update_preset') {
        final args = call.arguments as Map?;
        final settingsMap = args?['settings'] as Map<String, dynamic>?;
        if (settingsMap != null) {
          final newSettings = PresentationSettings.fromMap(settingsMap);
          setState(() {
            _settings = newSettings;
            _presetId = args?['presetId'] as int?;
          });
          await _applyCurrentWindowSizeIfNeeded(attempts: 3);
          _scheduleMonitor2SizeStabilization();
        }
      }
      return null;
    });

    // Ensure initial launch size is applied by the subwindow itself.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyCurrentWindowSizeIfNeeded(attempts: 6, retryDelay: const Duration(milliseconds: 120));
      _scheduleMonitor2SizeStabilization();
    });
  }

  void _initWindow() {
    final argsString = widget.windowController.arguments;
    if (argsString.isNotEmpty) {
      try {
        final parsed = jsonDecode(argsString) as Map<String, dynamic>;
        _presetId = parsed['presetId'] as int?;
        _activeSlideText = parsed['text'] as String?;
        _titleText = parsed['title'] as String?;
        _isSong = parsed['isSong'] as bool? ?? true;
        _isDualVersion = parsed['isDualVersion'] as bool? ?? false;
        _monitorIndex = parsed['monitorIndex'] as int?;
        _mainWindowId = parsed['mainWindowId'] as String?;

        final settingsMap = parsed['settings'] as Map<String, dynamic>?;
        if (settingsMap != null) {
          _settings = PresentationSettings.fromMap(settingsMap);
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget view = ExcludeSemantics(
      child: ProjectorView(
        settings: _settings,
        activeSlideText: _activeSlideText,
        titleText: _titleText,
        isSong: _isSong,
        isDualVersion: _isDualVersion,
        monitorIndex: _monitorIndex,
        captureBridgeWindowId: _mainWindowId,
      ),
    );  

    final bool isBlank = _activeSlideText == "";
    final bool isWindowSlide = _activeSlideText?.startsWith('WINDOW:') ?? false;
    final isTransparent = isBlank
        ? _settings.isBlankTransparent
        : (isWindowSlide ? _settings.isWindowTransparent : (_isDualVersion ? _settings.isDualScriptureTransparent : (_isSong ? _settings.isSongTransparent : _settings.isScriptureTransparent)));
    final Color scaffoldBgColor = isTransparent
        ? (Platform.isWindows ? const Color(0xFF010001) : Colors.transparent)
        : Colors.black;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: scaffoldBgColor,
        body: view,
      ),
    );
  }
}
