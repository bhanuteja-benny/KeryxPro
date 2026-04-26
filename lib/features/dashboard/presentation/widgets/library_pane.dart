import 'package:flutter/material.dart';
import '../../../songs/presentation/song_library_tab.dart';
import '../../../bible/presentation/widgets/bible_search_tab.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../global_ui_providers.dart';

class LibraryPane extends ConsumerWidget {
  const LibraryPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = ref.watch(libraryTabControllerProvider);

    if (tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Container(
            color: Colors.grey[900], // Darker background for tab bar
            child: TabBar(
              controller: tabController,
              indicatorColor: Colors.deepPurpleAccent,
              tabs: const [
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.library_music, size: 16), SizedBox(width: 4), Text('Songs', style: TextStyle(fontSize: 11))])),
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.menu_book, size: 16), SizedBox(width: 4), Text('Bible', style: TextStyle(fontSize: 11))])),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.grey[850],
            child: TabBarView(
              controller: tabController,
              children: const [
                SongLibraryTab(),
                BibleSearchTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
