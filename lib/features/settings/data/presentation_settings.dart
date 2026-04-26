import 'package:isar/isar.dart';

part 'presentation_settings.g.dart';

@collection
class PresentationSettings {
  Id id = Isar.autoIncrement; 

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
  bool isSongImageEnabled = false;
  bool isSongTransparent = false;

  int scriptureBackgroundColor = 0xFF000000;
  String scriptureBackgroundImage = '';
  bool isScriptureImageEnabled = false;
  bool isScriptureTransparent = false;

  // Title Settings
  bool showTitle = true;
  String titleAlignment = 'center';
  String titleVerticalAlignment = 'bottom';
  double titleFontSize = 24.0;
  String titleFontFamily = 'Arial';
  int titleFontColor = 0x8FFFFFFF; 
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
  bool verseUnderline = false;
  bool verseHasFill = false;
  int verseFillColor = 0x00000000;
  bool verseHasStroke = false;
  int verseStrokeColor = 0xFF000000;
  double verseMarginTop = 32.0;
  double verseMarginBottom = 32.0;
  double verseMarginLeft = 32.0;
  double verseMarginRight = 32.0;
}
