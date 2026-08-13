import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/data/presentation_settings.dart';
import '../../../../core/sync/media_sync_manager.dart';
import '../../../setlist/data/window_capture_service.dart';

class ProjectorView extends ConsumerWidget {
  // On Windows, LWA_COLORKEY uses RGB(1,0,1) as the chroma key.
  // Flutter must render this exact color for those pixels to become transparent.
  // On macOS, native window transparency works directly with Colors.transparent.
  static final Color _transparencyColor = Platform.isWindows
      ? const Color(0xFF010001) // Matches RGB(1,0,1) chroma key
      : Colors.transparent;
  final PresentationSettings settings;
  final String? activeSlideText;
  final String? titleText;
  final bool isSong;
  final bool showCheckerboard;
  final int? monitorIndex;
  final String? captureBridgeWindowId;

  const ProjectorView({
    super.key,
    required this.settings,
    this.activeSlideText,
    this.titleText,
    this.isSong = true,
    this.showCheckerboard = false,
    this.monitorIndex,
    this.captureBridgeWindowId,
  });

  static Size getCanvasSize(
    PresentationSettings settings, {
    required bool isSong,
    required bool isBlank,
    bool isWindow = false,
    BuildContext? context,
    int? monitorIndex,
  }) {
    final aspectRatioStr = isBlank
    ? settings.blankAspectRatio
    : (isWindow ? settings.windowAspectRatio : (isSong ? settings.songAspectRatio : settings.scriptureAspectRatio));
    double canvasWidth = 1920;
    double canvasHeight = 1080;

    if (aspectRatioStr == '4:3') {
      canvasWidth = 1440;
      canvasHeight = 1080;
    } else if (aspectRatioStr == '4:1') {
      canvasWidth = 1920;
      canvasHeight = 480;
    } else if (aspectRatioStr == 'Custom') {
      canvasWidth = isBlank
    ? settings.blankCustomWidth
    : (isWindow ? settings.windowCustomWidth : (isSong ? settings.songCustomWidth : settings.scriptureCustomWidth));
canvasHeight = isBlank
    ? settings.blankCustomHeight
    : (isWindow ? settings.windowCustomHeight : (isSong ? settings.songCustomHeight : settings.scriptureCustomHeight));
      if (canvasWidth <= 0) canvasWidth = 1920;
      if (canvasHeight <= 0) canvasHeight = 1080;
    } else if (aspectRatioStr == 'Fit to screen') {
      if (monitorIndex == 1 && context != null) {
        final screenSize = MediaQuery.of(context).size;
        if (screenSize.width > 0 && screenSize.height > 0) {
          canvasWidth = screenSize.width;
          canvasHeight = screenSize.height;
        }
      }
    }
    return Size(canvasWidth, canvasHeight);
  }

