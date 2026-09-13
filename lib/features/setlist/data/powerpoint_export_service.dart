import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';

import 'powerpoint_template_bytes.dart';

/// Data representation for an individual slide to be exported to PowerPoint.
class PowerpointSlideData {
  final String title;
  final String content;
  final bool isBlank;
  final bool isSong;
  final bool isDualVersion;
  final String? secondaryTitle;
  final String? secondaryContent;

  // Primary text formatting
  final String fontColorHex;
  final double fontSize;
  final String fontFamily;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final String horizontalAlign; // 'left', 'center', 'right', 'justify'
  final String verticalAlign;   // 'top', 'center', 'bottom'
  final double lineHeight;

  // Primary padding / margins (in pixels/points)
  final double padLeft;
  final double padTop;
  final double padRight;
  final double padBottom;

  // Secondary text formatting (for dual scripture / dual version)
  final String? secondaryFontColorHex;
  final double? secondaryFontSize;
  final String? secondaryFontFamily;
  final bool? secondaryBold;
  final bool? secondaryItalic;
  final bool? secondaryUnderline;
  final String? secondaryHorizontalAlign;
  final String? secondaryVerticalAlign;
  final double? secondaryLineHeight;
  final double? secondaryPadLeft;
  final double? secondaryPadTop;
  final double? secondaryPadRight;
  final double? secondaryPadBottom;

  // Dual layout settings
  final String dualLayoutDirection; // 'topBottom', 'sideBySide'
  final bool isPrimaryFirst;
  final double primaryRatio; // 0.1 to 0.9 (default 0.5)

  // Title / Chapter reference formatting
  final bool showTitle;
  final String titleColorHex;
  final double titleFontSize;
  final String titleFontFamily;
  final bool titleBold;
  final bool titleItalic;
  final String titleAlign;
  final String titleVerticalAlign;
  final double titleLineHeight;
  final double titlePadLeft;
  final double titlePadTop;
  final double titlePadRight;
  final double titlePadBottom;

  // Text Auto Shrink (shrinks font size to fit textbox without overflow)
  final bool autoShrinkText;

  // Background
  final String backgroundColorHex;
  final Uint8List? backgroundImageBytes;

  // Full-bleed slide image (for image slides or flattened image export mode)
  final Uint8List? imageSlideBytes;

  // Presenter notes (optional)
  final String? notes;

  PowerpointSlideData({
    this.title = '',
    this.content = '',
    this.isBlank = false,
    this.isSong = true,
    this.isDualVersion = false,
    this.secondaryTitle,
    this.secondaryContent,
    this.fontColorHex = 'FFFFFF',
    this.fontSize = 40.0,
    this.fontFamily = 'Segoe UI',
    this.isBold = true,
    this.isItalic = false,
    this.isUnderline = false,
    this.horizontalAlign = 'center',
    this.verticalAlign = 'center',
    this.lineHeight = 1.4,
    this.padLeft = 32.0,
    this.padTop = 16.0,
    this.padRight = 32.0,
    this.padBottom = 16.0,
    this.secondaryFontColorHex,
    this.secondaryFontSize,
    this.secondaryFontFamily,
    this.secondaryBold,
    this.secondaryItalic,
    this.secondaryUnderline,
    this.secondaryHorizontalAlign,
    this.secondaryVerticalAlign,
    this.secondaryLineHeight,
    this.secondaryPadLeft,
    this.secondaryPadTop,
    this.secondaryPadRight,
    this.secondaryPadBottom,
    this.dualLayoutDirection = 'topBottom',
    this.isPrimaryFirst = true,
    this.primaryRatio = 0.5,
    this.showTitle = false,
    this.titleColorHex = 'B0B0B0',
    this.titleFontSize = 20.0,
    this.titleFontFamily = 'Segoe UI',
    this.titleBold = true,
    this.titleItalic = false,
    this.titleAlign = 'center',
    this.titleVerticalAlign = 'top',
    this.titleLineHeight = 1.2,
    this.titlePadLeft = 16.0,
    this.titlePadTop = 16.0,
    this.titlePadRight = 16.0,
    this.titlePadBottom = 16.0,
    this.autoShrinkText = true,
    this.backgroundColorHex = '1E1E2E',
    this.backgroundImageBytes,
    Uint8List? imageSlideBytes,
    Uint8List? imageBytes,
    this.notes,
  }) : imageSlideBytes = imageSlideBytes ?? imageBytes;
}

