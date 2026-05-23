import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/data/presentation_settings.dart';
import '../../../../core/sync/media_sync_manager.dart';

class ProjectorView extends ConsumerWidget {
  final PresentationSettings settings;
  final String? activeSlideText;
  final String? titleText;
  final bool isSong;
  final bool showCheckerboard;

  const ProjectorView({
    super.key,
    required this.settings,
    this.activeSlideText,
    this.titleText,
    this.isSong = true,
    this.showCheckerboard = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaSync = ref.watch(mediaSyncManagerProvider);
    final bool isBlank = activeSlideText == "";

    final isTransparent = isBlank ? settings.isBlankTransparent : (isSong ? settings.isSongTransparent : settings.isScriptureTransparent);
    final backgroundColorValue = Color(isBlank ? settings.blankBackgroundColor : (isSong ? settings.songBackgroundColor : settings.scriptureBackgroundColor));
    final isImageEnabled = isBlank ? settings.isBlankImageEnabled : (isSong ? settings.isSongImageEnabled : settings.isScriptureImageEnabled);
    final rawBackgroundImage = isBlank ? settings.blankBackgroundImage : (isSong ? settings.songBackgroundImage : settings.scriptureBackgroundImage);
    final backgroundImage = rawBackgroundImage.isNotEmpty ? mediaSync.resolveMediaPath(rawBackgroundImage) : '';
    final backgroundLayout = isBlank ? settings.blankBackgroundImageLayout : (isSong ? settings.songBackgroundImageLayout : settings.scriptureBackgroundImageLayout);
    final backgroundAlignment = isBlank ? settings.blankBackgroundImageAlignment : (isSong ? settings.songBackgroundImageAlignment : settings.scriptureBackgroundImageAlignment);

    final alignStr = isSong ? settings.lyricsAlignment : settings.verseAlignment;
    final vAlignStr = isSong ? settings.lyricsVerticalAlignment : settings.verseVerticalAlignment;
    
    // Determine the reference canvas size
    final aspectRatioStr = isBlank ? settings.blankAspectRatio : (isSong ? settings.songAspectRatio : settings.scriptureAspectRatio);
    double canvasWidth = 1920;
    double canvasHeight = 1080;

    if (aspectRatioStr == '4:3') {
      canvasWidth = 1440;
      canvasHeight = 1080;
    } else if (aspectRatioStr == '4:1') {
      canvasWidth = 1920;
      canvasHeight = 480;
    } else if (aspectRatioStr == 'Custom') {
      canvasWidth = isBlank ? settings.blankCustomWidth : (isSong ? settings.songCustomWidth : settings.scriptureCustomWidth);
      canvasHeight = isBlank ? settings.blankCustomHeight : (isSong ? settings.songCustomHeight : settings.scriptureCustomHeight);
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
    final lyricsBoldValue = isSong ? settings.lyricsBold : settings.verseBold;
    final lyricsItalicValue = isSong ? settings.lyricsItalic : settings.verseItalic;

    final lyricsMarginTopValue = isSong ? settings.lyricsMarginTop : settings.verseMarginTop;
    final lyricsMarginBottomValue = isSong ? settings.lyricsMarginBottom : settings.verseMarginBottom;
    final lyricsMarginLeftValue = isSong ? settings.lyricsMarginLeft : settings.verseMarginLeft;
    final lyricsMarginRightValue = isSong ? settings.lyricsMarginRight : settings.verseMarginRight;

    final lyricsHasStrokeValue = isSong ? settings.lyricsHasStroke : settings.verseHasStroke;
    final lyricsStrokeColorValue = Color(isSong ? settings.lyricsStrokeColor : settings.verseStrokeColor);
    final lyricsHasFillValue = isSong ? settings.lyricsHasFill : settings.verseHasFill;
    final lyricsFillColorValue = Color(isSong ? settings.lyricsFillColor : settings.verseFillColor);

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
    final titleBoldValue = isSong ? settings.titleBold : settings.chapterBold;
    final titleItalicValue = isSong ? settings.titleItalic : settings.chapterItalic;

    final titleMarginTopValue = isSong ? settings.titleMarginTop : settings.chapterMarginTop;
    final titleMarginBottomValue = isSong ? settings.titleMarginBottom : settings.chapterMarginBottom;
    final titleMarginLeftValue = isSong ? settings.titleMarginLeft : settings.chapterMarginLeft;
    final titleMarginRightValue = isSong ? settings.titleMarginRight : settings.chapterMarginRight;

    final titleHasStrokeValue = isSong ? settings.titleHasStroke : settings.chapterHasStroke;
    final titleStrokeColorValue = Color(isSong ? settings.titleStrokeColor : settings.chapterStrokeColor);
    final titleHasFillValue = isSong ? settings.titleHasFill : settings.chapterHasFill;
    final titleFillColorValue = Color(isSong ? settings.titleFillColor : settings.chapterFillColor);

    final lineCount = activeSlideText?.split('\n').length ?? 1;
    final isBlankScreen = activeSlideText == "";
    final isImageSlide = activeSlideText?.startsWith('IMAGE:') ?? false;

    // The inner content that is sized to the virtual canvas
    Widget content = Container(
      width: canvasWidth,
      height: canvasHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Layer: Background Color
          Container(
            color: activeSlideText == null ? Colors.black : (isTransparent ? Colors.transparent : backgroundColorValue),
          ),
          
          // 2. Layer: Checkerboard
          if (isTransparent && showCheckerboard)
            Positioned.fill(
              child: CustomPaint(
                painter: _CheckerboardPainter(),
              ),
            ),

          // 3. Layer: Background Image
          if (activeSlideText != null && !isImageSlide && isImageEnabled && backgroundImage.isNotEmpty && File(backgroundImage).existsSync())
            Positioned.fill(
              child: Image.file(
                File(backgroundImage),
                fit: backgroundLayout == 'stretch' ? BoxFit.fill : BoxFit.contain,
                alignment: _parseAlignmentStr(backgroundAlignment),
              ),
            ),
          if (!isBlankScreen) ...[
              // Body Layer
              if (isImageSlide)
                _buildImageWidget(activeSlideText!, canvasWidth, canvasHeight, mediaSync)
              else
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
                                fontWeight: lyricsBoldValue ? FontWeight.bold : FontWeight.normal,
                                fontStyle: lyricsItalicValue ? FontStyle.italic : FontStyle.normal,
                              ),
                              maxLines: 1,
                            )
                          : Stack(
                              children: [
                                if (lyricsHasStrokeValue)
                                  AutoSizeText(
                                    activeSlideText!,
                                    style: TextStyle(
                                      fontSize: lyricsFontSizeValue,
                                      fontFamily: lyricsFontFamilyValue,
                                      fontWeight: lyricsBoldValue ? FontWeight.bold : FontWeight.normal,
                                      fontStyle: lyricsItalicValue ? FontStyle.italic : FontStyle.normal,
                                      height: 1.4,                                      
                                      decoration: lyricsUnderlineValue ? TextDecoration.underline : TextDecoration.none,
                                      backgroundColor: lyricsHasFillValue ? lyricsFillColorValue : null,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = lyricsFontSizeValue * 0.08
                                        ..strokeJoin = StrokeJoin.round
                                        ..strokeCap = StrokeCap.round
                                        ..color = lyricsStrokeColorValue,
                                    ),
                                    textAlign: _getTextAlign(alignStr),
                                    maxLines: (isSong && lineCount > 1) ? lineCount : 30, 
                                    minFontSize: 8, 
                                    wrapWords: !isSong || lineCount == 1,
                                    softWrap: true,
                                  ),
                                AutoSizeText(
                                  activeSlideText!,
                                  style: TextStyle(
                                    color: lyricsFontColorValue,
                                    fontSize: lyricsFontSizeValue,
                                    fontFamily: lyricsFontFamilyValue,
                                    fontWeight: lyricsBoldValue ? FontWeight.bold : FontWeight.normal,
                                    fontStyle: lyricsItalicValue ? FontStyle.italic : FontStyle.normal,
                                    height: 1.4,                                    
                                    decoration: lyricsUnderlineValue ? TextDecoration.underline : TextDecoration.none,
                                    backgroundColor: lyricsHasFillValue ? lyricsFillColorValue : null,
                                  ),
                                  textAlign: _getTextAlign(alignStr),
                                  maxLines: (isSong && lineCount > 1) ? lineCount : 30, 
                                  minFontSize: 8, 
                                  wrapWords: !isSong || lineCount == 1,
                                  softWrap: true,
                                ),
                              ],
                            ),
                ),
              ),

              // Title Layer
              if (showTitle && titleText != null && !isImageSlide)
                Align(
                  alignment: _getAlignmentGeometry(titleHorizontalStr, titleVerticalStr),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(titleMarginLeftValue, titleMarginTopValue, titleMarginRightValue, titleMarginBottomValue),
                    child: Stack(
                      children: [
                        if (titleHasStrokeValue)
                          Text(
                            titleText!,
                            textAlign: _getTextAlign(titleHorizontalStr),
                            style: TextStyle(
                              fontSize: titleFontSizeValue,
                              fontFamily: titleFontFamilyValue,
                              fontWeight: titleBoldValue ? FontWeight.bold : FontWeight.normal,
                              fontStyle: titleItalicValue ? FontStyle.italic : FontStyle.normal,
                              height: 1.2,
                              decoration: titleUnderlineValue ? TextDecoration.underline : TextDecoration.none,
                              backgroundColor: titleHasFillValue ? titleFillColorValue : null,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = titleFontSizeValue * 0.08
                                ..strokeJoin = StrokeJoin.round
                                ..strokeCap = StrokeCap.round
                                ..color = titleStrokeColorValue,
                            ),
                          ),
                        Text(
                          titleText!,
                          textAlign: _getTextAlign(titleHorizontalStr),
                          style: TextStyle(
                            color: titleFontColorValue,
                            fontSize: titleFontSizeValue,
                            fontFamily: titleFontFamilyValue,
                            fontWeight: titleBoldValue ? FontWeight.bold : FontWeight.normal,
                            fontStyle: titleItalicValue ? FontStyle.italic : FontStyle.normal,
                            height: 1.2,
                            decoration: titleUnderlineValue ? TextDecoration.underline : TextDecoration.none,
                            backgroundColor: titleHasFillValue ? titleFillColorValue : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );

    // Use FittedBox to scale the virtual canvas to the actual display window
    return Container(
      color: Colors.transparent, // Background fill for letterboxing
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

  CrossAxisAlignment _getCrossAxisAlignment(String alignment) {
    switch (alignment) {
      case 'left': return CrossAxisAlignment.start;
      case 'right': return CrossAxisAlignment.end;
      case 'center': default: return CrossAxisAlignment.center;
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

  Widget _buildImageWidget(String content, double width, double height, MediaSyncManager mediaSync) {
    final rest = content.substring(6);
    final parts = rest.split('|');
    final rawPath = parts[0];
    final path = mediaSync.resolveMediaPath(rawPath);
    final layout = parts.length > 1 ? parts[1] : 'contain';
    
    BoxFit fit;
    switch (layout) {
      case 'stretch': fit = BoxFit.fill; break;
      case 'contain': default: fit = BoxFit.contain; break;
    }

    if (!File(path).existsSync()) {
      return Center(child: Icon(Icons.broken_image, size: 64, color: Colors.red.withOpacity(0.5)));
    }

    return Image.file(
      File(path),
      fit: fit,
      width: width,
      height: height,
      alignment: _getImageAlignment(content),
    );
  }

  Alignment _getImageAlignment(String content) {
    final rest = content.substring(6);
    final parts = rest.split('|');
    final alignment = parts.length > 2 ? parts[2] : 'center';
    return _parseAlignmentStr(alignment);
  }

  Alignment _parseAlignmentStr(String alignment) {
    switch (alignment) {
      case 'topLeft': return Alignment.topLeft;
      case 'topCenter': return Alignment.topCenter;
      case 'topRight': return Alignment.topRight;
      case 'centerLeft': return Alignment.centerLeft;
      case 'center': return Alignment.center;
      case 'centerRight': return Alignment.centerRight;
      case 'bottomLeft': return Alignment.bottomLeft;
      case 'bottomCenter': return Alignment.bottomCenter;
      case 'bottomRight': return Alignment.bottomRight;
      default: return Alignment.center;
    }
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = Colors.grey[400]!;
    final paint2 = Paint()..color = Colors.grey[300]!;
    const double squareSize = 20.0;
    
    for (int i = 0; i < size.width / squareSize; i++) {
      for (int j = 0; j < size.height / squareSize; j++) {
        final isEven = (i + j) % 2 == 0;
        final rect = Rect.fromLTWH(i * squareSize, j * squareSize, squareSize, squareSize);
        canvas.drawRect(rect, isEven ? paint1 : paint2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
