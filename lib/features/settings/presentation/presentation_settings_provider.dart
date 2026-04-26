import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../data/presentation_settings.dart';
import 'package:isar/isar.dart';

final presetsListProvider = FutureProvider<List<PresentationSettings>>((ref) async {
  final isar = await ref.watch(isarServiceProvider).db;
  final results = await isar.presentationSettings.where().findAll();
  return results.map((e) => _processFallbacks(e)).toList();
});

final presentationSettingsProvider = StateNotifierProvider<ActivePresentationSettingsNotifier, PresentationSettings>((ref) {
  final isar = ref.watch(isarServiceProvider).db;
  return ActivePresentationSettingsNotifier(isar);
});

class ActivePresentationSettingsNotifier extends StateNotifier<PresentationSettings> {
  final Future<Isar> _dbFuture;

  ActivePresentationSettingsNotifier(this._dbFuture) : super(PresentationSettings()) {
    _init();
  }

  Future<void> _init() async {
    final isar = await _dbFuture;
    final first = await isar.presentationSettings.where().findFirst();
    if (first == null) {
      final defaultP = PresentationSettings()
        ..presetName = 'Default'
        ..isDefault = true;
      await isar.writeTxn(() async {
        await isar.presentationSettings.put(defaultP);
      });
      state = _processFallbacks(defaultP);
    } else {
      state = _processFallbacks(first);
    }
  }

  void setActivePreset(PresentationSettings preset) {
    state = preset;
  }
}

