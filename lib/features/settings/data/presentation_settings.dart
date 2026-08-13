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
    if (!blankCustomWidth.isFinite || blankCustomWidth <= 0) blankCustomWidth = 1920.0;
    if (!blankCustomHeight.isFinite || blankCustomHeight <= 0) blankCustomHeight = 1080.0;
    if (!windowCustomWidth.isFinite || windowCustomWidth <= 0) windowCustomWidth = 1920.0;
    if (!windowCustomHeight.isFinite || windowCustomHeight <= 0) windowCustomHeight = 1080.0;

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

    // Strings Fallback
    if (presetName.isEmpty) {
      presetName = (isDefault || id == 1) ? 'Default' : 'Preset $id';
    }
    if (presetName == 'Default') {
      isDefault = true;
    }

    if (songAspectRatio.isEmpty) songAspectRatio = '16:9';
    if (scriptureAspectRatio.isEmpty) scriptureAspectRatio = '16:9';
    if (blankAspectRatio.isEmpty) blankAspectRatio = '16:9';
    if (windowAspectRatio.isEmpty) windowAspectRatio = '16:9';
    if (titleAlignment.isEmpty) titleAlignment = 'center';
    if (titleVerticalAlignment.isEmpty) titleVerticalAlignment = 'bottom';
    if (chapterAlignment.isEmpty) chapterAlignment = 'center';
    if (chapterVerticalAlignment.isEmpty) chapterVerticalAlignment = 'bottom';
    if (verseAlignment.isEmpty) verseAlignment = 'center';
    if (verseVerticalAlignment.isEmpty) verseVerticalAlignment = 'center';
    if (lyricsAlignment.isEmpty) lyricsAlignment = 'center';
    if (lyricsVerticalAlignment.isEmpty) lyricsVerticalAlignment = 'center';
    if (chapterFontFamily.isEmpty) chapterFontFamily = 'Arial';
    if (verseFontFamily.isEmpty) verseFontFamily = 'Arial';
    if (lyricsFontFamily.isEmpty) lyricsFontFamily = 'Arial';
    if (titleFontFamily.isEmpty) titleFontFamily = 'Arial';

    if (songBackgroundImageLayout.isEmpty) songBackgroundImageLayout = 'stretch';
    if (songBackgroundImageAlignment.isEmpty) songBackgroundImageAlignment = 'center';
    if (scriptureBackgroundImageLayout.isEmpty) scriptureBackgroundImageLayout = 'stretch';
    if (scriptureBackgroundImageAlignment.isEmpty) scriptureBackgroundImageAlignment = 'center';
    if (blankBackgroundImageLayout.isEmpty) blankBackgroundImageLayout = 'stretch';
    if (blankBackgroundImageAlignment.isEmpty) blankBackgroundImageAlignment = 'center';
    if (windowBackgroundImageLayout.isEmpty) windowBackgroundImageLayout = 'stretch';
    if (windowBackgroundImageAlignment.isEmpty) windowBackgroundImageAlignment = 'center';

    if (songBackgroundColor == 0) songBackgroundColor = 0xFF000000;
    if (scriptureBackgroundColor == 0) scriptureBackgroundColor = 0xFF000000;
    if (blankBackgroundColor == 0) blankBackgroundColor = 0xFF000000;
    if (windowBackgroundColor == 0) windowBackgroundColor = 0xFF000000;
    if ((lyricsFontColor & 0xFF000000) == 0) lyricsFontColor = 0xFFFFFFFF;
    if ((titleFontColor & 0xFF000000) == 0) titleFontColor = 0x8FFFFFFF;
    if ((chapterFontColor & 0xFF000000) == 0) chapterFontColor = 0x8FFFFFFF;
    if ((verseFontColor & 0xFF000000) == 0) verseFontColor = 0xFFFFFFFF;

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
      ..verseMarginRight = (map['verseMarginRight'] as num?)?.toDouble() ?? 32.0;
    return settings.sanitize();
  }
}
