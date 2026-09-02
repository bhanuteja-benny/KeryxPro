import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../data/presentation_settings.dart';
import 'package:isar/isar.dart';
import '../../../../core/sync/sync_service.dart';

final presetsListProvider = FutureProvider<List<PresentationSettings>>((ref) async {
  final isar = await ref.watch(isarServiceProvider).db;
  final results = await isar.presentationSettings.where().findAll();
  if (results.isEmpty) {
    final defaultP = PresentationSettings()
      ..presetName = 'Default'
      ..isDefault = true;
    await isar.writeTxn(() async {
      await isar.presentationSettings.put(defaultP);
    });
    return [_processFallbacks(defaultP)];
  }
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
  return settings.sanitize();
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
    final existing = await isar.presentationSettings.get(id);
    
    await isar.writeTxn(() async {
      await isar.presentationSettings.delete(id);
    });
    
    if (existing != null) {
      _ref.read(syncServiceProvider).exportPresetDelete(existing.syncId);
    }
    
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
    
    _ref.read(syncServiceProvider).exportPresentationSettings(newPreset);
    _ref.invalidate(presetsListProvider);
  }

  Future<void> saveSettings() async {
    final isar = await _dbFuture;
    await isar.writeTxn(() async {
      await isar.presentationSettings.put(state);
    });
    
    _ref.read(syncServiceProvider).exportPresentationSettings(state);
    _ref.invalidate(presetsListProvider);
    
    final currentActive = _ref.read(presentationSettingsProvider);
    if (currentActive.id == state.id) {
       _ref.read(presentationSettingsProvider.notifier).setActivePreset(state);
    }
  }

  // --- Update Methods without auto-save ---
  void updateAspectRatio(String ratio, int tabIndex) {
    if (tabIndex == 0) {
      state = cloneState(state)..songAspectRatio = ratio;
    } else if (tabIndex == 1) {
      state = cloneState(state)..scriptureAspectRatio = ratio;
    } else if (tabIndex == 2) {
      state = cloneState(state)..dualScriptureAspectRatio = ratio;
    } else if (tabIndex == 3) {
      state = cloneState(state)..blankAspectRatio = ratio;
    } else if (tabIndex == 4) {
      state = cloneState(state)..windowAspectRatio = ratio;
    }
  }

  void updateCustomWidth(double w, int tabIndex) {
    if (tabIndex == 0) {
      state = cloneState(state)..songCustomWidth = w;
    } else if (tabIndex == 1) {
      state = cloneState(state)..scriptureCustomWidth = w;
    } else if (tabIndex == 2) {
      state = cloneState(state)..dualScriptureCustomWidth = w;
    } else if (tabIndex == 3) {
      state = cloneState(state)..blankCustomWidth = w;
    } else if (tabIndex == 4) {
      state = cloneState(state)..windowCustomWidth = w;
    }
  }

  void updateCustomHeight(double h, int tabIndex) {
    if (tabIndex == 0) {
      state = cloneState(state)..songCustomHeight = h;
    } else if (tabIndex == 1) {
      state = cloneState(state)..scriptureCustomHeight = h;
    } else if (tabIndex == 2) {
      state = cloneState(state)..dualScriptureCustomHeight = h;
    } else if (tabIndex == 3) {
      state = cloneState(state)..blankCustomHeight = h;
    } else if (tabIndex == 4) {
      state = cloneState(state)..windowCustomHeight = h;
    }
  }

  // Background updates take an int tabIndex
  void updateBackgroundColor(int color, int tabIndex) {
    final s = cloneState(state);
    if (tabIndex == 0) {
      s.songBackgroundColor = color;
      s.isSongTransparent = false;
    } else if (tabIndex == 1) {
      s.scriptureBackgroundColor = color;
      s.isScriptureTransparent = false;
    } else if (tabIndex == 2) {
      s.dualScriptureBackgroundColor = color;
      s.isDualScriptureTransparent = false;
    } else if (tabIndex == 3) {
      s.blankBackgroundColor = color;
      s.isBlankTransparent = false;
    } else if (tabIndex == 4) {
      s.windowBackgroundColor = color;
      s.isWindowTransparent = false;
    }   
    state = s;
  }
  
  void updateBackgroundImage(String path, String layout, String alignment, int tabIndex) {
    final s = cloneState(state);
    if (tabIndex == 0) {
      s.songBackgroundImage = path;
      s.songBackgroundImageLayout = layout;
      s.songBackgroundImageAlignment = alignment;
      s.isSongImageEnabled = true;
    } else if (tabIndex == 1) {
      s.scriptureBackgroundImage = path;
      s.scriptureBackgroundImageLayout = layout;
      s.scriptureBackgroundImageAlignment = alignment;
      s.isScriptureImageEnabled = true;
    } else if (tabIndex == 2) {
      s.dualScriptureBackgroundImage = path;
      s.dualScriptureBackgroundImageLayout = layout;
      s.dualScriptureBackgroundImageAlignment = alignment;
      s.isDualScriptureImageEnabled = true;
    } else if (tabIndex == 3) {
      s.blankBackgroundImage = path;
      s.blankBackgroundImageLayout = layout;
      s.blankBackgroundImageAlignment = alignment;
      s.isBlankImageEnabled = true;
    } else if (tabIndex == 4) {
      s.windowBackgroundImage = path;
      s.windowBackgroundImageLayout = layout;
      s.windowBackgroundImageAlignment = alignment;
      s.isWindowImageEnabled = true;
    }   
    state = s;
  }

  void updateIsImageEnabled(bool enabled, int tabIndex) {
    final s = cloneState(state);
    if (tabIndex == 0) {
      s.isSongImageEnabled = enabled;
    } else if (tabIndex == 1) {
      s.isScriptureImageEnabled = enabled;
    } else if (tabIndex == 2) {
      s.isDualScriptureImageEnabled = enabled;
    } else if (tabIndex == 3) {
      s.isBlankImageEnabled = enabled;
    } else if (tabIndex == 4) {
      s.isWindowImageEnabled = enabled;
    }   
    state = s;
  }
  
  void updateIsTransparent(bool transparent, int tabIndex) {
    final s = cloneState(state);
    if (tabIndex == 0) {
      s.isSongTransparent = transparent;
    } else if (tabIndex == 1) {
      s.isScriptureTransparent = transparent;
    } else if (tabIndex == 2) {
      s.isDualScriptureTransparent = transparent;
    } else if (tabIndex == 3) {
      s.isBlankTransparent = transparent;
    } else if (tabIndex == 4) {
      s.isWindowTransparent = transparent;
    }   
    state = s;
  }

  // Dual Scripture Layout Updates
  void updateDualScriptureLayoutDirection(String dir) => state = cloneState(state)..dualScriptureLayoutDirection = dir;
  void updateDualScripturePrimaryPosition(String pos) => state = cloneState(state)..dualScripturePrimaryPosition = pos;
  void updateDualScripturePrimaryRatio(double ratio) => state = cloneState(state)..dualScripturePrimaryRatio = ratio;

  // Title Updates
  void updateShowTitle(bool show) => state = cloneState(state)..showTitle = show;
  void updateTitleAlignment(String horizontal) => state = cloneState(state)..titleAlignment = horizontal;
  void updateTitleVerticalAlignment(String vertical) => state = cloneState(state)..titleVerticalAlignment = vertical;
  void updateTitleFontSize(double size) => state = cloneState(state)..titleFontSize = size;
  void updateTitleFontFamily(String family) => state = cloneState(state)..titleFontFamily = family;
  void updateTitleFontColor(int color) => state = cloneState(state)..titleFontColor = color;
  void updateTitleBold(bool v) => state = cloneState(state)..titleBold = v;
  void updateTitleItalic(bool v) => state = cloneState(state)..titleItalic = v;
  void updateTitleUnderline(bool v) => state = cloneState(state)..titleUnderline = v;
  void updateTitleFill(bool hasFill, int color) => state = cloneState(state)..titleHasFill = hasFill..titleFillColor = color;
  void updateTitleStroke(bool hasStroke, int color) => state = cloneState(state)..titleHasStroke = hasStroke..titleStrokeColor = color;
  void updateTitleLineHeight(double v) => state = cloneState(state)..titleLineHeight = v;
  void updateTitleStrokeWidth(double v) => state = cloneState(state)..titleStrokeWidth = v;
  void updateTitleShadow({bool? hasShadow, int? color, double? offsetX, double? offsetY, double? radius}) {
    final s = cloneState(state);
    if (hasShadow != null) s.titleHasShadow = hasShadow;
    if (color != null) s.titleShadowColor = color;
    if (offsetX != null) s.titleShadowOffsetX = offsetX;
    if (offsetY != null) s.titleShadowOffsetY = offsetY;
    if (radius != null) s.titleShadowRadius = radius;
    state = s;
  }
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
  void updateLyricsBold(bool v) => state = cloneState(state)..lyricsBold = v;
  void updateLyricsItalic(bool v) => state = cloneState(state)..lyricsItalic = v;
  void updateLyricsUnderline(bool v) => state = cloneState(state)..lyricsUnderline = v;
  void updateLyricsFill(bool hasFill, int color) => state = cloneState(state)..lyricsHasFill = hasFill..lyricsFillColor = color;
  void updateLyricsStroke(bool hasStroke, int color) => state = cloneState(state)..lyricsHasStroke = hasStroke..lyricsStrokeColor = color;
  void updateLyricsLineBreak(bool value) => state = cloneState(state)..lyricsLineBreak = value;
  void updateLyricsLineHeight(double v) => state = cloneState(state)..lyricsLineHeight = v;
  void updateLyricsStrokeWidth(double v) => state = cloneState(state)..lyricsStrokeWidth = v;
  void updateLyricsShadow({bool? hasShadow, int? color, double? offsetX, double? offsetY, double? radius}) {
    final s = cloneState(state);
    if (hasShadow != null) s.lyricsHasShadow = hasShadow;
    if (color != null) s.lyricsShadowColor = color;
    if (offsetX != null) s.lyricsShadowOffsetX = offsetX;
    if (offsetY != null) s.lyricsShadowOffsetY = offsetY;
    if (radius != null) s.lyricsShadowRadius = radius;
    state = s;
  }
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
  void updateChapterBold(bool v) => state = cloneState(state)..chapterBold = v;
  void updateChapterItalic(bool v) => state = cloneState(state)..chapterItalic = v;
  void updateChapterUnderline(bool v) => state = cloneState(state)..chapterUnderline = v;
  void updateChapterFill(bool hasFill, int color) => state = cloneState(state)..chapterHasFill = hasFill..chapterFillColor = color;
  void updateChapterStroke(bool hasStroke, int color) => state = cloneState(state)..chapterHasStroke = hasStroke..chapterStrokeColor = color;
  void updateChapterLineHeight(double v) => state = cloneState(state)..chapterLineHeight = v;
  void updateChapterStrokeWidth(double v) => state = cloneState(state)..chapterStrokeWidth = v;
  void updateChapterShadow({bool? hasShadow, int? color, double? offsetX, double? offsetY, double? radius}) {
    final s = cloneState(state);
    if (hasShadow != null) s.chapterHasShadow = hasShadow;
    if (color != null) s.chapterShadowColor = color;
    if (offsetX != null) s.chapterShadowOffsetX = offsetX;
    if (offsetY != null) s.chapterShadowOffsetY = offsetY;
    if (radius != null) s.chapterShadowRadius = radius;
    state = s;
  }
  void updateChapterMargins({double? top, double? bottom, double? left, double? right}) {
    final s = cloneState(state);
    if (top != null) s.chapterMarginTop = top;
    if (bottom != null) s.chapterMarginBottom = bottom;
    if (left != null) s.chapterMarginLeft = left;
    if (right != null) s.chapterMarginRight = right;
    state = s;
  }

  // Dual Chapter Updates
  void updateShowDualChapter(bool show) => state = cloneState(state)..showDualChapter = show;
  void updateDualChapterAlignment(String horizontal) => state = cloneState(state)..dualChapterAlignment = horizontal;
  void updateDualChapterVerticalAlignment(String vertical) => state = cloneState(state)..dualChapterVerticalAlignment = vertical;
  void updateDualChapterFontSize(double size) => state = cloneState(state)..dualChapterFontSize = size;
  void updateDualChapterFontFamily(String family) => state = cloneState(state)..dualChapterFontFamily = family;
  void updateDualChapterFontColor(int color) => state = cloneState(state)..dualChapterFontColor = color;
  void updateDualChapterBold(bool v) => state = cloneState(state)..dualChapterBold = v;
  void updateDualChapterItalic(bool v) => state = cloneState(state)..dualChapterItalic = v;
  void updateDualChapterUnderline(bool v) => state = cloneState(state)..dualChapterUnderline = v;
  void updateDualChapterFill(bool hasFill, int color) => state = cloneState(state)..dualChapterHasFill = hasFill..dualChapterFillColor = color;
  void updateDualChapterStroke(bool hasStroke, int color) => state = cloneState(state)..dualChapterHasStroke = hasStroke..dualChapterStrokeColor = color;
  void updateDualChapterLineHeight(double v) => state = cloneState(state)..dualChapterLineHeight = v;
  void updateDualChapterStrokeWidth(double v) => state = cloneState(state)..dualChapterStrokeWidth = v;
  void updateDualChapterShadow({bool? hasShadow, int? color, double? offsetX, double? offsetY, double? radius}) {
    final s = cloneState(state);
    if (hasShadow != null) s.dualChapterHasShadow = hasShadow;
    if (color != null) s.dualChapterShadowColor = color;
    if (offsetX != null) s.dualChapterShadowOffsetX = offsetX;
    if (offsetY != null) s.dualChapterShadowOffsetY = offsetY;
    if (radius != null) s.dualChapterShadowRadius = radius;
    state = s;
  }
  void updateDualChapterMargins({double? top, double? bottom, double? left, double? right}) {
    final s = cloneState(state);
    if (top != null) s.dualChapterMarginTop = top;
    if (bottom != null) s.dualChapterMarginBottom = bottom;
    if (left != null) s.dualChapterMarginLeft = left;
    if (right != null) s.dualChapterMarginRight = right;
    state = s;
  }

  // Verse Updates
  void updateVerseAlignment(String alignment) => state = cloneState(state)..verseAlignment = alignment;
  void updateVerseVerticalAlignment(String alignment) => state = cloneState(state)..verseVerticalAlignment = alignment;
  void updateVerseFontSize(double size) => state = cloneState(state)..verseFontSize = size;
  void updateVerseFontFamily(String family) => state = cloneState(state)..verseFontFamily = family;
  void updateVerseFontColor(int color) => state = cloneState(state)..verseFontColor = color;
  void updateVerseBold(bool v) => state = cloneState(state)..verseBold = v;
  void updateVerseItalic(bool v) => state = cloneState(state)..verseItalic = v;
  void updateVerseUnderline(bool v) => state = cloneState(state)..verseUnderline = v;
  void updateVerseFill(bool hasFill, int color) => state = cloneState(state)..verseHasFill = hasFill..verseFillColor = color;
  void updateVerseStroke(bool hasStroke, int color) => state = cloneState(state)..verseHasStroke = hasStroke..verseStrokeColor = color;
  void updateVerseLineHeight(double v) => state = cloneState(state)..verseLineHeight = v;
  void updateVerseStrokeWidth(double v) => state = cloneState(state)..verseStrokeWidth = v;
  void updateVerseShadow({bool? hasShadow, int? color, double? offsetX, double? offsetY, double? radius}) {
    final s = cloneState(state);
    if (hasShadow != null) s.verseHasShadow = hasShadow;
    if (color != null) s.verseShadowColor = color;
    if (offsetX != null) s.verseShadowOffsetX = offsetX;
    if (offsetY != null) s.verseShadowOffsetY = offsetY;
    if (radius != null) s.verseShadowRadius = radius;
    state = s;
  }
  void updateVerseMargins({double? top, double? bottom, double? left, double? right}) {
    final s = cloneState(state);
    if (top != null) s.verseMarginTop = top;
    if (bottom != null) s.verseMarginBottom = bottom;
    if (left != null) s.verseMarginLeft = left;
    if (right != null) s.verseMarginRight = right;
    state = s;
  }

  // Primary Verse Updates (Dual Scripture)
  void updatePrimaryVerseAlignment(String alignment) => state = cloneState(state)..primaryVerseAlignment = alignment;
  void updatePrimaryVerseVerticalAlignment(String alignment) => state = cloneState(state)..primaryVerseVerticalAlignment = alignment;
  void updatePrimaryVerseFontSize(double size) => state = cloneState(state)..primaryVerseFontSize = size;
  void updatePrimaryVerseFontFamily(String family) => state = cloneState(state)..primaryVerseFontFamily = family;
  void updatePrimaryVerseFontColor(int color) => state = cloneState(state)..primaryVerseFontColor = color;
  void updatePrimaryVerseBold(bool v) => state = cloneState(state)..primaryVerseBold = v;
  void updatePrimaryVerseItalic(bool v) => state = cloneState(state)..primaryVerseItalic = v;
  void updatePrimaryVerseUnderline(bool v) => state = cloneState(state)..primaryVerseUnderline = v;
  void updatePrimaryVerseFill(bool hasFill, int color) => state = cloneState(state)..primaryVerseHasFill = hasFill..primaryVerseFillColor = color;
  void updatePrimaryVerseStroke(bool hasStroke, int color) => state = cloneState(state)..primaryVerseHasStroke = hasStroke..primaryVerseStrokeColor = color;
  void updatePrimaryVerseLineHeight(double v) => state = cloneState(state)..primaryVerseLineHeight = v;
  void updatePrimaryVerseStrokeWidth(double v) => state = cloneState(state)..primaryVerseStrokeWidth = v;
  void updatePrimaryVerseShadow({bool? hasShadow, int? color, double? offsetX, double? offsetY, double? radius}) {
    final s = cloneState(state);
    if (hasShadow != null) s.primaryVerseHasShadow = hasShadow;
    if (color != null) s.primaryVerseShadowColor = color;
    if (offsetX != null) s.primaryVerseShadowOffsetX = offsetX;
    if (offsetY != null) s.primaryVerseShadowOffsetY = offsetY;
    if (radius != null) s.primaryVerseShadowRadius = radius;
    state = s;
  }
  void updatePrimaryVerseMargins({double? top, double? bottom, double? left, double? right}) {
    final s = cloneState(state);
    if (top != null) s.primaryVerseMarginTop = top;
    if (bottom != null) s.primaryVerseMarginBottom = bottom;
    if (left != null) s.primaryVerseMarginLeft = left;
    if (right != null) s.primaryVerseMarginRight = right;
    state = s;
  }

  // Secondary Verse Updates (Dual Scripture)
  void updateSecVerseAlignment(String alignment) => state = cloneState(state)..secVerseAlignment = alignment;
  void updateSecVerseVerticalAlignment(String alignment) => state = cloneState(state)..secVerseVerticalAlignment = alignment;
  void updateSecVerseFontSize(double size) => state = cloneState(state)..secVerseFontSize = size;
  void updateSecVerseFontFamily(String family) => state = cloneState(state)..secVerseFontFamily = family;
  void updateSecVerseFontColor(int color) => state = cloneState(state)..secVerseFontColor = color;
  void updateSecVerseBold(bool v) => state = cloneState(state)..secVerseBold = v;
  void updateSecVerseItalic(bool v) => state = cloneState(state)..secVerseItalic = v;
  void updateSecVerseUnderline(bool v) => state = cloneState(state)..secVerseUnderline = v;
  void updateSecVerseFill(bool hasFill, int color) => state = cloneState(state)..secVerseHasFill = hasFill..secVerseFillColor = color;
  void updateSecVerseStroke(bool hasStroke, int color) => state = cloneState(state)..secVerseHasStroke = hasStroke..secVerseStrokeColor = color;
  void updateSecVerseLineHeight(double v) => state = cloneState(state)..secVerseLineHeight = v;
  void updateSecVerseStrokeWidth(double v) => state = cloneState(state)..secVerseStrokeWidth = v;
  void updateSecVerseShadow({bool? hasShadow, int? color, double? offsetX, double? offsetY, double? radius}) {
    final s = cloneState(state);
    if (hasShadow != null) s.secVerseHasShadow = hasShadow;
    if (color != null) s.secVerseShadowColor = color;
    if (offsetX != null) s.secVerseShadowOffsetX = offsetX;
    if (offsetY != null) s.secVerseShadowOffsetY = offsetY;
    if (radius != null) s.secVerseShadowRadius = radius;
    state = s;
  }
  void updateSecVerseMargins({double? top, double? bottom, double? left, double? right}) {
    final s = cloneState(state);
    if (top != null) s.secVerseMarginTop = top;
    if (bottom != null) s.secVerseMarginBottom = bottom;
    if (left != null) s.secVerseMarginLeft = left;
    if (right != null) s.secVerseMarginRight = right;
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
      ..dualScriptureAspectRatio = src.dualScriptureAspectRatio
      ..dualScriptureCustomWidth = src.dualScriptureCustomWidth
      ..dualScriptureCustomHeight = src.dualScriptureCustomHeight
      ..isSongImageEnabled = src.isSongImageEnabled
      ..isSongTransparent = src.isSongTransparent
      ..songBackgroundColor = src.songBackgroundColor
      ..songBackgroundImage = src.songBackgroundImage
      ..songBackgroundImageLayout = src.songBackgroundImageLayout
      ..songBackgroundImageAlignment = src.songBackgroundImageAlignment
      ..isScriptureImageEnabled = src.isScriptureImageEnabled
      ..isScriptureTransparent = src.isScriptureTransparent
      ..scriptureBackgroundColor = src.scriptureBackgroundColor
      ..scriptureBackgroundImage = src.scriptureBackgroundImage
      ..scriptureBackgroundImageLayout = src.scriptureBackgroundImageLayout
      ..scriptureBackgroundImageAlignment = src.scriptureBackgroundImageAlignment
      ..isDualScriptureImageEnabled = src.isDualScriptureImageEnabled
      ..isDualScriptureTransparent = src.isDualScriptureTransparent
      ..dualScriptureBackgroundColor = src.dualScriptureBackgroundColor
      ..dualScriptureBackgroundImage = src.dualScriptureBackgroundImage
      ..dualScriptureBackgroundImageLayout = src.dualScriptureBackgroundImageLayout
      ..dualScriptureBackgroundImageAlignment = src.dualScriptureBackgroundImageAlignment
      ..dualScriptureLayoutDirection = src.dualScriptureLayoutDirection
      ..dualScripturePrimaryPosition = src.dualScripturePrimaryPosition
      ..dualScripturePrimaryRatio = src.dualScripturePrimaryRatio
      ..blankAspectRatio = src.blankAspectRatio
      ..blankCustomWidth = src.blankCustomWidth
      ..blankCustomHeight = src.blankCustomHeight
      ..isBlankImageEnabled = src.isBlankImageEnabled
      ..isBlankTransparent = src.isBlankTransparent
      ..blankBackgroundColor = src.blankBackgroundColor
      ..blankBackgroundImage = src.blankBackgroundImage
      ..blankBackgroundImageLayout = src.blankBackgroundImageLayout
      ..blankBackgroundImageAlignment = src.blankBackgroundImageAlignment
      ..windowAspectRatio = src.windowAspectRatio
      ..windowCustomWidth = src.windowCustomWidth
      ..windowCustomHeight = src.windowCustomHeight
      ..isWindowImageEnabled = src.isWindowImageEnabled
      ..isWindowTransparent = src.isWindowTransparent
      ..windowBackgroundColor = src.windowBackgroundColor
      ..windowBackgroundImage = src.windowBackgroundImage
      ..windowBackgroundImageLayout = src.windowBackgroundImageLayout
      ..windowBackgroundImageAlignment = src.windowBackgroundImageAlignment
      ..showTitle = src.showTitle
      ..titleAlignment = src.titleAlignment
      ..titleVerticalAlignment = src.titleVerticalAlignment
      ..titleFontSize = src.titleFontSize
      ..titleFontFamily = src.titleFontFamily
      ..titleFontColor = src.titleFontColor
      ..titleBold = src.titleBold
      ..titleItalic = src.titleItalic
      ..titleUnderline = src.titleUnderline
      ..titleHasFill = src.titleHasFill
      ..titleFillColor = src.titleFillColor
      ..titleHasStroke = src.titleHasStroke
      ..titleStrokeColor = src.titleStrokeColor
      ..titleLineHeight = src.titleLineHeight
      ..titleStrokeWidth = src.titleStrokeWidth
      ..titleHasShadow = src.titleHasShadow
      ..titleShadowColor = src.titleShadowColor
      ..titleShadowOffsetX = src.titleShadowOffsetX
      ..titleShadowOffsetY = src.titleShadowOffsetY
      ..titleShadowRadius = src.titleShadowRadius
      ..titleMarginTop = src.titleMarginTop
      ..titleMarginBottom = src.titleMarginBottom
      ..titleMarginLeft = src.titleMarginLeft
      ..titleMarginRight = src.titleMarginRight
      ..lyricsAlignment = src.lyricsAlignment
      ..lyricsVerticalAlignment = src.lyricsVerticalAlignment
      ..lyricsFontSize = src.lyricsFontSize
      ..lyricsFontFamily = src.lyricsFontFamily
      ..lyricsFontColor = src.lyricsFontColor
      ..lyricsBold = src.lyricsBold
      ..lyricsItalic = src.lyricsItalic
      ..lyricsUnderline = src.lyricsUnderline
      ..lyricsHasFill = src.lyricsHasFill
      ..lyricsFillColor = src.lyricsFillColor
      ..lyricsHasStroke = src.lyricsHasStroke
      ..lyricsStrokeColor = src.lyricsStrokeColor
      ..lyricsLineHeight = src.lyricsLineHeight
      ..lyricsStrokeWidth = src.lyricsStrokeWidth
      ..lyricsHasShadow = src.lyricsHasShadow
      ..lyricsShadowColor = src.lyricsShadowColor
      ..lyricsShadowOffsetX = src.lyricsShadowOffsetX
      ..lyricsShadowOffsetY = src.lyricsShadowOffsetY
      ..lyricsShadowRadius = src.lyricsShadowRadius
      ..lyricsMarginTop = src.lyricsMarginTop
      ..lyricsMarginBottom = src.lyricsMarginBottom
      ..lyricsMarginLeft = src.lyricsMarginLeft
      ..lyricsMarginRight = src.lyricsMarginRight
      ..lyricsLineBreak = src.lyricsLineBreak
      ..showChapter = src.showChapter
      ..chapterAlignment = src.chapterAlignment
      ..chapterVerticalAlignment = src.chapterVerticalAlignment
      ..chapterFontSize = src.chapterFontSize
      ..chapterFontFamily = src.chapterFontFamily
      ..chapterFontColor = src.chapterFontColor
      ..chapterBold = src.chapterBold
      ..chapterItalic = src.chapterItalic
      ..chapterUnderline = src.chapterUnderline
      ..chapterHasFill = src.chapterHasFill
      ..chapterFillColor = src.chapterFillColor
      ..chapterHasStroke = src.chapterHasStroke
      ..chapterStrokeColor = src.chapterStrokeColor
      ..chapterLineHeight = src.chapterLineHeight
      ..chapterStrokeWidth = src.chapterStrokeWidth
      ..chapterHasShadow = src.chapterHasShadow
      ..chapterShadowColor = src.chapterShadowColor
      ..chapterShadowOffsetX = src.chapterShadowOffsetX
      ..chapterShadowOffsetY = src.chapterShadowOffsetY
      ..chapterShadowRadius = src.chapterShadowRadius
      ..chapterMarginTop = src.chapterMarginTop
      ..chapterMarginBottom = src.chapterMarginBottom
      ..chapterMarginLeft = src.chapterMarginLeft
      ..chapterMarginRight = src.chapterMarginRight
      ..verseAlignment = src.verseAlignment
      ..verseVerticalAlignment = src.verseVerticalAlignment
      ..verseFontSize = src.verseFontSize
      ..verseFontFamily = src.verseFontFamily
      ..verseFontColor = src.verseFontColor
      ..verseBold = src.verseBold
      ..verseItalic = src.verseItalic
      ..verseUnderline = src.verseUnderline
      ..verseHasFill = src.verseHasFill
      ..verseFillColor = src.verseFillColor
      ..verseHasStroke = src.verseHasStroke
      ..verseStrokeColor = src.verseStrokeColor
      ..verseLineHeight = src.verseLineHeight
      ..verseStrokeWidth = src.verseStrokeWidth
      ..verseHasShadow = src.verseHasShadow
      ..verseShadowColor = src.verseShadowColor
      ..verseShadowOffsetX = src.verseShadowOffsetX
      ..verseShadowOffsetY = src.verseShadowOffsetY
      ..verseShadowRadius = src.verseShadowRadius
      ..verseMarginTop = src.verseMarginTop
      ..verseMarginBottom = src.verseMarginBottom
      ..verseMarginLeft = src.verseMarginLeft
      ..verseMarginRight = src.verseMarginRight
      ..showDualChapter = src.showDualChapter
      ..dualChapterAlignment = src.dualChapterAlignment
      ..dualChapterVerticalAlignment = src.dualChapterVerticalAlignment
      ..dualChapterFontSize = src.dualChapterFontSize
      ..dualChapterFontFamily = src.dualChapterFontFamily
      ..dualChapterFontColor = src.dualChapterFontColor
      ..dualChapterBold = src.dualChapterBold
      ..dualChapterItalic = src.dualChapterItalic
      ..dualChapterUnderline = src.dualChapterUnderline
      ..dualChapterHasFill = src.dualChapterHasFill
      ..dualChapterFillColor = src.dualChapterFillColor
      ..dualChapterHasStroke = src.dualChapterHasStroke
      ..dualChapterStrokeColor = src.dualChapterStrokeColor
      ..dualChapterLineHeight = src.dualChapterLineHeight
      ..dualChapterStrokeWidth = src.dualChapterStrokeWidth
      ..dualChapterHasShadow = src.dualChapterHasShadow
      ..dualChapterShadowColor = src.dualChapterShadowColor
      ..dualChapterShadowOffsetX = src.dualChapterShadowOffsetX
      ..dualChapterShadowOffsetY = src.dualChapterShadowOffsetY
      ..dualChapterShadowRadius = src.dualChapterShadowRadius
      ..dualChapterMarginTop = src.dualChapterMarginTop
      ..dualChapterMarginBottom = src.dualChapterMarginBottom
      ..dualChapterMarginLeft = src.dualChapterMarginLeft
      ..dualChapterMarginRight = src.dualChapterMarginRight
      ..primaryVerseAlignment = src.primaryVerseAlignment
      ..primaryVerseVerticalAlignment = src.primaryVerseVerticalAlignment
      ..primaryVerseFontSize = src.primaryVerseFontSize
      ..primaryVerseFontFamily = src.primaryVerseFontFamily
      ..primaryVerseFontColor = src.primaryVerseFontColor
      ..primaryVerseBold = src.primaryVerseBold
      ..primaryVerseItalic = src.primaryVerseItalic
      ..primaryVerseUnderline = src.primaryVerseUnderline
      ..primaryVerseHasFill = src.primaryVerseHasFill
      ..primaryVerseFillColor = src.primaryVerseFillColor
      ..primaryVerseHasStroke = src.primaryVerseHasStroke
      ..primaryVerseStrokeColor = src.primaryVerseStrokeColor
      ..primaryVerseLineHeight = src.primaryVerseLineHeight
      ..primaryVerseStrokeWidth = src.primaryVerseStrokeWidth
      ..primaryVerseHasShadow = src.primaryVerseHasShadow
      ..primaryVerseShadowColor = src.primaryVerseShadowColor
      ..primaryVerseShadowOffsetX = src.primaryVerseShadowOffsetX
      ..primaryVerseShadowOffsetY = src.primaryVerseShadowOffsetY
      ..primaryVerseShadowRadius = src.primaryVerseShadowRadius
      ..primaryVerseMarginTop = src.primaryVerseMarginTop
      ..primaryVerseMarginBottom = src.primaryVerseMarginBottom
      ..primaryVerseMarginLeft = src.primaryVerseMarginLeft
      ..primaryVerseMarginRight = src.primaryVerseMarginRight
      ..secVerseAlignment = src.secVerseAlignment
      ..secVerseVerticalAlignment = src.secVerseVerticalAlignment
      ..secVerseFontSize = src.secVerseFontSize
      ..secVerseFontFamily = src.secVerseFontFamily
      ..secVerseFontColor = src.secVerseFontColor
      ..secVerseBold = src.secVerseBold
      ..secVerseItalic = src.secVerseItalic
      ..secVerseUnderline = src.secVerseUnderline
      ..secVerseHasFill = src.secVerseHasFill
      ..secVerseFillColor = src.secVerseFillColor
      ..secVerseHasStroke = src.secVerseHasStroke
      ..secVerseStrokeColor = src.secVerseStrokeColor
      ..secVerseLineHeight = src.secVerseLineHeight
      ..secVerseStrokeWidth = src.secVerseStrokeWidth
      ..secVerseHasShadow = src.secVerseHasShadow
      ..secVerseShadowColor = src.secVerseShadowColor
      ..secVerseShadowOffsetX = src.secVerseShadowOffsetX
      ..secVerseShadowOffsetY = src.secVerseShadowOffsetY
      ..secVerseShadowRadius = src.secVerseShadowRadius
      ..secVerseMarginTop = src.secVerseMarginTop
      ..secVerseMarginBottom = src.secVerseMarginBottom
      ..secVerseMarginLeft = src.secVerseMarginLeft
      ..secVerseMarginRight = src.secVerseMarginRight;
  }
}
