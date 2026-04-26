import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../data/bible_repository.dart';
import '../data/bible.dart';
import '../data/bible_import_service.dart';

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return BibleRepository(isarService);
});

final bibleVersionsProvider = FutureProvider<List<BibleVersion>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.getVersions();
});

class BibleImportNotifier extends StateNotifier<AsyncValue<void>> {
  final BibleRepository _repository;

  BibleImportNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<int> importBibleFiles(List<String> filePaths) async {
    state = const AsyncValue.loading();
    int importedCount = 0;

    try {
      for (final path in filePaths) {
        final result = await BibleImportService.parseBibleFile(path);
        if (result != null && result.verses.isNotEmpty) {
          await _repository.saveBible(result.version, result.verses);
          importedCount++;
        }
      }
      state = const AsyncValue.data(null);
      return importedCount;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return importedCount;
    }
  }
}

final bibleImportProvider = StateNotifierProvider<BibleImportNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  return BibleImportNotifier(repo);
});