  static ImageProvider getImageProvider({
    required String path,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    return ResizeImage.resizeIfNeeded(
      canvasWidth.round(),
      canvasHeight.round(),
      FileImage(File(path)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaSync = ref.watch(mediaSyncManagerProvider);
    final isWindowSlide = activeSlideText?.startsWith('WINDOW:') ?? false;
    final bool isBlank = activeSlideText == "";

    final isTransparent = isBlank
    ? settings.isBlankTransparent
    : (isWindowSlide ? settings.isWindowTransparent : (isSong ? settings.isSongTransparent : settings.isScriptureTransparent));
final backgroundColorValue = Color(isBlank
    ? settings.blankBackgroundColor
    : (isWindowSlide ? settings.windowBackgroundColor : (isSong ? settings.songBackgroundColor : settings.scriptureBackgroundColor)));
final isImageEnabled = isBlank
    ? settings.isBlankImageEnabled
    : (isWindowSlide ? settings.isWindowImageEnabled : (isSong ? settings.isSongImageEnabled : settings.isScriptureImageEnabled));
final rawBackgroundImage = isBlank
    ? settings.blankBackgroundImage
    : (isWindowSlide ? settings.windowBackgroundImage : (isSong ? settings.songBackgroundImage : settings.scriptureBackgroundImage));
final backgroundImage = rawBackgroundImage.isNotEmpty ? mediaSync.resolveMediaPath(rawBackgroundImage) : '';
final backgroundLayout = isBlank
    ? settings.blankBackgroundImageLayout
    : (isWindowSlide ? settings.windowBackgroundImageLayout : (isSong ? settings.songBackgroundImageLayout : settings.scriptureBackgroundImageLayout));
final backgroundAlignment = isBlank
    ? settings.blankBackgroundImageAlignment
    : (isWindowSlide ? settings.windowBackgroundImageAlignment : (isSong ? settings.songBackgroundImageAlignment : settings.scriptureBackgroundImageAlignment));

    final alignStr = isSong ? settings.lyricsAlignment : settings.verseAlignment;
    final vAlignStr = isSong ? settings.lyricsVerticalAlignment : settings.verseVerticalAlignment;
    
    // Determine the reference canvas size
    final size = getCanvasSize(
      settings,
      isSong: isSong,
      isBlank: isBlank,
      isWindow: isWindowSlide,
      context: context,
      monitorIndex: monitorIndex,
    );
    final double canvasWidth = size.width;
    final double canvasHeight = size.height;

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
    final lyricsLineHeightValue = isSong ? settings.lyricsLineHeight : settings.verseLineHeight;
    final lyricsStrokeWidthFactor = isSong ? settings.lyricsStrokeWidth : settings.verseStrokeWidth;
    final lyricsHasShadowValue = isSong ? settings.lyricsHasShadow : settings.verseHasShadow;
    final lyricsShadowColorValue = Color(isSong ? settings.lyricsShadowColor : settings.verseShadowColor);
    final lyricsShadowOffsetXValue = isSong ? settings.lyricsShadowOffsetX : settings.verseShadowOffsetX;
    final lyricsShadowOffsetYValue = isSong ? settings.lyricsShadowOffsetY : settings.verseShadowOffsetY;
    final lyricsShadowRadiusValue = isSong ? settings.lyricsShadowRadius : settings.verseShadowRadius;
    final List<Shadow>? lyricsShadows = lyricsHasShadowValue
        ? [
            Shadow(
              color: lyricsShadowColorValue,
              offset: Offset(lyricsShadowOffsetXValue, lyricsShadowOffsetYValue),
              blurRadius: lyricsShadowRadiusValue,
            ),
          ]
        : null;

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
    final titleLineHeightValue = isSong ? settings.titleLineHeight : settings.chapterLineHeight;
    final titleStrokeWidthFactor = isSong ? settings.titleStrokeWidth : settings.chapterStrokeWidth;
    final titleHasShadowValue = isSong ? settings.titleHasShadow : settings.chapterHasShadow;
    final titleShadowColorValue = Color(isSong ? settings.titleShadowColor : settings.chapterShadowColor);
    final titleShadowOffsetXValue = isSong ? settings.titleShadowOffsetX : settings.chapterShadowOffsetX;
    final titleShadowOffsetYValue = isSong ? settings.titleShadowOffsetY : settings.chapterShadowOffsetY;
    final titleShadowRadiusValue = isSong ? settings.titleShadowRadius : settings.chapterShadowRadius;
    final List<Shadow>? titleShadows = titleHasShadowValue
        ? [
            Shadow(
              color: titleShadowColorValue,
              offset: Offset(titleShadowOffsetXValue, titleShadowOffsetYValue),
              blurRadius: titleShadowRadiusValue,
            ),
          ]
        : null;

    final lineCount = activeSlideText?.split('\n').length ?? 1;
    final isBlankScreen = activeSlideText == "";
    final isImageSlide = activeSlideText?.startsWith('IMAGE:') ?? false;

    String processedText = activeSlideText ?? "";
    int finalLineCount = lineCount;
    int finalMaxLines = (isSong && lineCount > 1) ? lineCount : 30;
    bool shouldWrapWords = !isSong || lineCount == 1;

    if (isSong && settings.lyricsLineBreak && processedText.isNotEmpty && !isImageSlide && !isWindowSlide) {
      final style = TextStyle(
        fontSize: lyricsFontSizeValue,
        fontFamily: lyricsFontFamilyValue,
        fontWeight: lyricsBoldValue ? FontWeight.bold : FontWeight.normal,
        fontStyle: lyricsItalicValue ? FontStyle.italic : FontStyle.normal,
        height: lyricsLineHeightValue,
      );
      final double availableWidth = canvasWidth - lyricsMarginLeftValue - lyricsMarginRightValue;
      final lines = processedText.split('\n');
      final newLines = <String>[];
      for (final line in lines) {
        newLines.addAll(_splitLineRecursively(line, style, availableWidth));
      }
      processedText = newLines.join('\n');
      finalLineCount = newLines.length;
      finalMaxLines = 30;
      shouldWrapWords = true;
    }

    // The inner content that is sized to the virtual canvas
    Widget content = Container(
      width: canvasWidth,
      height: canvasHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Layer: Background Color
          Container(
            color: activeSlideText == null ? Colors.black : (isTransparent ? _transparencyColor : backgroundColorValue),
          ),
          
          // 2. Layer: Checkerboard
          if (isTransparent && showCheckerboard)
            Positioned.fill(
              child: CustomPaint(
                painter: _CheckerboardPainter(),
              ),
            ),

          // 3. Layer: Background Image
          if (activeSlideText != null && !isImageSlide && !isWindowSlide && isImageEnabled && backgroundImage.isNotEmpty && File(backgroundImage).existsSync())
            Positioned.fill(
              child: Image(
                image: getImageProvider(
                  path: backgroundImage,
                  canvasWidth: canvasWidth,
                  canvasHeight: canvasHeight,
                ),
                fit: backgroundLayout == 'stretch' ? BoxFit.fill : BoxFit.contain,
                alignment: _parseAlignmentStr(backgroundAlignment),
              ),
            ),
          if (!isBlankScreen) ...[
              // Body Layer
              if (isImageSlide)
                _buildImageWidget(activeSlideText!, canvasWidth, canvasHeight, mediaSync)
              else if (isWindowSlide)
                _buildWindowWidget(activeSlideText!, canvasWidth, canvasHeight, captureBridgeWindowId)
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
                                height: lyricsLineHeightValue,
                                shadows: lyricsShadows,
                              ),
                              maxLines: 1,
                            )
                          : Stack(
                              children: [
                                if (lyricsHasStrokeValue)
                                  AutoSizeText(
                                    processedText,
                                    style: TextStyle(
                                      fontSize: lyricsFontSizeValue,
                                      fontFamily: lyricsFontFamilyValue,
                                      fontWeight: lyricsBoldValue ? FontWeight.bold : FontWeight.normal,
                                      fontStyle: lyricsItalicValue ? FontStyle.italic : FontStyle.normal,
                                      height: lyricsLineHeightValue,                                      
                                      decoration: lyricsUnderlineValue ? TextDecoration.underline : TextDecoration.none,
                                      backgroundColor: lyricsHasFillValue ? lyricsFillColorValue : null,
                                      shadows: lyricsShadows,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = lyricsFontSizeValue * lyricsStrokeWidthFactor
                                        ..strokeJoin = StrokeJoin.round
                                        ..strokeCap = StrokeCap.round
                                        ..color = lyricsStrokeColorValue,
                                    ),
                                    textAlign: _getTextAlign(alignStr),
                                    maxLines: finalMaxLines, 
                                    minFontSize: 8, 
                                    wrapWords: shouldWrapWords,
                                    softWrap: true,
                                  ),
                                AutoSizeText(
                                  processedText,
                                  style: TextStyle(
                                    color: lyricsFontColorValue,
                                    fontSize: lyricsFontSizeValue,
                                    fontFamily: lyricsFontFamilyValue,
                                    fontWeight: lyricsBoldValue ? FontWeight.bold : FontWeight.normal,
                                    fontStyle: lyricsItalicValue ? FontStyle.italic : FontStyle.normal,
                                    height: lyricsLineHeightValue,                                    
                                    decoration: lyricsUnderlineValue ? TextDecoration.underline : TextDecoration.none,
                                    backgroundColor: lyricsHasFillValue ? lyricsFillColorValue : null,
                                    shadows: lyricsShadows,
                                  ),
                                  textAlign: _getTextAlign(alignStr),
                                  maxLines: finalMaxLines, 
                                  minFontSize: 8, 
                                  wrapWords: shouldWrapWords,
                                  softWrap: true,
                                ),
                              ],
                            ),
                ),
              ),

              // Title Layer
              if (showTitle && titleText != null && !isImageSlide && !isWindowSlide)
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
                              height: titleLineHeightValue,
                              decoration: titleUnderlineValue ? TextDecoration.underline : TextDecoration.none,
                              backgroundColor: titleHasFillValue ? titleFillColorValue : null,
                              shadows: titleShadows,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = titleFontSizeValue * titleStrokeWidthFactor
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
                            height: titleLineHeightValue,
                            decoration: titleUnderlineValue ? TextDecoration.underline : TextDecoration.none,
                            backgroundColor: titleHasFillValue ? titleFillColorValue : null,
                            shadows: titleShadows,
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

    // Determine the outer fill color for letterboxing areas
    final outerFillColor = activeSlideText == null
        ? Colors.black
        : (isTransparent ? _transparencyColor : backgroundColorValue);

    // Use FittedBox to scale the virtual canvas to the actual display window
    return Container(
      color: outerFillColor, // Background fill for letterboxing
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

    return Image(
      image: getImageProvider(
        path: path,
        canvasWidth: width,
        canvasHeight: height,
      ),
      fit: fit,
      width: width,
      height: height,
      alignment: _getImageAlignment(content),
    );
  }
  
  Widget _buildWindowWidget(String content, double width, double height, String? bridgeWindowId) {
  final rest = content.substring(7);
  final parts = rest.split('|');
  final handle = parts.isNotEmpty ? parts[0] : '';
  final title = parts.length > 1 ? Uri.decodeComponent(parts[1]) : 'Window';
  final layout = parts.length > 2 ? parts[2] : 'contain';
  final contentOnly = parts.length > 3 ? parts[3] == '1' : false;

  if (handle.isEmpty) {
    return Center(
      child: Text(
        'Invalid window reference',
        style: TextStyle(color: Colors.red.withOpacity(0.7), fontSize: 14),
      ), // Text
    ); // Center
  }

  return _LiveWindowCaptureWidget(
    windowHandle: handle,
    title: title,
    width: width,
    height: height,
    layout: layout,
    contentOnly: contentOnly,
    bridgeWindowId: bridgeWindowId,
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

  bool _isLineTooLong(String line, TextStyle style, double availableWidth) {
    final textPainter = TextPainter(
      text: TextSpan(text: line, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width > availableWidth * 0.7;
  }

  int? _findBestCommaSplitIndex(String line) {
    final commaIndices = <int>[];
    for (int i = 0; i < line.length; i++) {
      if (line[i] == ',') {
        commaIndices.add(i);
      }
    }
    if (commaIndices.isEmpty) return null;
    
    int bestIndex = commaIndices.first;
    double minDiff = double.infinity;
    
    for (final index in commaIndices) {
      final part1 = line.substring(0, index + 1).trim();
      final part2 = line.substring(index + 1).trim();
      final diff = (part1.length - part2.length).abs().toDouble();
      if (diff < minDiff) {
        minDiff = diff;
        bestIndex = index;
      }
    }
    return bestIndex;
  }

  List<String> _splitLineRecursively(String line, TextStyle style, double availableWidth) {
    if (!_isLineTooLong(line, style, availableWidth)) {
      return [line];
    }
    final commaIndex = _findBestCommaSplitIndex(line);
    if (commaIndex == null) {
      return [line];
    }
    final part1 = line.substring(0, commaIndex + 1).trim();
    final part2 = line.substring(commaIndex + 1).trim();
    
    if (part1 == line || part2 == line || part1.isEmpty || part2.isEmpty) {
      return [line];
    }
    
    return [
      ..._splitLineRecursively(part1, style, availableWidth),
      ..._splitLineRecursively(part2, style, availableWidth),
    ];
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

class _LiveWindowCaptureWidget extends StatefulWidget {
  final String windowHandle;
  final String title;
  final double width;
  final double height;
  final String layout;
  final bool contentOnly;
  final String? bridgeWindowId;

  const _LiveWindowCaptureWidget({
    required this.windowHandle,
    required this.title,
    required this.width,
    required this.height,
    required this.layout,
    required this.contentOnly,
    this.bridgeWindowId,
  });

  @override
  State<_LiveWindowCaptureWidget> createState() => _LiveWindowCaptureWidgetState();
}

class _LiveWindowCaptureWidgetState extends State<_LiveWindowCaptureWidget> {
  Timer? _timer;
  bool _capturing = false;
  ui.Image? _image;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _capture();
    _timer = Timer.periodic(const Duration(milliseconds: 120), (_) => _capture());
  }
  
  @override
  void didUpdateWidget(covariant _LiveWindowCaptureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.windowHandle != widget.windowHandle || oldWidget.bridgeWindowId != widget.bridgeWindowId) {
      _image?.dispose();
      _image = null;
      _error = null;
      _capture();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _image?.dispose();
    super.dispose();
  }

  Future<void> _capture() async{
    if(_capturing || !mounted) return;
    _capturing = true;

    try{
      final frame = await WindowCaptureService.instance.captureWindow(
        widget.windowHandle,
        bridgeWindowId: widget.bridgeWindowId,
        contentOnly: widget.contentOnly,
      );
      if (frame == null || !frame.isValid) {
        if (mounted) {
          setState(() {
            _error = 'Window unavailable';
          });
        }
        return;
      }

      final image = await _decodeBgraImage(frame.pixels, frame.width, frame.height);
      if (!mounted || image == null) return;

      final previous = _image;
      setState(() {
        _error = null;
        _image = image;
      }); 
      previous?.dispose();
    }catch(e){
      if(mounted){
        setState(() {
          _error = "Capture failed";
        });
      }
    }finally{
      _capturing = false;
    }
  }

  Future<ui.Image?> _decodeBgraImage(Uint8List bytes, int width, int height) async {
    final completer = Completer<ui.Image?>();
    ui.decodeImageFromPixels(
      bytes, 
      width, 
      height, 
      ui.PixelFormat.bgra8888, 
      (image) => completer.complete(image),
      rowBytes: width * 4, // BGRA8888 has 4 bytes per pixel
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if(_image != null) {
      final fit = widget.layout == 'stretch' ? BoxFit.fill : BoxFit.fitHeight;
      return RawImage(
        image: _image,
        width: widget.width,
        height: widget.height,
        fit: fit,
      );
    }

    if(_error != null){
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.desktop_access_disabled, color: Colors.red.withOpacity(0.7), size: 40),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              widget.title,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            )
          ]
        )
      );
    }

    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
