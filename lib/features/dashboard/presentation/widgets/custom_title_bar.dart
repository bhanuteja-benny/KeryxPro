import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../settings/presentation/widgets/presentation_settings_dialog.dart';
import '../../../settings/presentation/widgets/database_sync_settings_dialog.dart';
import '../../../settings/presentation/widgets/general_settings_dialog.dart';
import '../../../songs/presentation/song_providers.dart';
import '../../../songs/data/song_import_service.dart';
import '../../../bible/presentation/widgets/bible_import_dialog.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../setlist/presentation/manage_setlists_dialog.dart';
import 'help_dialog.dart';

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
          SizedBox(width: Platform.isMacOS ? 80 : 8),
          Image.asset('assets/icons/app_icon.png', width: 18, height: 18), // App Logo
          const SizedBox(width: 8),
          
          MenuBar(
            style: const MenuStyle(
              elevation: WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
              padding: WidgetStatePropertyAll(EdgeInsets.zero),
            ),
            children: [
              SubmenuButton(
                style: const ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size.zero),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8, vertical: 0)),
                ),
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
                style: const ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size.zero),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8, vertical: 0)),
                ),
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
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const DatabaseSyncSettingsDialog(),
                      );
                    },
                    child: const Text('Data Sync Settings'),
                  ),
                  MenuItemButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const GeneralSettingsDialog(),
                      );
                    },
                    child: const Text('General Settings'),
                  ),
                ],
                child: const Text('Settings', style: TextStyle(fontSize: 12)),
              ),
              SubmenuButton(
                style: const ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size.zero),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8, vertical: 0)),
                ),
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
              MenuItemButton(
                style: const ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size.zero),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8, vertical: 0)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ManageSetlistsDialog(),
                  );
                },
                child: const Text('Manage Setlists', style: TextStyle(fontSize: 12)),
              ),
              MenuItemButton(
                style: const ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size.zero),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8, vertical: 0)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const HelpDialog(),
                  );
                },
                child: const Text('Help', style: TextStyle(fontSize: 12)),
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
          
          // Global Sync Button
          if (ref.watch(syncConfigProvider).syncEnabled)
            Tooltip(
              message: 'Sync Changes',
              child: _WindowButton(
                iconWidget: Badge(
                  isLabelVisible: ref.watch(hasPendingSyncProvider),
                  child: const Icon(Icons.sync, size: 16, color: Colors.white70),
                ),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Syncing data...'), duration: Duration(seconds: 1)),
                  );
                  await ref.read(syncServiceProvider).syncPendingEvents();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sync complete!'), duration: Duration(seconds: 1)),
                  );
                },
              ),
            ),

          // Help & Shortcuts Icon Button
          Tooltip(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(top: 8),
            preferBelow: true,
            waitDuration: const Duration(milliseconds: 100),
            richMessage: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                height: 1.4,
              ),
              children: [
                const TextSpan(
                  text: "Shortcut Keys:\n\n",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
                TextSpan(
                  text: "'s'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - open scripture search\n"),
                TextSpan(
                  text: "'q'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - open song search\n"),
                TextSpan(
                  text: "'L'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - go to slides navigation\n"),
                TextSpan(
                  text: "'enter' + 'enter'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " in scripture search - add and display the verse immediately\n"),
                TextSpan(
                  text: "'enter' + 'tab' + 'enter'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " in scripture search - just add the verse\n"),
                TextSpan(
                  text: "'ctrl/cmd + b'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - toggle bookmark on the current slide\n"),
                TextSpan(
                  text: "'ctrl/cmd + up arrow'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - navigate to the bookmarked slides towards up\n"),
                TextSpan(
                  text: "'ctrl/cmd + down arrow'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - navigate to the bookmarked slides towards down\n"),
                TextSpan(
                  text: "'ctrl/cmd + right arrow'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - add and display next verse of the currently displaying verse\n"),
                TextSpan(
                  text: "'ctrl/cmd + right arrow + right arrow'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - add and display next two verses of the currently displaying verse\n"),
                TextSpan(
                  text: "'ctrl/cmd + left arrow'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - add and display before verse of the currently displaying verse\n"),
                TextSpan(
                  text: "'ctrl/cmd + left arrow + left arrow'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - add and display before two verses of the currently displaying verse\n"),
                TextSpan(
                  text: "'ctrl/cmd + s'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - open the current displaying verse in scripture search\n"),
                TextSpan(
                  text: "'space'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - jump to next slide\n"),
                TextSpan(
                  text: "'tab'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - jump to next blank screen\n"),
                TextSpan(
                  text: "'f'",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Colors.amberAccent),
                ),
                const TextSpan(text: " - freeze/unfreeze the presentation screens"),
              ],
            ),
            child: _WindowButton(
              icon: Icons.help_outline,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const HelpDialog(),
                );
              },
            ),
          ),

          // System Window Controls
          if (!Platform.isMacOS) const WindowButtons(),
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
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowButton({
    this.icon,
    this.iconWidget,
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
          child: iconWidget ?? Icon(icon, size: 16, color: Colors.white70),
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
