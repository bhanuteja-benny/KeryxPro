import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'presentation_settings.g.dart';

@collection
class PresentationSettings {
  Id id = Isar.autoIncrement; 

  @Index(unique: true, replace: true)
  String syncId = const Uuid().v4();


  String presetName = 'Default';
  bool isDefault = false;

  // View Settings (Song)
  String songAspectRatio = '16:9'; // '16:9', '4:3', '4:1', 'Custom'
  double songCustomWidth = 1920.0;
  double songCustomHeight = 1080.0;

  // View Settings (Scripture)
  String scriptureAspectRatio = '16:9'; // '16:9', '4:3', '4:1', 'Custom'
  double scriptureCustomWidth = 1920.0;
  double scriptureCustomHeight = 1080.0;

  // Background Options
  int songBackgroundColor = 0xFF000000;
  String songBackgroundImage = '';
  String songBackgroundImageLayout = 'stretch';
  String songBackgroundImageAlignment = 'center';
  bool isSongImageEnabled = false;
  bool isSongTransparent = false;

  int scriptureBackgroundColor = 0xFF000000;
  String scriptureBackgroundImage = '';
  String scriptureBackgroundImageLayout = 'stretch';
  String scriptureBackgroundImageAlignment = 'center';
  bool isScriptureImageEnabled = false;
  bool isScriptureTransparent = false;

  // View Settings (Blank)
  String blankAspectRatio = '16:9'; // '16:9', '4:3', '4:1', 'Custom'
  double blankCustomWidth = 1920.0;
  double blankCustomHeight = 1080.0;

  int blankBackgroundColor = 0xFF000000;
  String blankBackgroundImage = '';
  String blankBackgroundImageLayout = 'stretch';
  String blankBackgroundImageAlignment = 'center';
  bool isBlankImageEnabled = false;
  bool isBlankTransparent = false;

// View Settings (Window)
String windowAspectRatio = '16:9'; // '16:9', '4:3', '4:1', 'Custom'
double windowCustomWidth = 1920.0;
double windowCustomHeight = 1080.0;

int windowBackgroundColor = 0xFF000000;
String windowBackgroundImage = '';
String windowBackgroundImageLayout = 'stretch';
String windowBackgroundImageAlignment = 'center';
bool isWindowImageEnabled = false;
bool isWindowTransparent = false;

  // View Settings (Dual Scripture)
  String dualScriptureAspectRatio = '16:9';
  double dualScriptureCustomWidth = 1920.0;
  double dualScriptureCustomHeight = 1080.0;

  int dualScriptureBackgroundColor = 0xFF000000;
  String dualScriptureBackgroundImage = '';
  String dualScriptureBackgroundImageLayout = 'stretch';
  String dualScriptureBackgroundImageAlignment = 'center';
  bool isDualScriptureImageEnabled = false;
  bool isDualScriptureTransparent = false;

  // Dual Scripture Layout Controls
  String dualScriptureLayoutDirection = 'topBottom'; // 'topBottom', 'sideBySide'
  String dualScripturePrimaryPosition = 'primaryFirst'; // 'primaryFirst', 'secondaryFirst'
  double dualScripturePrimaryRatio = 50.0; // 20.0 to 80.0

  // Chapter Settings (Dual Scripture)
  bool showDualChapter = true;
  String dualChapterAlignment = 'center';
  String dualChapterVerticalAlignment = 'bottom';
  double dualChapterFontSize = 24.0;
  String dualChapterFontFamily = 'Arial';
  int dualChapterFontColor = 0x8FFFFFFF; 
  bool dualChapterBold = true;
  bool dualChapterItalic = false;
  bool dualChapterUnderline = false;
  bool dualChapterHasFill = false;
  int dualChapterFillColor = 0x00000000;
  bool dualChapterHasStroke = false;
  int dualChapterStrokeColor = 0xFF000000;
  double dualChapterMarginTop = 16.0;
  double dualChapterMarginBottom = 16.0;
  double dualChapterMarginLeft = 16.0;
  double dualChapterMarginRight = 16.0;
  double dualChapterLineHeight = 1.2;
  double dualChapterStrokeWidth = 0.08;
  bool dualChapterHasShadow = false;
  int dualChapterShadowColor = 0xFF000000;
  double dualChapterShadowOffsetX = 2.0;
  double dualChapterShadowOffsetY = 2.0;
  double dualChapterShadowRadius = 4.0;

  // Primary Verse Settings (Dual Scripture)
  String primaryVerseAlignment = 'center';
  String primaryVerseVerticalAlignment = 'center';
  double primaryVerseFontSize = 60.0;
  String primaryVerseFontFamily = 'Arial';
  int primaryVerseFontColor = 0xFFFFFFFF;
  bool primaryVerseBold = true;
  bool primaryVerseItalic = false;
  bool primaryVerseUnderline = false;
  bool primaryVerseHasFill = false;
  int primaryVerseFillColor = 0x00000000;
  bool primaryVerseHasStroke = false;
  int primaryVerseStrokeColor = 0xFF000000;
  double primaryVerseMarginTop = 16.0;
  double primaryVerseMarginBottom = 16.0;
  double primaryVerseMarginLeft = 16.0;
  double primaryVerseMarginRight = 16.0;
  double primaryVerseLineHeight = 1.4;
  double primaryVerseStrokeWidth = 0.08;
  bool primaryVerseHasShadow = false;
  int primaryVerseShadowColor = 0xFF000000;
  double primaryVerseShadowOffsetX = 2.0;
  double primaryVerseShadowOffsetY = 2.0;
  double primaryVerseShadowRadius = 4.0;

  // Secondary Verse Settings (Dual Scripture)
  String secVerseAlignment = 'center';
  String secVerseVerticalAlignment = 'center';
  double secVerseFontSize = 60.0;
  String secVerseFontFamily = 'Arial';
  int secVerseFontColor = 0xFFFFFFFF;
  bool secVerseBold = true;
  bool secVerseItalic = false;
  bool secVerseUnderline = false;
  bool secVerseHasFill = false;
  int secVerseFillColor = 0x00000000;
  bool secVerseHasStroke = false;
  int secVerseStrokeColor = 0xFF000000;
  double secVerseMarginTop = 16.0;
  double secVerseMarginBottom = 16.0;
  double secVerseMarginLeft = 16.0;
  double secVerseMarginRight = 16.0;
  double secVerseLineHeight = 1.4;
  double secVerseStrokeWidth = 0.08;
  bool secVerseHasShadow = false;
  int secVerseShadowColor = 0xFF000000;
  double secVerseShadowOffsetX = 2.0;
  double secVerseShadowOffsetY = 2.0;
  double secVerseShadowRadius = 4.0;

  // Title Settings
  bool showTitle = true;
  String titleAlignment = 'center';
  String titleVerticalAlignment = 'bottom';
  double titleFontSize = 24.0;
  String titleFontFamily = 'Arial';
  int titleFontColor = 0x8FFFFFFF; 
  bool titleBold = true;
  bool titleItalic = false;
  bool titleUnderline = false;
  bool titleHasFill = false;
  int titleFillColor = 0x00000000;
  bool titleHasStroke = false;
  int titleStrokeColor = 0xFF000000;
  double titleMarginTop = 16.0;
  double titleMarginBottom = 16.0;
  double titleMarginLeft = 16.0;
  double titleMarginRight = 16.0;
  double titleLineHeight = 1.2;
  double titleStrokeWidth = 0.08;
  bool titleHasShadow = false;
  int titleShadowColor = 0xFF000000;
  double titleShadowOffsetX = 2.0;
  double titleShadowOffsetY = 2.0;
  double titleShadowRadius = 4.0;

