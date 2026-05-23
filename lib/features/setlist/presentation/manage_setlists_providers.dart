import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/setlist_repository.dart';
import '../data/saved_setlist.dart';

final allSavedSetlistsProvider = FutureProvider.autoDispose<List<SavedSetlist>>((ref) async {
  final repo = ref.read(setlistRepositoryProvider);
  return repo.getAllSetlists();
});
