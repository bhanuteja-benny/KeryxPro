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

  Map<String, dynamic> toMap() {
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
      'lyricsMarginTop': lyricsMarginTop,
      'lyricsMarginBottom': lyricsMarginBottom,
      'lyricsMarginLeft': lyricsMarginLeft,
      'lyricsMarginRight': lyricsMarginRight,
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
      'verseMarginTop': verseMarginTop,
      'verseMarginBottom': verseMarginBottom,
      'verseMarginLeft': verseMarginLeft,
      'verseMarginRight': verseMarginRight,
    };
  }

  static PresentationSettings fromMap(Map<String, dynamic> map) {
    return PresentationSettings()
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
      ..lyricsMarginTop = (map['lyricsMarginTop'] as num?)?.toDouble() ?? 32.0
      ..lyricsMarginBottom = (map['lyricsMarginBottom'] as num?)?.toDouble() ?? 32.0
      ..lyricsMarginLeft = (map['lyricsMarginLeft'] as num?)?.toDouble() ?? 32.0
      ..lyricsMarginRight = (map['lyricsMarginRight'] as num?)?.toDouble() ?? 32.0
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
      ..verseMarginTop = (map['verseMarginTop'] as num?)?.toDouble() ?? 32.0
      ..verseMarginBottom = (map['verseMarginBottom'] as num?)?.toDouble() ?? 32.0
      ..verseMarginLeft = (map['verseMarginLeft'] as num?)?.toDouble() ?? 32.0
      ..verseMarginRight = (map['verseMarginRight'] as num?)?.toDouble() ?? 32.0;
  }
}