  // Lyrics Settings
  String lyricsAlignment = 'center'; // 'left', 'center', 'right'
  String lyricsVerticalAlignment = 'center'; // 'top', 'center', 'bottom'
  double lyricsFontSize = 80.0;
  String lyricsFontFamily = 'Arial';
  int lyricsFontColor = 0xFFFFFFFF;
  bool lyricsBold = true;
  bool lyricsItalic = false;
  bool lyricsUnderline = false;
  bool lyricsHasFill = false;
  int lyricsFillColor = 0x00000000;
  bool lyricsHasStroke = false;
  int lyricsStrokeColor = 0xFF000000;
  double lyricsMarginTop = 32.0;
  double lyricsMarginBottom = 32.0;
  double lyricsMarginLeft = 32.0;
  double lyricsMarginRight = 32.0;
  bool lyricsLineBreak = false;
  double lyricsLineHeight = 1.4;
  double lyricsStrokeWidth = 0.08;
  bool lyricsHasShadow = false;
  int lyricsShadowColor = 0xFF000000;
  double lyricsShadowOffsetX = 2.0;
  double lyricsShadowOffsetY = 2.0;
  double lyricsShadowRadius = 4.0;

  // Chapter Settings (Bible)
  bool showChapter = true;
  String chapterAlignment = 'center';
  String chapterVerticalAlignment = 'bottom';
  double chapterFontSize = 24.0;
  String chapterFontFamily = 'Arial';
  int chapterFontColor = 0x8FFFFFFF; 
  bool chapterBold = true;
  bool chapterItalic = false;
  bool chapterUnderline = false;
  bool chapterHasFill = false;
  int chapterFillColor = 0x00000000;
  bool chapterHasStroke = false;
  int chapterStrokeColor = 0xFF000000;
  double chapterMarginTop = 16.0;
  double chapterMarginBottom = 16.0;
  double chapterMarginLeft = 16.0;
  double chapterMarginRight = 16.0;
  double chapterLineHeight = 1.2;
  double chapterStrokeWidth = 0.08;
  bool chapterHasShadow = false;
  int chapterShadowColor = 0xFF000000;
  double chapterShadowOffsetX = 2.0;
  double chapterShadowOffsetY = 2.0;
  double chapterShadowRadius = 4.0;

  // Verse Settings (Bible)
  String verseAlignment = 'center'; // 'left', 'center', 'right'
  String verseVerticalAlignment = 'center'; // 'top', 'center', 'bottom'
  double verseFontSize = 80.0;
  String verseFontFamily = 'Arial';
  int verseFontColor = 0xFFFFFFFF;
  bool verseBold = true;
  bool verseItalic = false;
  bool verseUnderline = false;
  bool verseHasFill = false;
  int verseFillColor = 0x00000000;
  bool verseHasStroke = false;
  int verseStrokeColor = 0xFF000000;
  double verseMarginTop = 32.0;
  double verseMarginBottom = 32.0;
  double verseMarginLeft = 32.0;
  double verseMarginRight = 32.0;
  double verseLineHeight = 1.4;
  double verseStrokeWidth = 0.08;
  bool verseHasShadow = false;
  int verseShadowColor = 0xFF000000;
  double verseShadowOffsetX = 2.0;
  double verseShadowOffsetY = 2.0;
  double verseShadowRadius = 4.0;