PresentationSettings _processFallbacks(PresentationSettings settings) {
  // Numbers Fallback
  if (!settings.lyricsFontSize.isFinite || settings.lyricsFontSize <= 0) settings.lyricsFontSize = 80.0;
  if (!settings.titleFontSize.isFinite || settings.titleFontSize <= 0) settings.titleFontSize = 24.0;
  if (!settings.chapterFontSize.isFinite || settings.chapterFontSize <= 0) settings.chapterFontSize = 24.0;
  if (!settings.verseFontSize.isFinite || settings.verseFontSize <= 0) settings.verseFontSize = 80.0;
  
  // Margins Fallback
  if (!settings.lyricsMarginTop.isFinite || settings.lyricsMarginTop < 0) settings.lyricsMarginTop = 32.0;
  if (!settings.lyricsMarginBottom.isFinite || settings.lyricsMarginBottom < 0) settings.lyricsMarginBottom = 32.0;
  if (!settings.lyricsMarginLeft.isFinite || settings.lyricsMarginLeft < 0) settings.lyricsMarginLeft = 32.0;
  if (!settings.lyricsMarginRight.isFinite || settings.lyricsMarginRight < 0) settings.lyricsMarginRight = 32.0;
  
  if (!settings.verseMarginTop.isFinite || settings.verseMarginTop < 0) settings.verseMarginTop = 32.0;
  if (!settings.verseMarginBottom.isFinite || settings.verseMarginBottom < 0) settings.verseMarginBottom = 32.0;
  if (!settings.verseMarginLeft.isFinite || settings.verseMarginLeft < 0) settings.verseMarginLeft = 32.0;
  if (!settings.verseMarginRight.isFinite || settings.verseMarginRight < 0) settings.verseMarginRight = 32.0;

  if (!settings.titleMarginTop.isFinite || settings.titleMarginTop < 0) settings.titleMarginTop = 16.0;
  if (!settings.titleMarginBottom.isFinite || settings.titleMarginBottom < 0) settings.titleMarginBottom = 16.0;
  if (!settings.titleMarginLeft.isFinite || settings.titleMarginLeft < 0) settings.titleMarginLeft = 16.0;
  if (!settings.titleMarginRight.isFinite || settings.titleMarginRight < 0) settings.titleMarginRight = 16.0;

  if (!settings.chapterMarginTop.isFinite || settings.chapterMarginTop < 0) settings.chapterMarginTop = 16.0;
  if (!settings.chapterMarginBottom.isFinite || settings.chapterMarginBottom < 0) settings.chapterMarginBottom = 16.0;
  if (!settings.chapterMarginLeft.isFinite || settings.chapterMarginLeft < 0) settings.chapterMarginLeft = 16.0;
  if (!settings.chapterMarginRight.isFinite || settings.chapterMarginRight < 0) settings.chapterMarginRight = 16.0;

  if (!settings.songCustomWidth.isFinite || settings.songCustomWidth <= 0) settings.songCustomWidth = 1920.0;
  if (!settings.songCustomHeight.isFinite || settings.songCustomHeight <= 0) settings.songCustomHeight = 1080.0;

  if (!settings.scriptureCustomWidth.isFinite || settings.scriptureCustomWidth <= 0) settings.scriptureCustomWidth = 1920.0;
  if (!settings.scriptureCustomHeight.isFinite || settings.scriptureCustomHeight <= 0) settings.scriptureCustomHeight = 1080.0;

  // Strings Fallback
  if (settings.presetName.isEmpty) {
    settings.presetName = (settings.isDefault || settings.id == 1) ? 'Default' : 'Preset ${settings.id}';
  }
  if (settings.presetName == 'Default') {
    settings.isDefault = true; // Repair old records
  }

  if (settings.songAspectRatio.isEmpty) settings.songAspectRatio = '16:9';
  if (settings.scriptureAspectRatio.isEmpty) settings.scriptureAspectRatio = '16:9';
  if (settings.titleAlignment.isEmpty) settings.titleAlignment = 'center';
  if (settings.titleVerticalAlignment.isEmpty) settings.titleVerticalAlignment = 'bottom';
  if (settings.chapterAlignment.isEmpty) settings.chapterAlignment = 'center';
  if (settings.chapterVerticalAlignment.isEmpty) settings.chapterVerticalAlignment = 'bottom';
  if (settings.verseAlignment.isEmpty) settings.verseAlignment = 'center';
  if (settings.verseVerticalAlignment.isEmpty) settings.verseVerticalAlignment = 'center';
  if (settings.lyricsVerticalAlignment.isEmpty) settings.lyricsVerticalAlignment = 'center';
  if (settings.chapterFontFamily.isEmpty) settings.chapterFontFamily = 'Arial';
  if (settings.verseFontFamily.isEmpty) settings.verseFontFamily = 'Arial';
  if (settings.lyricsFontFamily.isEmpty) settings.lyricsFontFamily = 'Arial';
  if (settings.titleFontFamily.isEmpty) settings.titleFontFamily = 'Arial';

  // Colors Fallback
  if (settings.songBackgroundColor == 0) settings.songBackgroundColor = 0xFF000000;
  if (settings.scriptureBackgroundColor == 0) settings.scriptureBackgroundColor = 0xFF000000;
  if ((settings.lyricsFontColor & 0xFF000000) == 0) settings.lyricsFontColor = 0xFFFFFFFF;
  if ((settings.titleFontColor & 0xFF000000) == 0) settings.titleFontColor = 0x8FFFFFFF;
  if ((settings.chapterFontColor & 0xFF000000) == 0) settings.chapterFontColor = 0x8FFFFFFF;
  if ((settings.verseFontColor & 0xFF000000) == 0) settings.verseFontColor = 0xFFFFFFFF;

  return settings;
}

final editingPresetProvider = StateNotifierProvider<EditingPresetNotifier, PresentationSettings>((ref) {
  final isar = ref.watch(isarServiceProvider).db;
  return EditingPresetNotifier(isar, ref);
});

class EditingPresetNotifier extends StateNotifier<PresentationSettings> {
  final Future<Isar> _dbFuture;
  final Ref _ref;

  EditingPresetNotifier(this._dbFuture, this._ref) : super(PresentationSettings());

  void setPresetToEdit(PresentationSettings preset) {
    state = cloneState(preset);
  }

  Future<void> deletePreset(int id) async {
    final isar = await _dbFuture;
    await isar.writeTxn(() async {
      await isar.presentationSettings.delete(id);
    });
    _ref.invalidate(presetsListProvider);
    
    // If the active preset was deleted, fall back to default
    final currentActive = _ref.read(presentationSettingsProvider);
    if (currentActive.id == id) {
      final defaultP = await isar.presentationSettings.filter().isDefaultEqualTo(true).findFirst();
      if (defaultP != null) {
        _ref.read(presentationSettingsProvider.notifier).setActivePreset(_processFallbacks(defaultP));
      }
    }
  }