/// Service that generates certified, standard-compliant Microsoft PowerPoint (`.pptx`) files
/// with native editable text boxes and visual fidelity matching the live projection.
class PowerpointExportService {
  /// Exports presentation directly to the specified file path.
  static Future<void> exportPresentation({
    required String outputPath,
    required List<PowerpointSlideData> slides,
    String aspectRatio = '16:9',
    double slideWidth = 1920,
    double slideHeight = 1080,
  }) async {
    final bytes = generatePptxBytes(
      slides: slides,
      aspectRatio: aspectRatio,
      slideWidth: slideWidth,
      slideHeight: slideHeight,
    );
    final file = File(outputPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  /// Generates the raw `.pptx` archive bytes.
  static Uint8List generatePptxBytes({
    required List<PowerpointSlideData> slides,
    String aspectRatio = '16:9',
    double slideWidth = 1920,
    double slideHeight = 1080,
  }) {
    // 1. Decode base certified OpenXML template archive
    final templateBytes = base64Decode(powerpointTemplateBase64);
    final srcArchive = ZipDecoder().decodeBytes(templateBytes);
    final outArchive = Archive();

    // Copy everything except dynamic slides, presentation.xml, presentation.xml.rels, and [Content_Types].xml
    final skipPatterns = [
      'ppt/slides/',
      '[Content_Types].xml',
      'ppt/presentation.xml',
      'ppt/_rels/presentation.xml.rels',
    ];

    for (final file in srcArchive.files) {
      bool skip = false;
      for (final pat in skipPatterns) {
        if (file.name == pat || file.name.startsWith(pat)) {
          skip = true;
          break;
        }
      }
      if (!skip) {
        outArchive.addFile(ArchiveFile(file.name, file.size, file.content));
      }
    }

    // 2. Calculate dimensions in EMUs (1 inch = 914,400 EMUs)
    final int cx;
    final int cy;
    if (aspectRatio == '4:3') {
      cx = 9144000;
      cy = 6858000;
    } else if (aspectRatio == '16:9') {
      cx = 12192000;
      cy = 6858000;
    } else {
      final double width = slideWidth > 0 ? slideWidth : 1920;
      final double height = slideHeight > 0 ? slideHeight : 1080;
      cx = (width * 9525).round();
      cy = (height * 9525).round();
    }

    // 3. [Content_Types].xml
    final contentTypesXml = _buildContentTypesXml(slides.length);
    _addFileToArchive(outArchive, '[Content_Types].xml', utf8.encode(contentTypesXml));

    // 4. ppt/presentation.xml
    final presentationXml = _buildPresentationXml(slides.length, cx, cy);
    _addFileToArchive(outArchive, 'ppt/presentation.xml', utf8.encode(presentationXml));

    // 5. ppt/_rels/presentation.xml.rels
    final presentationRelsXml = _buildPresentationRelsXml(slides.length);
    _addFileToArchive(outArchive, 'ppt/_rels/presentation.xml.rels', utf8.encode(presentationRelsXml));

    // 6. Dynamic slides, media assets, and slide rels
    for (int i = 0; i < slides.length; i++) {
      final slideIndex = i + 1;
      final slide = slides[i];

      String? mediaFileName;
      if (slide.imageSlideBytes != null) {
        mediaFileName = 'image_slide_$slideIndex.png';
        _addFileToArchive(outArchive, 'ppt/media/$mediaFileName', slide.imageSlideBytes!);
      } else if (slide.backgroundImageBytes != null) {
        mediaFileName = 'bg_$slideIndex.png';
        _addFileToArchive(outArchive, 'ppt/media/$mediaFileName', slide.backgroundImageBytes!);
      }

      final slideXml = _buildSlideXml(
        slide: slide,
        slideIndex: slideIndex,
        cx: cx,
        cy: cy,
        hasMedia: mediaFileName != null,
        slideWidth: slideWidth,
        slideHeight: slideHeight,
      );
      _addFileToArchive(outArchive, 'ppt/slides/slide$slideIndex.xml', utf8.encode(slideXml));

      final slideRelsXml = _buildSlideRelsXml(mediaFileName: mediaFileName);
      _addFileToArchive(outArchive, 'ppt/slides/_rels/slide$slideIndex.xml.rels', utf8.encode(slideRelsXml));
    }

    final zipEncoder = ZipEncoder();
    final encodedData = zipEncoder.encode(outArchive);
    return Uint8List.fromList(encodedData!);
  }

  static void _addFileToArchive(Archive archive, String path, List<int> bytes) {
    final normalizedPath = path.replaceAll('\\', '/');
    final archiveFile = ArchiveFile(normalizedPath, bytes.length, bytes);
    archive.addFile(archiveFile);
  }

  static String _buildContentTypesXml(int slideCount) {
    final buffer = StringBuffer();
    buffer.write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n');
    buffer.write('<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">\n');
    buffer.write('  <Default Extension="jpeg" ContentType="image/jpeg"/>\n');
    buffer.write('  <Default Extension="jpg" ContentType="image/jpeg"/>\n');
    buffer.write('  <Default Extension="png" ContentType="image/png"/>\n');
    buffer.write('  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>\n');
    buffer.write('  <Default Extension="xml" ContentType="application/xml"/>\n');
    buffer.write('  <Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>\n');
    buffer.write('  <Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/>\n');
    buffer.write('  <Override PartName="/ppt/presProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presProps+xml"/>\n');
    buffer.write('  <Override PartName="/ppt/viewProps.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.viewProps+xml"/>\n');
    buffer.write('  <Override PartName="/ppt/theme/theme1.xml" ContentType="application/vnd.openxmlformats-officedocument.theme+xml"/>\n');
    buffer.write('  <Override PartName="/ppt/tableStyles.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.tableStyles+xml"/>\n');

    // Certified slide layouts 1-11
    for (int l = 1; l <= 11; l++) {
      buffer.write('  <Override PartName="/ppt/slideLayouts/slideLayout$l.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/>\n');
    }

    // Slides
    for (int i = 1; i <= slideCount; i++) {
      buffer.write('  <Override PartName="/ppt/slides/slide$i.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>\n');
    }

    buffer.write('</Types>');
    return buffer.toString();
  }

  static String _buildPresentationXml(int slideCount, int cx, int cy) {
    final buffer = StringBuffer();
    buffer.write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n');
    buffer.write('<p:presentation xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" ');
    buffer.write('xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" ');
    buffer.write('xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">\n');
    buffer.write('  <p:sldMasterIdLst><p:sldMasterId id="2147483648" r:id="rId1"/></p:sldMasterIdLst>\n');
    buffer.write('  <p:sldIdLst>\n');

    for (int i = 0; i < slideCount; i++) {
      final slideId = 256 + i;
      final relId = 'rId${i + 10}';
      buffer.write('    <p:sldId id="$slideId" r:id="$relId"/>\n');
    }

    buffer.write('  </p:sldIdLst>\n');
    buffer.write('  <p:sldSz cx="$cx" cy="$cy"/>\n');
    buffer.write('  <p:notesSz cx="6858000" cy="9144000"/>\n');
    buffer.write('</p:presentation>');
    return buffer.toString();
  }

  static String _buildPresentationRelsXml(int slideCount) {
    final buffer = StringBuffer();
    buffer.write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n');
    buffer.write('<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n');
    buffer.write('  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideMaster" Target="slideMasters/slideMaster1.xml"/>\n');
    buffer.write('  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/presProps" Target="presProps.xml"/>\n');
    buffer.write('  <Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/viewProps" Target="viewProps.xml"/>\n');
    buffer.write('  <Relationship Id="rId5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" Target="theme/theme1.xml"/>\n');
    buffer.write('  <Relationship Id="rId6" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/tableStyles" Target="tableStyles.xml"/>\n');

    for (int i = 0; i < slideCount; i++) {
      final slideIndex = i + 1;
      final relId = 'rId${i + 10}';
      buffer.write('  <Relationship Id="$relId" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide$slideIndex.xml"/>\n');
    }

    buffer.write('</Relationships>');
    return buffer.toString();
  }

  static String _buildSlideXml({
    required PowerpointSlideData slide,
    required int slideIndex,
    required int cx,
    required int cy,
    required bool hasMedia,
    double slideWidth = 1920,
    double slideHeight = 1080,
  }) {
    final buffer = StringBuffer();
    buffer.write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n');
    buffer.write('<p:sld xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" ');
    buffer.write('xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" ');
    buffer.write('xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">\n');
    buffer.write('  <p:cSld>\n');

    // Background color
    final bgColor = _cleanHex(slide.backgroundColorHex);
    buffer.write('    <p:bg><p:bgPr><a:solidFill><a:srgbClr val="$bgColor"/></a:solidFill></p:bgPr></p:bg>\n');

    buffer.write('    <p:spTree>\n');
    buffer.write('      <p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>\n');
    buffer.write('      <p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>\n');

    int shapeId = 2;

    // Background or Slide Image
    if (hasMedia) {
      buffer.write('''      <p:pic>
        <p:nvPicPr>
          <p:cNvPr id="$shapeId" name="Picture $shapeId"/>
          <p:cNvPicPr><a:picLocks noChangeAspect="1"/></p:cNvPicPr>
          <p:nvPr/>
        </p:nvPicPr>
        <p:blipFill>
          <a:blip r:embed="rId2"/>
          <a:stretch><a:fillRect/></a:stretch>
        </p:blipFill>
        <p:spPr>
          <a:xfrm><a:off x="0" y="0"/><a:ext cx="$cx" cy="$cy"/></a:xfrm>
          <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
        </p:spPr>
      </p:pic>\n''');
      shapeId++;
    }

    // Scaling factor from virtual canvas pixels to OpenXML EMUs (1px @ 1920x1080 = 6350 EMUs)
    final double scaleX = cx / (slideWidth > 0 ? slideWidth : 1920.0);
    final double scaleY = cy / (slideHeight > 0 ? slideHeight : 1080.0);

    int toEmu(double px, double scale, int maxEmu) {
      if (px <= 0) return 0;
      final int emu = (px * scale).round();
      final int limit = (maxEmu * 0.45).round();
      return emu > limit ? limit : emu;
    }

    // If not a full-bleed image slide and not blank, generate native text boxes
    if (slide.imageSlideBytes == null && !slide.isBlank) {
      final bool hasTitle = slide.showTitle && slide.title.trim().isNotEmpty;
      final bool isTitleBottom = slide.titleVerticalAlign.toLowerCase() == 'bottom';

      // Slide-level vertical margins (~4% top & ~4% bottom) to prevent text from touching physical slide edges
      final int slideMarginTop = (cy * 0.04).round();
      final int slideMarginBottom = (cy * 0.04).round();
      final int usableCy = cy - slideMarginTop - slideMarginBottom;

      // Title bounds: dynamic height based on font size and line count (clamped to 5%–8% of usable slide height)
      final titleLines = slide.title.trim().split('\n');
      final double effectiveTitleLineHeight = slide.titleLineHeight > 0 ? slide.titleLineHeight : 1.2;
      // 1 pt = 12,700 EMUs
      final int rawTitleH = (slide.titleFontSize * 12700 * effectiveTitleLineHeight * titleLines.length * 1.3).round();
      final int minTitleH = (usableCy * 0.05).round();
      final int maxTitleH = (usableCy * 0.08).round();
      final int titleH = rawTitleH.clamp(minTitleH, maxTitleH);

      final int titleY = isTitleBottom ? (slideMarginTop + usableCy - titleH) : slideMarginTop;
      final int titleX = 0;
      final int titleW = cx;

      // Available content area bounds within overall slide margins
      final int contentY = hasTitle ? (isTitleBottom ? slideMarginTop : (slideMarginTop + titleH)) : slideMarginTop;
      final int contentH = hasTitle ? (usableCy - titleH) : usableCy;
      final int contentX = 0;
      final int contentW = cx;

      // 1. Title Text Box (Chapter reference or song title)
      if (hasTitle) {
        final titleXml = _buildTextBoxXml(
          shapeId: shapeId++,
          shapeName: slide.isDualVersion ? 'Dual Chapter $slideIndex' : 'Title $slideIndex',
          text: slide.title.trim(),
          x: titleX,
          y: titleY,
          width: titleW,
          height: titleH,
          fontSizePt: slide.titleFontSize,
          fontFamily: slide.titleFontFamily,
          fontColorHex: _cleanHex(slide.titleColorHex),
          isBold: slide.titleBold,
          isItalic: slide.titleItalic,
          isUnderline: false,
          horizontalAlign: slide.titleAlign,
          verticalAlign: slide.titleVerticalAlign,
          lineHeight: slide.titleLineHeight,
          lIns: toEmu(slide.titlePadLeft, scaleX, titleW),
          tIns: 0,
          rIns: toEmu(slide.titlePadRight, scaleX, titleW),
          bIns: 0,
          autoShrink: slide.autoShrinkText,
        );
        buffer.write(titleXml);
      }

      // Check if this is a dual version slide with both primary & secondary texts
      final bool isDual = slide.isDualVersion &&
          slide.secondaryContent != null &&
          slide.secondaryContent!.trim().isNotEmpty;

      if (isDual) {
        // ── DUAL SCRIPTURE / DUAL VERSION: SEPARATE TEXT BOXES ────────────
        final bool isTopBottom = slide.dualLayoutDirection != 'sideBySide';
        final double primaryRatio = slide.primaryRatio.clamp(0.15, 0.85);
        final bool isPrimaryFirst = slide.isPrimaryFirst;

        int primX, primY, primW, primH;
        int secX, secY, secW, secH;

        if (isTopBottom) {
          // Top-to-Bottom
          final int gapY = (contentH * 0.02).round();
          final int netH = contentH - gapY;
          final int hPrim = (netH * primaryRatio).round();
          final int hSec = netH - hPrim;

          if (isPrimaryFirst) {
            primX = contentX;
            primY = contentY;
            primW = contentW;
            primH = hPrim;

            secX = contentX;
            secY = contentY + hPrim + gapY;
            secW = contentW;
            secH = hSec;
          } else {
            secX = contentX;
            secY = contentY;
            secW = contentW;
            secH = hSec;

            primX = contentX;
            primY = contentY + hSec + gapY;
            primW = contentW;
            primH = hPrim;
          }
        } else {
          // Side-by-Side
          final int gapX = (contentW * 0.02).round();
          final int netW = contentW - gapX;
          final int wPrim = (netW * primaryRatio).round();
          final int wSec = netW - wPrim;

          if (isPrimaryFirst) {
            primX = contentX;
            primY = contentY;
            primW = wPrim;
            primH = contentH;

            secX = contentX + wPrim + gapX;
            secY = contentY;
            secW = wSec;
            secH = contentH;
          } else {
            secX = contentX;
            secY = contentY;
            secW = wSec;
            secH = contentH;

            primX = contentX + wSec + gapX;
            primY = contentY;
            primW = wPrim;
            primH = contentH;
          }
        }

        // Primary Verse Text Box
        final primaryBoxXml = _buildTextBoxXml(
          shapeId: shapeId++,
          shapeName: slide.isSong ? 'Primary Lyrics $slideIndex' : 'Primary Verse $slideIndex',
          text: slide.content.trim(),
          x: primX,
          y: primY,
          width: primW,
          height: primH,
          fontSizePt: slide.fontSize,
          fontFamily: slide.fontFamily,
          fontColorHex: _cleanHex(slide.fontColorHex),
          isBold: slide.isBold,
          isItalic: slide.isItalic,
          isUnderline: slide.isUnderline,
          horizontalAlign: slide.horizontalAlign,
          verticalAlign: slide.verticalAlign,
          lineHeight: slide.lineHeight,
          lIns: toEmu(slide.padLeft, scaleX, primW),
          tIns: 0,
          rIns: toEmu(slide.padRight, scaleX, primW),
          bIns: 0,
          autoShrink: slide.autoShrinkText,
        );
        buffer.write(primaryBoxXml);

        // Secondary Verse Text Box
        final secondaryBoxXml = _buildTextBoxXml(
          shapeId: shapeId++,
          shapeName: slide.isSong ? 'Secondary Lyrics $slideIndex' : 'Secondary Verse $slideIndex',
          text: slide.secondaryContent!.trim(),
          x: secX,
          y: secY,
          width: secW,
          height: secH,
          fontSizePt: slide.secondaryFontSize ?? slide.fontSize,
          fontFamily: slide.secondaryFontFamily ?? slide.fontFamily,
          fontColorHex: _cleanHex(slide.secondaryFontColorHex ?? slide.fontColorHex),
          isBold: slide.secondaryBold ?? slide.isBold,
          isItalic: slide.secondaryItalic ?? slide.isItalic,
          isUnderline: slide.secondaryUnderline ?? slide.isUnderline,
          horizontalAlign: slide.secondaryHorizontalAlign ?? slide.horizontalAlign,
          verticalAlign: slide.secondaryVerticalAlign ?? slide.verticalAlign,
          lineHeight: slide.secondaryLineHeight ?? slide.lineHeight,
          lIns: toEmu(slide.secondaryPadLeft ?? slide.padLeft, scaleX, secW),
          tIns: 0,
          rIns: toEmu(slide.secondaryPadRight ?? slide.padRight, scaleX, secW),
          bIns: 0,
          autoShrink: slide.autoShrinkText,
        );
        buffer.write(secondaryBoxXml);
      } else if (slide.content.trim().isNotEmpty) {
        // ── SINGLE VERSION CONTENT TEXT BOX ────────────────────────────────
        final contentXml = _buildTextBoxXml(
          shapeId: shapeId++,
          shapeName: slide.isSong ? 'Lyrics $slideIndex' : 'Verse $slideIndex',
          text: slide.content.trim(),
          x: contentX,
          y: contentY,
          width: contentW,
          height: contentH,
          fontSizePt: slide.fontSize,
          fontFamily: slide.fontFamily,
          fontColorHex: _cleanHex(slide.fontColorHex),
          isBold: slide.isBold,
          isItalic: slide.isItalic,
          isUnderline: slide.isUnderline,
          horizontalAlign: slide.horizontalAlign,
          verticalAlign: slide.verticalAlign,
          lineHeight: slide.lineHeight,
          lIns: toEmu(slide.padLeft, scaleX, contentW),
          tIns: 0,
          rIns: toEmu(slide.padRight, scaleX, contentW),
          bIns: 0,
          autoShrink: slide.autoShrinkText,
        );
        buffer.write(contentXml);
      }
    }

    buffer.write('    </p:spTree>\n');
    buffer.write('  </p:cSld>\n');
    buffer.write('  <p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr>\n');
    buffer.write('</p:sld>');
    return buffer.toString();
  }

  static String _buildTextBoxXml({
    required int shapeId,
    required String shapeName,
    required String text,
    required int x,
    required int y,
    required int width,
    required int height,
    required double fontSizePt,
    required String fontFamily,
    required String fontColorHex,
    required bool isBold,
    required bool isItalic,
    required bool isUnderline,
    required String horizontalAlign,
    required String verticalAlign,
    double lineHeight = 1.4,
    int lIns = 0,
    int tIns = 0,
    int rIns = 0,
    int bIns = 0,
    bool autoShrink = true,
  }) {
    // Map horizontal alignment: 'l', 'ctr', 'r', 'just'
    final String pptAlign = switch (horizontalAlign.toLowerCase()) {
      'left' => 'l',
      'right' => 'r',
      'justify' => 'just',
      _ => 'ctr',
    };

    // Map vertical alignment: 't', 'ctr', 'b'
    final String pptAnchor = switch (verticalAlign.toLowerCase()) {
      'top' => 't',
      'bottom' => 'b',
      _ => 'ctr',
    };

    // OpenXML paragraph line spacing percentage (100000 = 100% = 1.0)
    final double effectiveLineHeight = (lineHeight <= 0 ? 1.4 : lineHeight).clamp(0.8, 3.0);
    final int lnSpcVal = (effectiveLineHeight * 100000).round();

    // 1. Calculate available inner dimensions in points (1 pt = 12,700 EMUs)
    final double availWPt = ((width - lIns - rIns) > 0 ? (width - lIns - rIns) : width) / 12700.0;
    final double availHPt = ((height - tIns - bIns) > 0 ? (height - tIns - bIns) : height) / 12700.0;

    // 2. Estimate total lines including word/character wrapping at requested fontSizePt
    final lines = text.split('\n');
    double estimatedLines = 0.0;
    for (final line in lines) {
      if (line.trim().isEmpty) {
        estimatedLines += 1.0;
      } else {
        // Average character width in OpenXML sans-serif fonts is ~0.55 * fontSizePt
        final double maxCharsPerLine = (availWPt / (fontSizePt * 0.55)).clamp(10.0, 500.0);
        final double lineWraps = (line.length / maxCharsPerLine).ceilToDouble();
        estimatedLines += lineWraps > 0 ? lineWraps : 1.0;
      }
    }

    // 3. Calculate total required height in points at font size fontSizePt
    final double reqHPt = estimatedLines * fontSizePt * effectiveLineHeight;

    // 4. Calculate scale factor if text height exceeds available box height
    final double scale = (reqHPt > availHPt && availHPt > 0 && reqHPt > 0)
        ? (availHPt / reqHPt).clamp(0.25, 1.0)
        : 1.0;

    final double fittedFontSizePt = (fontSizePt * scale).clamp(8.0, fontSizePt);
    final int sz = (fittedFontSizePt * 100).round();
    final int fontScaleVal = (scale * 100000).round();

    // Autofit element: normAutofit with fontScale attribute ensures immediate fit on file load
    final String autofitXml = scale < 0.999
        ? '<a:normAutofit fontScale="$fontScaleVal" lnSpcReduction="0"/>'
        : '<a:normAutofit fontScale="100000" lnSpcReduction="0"/>';

    final buffer = StringBuffer();
    buffer.write('''      <p:sp>
        <p:nvSpPr>
          <p:cNvPr id="$shapeId" name="$shapeName"/>
          <p:cNvSpPr txBox="1"/>
          <p:nvPr/>
        </p:nvSpPr>
        <p:spPr>
          <a:xfrm><a:off x="$x" y="$y"/><a:ext cx="$width" cy="$height"/></a:xfrm>
          <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
          <a:noFill/>
        </p:spPr>
        <p:txBody>
          <a:bodyPr vert="horz" wrap="square" lIns="$lIns" tIns="$tIns" rIns="$rIns" bIns="$bIns" rtlCol="0" anchor="$pptAnchor">
            $autofitXml
          </a:bodyPr>
          <a:lstStyle/>\n''');

    final String defRPrXml = '<a:defRPr lang="en-US" sz="$sz"${isBold ? ' b="1"' : ''}${isItalic ? ' i="1"' : ''}${isUnderline ? ' u="sng"' : ''}><a:solidFill><a:srgbClr val="$fontColorHex"/></a:solidFill><a:latin typeface="$fontFamily"/><a:cs typeface="$fontFamily"/></a:defRPr>';

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) {
        // Empty line
        buffer.write('''          <a:p>
            <a:pPr algn="$pptAlign">
              <a:lnSpc><a:spcPct val="$lnSpcVal"/></a:lnSpc>
              $defRPrXml
            </a:pPr>
            <a:endParaRPr lang="en-US" sz="$sz"/>
          </a:p>\n''');
      } else {
        final escaped = _escapeXml(line);
        buffer.write('''          <a:p>
            <a:pPr algn="$pptAlign">
              <a:lnSpc><a:spcPct val="$lnSpcVal"/></a:lnSpc>
              $defRPrXml
            </a:pPr>
            <a:r>
              <a:rPr lang="en-US"/>
              <a:t>$escaped</a:t>
            </a:r>
          </a:p>\n''');
      }
    }

    buffer.write('''        </p:txBody>
      </p:sp>\n''');
    return buffer.toString();
  }

  static String _buildSlideRelsXml({String? mediaFileName}) {
    final buffer = StringBuffer();
    buffer.write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n');
    buffer.write('<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n');
    // Reference slideLayout7 (the certified clean blank layout)
    buffer.write('  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slideLayout" Target="../slideLayouts/slideLayout7.xml"/>\n');

    if (mediaFileName != null) {
      buffer.write('  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="../media/$mediaFileName"/>\n');
    }

    buffer.write('</Relationships>');
    return buffer.toString();
  }

  static String _cleanHex(String hex) {
    var cleaned = hex.replaceAll('#', '').trim();
    if (cleaned.length == 8) {
      // ARGB -> RRGGBB (drop alpha)
      cleaned = cleaned.substring(2);
    }
    if (cleaned.length < 6) {
      cleaned = cleaned.padLeft(6, '0');
    }
    return cleaned.toUpperCase();
  }

  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