  PresentationSettings sanitize() {
    // Numbers / Doubles Fallback
    if (!songCustomWidth.isFinite || songCustomWidth <= 0) songCustomWidth = 1920.0;
    if (!songCustomHeight.isFinite || songCustomHeight <= 0) songCustomHeight = 1080.0;
    if (!scriptureCustomWidth.isFinite || scriptureCustomWidth <= 0) scriptureCustomWidth = 1920.0;
    if (!scriptureCustomHeight.isFinite || scriptureCustomHeight <= 0) scriptureCustomHeight = 1080.0;
    if (!dualScriptureCustomWidth.isFinite || dualScriptureCustomWidth <= 0) dualScriptureCustomWidth = 1920.0;
    if (!dualScriptureCustomHeight.isFinite || dualScriptureCustomHeight <= 0) dualScriptureCustomHeight = 1080.0;
    if (!blankCustomWidth.isFinite || blankCustomWidth <= 0) blankCustomWidth = 1920.0;
    if (!blankCustomHeight.isFinite || blankCustomHeight <= 0) blankCustomHeight = 1080.0;
    if (!windowCustomWidth.isFinite || windowCustomWidth <= 0) windowCustomWidth = 1920.0;
    if (!windowCustomHeight.isFinite || windowCustomHeight <= 0) windowCustomHeight = 1080.0;

    if (!dualScripturePrimaryRatio.isFinite || dualScripturePrimaryRatio < 20.0 || dualScripturePrimaryRatio > 80.0) {
      dualScripturePrimaryRatio = 50.0;
    }

    if (!titleFontSize.isFinite || titleFontSize <= 0) titleFontSize = 24.0;
    if (!titleLineHeight.isFinite || titleLineHeight <= 0) titleLineHeight = 1.2;
    if (!titleStrokeWidth.isFinite || titleStrokeWidth <= 0) titleStrokeWidth = 0.08;
    if (!titleShadowOffsetX.isFinite) titleShadowOffsetX = 2.0;
    if (!titleShadowOffsetY.isFinite) titleShadowOffsetY = 2.0;
    if (!titleShadowRadius.isFinite || titleShadowRadius < 0) titleShadowRadius = 4.0;
    if (!titleMarginTop.isFinite || titleMarginTop < 0) titleMarginTop = 16.0;
    if (!titleMarginBottom.isFinite || titleMarginBottom < 0) titleMarginBottom = 16.0;
    if (!titleMarginLeft.isFinite || titleMarginLeft < 0) titleMarginLeft = 16.0;
    if (!titleMarginRight.isFinite || titleMarginRight < 0) titleMarginRight = 16.0;

    if (!lyricsFontSize.isFinite || lyricsFontSize <= 0) lyricsFontSize = 80.0;
    if (!lyricsLineHeight.isFinite || lyricsLineHeight <= 0) lyricsLineHeight = 1.4;
    if (!lyricsStrokeWidth.isFinite || lyricsStrokeWidth <= 0) lyricsStrokeWidth = 0.08;
    if (!lyricsShadowOffsetX.isFinite) lyricsShadowOffsetX = 2.0;
    if (!lyricsShadowOffsetY.isFinite) lyricsShadowOffsetY = 2.0;
    if (!lyricsShadowRadius.isFinite || lyricsShadowRadius < 0) lyricsShadowRadius = 4.0;
    if (!lyricsMarginTop.isFinite || lyricsMarginTop < 0) lyricsMarginTop = 32.0;
    if (!lyricsMarginBottom.isFinite || lyricsMarginBottom < 0) lyricsMarginBottom = 32.0;
    if (!lyricsMarginLeft.isFinite || lyricsMarginLeft < 0) lyricsMarginLeft = 32.0;
    if (!lyricsMarginRight.isFinite || lyricsMarginRight < 0) lyricsMarginRight = 32.0;

    if (!chapterFontSize.isFinite || chapterFontSize <= 0) chapterFontSize = 24.0;
    if (!chapterLineHeight.isFinite || chapterLineHeight <= 0) chapterLineHeight = 1.2;
    if (!chapterStrokeWidth.isFinite || chapterStrokeWidth <= 0) chapterStrokeWidth = 0.08;
    if (!chapterShadowOffsetX.isFinite) chapterShadowOffsetX = 2.0;
    if (!chapterShadowOffsetY.isFinite) chapterShadowOffsetY = 2.0;
    if (!chapterShadowRadius.isFinite || chapterShadowRadius < 0) chapterShadowRadius = 4.0;
    if (!chapterMarginTop.isFinite || chapterMarginTop < 0) chapterMarginTop = 16.0;
    if (!chapterMarginBottom.isFinite || chapterMarginBottom < 0) chapterMarginBottom = 16.0;
    if (!chapterMarginLeft.isFinite || chapterMarginLeft < 0) chapterMarginLeft = 16.0;
    if (!chapterMarginRight.isFinite || chapterMarginRight < 0) chapterMarginRight = 16.0;

    if (!verseFontSize.isFinite || verseFontSize <= 0) verseFontSize = 80.0;
    if (!verseLineHeight.isFinite || verseLineHeight <= 0) verseLineHeight = 1.4;
    if (!verseStrokeWidth.isFinite || verseStrokeWidth <= 0) verseStrokeWidth = 0.08;
    if (!verseShadowOffsetX.isFinite) verseShadowOffsetX = 2.0;
    if (!verseShadowOffsetY.isFinite) verseShadowOffsetY = 2.0;
    if (!verseShadowRadius.isFinite || verseShadowRadius < 0) verseShadowRadius = 4.0;
    if (!verseMarginTop.isFinite || verseMarginTop < 0) verseMarginTop = 32.0;
    if (!verseMarginBottom.isFinite || verseMarginBottom < 0) verseMarginBottom = 32.0;
    if (!verseMarginLeft.isFinite || verseMarginLeft < 0) verseMarginLeft = 32.0;
    if (!verseMarginRight.isFinite || verseMarginRight < 0) verseMarginRight = 32.0;

    if (!dualChapterFontSize.isFinite || dualChapterFontSize <= 0) dualChapterFontSize = 24.0;
    if (!dualChapterLineHeight.isFinite || dualChapterLineHeight <= 0) dualChapterLineHeight = 1.2;
    if (!dualChapterStrokeWidth.isFinite || dualChapterStrokeWidth <= 0) dualChapterStrokeWidth = 0.08;
    if (!dualChapterShadowOffsetX.isFinite) dualChapterShadowOffsetX = 2.0;
    if (!dualChapterShadowOffsetY.isFinite) dualChapterShadowOffsetY = 2.0;
    if (!dualChapterShadowRadius.isFinite || dualChapterShadowRadius < 0) dualChapterShadowRadius = 4.0;
    if (!dualChapterMarginTop.isFinite || dualChapterMarginTop < 0) dualChapterMarginTop = 16.0;
    if (!dualChapterMarginBottom.isFinite || dualChapterMarginBottom < 0) dualChapterMarginBottom = 16.0;
    if (!dualChapterMarginLeft.isFinite || dualChapterMarginLeft < 0) dualChapterMarginLeft = 16.0;
    if (!dualChapterMarginRight.isFinite || dualChapterMarginRight < 0) dualChapterMarginRight = 16.0;

    if (!primaryVerseFontSize.isFinite || primaryVerseFontSize <= 0) primaryVerseFontSize = 60.0;
    if (!primaryVerseLineHeight.isFinite || primaryVerseLineHeight <= 0) primaryVerseLineHeight = 1.4;
    if (!primaryVerseStrokeWidth.isFinite || primaryVerseStrokeWidth <= 0) primaryVerseStrokeWidth = 0.08;
    if (!primaryVerseShadowOffsetX.isFinite) primaryVerseShadowOffsetX = 2.0;
    if (!primaryVerseShadowOffsetY.isFinite) primaryVerseShadowOffsetY = 2.0;
    if (!primaryVerseShadowRadius.isFinite || primaryVerseShadowRadius < 0) primaryVerseShadowRadius = 4.0;
    if (!primaryVerseMarginTop.isFinite || primaryVerseMarginTop < 0) primaryVerseMarginTop = 16.0;
    if (!primaryVerseMarginBottom.isFinite || primaryVerseMarginBottom < 0) primaryVerseMarginBottom = 16.0;
    if (!primaryVerseMarginLeft.isFinite || primaryVerseMarginLeft < 0) primaryVerseMarginLeft = 16.0;
    if (!primaryVerseMarginRight.isFinite || primaryVerseMarginRight < 0) primaryVerseMarginRight = 16.0;

    if (!secVerseFontSize.isFinite || secVerseFontSize <= 0) secVerseFontSize = 60.0;
    if (!secVerseLineHeight.isFinite || secVerseLineHeight <= 0) secVerseLineHeight = 1.4;
    if (!secVerseStrokeWidth.isFinite || secVerseStrokeWidth <= 0) secVerseStrokeWidth = 0.08;
    if (!secVerseShadowOffsetX.isFinite) secVerseShadowOffsetX = 2.0;
    if (!secVerseShadowOffsetY.isFinite) secVerseShadowOffsetY = 2.0;
    if (!secVerseShadowRadius.isFinite || secVerseShadowRadius < 0) secVerseShadowRadius = 4.0;
    if (!secVerseMarginTop.isFinite || secVerseMarginTop < 0) secVerseMarginTop = 16.0;
    if (!secVerseMarginBottom.isFinite || secVerseMarginBottom < 0) secVerseMarginBottom = 16.0;
    if (!secVerseMarginLeft.isFinite || secVerseMarginLeft < 0) secVerseMarginLeft = 16.0;
    if (!secVerseMarginRight.isFinite || secVerseMarginRight < 0) secVerseMarginRight = 16.0;

    // Strings Fallback
    if (presetName.isEmpty) {
      presetName = (isDefault || id == 1) ? 'Default' : 'Preset $id';
    }
    if (presetName == 'Default') {
      isDefault = true;
    }

    if (songAspectRatio.isEmpty) songAspectRatio = '16:9';
    if (scriptureAspectRatio.isEmpty) scriptureAspectRatio = '16:9';
    if (dualScriptureAspectRatio.isEmpty) dualScriptureAspectRatio = '16:9';
    if (blankAspectRatio.isEmpty) blankAspectRatio = '16:9';
    if (windowAspectRatio.isEmpty) windowAspectRatio = '16:9';
    if (dualScriptureLayoutDirection.isEmpty) dualScriptureLayoutDirection = 'topBottom';
    if (dualScripturePrimaryPosition.isEmpty) dualScripturePrimaryPosition = 'primaryFirst';

    if (titleAlignment.isEmpty) titleAlignment = 'center';
    if (titleVerticalAlignment.isEmpty) titleVerticalAlignment = 'bottom';
    if (chapterAlignment.isEmpty) chapterAlignment = 'center';
    if (chapterVerticalAlignment.isEmpty) chapterVerticalAlignment = 'bottom';
    if (verseAlignment.isEmpty) verseAlignment = 'center';
    if (verseVerticalAlignment.isEmpty) verseVerticalAlignment = 'center';
    if (dualChapterAlignment.isEmpty) dualChapterAlignment = 'center';
    if (dualChapterVerticalAlignment.isEmpty) dualChapterVerticalAlignment = 'bottom';
    if (primaryVerseAlignment.isEmpty) primaryVerseAlignment = 'center';
    if (primaryVerseVerticalAlignment.isEmpty) primaryVerseVerticalAlignment = 'center';
    if (secVerseAlignment.isEmpty) secVerseAlignment = 'center';
    if (secVerseVerticalAlignment.isEmpty) secVerseVerticalAlignment = 'center';
    if (lyricsAlignment.isEmpty) lyricsAlignment = 'center';
    if (lyricsVerticalAlignment.isEmpty) lyricsVerticalAlignment = 'center';
    if (chapterFontFamily.isEmpty) chapterFontFamily = 'Arial';
    if (verseFontFamily.isEmpty) verseFontFamily = 'Arial';
    if (dualChapterFontFamily.isEmpty) dualChapterFontFamily = 'Arial';
    if (primaryVerseFontFamily.isEmpty) primaryVerseFontFamily = 'Arial';
    if (secVerseFontFamily.isEmpty) secVerseFontFamily = 'Arial';
    if (lyricsFontFamily.isEmpty) lyricsFontFamily = 'Arial';
    if (titleFontFamily.isEmpty) titleFontFamily = 'Arial';

    if (songBackgroundImageLayout.isEmpty) songBackgroundImageLayout = 'stretch';
    if (songBackgroundImageAlignment.isEmpty) songBackgroundImageAlignment = 'center';
    if (scriptureBackgroundImageLayout.isEmpty) scriptureBackgroundImageLayout = 'stretch';
    if (scriptureBackgroundImageAlignment.isEmpty) scriptureBackgroundImageAlignment = 'center';
    if (dualScriptureBackgroundImageLayout.isEmpty) dualScriptureBackgroundImageLayout = 'stretch';
    if (dualScriptureBackgroundImageAlignment.isEmpty) dualScriptureBackgroundImageAlignment = 'center';
    if (blankBackgroundImageLayout.isEmpty) blankBackgroundImageLayout = 'stretch';
    if (blankBackgroundImageAlignment.isEmpty) blankBackgroundImageAlignment = 'center';
    if (windowBackgroundImageLayout.isEmpty) windowBackgroundImageLayout = 'stretch';
    if (windowBackgroundImageAlignment.isEmpty) windowBackgroundImageAlignment = 'center';

    if (songBackgroundColor == 0) songBackgroundColor = 0xFF000000;
    if (scriptureBackgroundColor == 0) scriptureBackgroundColor = 0xFF000000;
    if (dualScriptureBackgroundColor == 0) dualScriptureBackgroundColor = 0xFF000000;
    if (blankBackgroundColor == 0) blankBackgroundColor = 0xFF000000;
    if (windowBackgroundColor == 0) windowBackgroundColor = 0xFF000000;
    if ((lyricsFontColor & 0xFF000000) == 0) lyricsFontColor = 0xFFFFFFFF;
    if ((titleFontColor & 0xFF000000) == 0) titleFontColor = 0x8FFFFFFF;
    if ((chapterFontColor & 0xFF000000) == 0) chapterFontColor = 0x8FFFFFFF;
    if ((verseFontColor & 0xFF000000) == 0) verseFontColor = 0xFFFFFFFF;
    if ((dualChapterFontColor & 0xFF000000) == 0) dualChapterFontColor = 0x8FFFFFFF;
    if ((primaryVerseFontColor & 0xFF000000) == 0) primaryVerseFontColor = 0xFFFFFFFF;
    if ((secVerseFontColor & 0xFF000000) == 0) secVerseFontColor = 0xFFFFFFFF;

    return this;
  }