  Future<void> createNewPreset(String name) async {
    // Copy from Default
    final isar = await _dbFuture;
    final defaultP = await isar.presentationSettings.filter().isDefaultEqualTo(true).findFirst();
    final base = defaultP ?? PresentationSettings();
    
    final newPreset = cloneState(base)
      ..id = Isar.autoIncrement
      ..presetName = name
      ..isDefault = false;
      
    await isar.writeTxn(() async {
      await isar.presentationSettings.put(newPreset);
    });
    _ref.invalidate(presetsListProvider);
  }

  Future<void> saveSettings() async {
    final isar = await _dbFuture;
    await isar.writeTxn(() async {
      await isar.presentationSettings.put(state);
    });
    _ref.invalidate(presetsListProvider);
    
    final currentActive = _ref.read(presentationSettingsProvider);
    if (currentActive.id == state.id) {
       _ref.read(presentationSettingsProvider.notifier).setActivePreset(state);
    }
  }

  // --- Update Methods without auto-save ---
  void updateAspectRatio(String ratio, bool isSong) {
    if (isSong) {
      state = cloneState(state)..songAspectRatio = ratio;
    } else {
      state = cloneState(state)..scriptureAspectRatio = ratio;
    }
  }

  void updateCustomWidth(double w, bool isSong) {
    if (isSong) {
      state = cloneState(state)..songCustomWidth = w;
    } else {
      state = cloneState(state)..scriptureCustomWidth = w;
    }
  }

  void updateCustomHeight(double h, bool isSong) {
    if (isSong) {
      state = cloneState(state)..songCustomHeight = h;
    } else {
      state = cloneState(state)..scriptureCustomHeight = h;
    }
  }
  // Background updates now take a boolean to distinguish song/scripture
  void updateBackgroundColor(int color, bool isSong) {
    final s = cloneState(state);
    if (isSong) {
      s.songBackgroundColor = color;
      s.isSongTransparent = false;
    } else {
      s.scriptureBackgroundColor = color;
      s.isScriptureTransparent = false;
    }
    state = s;
  }
  
  void updateBackgroundImage(String path, bool isSong) {
    final s = cloneState(state);
    if (isSong) {
      s.songBackgroundImage = path;
      s.isSongImageEnabled = true;
    } else {
      s.scriptureBackgroundImage = path;
      s.isScriptureImageEnabled = true;
    }
    state = s;
  }

  void updateIsImageEnabled(bool enabled, bool isSong) {
    final s = cloneState(state);
    if (isSong) {
      s.isSongImageEnabled = enabled;
    } else {
      s.isScriptureImageEnabled = enabled;
    }
    state = s;
  }
  
  void updateIsTransparent(bool transparent, bool isSong) {
    final s = cloneState(state);
    if (isSong) {
      s.isSongTransparent = transparent;
    } else {
      s.isScriptureTransparent = transparent;
    }
    state = s;
  }

  // Title Updates
  void updateShowTitle(bool show) => state = cloneState(state)..showTitle = show;
  void updateTitleAlignment(String horizontal) => state = cloneState(state)..titleAlignment = horizontal;
  void updateTitleVerticalAlignment(String vertical) => state = cloneState(state)..titleVerticalAlignment = vertical;
  void updateTitleFontSize(double size) => state = cloneState(state)..titleFontSize = size;
  void updateTitleFontFamily(String family) => state = cloneState(state)..titleFontFamily = family;
  void updateTitleFontColor(int color) => state = cloneState(state)..titleFontColor = color;
  void updateTitleUnderline(bool v) => state = cloneState(state)..titleUnderline = v;
  void updateTitleFill(bool hasFill, int color) => state = cloneState(state)..titleHasFill = hasFill..titleFillColor = color;
  void updateTitleStroke(bool hasStroke, int color) => state = cloneState(state)..titleHasStroke = hasStroke..titleStrokeColor = color;
  void updateTitleMargins({double? top, double? bottom, double? left, double? right}) {
    final s = cloneState(state);
    if (top != null) s.titleMarginTop = top;
    if (bottom != null) s.titleMarginBottom = bottom;
    if (left != null) s.titleMarginLeft = left;
    if (right != null) s.titleMarginRight = right;
    state = s;
  }

