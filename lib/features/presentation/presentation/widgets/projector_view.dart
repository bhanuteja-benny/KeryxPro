import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io';
import '../../../settings/data/presentation_settings.dart';

class ProjectorView extends StatelessWidget {
  final PresentationSettings settings;
  final String? activeSlideText;
  final String? titleText;
  final bool isSong;

  const ProjectorView({
    super.key,
    required this.settings,
    this.activeSlideText,
    this.titleText,
    this.isSong = true,
  });

  @override
  Widget build(BuildContext context) {
    final isTransparent = isSong ? settings.isSongTransparent : settings.isScriptureTransparent;
    final backgroundColorValue = Color(isSong ? settings.songBackgroundColor : settings.scriptureBackgroundColor);
    final isImageEnabled = isSong ? settings.isSongImageEnabled : settings.isScriptureImageEnabled;
    final backgroundImage = isSong ? settings.songBackgroundImage : settings.scriptureBackgroundImage;

    final alignStr = isSong ? settings.lyricsAlignment : settings.verseAlignment;
    final vAlignStr = isSong ? settings.lyricsVerticalAlignment : settings.verseVerticalAlignment;
    
    // Determine the reference canvas size
    final aspectRatioStr = isSong ? settings.songAspectRatio : settings.scriptureAspectRatio;
    double canvasWidth = 1920;
    double canvasHeight = 1080;

    if (aspectRatioStr == '4:3') {
      canvasWidth = 1440;
      canvasHeight = 1080;
    } else if (aspectRatioStr == '4:1') {
      canvasWidth = 1920;
      canvasHeight = 480;
    } else if (aspectRatioStr == 'Custom') {
      canvasWidth = isSong ? settings.songCustomWidth : settings.scriptureCustomWidth;
      canvasHeight = isSong ? settings.songCustomHeight : settings.scriptureCustomHeight;
      // Safety fallbacks
      if (canvasWidth <= 0) canvasWidth = 1920;
      if (canvasHeight <= 0) canvasHeight = 1080;
    }

    final lyricsFontSizeValue = isSong 
        ? ((settings.lyricsFontSize.isNaN || settings.lyricsFontSize <= 0) ? 80.0 : settings.lyricsFontSize)
        : ((settings.verseFontSize.isNaN || settings.verseFontSize <= 0) ? 80.0 : settings.verseFontSize);
    
    var lyricsFontColorValue = Color(isSong ? settings.lyricsFontColor : settings.verseFontColor);
    if (lyricsFontColorValue.a == 0) lyricsFontColorValue = Colors.white;

    final lyricsFontFamilyValue = isSong ? settings.lyricsFontFamily : settings.verseFontFamily;
    final lyricsUnderlineValue = isSong ? settings.lyricsUnderline : settings.verseUnderline;

    final lyricsMarginTopValue = isSong ? settings.lyricsMarginTop : settings.verseMarginTop;
    final lyricsMarginBottomValue = isSong ? settings.lyricsMarginBottom : settings.verseMarginBottom;
    final lyricsMarginLeftValue = isSong ? settings.lyricsMarginLeft : settings.verseMarginLeft;
    final lyricsMarginRightValue = isSong ? settings.lyricsMarginRight : settings.verseMarginRight;

    final showTitle = isSong ? settings.showTitle : settings.showChapter;
    final titleHorizontalStr = isSong ? settings.titleAlignment : settings.chapterAlignment;
    final titleVerticalStr = isSong ? settings.titleVerticalAlignment : settings.chapterVerticalAlignment;
    
    final titleFontSizeValue = isSong
        ? ((settings.titleFontSize.isNaN || settings.titleFontSize <= 0) ? 24.0 : settings.titleFontSize)
        : ((settings.chapterFontSize.isNaN || settings.chapterFontSize <= 0) ? 24.0 : settings.chapterFontSize);
        
    var titleFontColorValue = Color(isSong ? settings.titleFontColor : settings.chapterFontColor);
    if (titleFontColorValue.a == 0) titleFontColorValue = Colors.white70;

    final titleFontFamilyValue = isSong ? settings.titleFontFamily : settings.chapterFontFamily;
    final titleUnderlineValue = isSong ? settings.titleUnderline : settings.chapterUnderline;

    final titleMarginTopValue = isSong ? settings.titleMarginTop : settings.chapterMarginTop;
    final titleMarginBottomValue = isSong ? settings.titleMarginBottom : settings.chapterMarginBottom;
    final titleMarginLeftValue = isSong ? settings.titleMarginLeft : settings.chapterMarginLeft;
    final titleMarginRightValue = isSong ? settings.titleMarginRight : settings.chapterMarginRight;

    final lineCount = activeSlideText?.split('\n').length ?? 1;
    final isBlankScreen = activeSlideText == "";

    // The inner content that is sized to the virtual canvas
    Widget content = Container(
      width: canvasWidth,
      height: canvasHeight,
      decoration: BoxDecoration(
        color: (activeSlideText == null || isBlankScreen) ? Colors.black : (isTransparent ? Colors.transparent : backgroundColorValue),
        image: !isBlankScreen && activeSlideText != null && isImageEnabled && (backgroundImage?.isNotEmpty ?? false) && File(backgroundImage!).existsSync()
          ? DecorationImage(
              image: FileImage(File(backgroundImage!)),
              fit: BoxFit.cover,
            )
          : null,
      ),
      child: isBlankScreen 
        ? const SizedBox.shrink()
        : Stack(
            fit: StackFit.expand,
            children: [
              // Body Layer
              Align(
                alignment: _getAlignmentGeometry(alignStr, vAlignStr),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(lyricsMarginLeftValue, lyricsMarginTopValue, lyricsMarginRightValue, lyricsMarginBottomValue),
                  child: activeSlideText == null || activeSlideText!.isEmpty
                      ? AutoSizeText(
                          'KeryxPro Worship',
                          style: TextStyle(
                            color: lyricsFontColorValue.withValues(alpha: 0.2),
                            fontSize: lyricsFontSizeValue,
                            fontFamily: settings.lyricsFontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        )
                      : AutoSizeText(
                          activeSlideText!,
                          style: TextStyle(
                            color: lyricsFontColorValue,
                            fontSize: lyricsFontSizeValue,
                            fontFamily: lyricsFontFamilyValue,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            decoration: lyricsUnderlineValue ? TextDecoration.underline : TextDecoration.none,
                          ),
                          textAlign: _getTextAlign(alignStr),
                          maxLines: (isSong && lineCount > 1) ? lineCount : 30, 
                          minFontSize: 8, 
                          wrapWords: !isSong || lineCount == 1,
                          softWrap: true,
                        ),
                ),
              ),

              // Title Layer
              if (showTitle && titleText != null)
                Align(
                  alignment: _getAlignmentGeometry(titleHorizontalStr, titleVerticalStr),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(titleMarginLeftValue, titleMarginTopValue, titleMarginRightValue, titleMarginBottomValue),
                    child: Text(
                      titleText!,
                      textAlign: _getTextAlign(titleHorizontalStr),
                      style: TextStyle(
                        color: titleFontColorValue,
                        fontSize: titleFontSizeValue,
                        fontFamily: titleFontFamilyValue,
                        fontWeight: FontWeight.bold,
                        decoration: titleUnderlineValue ? TextDecoration.underline : TextDecoration.none,
                      ),
                    ),
                  ),
                ),
            ],
          ),
    );

    // Use FittedBox to scale the virtual canvas to the actual display window
    return Container(
      color: Colors.black, // Background fill for letterboxing
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: content,
        ),
      ),
    );
  }

  TextAlign _getTextAlign(String alignment) {
    switch (alignment) {
      case 'left': return TextAlign.left;
      case 'right': return TextAlign.right;
      case 'center': default: return TextAlign.center;
    }
  }

  Alignment _getAlignmentGeometry(String horizontal, String vertical) {
    double x = 0;
    double y = 0;
    switch (horizontal) {
      case 'left': x = -1; break;
      case 'right': x = 1; break;
      case 'center': default: x = 0; break;
    }
    switch (vertical) {
      case 'top': y = -1; break;
      case 'bottom': y = 1; break;
      case 'center': default: y = 0; break;
    }
    return Alignment(x, y);
  }
}
