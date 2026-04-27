import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/setlist_item.dart';
import '../data/setlist_repository.dart';
import '../../songs/data/song.dart';

// ─────────────────────────────────────────────────────────
// Active SetList Items
// ─────────────────────────────────────────────────────────

class SetlistNotifier extends StateNotifier<List<SetlistItem>> {
  SetlistNotifier() : super([]);

  void addSong(Song song) {
    state = [...state, SongSetlistItem(song)];
  }

  void addImage(ImageSetlistItem imageItem) {
    state = [...state, imageItem];
  }

  void removeAtIndices(Set<int> indices) {
    final newList = <SetlistItem>[];
    for (int i = 0; i < state.length; i++) {
      if (!indices.contains(i)) newList.add(state[i]);
    }
    state = newList;
  }

  void moveUp(Set<int> indices) {
    if (indices.isEmpty || indices.contains(0)) return;
    final newList = List<SetlistItem>.from(state);
    final sorted = indices.toList()..sort();
    for (final i in sorted) {
      final tmp = newList[i - 1];
      newList[i - 1] = newList[i];
      newList[i] = tmp;
    }
    state = newList;
  }

  void moveDown(Set<int> indices) {
    if (indices.isEmpty || indices.contains(state.length - 1)) return;
    final newList = List<SetlistItem>.from(state);
    final sorted = indices.toList()..sort((a, b) => b.compareTo(a));
    for (final i in sorted) {
      final tmp = newList[i + 1];
      newList[i + 1] = newList[i];
      newList[i] = tmp;
    }
    state = newList;
  }

  void replaceAll(List<SetlistItem> items) {
    state = List.from(items);
  }

  void clear() {
    state = [];
  }

  // Legacy helper used by Bible search add
  void addItem(SetlistItem item) {
    state = [...state, item];
  }
}

final setlistProvider = StateNotifierProvider<SetlistNotifier, List<SetlistItem>>((ref) {
  return SetlistNotifier();
});

// ─────────────────────────────────────────────────────────
// Multi-Selection State
// ─────────────────────────────────────────────────────────

class SetlistSelectionNotifier extends StateNotifier<Set<int>> {
  SetlistSelectionNotifier() : super({});

  void selectSingle(int index) {
    state = {index};
  }

  void toggleCtrl(int index) {
    final current = Set<int>.from(state);
    if (current.contains(index)) {
      current.remove(index);
    } else {
      current.add(index);
    }
    state = current;
  }

  void selectShift(int index, int listLength) {
    if (state.isEmpty) {
      state = {index};
      return;
    }
    final anchor = state.last;
    final start = anchor < index ? anchor : index;
    final end = anchor < index ? index : anchor;
    state = Set.from(List.generate(end - start + 1, (i) => start + i));
  }

  void selectBatch(Set<int> indices) {
    state = indices;
  }

  void clear() {
    state = {};
  }
}

final setlistSelectionProvider =
    StateNotifierProvider<SetlistSelectionNotifier, Set<int>>((ref) {
  return SetlistSelectionNotifier();
});

// ─────────────────────────────────────────────────────────
// Active Saved SetList Name
// ─────────────────────────────────────────────────────────

final activeSetlistNameProvider = StateProvider<String?>((ref) => null);

// ─────────────────────────────────────────────────────────
// List of all saved SetList names (for the dropdown)
// ─────────────────────────────────────────────────────────

final savedSetlistNamesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.read(setlistRepositoryProvider);
  return repo.getAllNames();
});