  // Lyrics Updates
  void updateLyricsAlignment(String alignment) => state = cloneState(state)..lyricsAlignment = alignment;
  void updateLyricsVerticalAlignment(String alignment) => state = cloneState(state)..lyricsVerticalAlignment = alignment;
  void updateLyricsFontSize(double size) => state = cloneState(state)..lyricsFontSize = size;
  void updateLyricsFontFamily(String family) => state = cloneState(state)..lyricsFontFamily = family;
  void updateLyricsFontColor(int color) => state = cloneState(state)..lyricsFontColor = color;
  void updateLyricsUnderline(bool v) => state = cloneState(state)..lyricsUnderline = v;
  void updateLyricsFill(bool hasFill, int color) => state = cloneState(state)..lyricsHasFill = hasFill..lyricsFillColor = color;
  void updateLyricsStroke(bool hasStroke, int color) => state = cloneState(state)..lyricsHasStroke = hasStroke..lyricsStrokeColor = color;
  void updateLyricsMargins({double? top, double? bottom, double? left, double? right}) {
    final s = cloneState(state);
    if (top != null) s.lyricsMarginTop = top;
    if (bottom != null) s.lyricsMarginBottom = bottom;
    if (left != null) s.lyricsMarginLeft = left;
    if (right != null) s.lyricsMarginRight = right;
    state = s;
  }

  // Chapter Updates
  void updateShowChapter(bool show) => state = cloneState(state)..showChapter = show;
  void updateChapterAlignment(String horizontal) => state = cloneState(state)..chapterAlignment = horizontal;
  void updateChapterVerticalAlignment(String vertical) => state = cloneState(state)..chapterVerticalAlignment = vertical;
  void updateChapterFontSize(double size) => state = cloneState(state)..chapterFontSize = size;
  void updateChapterFontFamily(String family) => state = cloneState(state)..chapterFontFamily = family;
  void updateChapterFontColor(int color) => state = cloneState(state)..chapterFontColor = color;
  void updateChapterUnderline(bool v) => state = cloneState(state)..chapterUnderline = v;
  void updateChapterFill(bool hasFill, int color) => state = cloneState(state)..chapterHasFill = hasFill..chapterFillColor = color;
  void updateChapterStroke(bool hasStroke, int color) => state = cloneState(state)..chapterHasStroke = hasStroke..chapterStrokeColor = color;
  void updateChapterMargins({double? top, double? bottom, double? left, double? right}) {
    final s = cloneState(state);
    if (top != null) s.chapterMarginTop = top;
    if (bottom != null) s.chapterMarginBottom = bottom;
    if (left != null) s.chapterMarginLeft = left;
    if (right != null) s.chapterMarginRight = right;
    state = s;
  }

  // Verse Updates
  void updateVerseAlignment(String alignment) => state = cloneState(state)..verseAlignment = alignment;
  void updateVerseVerticalAlignment(String alignment) => state = cloneState(state)..verseVerticalAlignment = alignment;
  void updateVerseFontSize(double size) => state = cloneState(state)..verseFontSize = size;
  void updateVerseFontFamily(String family) => state = cloneState(state)..verseFontFamily = family;
  void updateVerseFontColor(int color) => state = cloneState(state)..verseFontColor = color;
  void updateVerseUnderline(bool v) => state = cloneState(state)..verseUnderline = v;
  void updateVerseFill(bool hasFill, int color) => state = cloneState(state)..verseHasFill = hasFill..verseFillColor = color;
  void updateVerseStroke(bool hasStroke, int color) => state = cloneState(state)..verseHasStroke = hasStroke..verseStrokeColor = color;
  void updateVerseMargins({double? top, double? bottom, double? left, double? right}) {
    final s = cloneState(state);
    if (top != null) s.verseMarginTop = top;
    if (bottom != null) s.verseMarginBottom = bottom;
    if (left != null) s.verseMarginLeft = left;
    if (right != null) s.verseMarginRight = right;
    state = s;
  }

