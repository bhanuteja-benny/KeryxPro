import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

import 'core/database/isar_service.dart';
import 'features/dashboard/presentation/pages/main_dashboard_page.dart';
import 'features/presentation/presentation/widgets/projector_view.dart';
import 'features/settings/data/presentation_settings.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // If this is a spawned sub-window, handle projector UI
  if (args.firstOrNull == 'multi_window') {
    final windowController = await WindowController.fromCurrentEngine();
    runApp(
      ProviderScope(
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

  runApp(
    ProviderScope(
      overrides: [
        isarServiceProvider.overrideWithValue(isarService),
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
  PresentationSettings _settings = PresentationSettings();
  int? _presetId;

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
          setState(() {
            _activeSlideText = args['text'] as String?;
            _titleText = args['title'] as String?;
            _isSong = args['isSong'] as bool? ?? true;
          });
        }
      } else if (call.method == 'update_preset') {
        final args = call.arguments as Map?;
        final newPresetId = args?['presetId'] as int?;
        if (newPresetId != null && newPresetId != _presetId) {
          setState(() {
            _presetId = newPresetId;
          });
        }
      }
      return null;
    });
  }

  void _initWindow() {
    // Parse the arguments string that was passed during WindowController.create()
    final argsString = widget.windowController.arguments;
    if (argsString.isNotEmpty) {
      try {
        final parsed = jsonDecode(argsString) as Map<String, dynamic>;
        _presetId = parsed['presetId'] as int?;
      } catch (_) {
        // Ignore parse errors
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: ProjectorView(
          settings: _settings,
          activeSlideText: _activeSlideText,
          titleText: _titleText,
          isSong: _isSong,
        ),
      ),
    );
  }
}
