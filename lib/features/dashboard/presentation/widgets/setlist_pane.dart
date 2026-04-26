import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../songs/presentation/song_selection_providers.dart';
import '../global_ui_providers.dart';
import '../../../live_controller/presentation/slide_utils.dart';

class SetlistPane extends ConsumerWidget {
  const SetlistPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setlist = ref.watch(setlistProvider);

    return Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.black26,
            width: double.infinity,
            child: const Text(
              'Setlist (Live Queue)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.white54),
            ),
          ),
          Expanded(
            child: setlist.isEmpty
                ? const Center(
                    child: Text(
                      'No songs added yet.\nUse library to add songs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: setlist.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
                    itemBuilder: (context, index) {
                      final song = setlist[index];
                      return ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        onTap: () {
                          // Calculate the starting slide index for this song
                          int slideStartIndex = 0;
                          for (int i = 0; i < index; i++) {
                            // parseLyrics includes the blank slide at end, so we add those
                            final slides = SlideUtils.parseLyrics(setlist[i].lyrics, setlist[i].title);
                            slideStartIndex += slides.length;
                          }

                          // Use the shared scroll controller to jump to that slide
                          final scrollController = ref.read(slideListScrollControllerProvider);
                          if (scrollController.hasClients) {
                            final targetOffset = slideStartIndex * 28.0; // 28 is the height of SlideItemWidget
                            scrollController.animateTo(
                              targetOffset,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        title: Text(
                          song.title,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.remove_circle_outline, size: 14, color: Colors.redAccent),
                          onPressed: () {
                            ref.read(setlistProvider.notifier).removeAt(index);
                          },
                        ),
                      );
                    },
                  ),
          ),
          if (setlist.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => ref.read(setlistProvider.notifier).clear(),
                  icon: const Icon(Icons.delete_sweep, size: 16, color: Colors.grey),
                  label: const Text('Clear All', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