  PresentationSettings cloneState(PresentationSettings src) {
    return PresentationSettings()
      ..id = src.id
      ..presetName = src.presetName
      ..isDefault = src.isDefault
      ..songAspectRatio = src.songAspectRatio
      ..songCustomWidth = src.songCustomWidth
      ..songCustomHeight = src.songCustomHeight
      ..scriptureAspectRatio = src.scriptureAspectRatio
      ..scriptureCustomWidth = src.scriptureCustomWidth
      ..scriptureCustomHeight = src.scriptureCustomHeight
      ..isSongImageEnabled = src.isSongImageEnabled
      ..isSongTransparent = src.isSongTransparent
      ..songBackgroundColor = src.songBackgroundColor
      ..songBackgroundImage = src.songBackgroundImage
      ..isScriptureImageEnabled = src.isScriptureImageEnabled
      ..isScriptureTransparent = src.isScriptureTransparent
      ..scriptureBackgroundColor = src.scriptureBackgroundColor
      ..scriptureBackgroundImage = src.scriptureBackgroundImage
      ..showTitle = src.showTitle
      ..titleAlignment = src.titleAlignment
      ..titleVerticalAlignment = src.titleVerticalAlignment
      ..titleFontSize = src.titleFontSize
      ..titleFontFamily = src.titleFontFamily
      ..titleFontColor = src.titleFontColor
      ..titleUnderline = src.titleUnderline
      ..titleHasFill = src.titleHasFill
      ..titleFillColor = src.titleFillColor
      ..titleHasStroke = src.titleHasStroke
      ..titleStrokeColor = src.titleStrokeColor
      ..titleMarginTop = src.titleMarginTop
      ..titleMarginBottom = src.titleMarginBottom
      ..titleMarginLeft = src.titleMarginLeft
      ..titleMarginRight = src.titleMarginRight
      ..lyricsAlignment = src.lyricsAlignment
      ..lyricsVerticalAlignment = src.lyricsVerticalAlignment
      ..lyricsFontSize = src.lyricsFontSize
      ..lyricsFontFamily = src.lyricsFontFamily
      ..lyricsFontColor = src.lyricsFontColor
      ..lyricsUnderline = src.lyricsUnderline
      ..lyricsHasFill = src.lyricsHasFill
      ..lyricsFillColor = src.lyricsFillColor
      ..lyricsHasStroke = src.lyricsHasStroke
      ..lyricsStrokeColor = src.lyricsStrokeColor
      ..lyricsMarginTop = src.lyricsMarginTop
      ..lyricsMarginBottom = src.lyricsMarginBottom
      ..lyricsMarginLeft = src.lyricsMarginLeft
      ..lyricsMarginRight = src.lyricsMarginRight
      ..showChapter = src.showChapter
      ..chapterAlignment = src.chapterAlignment
      ..chapterVerticalAlignment = src.chapterVerticalAlignment
      ..chapterFontSize = src.chapterFontSize
      ..chapterFontFamily = src.chapterFontFamily
      ..chapterFontColor = src.chapterFontColor
      ..chapterUnderline = src.chapterUnderline
      ..chapterHasFill = src.chapterHasFill
      ..chapterFillColor = src.chapterFillColor
      ..chapterHasStroke = src.chapterHasStroke
      ..chapterStrokeColor = src.chapterStrokeColor
      ..chapterMarginTop = src.chapterMarginTop
      ..chapterMarginBottom = src.chapterMarginBottom
      ..chapterMarginLeft = src.chapterMarginLeft
      ..chapterMarginRight = src.chapterMarginRight
      ..verseAlignment = src.verseAlignment
      ..verseVerticalAlignment = src.verseVerticalAlignment
      ..verseFontSize = src.verseFontSize
      ..verseFontFamily = src.verseFontFamily
      ..verseFontColor = src.verseFontColor
      ..verseUnderline = src.verseUnderline
      ..verseHasFill = src.verseHasFill
      ..verseFillColor = src.verseFillColor
      ..verseHasStroke = src.verseHasStroke
      ..verseStrokeColor = src.verseStrokeColor
      ..verseMarginTop = src.verseMarginTop
      ..verseMarginBottom = src.verseMarginBottom
      ..verseMarginLeft = src.verseMarginLeft
      ..verseMarginRight = src.verseMarginRight;
  }
}