  Map<String, dynamic> toMap() {
    sanitize();
    return {
      'id': id,
      'syncId': syncId,
      'presetName': presetName,
      'isDefault': isDefault,
      'songAspectRatio': songAspectRatio,
      'songCustomWidth': songCustomWidth,
      'songCustomHeight': songCustomHeight,
      'scriptureAspectRatio': scriptureAspectRatio,
      'scriptureCustomWidth': scriptureCustomWidth,
      'scriptureCustomHeight': scriptureCustomHeight,
      'dualScriptureAspectRatio': dualScriptureAspectRatio,
      'dualScriptureCustomWidth': dualScriptureCustomWidth,
      'dualScriptureCustomHeight': dualScriptureCustomHeight,
      'songBackgroundColor': songBackgroundColor,
      'songBackgroundImage': songBackgroundImage,
      'songBackgroundImageLayout': songBackgroundImageLayout,
      'songBackgroundImageAlignment': songBackgroundImageAlignment,
      'isSongImageEnabled': isSongImageEnabled,
      'isSongTransparent': isSongTransparent,
      'scriptureBackgroundColor': scriptureBackgroundColor,
      'scriptureBackgroundImage': scriptureBackgroundImage,
      'scriptureBackgroundImageLayout': scriptureBackgroundImageLayout,
      'scriptureBackgroundImageAlignment': scriptureBackgroundImageAlignment,
      'isScriptureImageEnabled': isScriptureImageEnabled,
      'isScriptureTransparent': isScriptureTransparent,
      'dualScriptureBackgroundColor': dualScriptureBackgroundColor,
      'dualScriptureBackgroundImage': dualScriptureBackgroundImage,
      'dualScriptureBackgroundImageLayout': dualScriptureBackgroundImageLayout,
      'dualScriptureBackgroundImageAlignment': dualScriptureBackgroundImageAlignment,
      'isDualScriptureImageEnabled': isDualScriptureImageEnabled,
      'isDualScriptureTransparent': isDualScriptureTransparent,
      'dualScriptureLayoutDirection': dualScriptureLayoutDirection,
      'dualScripturePrimaryPosition': dualScripturePrimaryPosition,
      'dualScripturePrimaryRatio': dualScripturePrimaryRatio,
      'blankAspectRatio': blankAspectRatio,
      'blankCustomWidth': blankCustomWidth,
      'blankCustomHeight': blankCustomHeight,
      'blankBackgroundColor': blankBackgroundColor,
      'blankBackgroundImage': blankBackgroundImage,
      'blankBackgroundImageLayout': blankBackgroundImageLayout,
      'blankBackgroundImageAlignment': blankBackgroundImageAlignment,
      'isBlankImageEnabled': isBlankImageEnabled,
      'isBlankTransparent': isBlankTransparent,
      'windowAspectRatio': windowAspectRatio,
      'windowCustomWidth': windowCustomWidth,
      'windowCustomHeight': windowCustomHeight,
      'windowBackgroundColor': windowBackgroundColor,
      'windowBackgroundImage': windowBackgroundImage,
      'windowBackgroundImageLayout': windowBackgroundImageLayout,
      'windowBackgroundImageAlignment': windowBackgroundImageAlignment,
      'isWindowImageEnabled': isWindowImageEnabled,
      'isWindowTransparent': isWindowTransparent,
      'showTitle': showTitle,
      'titleAlignment': titleAlignment,
      'titleVerticalAlignment': titleVerticalAlignment,
      'titleFontSize': titleFontSize,
      'titleFontFamily': titleFontFamily,
      'titleFontColor': titleFontColor,
      'titleBold': titleBold,
      'titleItalic': titleItalic,
      'titleUnderline': titleUnderline,
      'titleHasFill': titleHasFill,
      'titleFillColor': titleFillColor,
      'titleHasStroke': titleHasStroke,
      'titleStrokeColor': titleStrokeColor,
      'titleLineHeight': titleLineHeight,
      'titleStrokeWidth': titleStrokeWidth,
      'titleHasShadow': titleHasShadow,
      'titleShadowColor': titleShadowColor,
      'titleShadowOffsetX': titleShadowOffsetX,
      'titleShadowOffsetY': titleShadowOffsetY,
      'titleShadowRadius': titleShadowRadius,
      'titleMarginTop': titleMarginTop,
      'titleMarginBottom': titleMarginBottom,
      'titleMarginLeft': titleMarginLeft,
      'titleMarginRight': titleMarginRight,
      'lyricsAlignment': lyricsAlignment,
      'lyricsVerticalAlignment': lyricsVerticalAlignment,
      'lyricsFontSize': lyricsFontSize,
      'lyricsFontFamily': lyricsFontFamily,
      'lyricsFontColor': lyricsFontColor,
      'lyricsBold': lyricsBold,
      'lyricsItalic': lyricsItalic,
      'lyricsUnderline': lyricsUnderline,
      'lyricsHasFill': lyricsHasFill,
      'lyricsFillColor': lyricsFillColor,
      'lyricsHasStroke': lyricsHasStroke,
      'lyricsStrokeColor': lyricsStrokeColor,
      'lyricsLineHeight': lyricsLineHeight,
      'lyricsStrokeWidth': lyricsStrokeWidth,
      'lyricsHasShadow': lyricsHasShadow,
      'lyricsShadowColor': lyricsShadowColor,
      'lyricsShadowOffsetX': lyricsShadowOffsetX,
      'lyricsShadowOffsetY': lyricsShadowOffsetY,
      'lyricsShadowRadius': lyricsShadowRadius,
      'lyricsMarginTop': lyricsMarginTop,
      'lyricsMarginBottom': lyricsMarginBottom,
      'lyricsMarginLeft': lyricsMarginLeft,
      'lyricsMarginRight': lyricsMarginRight,
      'lyricsLineBreak': lyricsLineBreak,
      'showChapter': showChapter,
      'chapterAlignment': chapterAlignment,
      'chapterVerticalAlignment': chapterVerticalAlignment,
      'chapterFontSize': chapterFontSize,
      'chapterFontFamily': chapterFontFamily,
      'chapterFontColor': chapterFontColor,
      'chapterBold': chapterBold,
      'chapterItalic': chapterItalic,
      'chapterUnderline': chapterUnderline,
      'chapterHasFill': chapterHasFill,
      'chapterFillColor': chapterFillColor,
      'chapterHasStroke': chapterHasStroke,
      'chapterStrokeColor': chapterStrokeColor,
      'chapterLineHeight': chapterLineHeight,
      'chapterStrokeWidth': chapterStrokeWidth,
      'chapterHasShadow': chapterHasShadow,
      'chapterShadowColor': chapterShadowColor,
      'chapterShadowOffsetX': chapterShadowOffsetX,
      'chapterShadowOffsetY': chapterShadowOffsetY,
      'chapterShadowRadius': chapterShadowRadius,
      'chapterMarginTop': chapterMarginTop,
      'chapterMarginBottom': chapterMarginBottom,
      'chapterMarginLeft': chapterMarginLeft,
      'chapterMarginRight': chapterMarginRight,
      'verseAlignment': verseAlignment,
      'verseVerticalAlignment': verseVerticalAlignment,
      'verseFontSize': verseFontSize,
      'verseFontFamily': verseFontFamily,
      'verseFontColor': verseFontColor,
      'verseBold': verseBold,
      'verseItalic': verseItalic,
      'verseUnderline': verseUnderline,
      'verseHasFill': verseHasFill,
      'verseFillColor': verseFillColor,
      'verseHasStroke': verseHasStroke,
      'verseStrokeColor': verseStrokeColor,
      'verseLineHeight': verseLineHeight,
      'verseStrokeWidth': verseStrokeWidth,
      'verseHasShadow': verseHasShadow,
      'verseShadowColor': verseShadowColor,
      'verseShadowOffsetX': verseShadowOffsetX,
      'verseShadowOffsetY': verseShadowOffsetY,
      'verseShadowRadius': verseShadowRadius,
      'verseMarginTop': verseMarginTop,
      'verseMarginBottom': verseMarginBottom,
      'verseMarginLeft': verseMarginLeft,
      'verseMarginRight': verseMarginRight,
      'showDualChapter': showDualChapter,
      'dualChapterAlignment': dualChapterAlignment,
      'dualChapterVerticalAlignment': dualChapterVerticalAlignment,
      'dualChapterFontSize': dualChapterFontSize,
      'dualChapterFontFamily': dualChapterFontFamily,
      'dualChapterFontColor': dualChapterFontColor,
      'dualChapterBold': dualChapterBold,
      'dualChapterItalic': dualChapterItalic,
      'dualChapterUnderline': dualChapterUnderline,
      'dualChapterHasFill': dualChapterHasFill,
      'dualChapterFillColor': dualChapterFillColor,
      'dualChapterHasStroke': dualChapterHasStroke,
      'dualChapterStrokeColor': dualChapterStrokeColor,
      'dualChapterLineHeight': dualChapterLineHeight,
      'dualChapterStrokeWidth': dualChapterStrokeWidth,
      'dualChapterHasShadow': dualChapterHasShadow,
      'dualChapterShadowColor': dualChapterShadowColor,
      'dualChapterShadowOffsetX': dualChapterShadowOffsetX,
      'dualChapterShadowOffsetY': dualChapterShadowOffsetY,
      'dualChapterShadowRadius': dualChapterShadowRadius,
      'dualChapterMarginTop': dualChapterMarginTop,
      'dualChapterMarginBottom': dualChapterMarginBottom,
      'dualChapterMarginLeft': dualChapterMarginLeft,
      'dualChapterMarginRight': dualChapterMarginRight,
      'primaryVerseAlignment': primaryVerseAlignment,
      'primaryVerseVerticalAlignment': primaryVerseVerticalAlignment,
      'primaryVerseFontSize': primaryVerseFontSize,
      'primaryVerseFontFamily': primaryVerseFontFamily,
      'primaryVerseFontColor': primaryVerseFontColor,
      'primaryVerseBold': primaryVerseBold,
      'primaryVerseItalic': primaryVerseItalic,
      'primaryVerseUnderline': primaryVerseUnderline,
      'primaryVerseHasFill': primaryVerseHasFill,
      'primaryVerseFillColor': primaryVerseFillColor,
      'primaryVerseHasStroke': primaryVerseHasStroke,
      'primaryVerseStrokeColor': primaryVerseStrokeColor,
      'primaryVerseLineHeight': primaryVerseLineHeight,
      'primaryVerseStrokeWidth': primaryVerseStrokeWidth,
      'primaryVerseHasShadow': primaryVerseHasShadow,
      'primaryVerseShadowColor': primaryVerseShadowColor,
      'primaryVerseShadowOffsetX': primaryVerseShadowOffsetX,
      'primaryVerseShadowOffsetY': primaryVerseShadowOffsetY,
      'primaryVerseShadowRadius': primaryVerseShadowRadius,
      'primaryVerseMarginTop': primaryVerseMarginTop,
      'primaryVerseMarginBottom': primaryVerseMarginBottom,
      'primaryVerseMarginLeft': primaryVerseMarginLeft,
      'primaryVerseMarginRight': primaryVerseMarginRight,
      'secVerseAlignment': secVerseAlignment,
      'secVerseVerticalAlignment': secVerseVerticalAlignment,
      'secVerseFontSize': secVerseFontSize,
      'secVerseFontFamily': secVerseFontFamily,
      'secVerseFontColor': secVerseFontColor,
      'secVerseBold': secVerseBold,
      'secVerseItalic': secVerseItalic,
      'secVerseUnderline': secVerseUnderline,
      'secVerseHasFill': secVerseHasFill,
      'secVerseFillColor': secVerseFillColor,
      'secVerseHasStroke': secVerseHasStroke,
      'secVerseStrokeColor': secVerseStrokeColor,
      'secVerseLineHeight': secVerseLineHeight,
      'secVerseStrokeWidth': secVerseStrokeWidth,
      'secVerseHasShadow': secVerseHasShadow,
      'secVerseShadowColor': secVerseShadowColor,
      'secVerseShadowOffsetX': secVerseShadowOffsetX,
      'secVerseShadowOffsetY': secVerseShadowOffsetY,
      'secVerseShadowRadius': secVerseShadowRadius,
      'secVerseMarginTop': secVerseMarginTop,
      'secVerseMarginBottom': secVerseMarginBottom,
      'secVerseMarginLeft': secVerseMarginLeft,
      'secVerseMarginRight': secVerseMarginRight,
    };
  }

