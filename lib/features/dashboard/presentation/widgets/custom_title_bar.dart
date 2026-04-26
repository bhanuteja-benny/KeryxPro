import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../settings/presentation/widgets/presentation_settings_dialog.dart';
import '../../../songs/presentation/song_providers.dart';
import '../../../songs/data/song_import_service.dart';
import '../../../bible/presentation/widgets/bible_import_dialog.dart';

class CustomTitleBar extends ConsumerWidget {
  const CustomTitleBar({super.key});

  Future<void> _handleImportSongs(BuildContext context, WidgetRef ref) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        final paths = result.paths.whereType<String>().toList();
        if (paths.isNotEmpty) {
          // Show a loading snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Importing songs...')),
          );

          final parsedSongs = await SongImportService.parseOpenSongFiles(paths);
          final importedCount = await ref.read(songListProvider.notifier).importSongs(parsedSongs);

          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Successfully imported $importedCount songs!')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing songs: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 32, // Slim header
      color: const Color(0xFF2D2D2D), // Slightly accented grey
      child: Row(
        children: [
          // Drag area for the icon part
          const SizedBox(width: 8),
          const Icon(Icons.auto_awesome, size: 16, color: Colors.deepPurpleAccent), // App Logo
          const SizedBox(width: 8),
          
          // Menu Area
          MenuBar(
            style: const MenuStyle(
              elevation: WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
              padding: WidgetStatePropertyAll(EdgeInsets.zero),
            ),
            children: [
              SubmenuButton(
                menuStyle: const MenuStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0xFF4A4A4A)),
                  elevation: WidgetStatePropertyAll(4),
                ),
                menuChildren: [
                  MenuItemButton(
                    onPressed: () => exit(0),
                    child: const Text('Exit'),
                  ),
                ],
                child: const Text('File', style: TextStyle(fontSize: 12)),
              ),
              SubmenuButton(
                menuStyle: const MenuStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0xFF4A4A4A)),
                  elevation: WidgetStatePropertyAll(4),
                ),
                menuChildren: [
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const PresentationSettingsDialog(),
                      );
                    },
                    child: const Text('Presentation Settings'),
                  ),
                ],
                child: const Text('Settings', style: TextStyle(fontSize: 12)),
              ),
              SubmenuButton(
                menuStyle: const MenuStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0xFF4A4A4A)),
                  elevation: WidgetStatePropertyAll(4),
                ),
                menuChildren: [
                  MenuItemButton(
                    onPressed: () => _handleImportSongs(context, ref),
                    child: const Text('Import Songs'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const BibleImportDialog(),
                      );
                    },
                    child: const Text('Import Bible'),
                  ),
                ],
                child: const Text('Imports', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          
          // Main Drag Area
          const Expanded(
            child: WindowCaptionSegment(
              child: DragToMoveArea(
                child: SizedBox.expand(),
              ),
            ),
          ),
          
          // System Window Controls
          const WindowButtons(),
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _WindowButton(
          icon: Icons.minimize,
          onPressed: () => windowManager.minimize(),
        ),
        _WindowButton(
          icon: Icons.crop_square,
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
        ),
        _WindowButton(
          icon: Icons.close,
          isClose: true,
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }
}

class _WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 46,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Icon(icon, size: 16, color: Colors.white70),
        ),
      ),
    );
  }
}

// Helper to make it easier to add more segments if needed
class WindowCaptionSegment extends StatelessWidget {
  final Widget child;
  const WindowCaptionSegment({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