  static PresentationSettings fromMap(Map<String, dynamic> map) {
    final settings = PresentationSettings()
      ..id = map['id'] as int? ?? Isar.autoIncrement
      ..syncId = map['syncId'] as String? ?? const Uuid().v4()
      ..presetName = map['presetName'] as String? ?? 'Default'
      ..isDefault = map['isDefault'] as bool? ?? false
      ..songAspectRatio = map['songAspectRatio'] as String? ?? '16:9'
      ..songCustomWidth = (map['songCustomWidth'] as num?)?.toDouble() ?? 1920.0
      ..songCustomHeight = (map['songCustomHeight'] as num?)?.toDouble() ?? 1080.0
      ..scriptureAspectRatio = map['scriptureAspectRatio'] as String? ?? '16:9'
      ..scriptureCustomWidth = (map['scriptureCustomWidth'] as num?)?.toDouble() ?? 1920.0
      ..scriptureCustomHeight = (map['scriptureCustomHeight'] as num?)?.toDouble() ?? 1080.0
      ..dualScriptureAspectRatio = map['dualScriptureAspectRatio'] as String? ?? '16:9'
      ..dualScriptureCustomWidth = (map['dualScriptureCustomWidth'] as num?)?.toDouble() ?? 1920.0
      ..dualScriptureCustomHeight = (map['dualScriptureCustomHeight'] as num?)?.toDouble() ?? 1080.0
      ..songBackgroundColor = map['songBackgroundColor'] as int? ?? 0xFF000000
      ..songBackgroundImage = map['songBackgroundImage'] as String? ?? ''
      ..songBackgroundImageLayout = map['songBackgroundImageLayout'] as String? ?? 'stretch'
      ..songBackgroundImageAlignment = map['songBackgroundImageAlignment'] as String? ?? 'center'
      ..isSongImageEnabled = map['isSongImageEnabled'] as bool? ?? false
      ..isSongTransparent = map['isSongTransparent'] as bool? ?? false
      ..scriptureBackgroundColor = map['scriptureBackgroundColor'] as int? ?? 0xFF000000
      ..scriptureBackgroundImage = map['scriptureBackgroundImage'] as String? ?? ''
      ..scriptureBackgroundImageLayout = map['scriptureBackgroundImageLayout'] as String? ?? 'stretch'
      ..scriptureBackgroundImageAlignment = map['scriptureBackgroundImageAlignment'] as String? ?? 'center'
      ..isScriptureImageEnabled = map['isScriptureImageEnabled'] as bool? ?? false
      ..isScriptureTransparent = map['isScriptureTransparent'] as bool? ?? false
      ..dualScriptureBackgroundColor = map['dualScriptureBackgroundColor'] as int? ?? 0xFF000000
      ..dualScriptureBackgroundImage = map['dualScriptureBackgroundImage'] as String? ?? ''
      ..dualScriptureBackgroundImageLayout = map['dualScriptureBackgroundImageLayout'] as String? ?? 'stretch'
      ..dualScriptureBackgroundImageAlignment = map['dualScriptureBackgroundImageAlignment'] as String? ?? 'center'
      ..isDualScriptureImageEnabled = map['isDualScriptureImageEnabled'] as bool? ?? false
      ..isDualScriptureTransparent = map['isDualScriptureTransparent'] as bool? ?? false
      ..dualScriptureLayoutDirection = map['dualScriptureLayoutDirection'] as String? ?? 'topBottom'
      ..dualScripturePrimaryPosition = map['dualScripturePrimaryPosition'] as String? ?? 'primaryFirst'
      ..dualScripturePrimaryRatio = (map['dualScripturePrimaryRatio'] as num?)?.toDouble() ?? 50.0
      ..blankAspectRatio = map['blankAspectRatio'] as String? ?? '16:9'
      ..blankCustomWidth = (map['blankCustomWidth'] as num?)?.toDouble() ?? 1920.0
      ..blankCustomHeight = (map['blankCustomHeight'] as num?)?.toDouble() ?? 1080.0
      ..blankBackgroundColor = map['blankBackgroundColor'] as int? ?? 0xFF000000
      ..blankBackgroundImage = map['blankBackgroundImage'] as String? ?? ''
      ..blankBackgroundImageLayout = map['blankBackgroundImageLayout'] as String? ?? 'stretch'
      ..blankBackgroundImageAlignment = map['blankBackgroundImageAlignment'] as String? ?? 'center'
      ..isBlankImageEnabled = map['isBlankImageEnabled'] as bool? ?? false
      ..isBlankTransparent = map['isBlankTransparent'] as bool? ?? false
      ..windowAspectRatio = map['windowAspectRatio'] as String? ?? '16:9'
      ..windowCustomWidth = (map['windowCustomWidth'] as num?)?.toDouble() ?? 1920.0
      ..windowCustomHeight = (map['windowCustomHeight'] as num?)?.toDouble() ?? 1080.0
      ..windowBackgroundColor = map['windowBackgroundColor'] as int? ?? 0xFF000000
      ..windowBackgroundImage = map['windowBackgroundImage'] as String? ?? ''
      ..windowBackgroundImageLayout = map['windowBackgroundImageLayout'] as String? ?? 'stretch'
      ..windowBackgroundImageAlignment = map['windowBackgroundImageAlignment'] as String? ?? 'center'
      ..isWindowImageEnabled = map['isWindowImageEnabled'] as bool? ?? false
      ..isWindowTransparent = map['isWindowTransparent'] as bool? ?? false
      ..showTitle = map['showTitle'] as bool? ?? true
      ..titleAlignment = map['titleAlignment'] as String? ?? 'center'
      ..titleVerticalAlignment = map['titleVerticalAlignment'] as String? ?? 'bottom'
      ..titleFontSize = (map['titleFontSize'] as num?)?.toDouble() ?? 24.0
      ..titleFontFamily = map['titleFontFamily'] as String? ?? 'Arial'
      ..titleFontColor = map['titleFontColor'] as int? ?? 0x8FFFFFFF
      ..titleBold = map['titleBold'] as bool? ?? true
      ..titleItalic = map['titleItalic'] as bool? ?? false
      ..titleUnderline = map['titleUnderline'] as bool? ?? false
      ..titleHasFill = map['titleHasFill'] as bool? ?? false
      ..titleFillColor = map['titleFillColor'] as int? ?? 0x00000000
      ..titleHasStroke = map['titleHasStroke'] as bool? ?? false
      ..titleStrokeColor = map['titleStrokeColor'] as int? ?? 0xFF000000
      ..titleLineHeight = (map['titleLineHeight'] as num?)?.toDouble() ?? 1.2
      ..titleStrokeWidth = (map['titleStrokeWidth'] as num?)?.toDouble() ?? 0.08
      ..titleHasShadow = map['titleHasShadow'] as bool? ?? false
      ..titleShadowColor = map['titleShadowColor'] as int? ?? 0xFF000000
      ..titleShadowOffsetX = (map['titleShadowOffsetX'] as num?)?.toDouble() ?? 2.0
      ..titleShadowOffsetY = (map['titleShadowOffsetY'] as num?)?.toDouble() ?? 2.0
      ..titleShadowRadius = (map['titleShadowRadius'] as num?)?.toDouble() ?? 4.0
      ..titleMarginTop = (map['titleMarginTop'] as num?)?.toDouble() ?? 16.0
      ..titleMarginBottom = (map['titleMarginBottom'] as num?)?.toDouble() ?? 16.0
      ..titleMarginLeft = (map['titleMarginLeft'] as num?)?.toDouble() ?? 16.0
      ..titleMarginRight = (map['titleMarginRight'] as num?)?.toDouble() ?? 16.0
      ..lyricsAlignment = map['lyricsAlignment'] as String? ?? 'center'
      ..lyricsVerticalAlignment = map['lyricsVerticalAlignment'] as String? ?? 'center'
      ..lyricsFontSize = (map['lyricsFontSize'] as num?)?.toDouble() ?? 80.0
      ..lyricsFontFamily = map['lyricsFontFamily'] as String? ?? 'Arial'
      ..lyricsFontColor = map['lyricsFontColor'] as int? ?? 0xFFFFFFFF
      ..lyricsBold = map['lyricsBold'] as bool? ?? true
      ..lyricsItalic = map['lyricsItalic'] as bool? ?? false
      ..lyricsUnderline = map['lyricsUnderline'] as bool? ?? false
      ..lyricsHasFill = map['lyricsHasFill'] as bool? ?? false
      ..lyricsFillColor = map['lyricsFillColor'] as int? ?? 0x00000000
      ..lyricsHasStroke = map['lyricsHasStroke'] as bool? ?? false
      ..lyricsStrokeColor = map['lyricsStrokeColor'] as int? ?? 0xFF000000
      ..lyricsLineHeight = (map['lyricsLineHeight'] as num?)?.toDouble() ?? 1.4
      ..lyricsStrokeWidth = (map['lyricsStrokeWidth'] as num?)?.toDouble() ?? 0.08
      ..lyricsHasShadow = map['lyricsHasShadow'] as bool? ?? false
      ..lyricsShadowColor = map['lyricsShadowColor'] as int? ?? 0xFF000000
      ..lyricsShadowOffsetX = (map['lyricsShadowOffsetX'] as num?)?.toDouble() ?? 2.0
      ..lyricsShadowOffsetY = (map['lyricsShadowOffsetY'] as num?)?.toDouble() ?? 2.0
      ..lyricsShadowRadius = (map['lyricsShadowRadius'] as num?)?.toDouble() ?? 4.0
      ..lyricsMarginTop = (map['lyricsMarginTop'] as num?)?.toDouble() ?? 32.0
      ..lyricsMarginBottom = (map['lyricsMarginBottom'] as num?)?.toDouble() ?? 32.0
      ..lyricsMarginLeft = (map['lyricsMarginLeft'] as num?)?.toDouble() ?? 32.0
      ..lyricsMarginRight = (map['lyricsMarginRight'] as num?)?.toDouble() ?? 32.0
      ..lyricsLineBreak = map['lyricsLineBreak'] as bool? ?? false
      ..showChapter = map['showChapter'] as bool? ?? true
      ..chapterAlignment = map['chapterAlignment'] as String? ?? 'center'
      ..chapterVerticalAlignment = map['chapterVerticalAlignment'] as String? ?? 'bottom'
      ..chapterFontSize = (map['chapterFontSize'] as num?)?.toDouble() ?? 24.0
      ..chapterFontFamily = map['chapterFontFamily'] as String? ?? 'Arial'
      ..chapterFontColor = map['chapterFontColor'] as int? ?? 0x8FFFFFFF
      ..chapterBold = map['chapterBold'] as bool? ?? true
      ..chapterItalic = map['chapterItalic'] as bool? ?? false
      ..chapterUnderline = map['chapterUnderline'] as bool? ?? false
      ..chapterHasFill = map['chapterHasFill'] as bool? ?? false
      ..chapterFillColor = map['chapterFillColor'] as int? ?? 0x00000000
      ..chapterHasStroke = map['chapterHasStroke'] as bool? ?? false
      ..chapterStrokeColor = map['chapterStrokeColor'] as int? ?? 0xFF000000
      ..chapterLineHeight = (map['chapterLineHeight'] as num?)?.toDouble() ?? 1.2
      ..chapterStrokeWidth = (map['chapterStrokeWidth'] as num?)?.toDouble() ?? 0.08
      ..chapterHasShadow = map['chapterHasShadow'] as bool? ?? false
      ..chapterShadowColor = map['chapterShadowColor'] as int? ?? 0xFF000000
      ..chapterShadowOffsetX = (map['chapterShadowOffsetX'] as num?)?.toDouble() ?? 2.0
      ..chapterShadowOffsetY = (map['chapterShadowOffsetY'] as num?)?.toDouble() ?? 2.0
      ..chapterShadowRadius = (map['chapterShadowRadius'] as num?)?.toDouble() ?? 4.0
      ..chapterMarginTop = (map['chapterMarginTop'] as num?)?.toDouble() ?? 16.0
      ..chapterMarginBottom = (map['chapterMarginBottom'] as num?)?.toDouble() ?? 16.0
      ..chapterMarginLeft = (map['chapterMarginLeft'] as num?)?.toDouble() ?? 16.0
      ..chapterMarginRight = (map['chapterMarginRight'] as num?)?.toDouble() ?? 16.0
      ..verseAlignment = map['verseAlignment'] as String? ?? 'center'
      ..verseVerticalAlignment = map['verseVerticalAlignment'] as String? ?? 'center'
      ..verseFontSize = (map['verseFontSize'] as num?)?.toDouble() ?? 80.0
      ..verseFontFamily = map['verseFontFamily'] as String? ?? 'Arial'
      ..verseFontColor = map['verseFontColor'] as int? ?? 0xFFFFFFFF
      ..verseBold = map['verseBold'] as bool? ?? true
      ..verseItalic = map['verseItalic'] as bool? ?? false
      ..verseUnderline = map['verseUnderline'] as bool? ?? false
      ..verseHasFill = map['verseHasFill'] as bool? ?? false
      ..verseFillColor = map['verseFillColor'] as int? ?? 0x00000000
      ..verseHasStroke = map['verseHasStroke'] as bool? ?? false
      ..verseStrokeColor = map['verseStrokeColor'] as int? ?? 0xFF000000
      ..verseLineHeight = (map['verseLineHeight'] as num?)?.toDouble() ?? 1.4
      ..verseStrokeWidth = (map['verseStrokeWidth'] as num?)?.toDouble() ?? 0.08
      ..verseHasShadow = map['verseHasShadow'] as bool? ?? false
      ..verseShadowColor = map['verseShadowColor'] as int? ?? 0xFF000000
      ..verseShadowOffsetX = (map['verseShadowOffsetX'] as num?)?.toDouble() ?? 2.0
      ..verseShadowOffsetY = (map['verseShadowOffsetY'] as num?)?.toDouble() ?? 2.0
      ..verseShadowRadius = (map['verseShadowRadius'] as num?)?.toDouble() ?? 4.0
      ..verseMarginTop = (map['verseMarginTop'] as num?)?.toDouble() ?? 32.0
      ..verseMarginBottom = (map['verseMarginBottom'] as num?)?.toDouble() ?? 32.0
      ..verseMarginLeft = (map['verseMarginLeft'] as num?)?.toDouble() ?? 32.0
      ..verseMarginRight = (map['verseMarginRight'] as num?)?.toDouble() ?? 32.0
      ..showDualChapter = map['showDualChapter'] as bool? ?? true
      ..dualChapterAlignment = map['dualChapterAlignment'] as String? ?? 'center'
      ..dualChapterVerticalAlignment = map['dualChapterVerticalAlignment'] as String? ?? 'bottom'
      ..dualChapterFontSize = (map['dualChapterFontSize'] as num?)?.toDouble() ?? 24.0
      ..dualChapterFontFamily = map['dualChapterFontFamily'] as String? ?? 'Arial'
      ..dualChapterFontColor = map['dualChapterFontColor'] as int? ?? 0x8FFFFFFF
      ..dualChapterBold = map['dualChapterBold'] as bool? ?? true
      ..dualChapterItalic = map['dualChapterItalic'] as bool? ?? false
      ..dualChapterUnderline = map['dualChapterUnderline'] as bool? ?? false
      ..dualChapterHasFill = map['dualChapterHasFill'] as bool? ?? false
      ..dualChapterFillColor = map['dualChapterFillColor'] as int? ?? 0x00000000
      ..dualChapterHasStroke = map['dualChapterHasStroke'] as bool? ?? false
      ..dualChapterStrokeColor = map['dualChapterStrokeColor'] as int? ?? 0xFF000000
      ..dualChapterLineHeight = (map['dualChapterLineHeight'] as num?)?.toDouble() ?? 1.2
      ..dualChapterStrokeWidth = (map['dualChapterStrokeWidth'] as num?)?.toDouble() ?? 0.08
      ..dualChapterHasShadow = map['dualChapterHasShadow'] as bool? ?? false
      ..dualChapterShadowColor = map['dualChapterShadowColor'] as int? ?? 0xFF000000
      ..dualChapterShadowOffsetX = (map['dualChapterShadowOffsetX'] as num?)?.toDouble() ?? 2.0
      ..dualChapterShadowOffsetY = (map['dualChapterShadowOffsetY'] as num?)?.toDouble() ?? 2.0
      ..dualChapterShadowRadius = (map['dualChapterShadowRadius'] as num?)?.toDouble() ?? 4.0
      ..dualChapterMarginTop = (map['dualChapterMarginTop'] as num?)?.toDouble() ?? 16.0
      ..dualChapterMarginBottom = (map['dualChapterMarginBottom'] as num?)?.toDouble() ?? 16.0
      ..dualChapterMarginLeft = (map['dualChapterMarginLeft'] as num?)?.toDouble() ?? 16.0
      ..dualChapterMarginRight = (map['dualChapterMarginRight'] as num?)?.toDouble() ?? 16.0
      ..primaryVerseAlignment = map['primaryVerseAlignment'] as String? ?? 'center'
      ..primaryVerseVerticalAlignment = map['primaryVerseVerticalAlignment'] as String? ?? 'center'
      ..primaryVerseFontSize = (map['primaryVerseFontSize'] as num?)?.toDouble() ?? 60.0
      ..primaryVerseFontFamily = map['primaryVerseFontFamily'] as String? ?? 'Arial'
      ..primaryVerseFontColor = map['primaryVerseFontColor'] as int? ?? 0xFFFFFFFF
      ..primaryVerseBold = map['primaryVerseBold'] as bool? ?? true
      ..primaryVerseItalic = map['primaryVerseItalic'] as bool? ?? false
      ..primaryVerseUnderline = map['primaryVerseUnderline'] as bool? ?? false
      ..primaryVerseHasFill = map['primaryVerseHasFill'] as bool? ?? false
      ..primaryVerseFillColor = map['primaryVerseFillColor'] as int? ?? 0x00000000
      ..primaryVerseHasStroke = map['primaryVerseHasStroke'] as bool? ?? false
      ..primaryVerseStrokeColor = map['primaryVerseStrokeColor'] as int? ?? 0xFF000000
      ..primaryVerseLineHeight = (map['primaryVerseLineHeight'] as num?)?.toDouble() ?? 1.4
      ..primaryVerseStrokeWidth = (map['primaryVerseStrokeWidth'] as num?)?.toDouble() ?? 0.08
      ..primaryVerseHasShadow = map['primaryVerseHasShadow'] as bool? ?? false
      ..primaryVerseShadowColor = map['primaryVerseShadowColor'] as int? ?? 0xFF000000
      ..primaryVerseShadowOffsetX = (map['primaryVerseShadowOffsetX'] as num?)?.toDouble() ?? 2.0
      ..primaryVerseShadowOffsetY = (map['primaryVerseShadowOffsetY'] as num?)?.toDouble() ?? 2.0
      ..primaryVerseShadowRadius = (map['primaryVerseShadowRadius'] as num?)?.toDouble() ?? 4.0
      ..primaryVerseMarginTop = (map['primaryVerseMarginTop'] as num?)?.toDouble() ?? 16.0
      ..primaryVerseMarginBottom = (map['primaryVerseMarginBottom'] as num?)?.toDouble() ?? 16.0
      ..primaryVerseMarginLeft = (map['primaryVerseMarginLeft'] as num?)?.toDouble() ?? 16.0
      ..primaryVerseMarginRight = (map['primaryVerseMarginRight'] as num?)?.toDouble() ?? 16.0
      ..secVerseAlignment = map['secVerseAlignment'] as String? ?? 'center'
      ..secVerseVerticalAlignment = map['secVerseVerticalAlignment'] as String? ?? 'center'
      ..secVerseFontSize = (map['secVerseFontSize'] as num?)?.toDouble() ?? 60.0
      ..secVerseFontFamily = map['secVerseFontFamily'] as String? ?? 'Arial'
      ..secVerseFontColor = map['secVerseFontColor'] as int? ?? 0xFFFFFFFF
      ..secVerseBold = map['secVerseBold'] as bool? ?? true
      ..secVerseItalic = map['secVerseItalic'] as bool? ?? false
      ..secVerseUnderline = map['secVerseUnderline'] as bool? ?? false
      ..secVerseHasFill = map['secVerseHasFill'] as bool? ?? false
      ..secVerseFillColor = map['secVerseFillColor'] as int? ?? 0x00000000
      ..secVerseHasStroke = map['secVerseHasStroke'] as bool? ?? false
      ..secVerseStrokeColor = map['secVerseStrokeColor'] as int? ?? 0xFF000000
      ..secVerseLineHeight = (map['secVerseLineHeight'] as num?)?.toDouble() ?? 1.4
      ..secVerseStrokeWidth = (map['secVerseStrokeWidth'] as num?)?.toDouble() ?? 0.08
      ..secVerseHasShadow = map['secVerseHasShadow'] as bool? ?? false
      ..secVerseShadowColor = map['secVerseShadowColor'] as int? ?? 0xFF000000
      ..secVerseShadowOffsetX = (map['secVerseShadowOffsetX'] as num?)?.toDouble() ?? 2.0
      ..secVerseShadowOffsetY = (map['secVerseShadowOffsetY'] as num?)?.toDouble() ?? 2.0
      ..secVerseShadowRadius = (map['secVerseShadowRadius'] as num?)?.toDouble() ?? 4.0
      ..secVerseMarginTop = (map['secVerseMarginTop'] as num?)?.toDouble() ?? 16.0
      ..secVerseMarginBottom = (map['secVerseMarginBottom'] as num?)?.toDouble() ?? 16.0
      ..secVerseMarginLeft = (map['secVerseMarginLeft'] as num?)?.toDouble() ?? 16.0
      ..secVerseMarginRight = (map['secVerseMarginRight'] as num?)?.toDouble() ?? 16.0;
    return settings.sanitize();
  }
}
