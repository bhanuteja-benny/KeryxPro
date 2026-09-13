import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:keryxpro/features/setlist/data/powerpoint_export_service.dart';

void main() {
  test('PowerpointExportService generates valid PPTX archive with native text boxes', () {
    final slides = [
      PowerpointSlideData(
        title: 'Amazing Grace',
        content: 'Amazing grace, how sweet the sound\nThat saved a wretch like me',
        fontColorHex: 'FFFFFF',
        fontSize: 40.0,
        fontFamily: 'Segoe UI',
        isBold: true,
        showTitle: true,
        titleColorHex: 'FFB300',
        titleFontSize: 20.0,
        backgroundColorHex: '1E1E2E',
      ),
      PowerpointSlideData(
        title: 'John 3:16',
        content: 'For God so loved the world that he gave his one and only Son',
        fontColorHex: 'E0E0FF',
        fontSize: 36.0,
        fontFamily: 'Segoe UI',
        isBold: true,
        showTitle: true,
        titleColorHex: '64B5F6',
        backgroundColorHex: '0A192F',
        isSong: false,
      ),
    ];

    final pptxBytes = PowerpointExportService.generatePptxBytes(
      slides: slides,
      aspectRatio: '16:9',
      slideWidth: 1920,
      slideHeight: 1080,
    );

    expect(pptxBytes.isNotEmpty, isTrue);

    // Unpack archive and inspect files
    final archive = ZipDecoder().decodeBytes(pptxBytes);
    final fileNames = archive.files.map((f) => f.name).toSet();

    // Verify critical OpenXML structure
    expect(fileNames.contains('[Content_Types].xml'), isTrue);
    expect(fileNames.contains('_rels/.rels'), isTrue);
    expect(fileNames.contains('ppt/presentation.xml'), isTrue);
    expect(fileNames.contains('ppt/_rels/presentation.xml.rels'), isTrue);
    expect(fileNames.contains('ppt/theme/theme1.xml'), isTrue);
    expect(fileNames.contains('ppt/slideMasters/slideMaster1.xml'), isTrue);
    expect(fileNames.contains('ppt/slideLayouts/slideLayout7.xml'), isTrue);
    expect(fileNames.contains('ppt/slides/slide1.xml'), isTrue);
    expect(fileNames.contains('ppt/slides/slide2.xml'), isTrue);
    expect(fileNames.contains('ppt/slides/_rels/slide1.xml.rels'), isTrue);
    expect(fileNames.contains('ppt/slides/_rels/slide2.xml.rels'), isTrue);

    // Verify all XML files are strictly parseable without syntax errors
    for (final file in archive.files) {
      if (file.name.endsWith('.xml') || file.name.endsWith('.rels')) {
        final content = utf8.decode(file.content as List<int>);
        expect(() => XmlDocument.parse(content), returnsNormally,
            reason: 'Failed to parse XML for file ${file.name}');
      }
    }

    // Inspect slide 1 XML for native text boxes and text content
    final slide1File = archive.findFile('ppt/slides/slide1.xml')!;
    final slide1Content = utf8.decode(slide1File.content as List<int>);
    expect(slide1Content, contains('txBox="1"'));
    expect(slide1Content, contains('Amazing Grace'));
    expect(slide1Content, contains('Amazing grace, how sweet the sound'));
    expect(slide1Content, contains('That saved a wretch like me'));
    expect(slide1Content, contains('1E1E2E')); // Background color

    // Inspect slide 2 XML for scripture content
    final slide2File = archive.findFile('ppt/slides/slide2.xml')!;
    final slide2Content = utf8.decode(slide2File.content as List<int>);
    expect(slide2Content, contains('txBox="1"'));
    expect(slide2Content, contains('John 3:16'));
    expect(slide2Content, contains('For God so loved the world'));
  });

  test('PowerpointExportService handles image slides and background images', () {
    final dummyPng = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82
    ]);

    final slides = [
      PowerpointSlideData(
        title: 'Background Image Slide',
        content: 'Lyrics over image',
        backgroundImageBytes: dummyPng,
      ),
      PowerpointSlideData(
        title: 'Full Image Slide',
        imageSlideBytes: dummyPng,
      ),
    ];

    final pptxBytes = PowerpointExportService.generatePptxBytes(
      slides: slides,
      aspectRatio: '16:9',
    );

    final archive = ZipDecoder().decodeBytes(pptxBytes);
    final fileNames = archive.files.map((f) => f.name).toSet();

    expect(fileNames.contains('ppt/media/bg_1.png'), isTrue);
    expect(fileNames.contains('ppt/media/image_slide_2.png'), isTrue);

    // Slide 1 has both picture and text
    final slide1Content = utf8.decode(archive.findFile('ppt/slides/slide1.xml')!.content as List<int>);
    expect(slide1Content, contains('p:pic'));
    expect(slide1Content, contains('txBox="1"'));
    expect(slide1Content, contains('Lyrics over image'));

    // Slide 2 is image-only
    final slide2Content = utf8.decode(archive.findFile('ppt/slides/slide2.xml')!.content as List<int>);
    expect(slide2Content, contains('p:pic'));
  });

  test('PowerpointExportService creates separate textboxes and distinct styles for dual scripture', () {
    final slides = [
      // Top-Bottom Dual Scripture
      PowerpointSlideData(
        title: 'Genesis 1:1',
        content: 'In the beginning God created the heaven and the earth.',
        secondaryContent: 'ఆదియందు దేవుడు భూమ్యాకాశములను సృజించెను.',
        isSong: false,
        isDualVersion: true,
        showTitle: true,
        titleColorHex: '64B5F6',
        titleFontSize: 20.0,
        titleFontFamily: 'Segoe UI',
        titleBold: true,
        // Primary version style (English)
        fontSize: 36.0,
        fontFamily: 'Segoe UI',
        fontColorHex: 'FFFFFF',
        isBold: true,
        horizontalAlign: 'center',
        // Secondary version style (Telugu / Regional)
        secondaryFontSize: 32.0,
        secondaryFontFamily: 'Gautami',
        secondaryFontColorHex: 'FFE082',
        secondaryBold: false,
        secondaryHorizontalAlign: 'center',
        // Layout
        dualLayoutDirection: 'topBottom',
        isPrimaryFirst: true,
        primaryRatio: 0.5,
        backgroundColorHex: '101A26',
      ),
      // Side-by-Side Dual Scripture
      PowerpointSlideData(
        title: 'Psalm 23:1',
        content: 'The LORD is my shepherd; I shall not want.',
        secondaryContent: 'యెహోవా నా కాపరి నాకు లేమి కలుగదు.',
        isSong: false,
        isDualVersion: true,
        showTitle: true,
        titleColorHex: '81C784',
        // Primary version style
        fontSize: 30.0,
        fontFamily: 'Segoe UI',
        fontColorHex: 'FFFFFF',
        // Secondary version style
        secondaryFontSize: 28.0,
        secondaryFontFamily: 'Gautami',
        secondaryFontColorHex: 'A5D6A7',
        // Layout
        dualLayoutDirection: 'sideBySide',
        isPrimaryFirst: true,
        primaryRatio: 0.5,
        backgroundColorHex: '1B261A',
      ),
    ];

    final pptxBytes = PowerpointExportService.generatePptxBytes(
      slides: slides,
      aspectRatio: '16:9',
    );

    expect(pptxBytes.isNotEmpty, isTrue);

    final archive = ZipDecoder().decodeBytes(pptxBytes);

    // Verify slide 1 (Top-Bottom) has 3 separate textboxes: Title, Primary, and Secondary
    final slide1File = archive.findFile('ppt/slides/slide1.xml')!;
    final slide1Content = utf8.decode(slide1File.content as List<int>);

    // Strictly parseable XML
    expect(() => XmlDocument.parse(slide1Content), returnsNormally);

    // Check separate shape names
    expect(slide1Content, contains('name="Dual Chapter 1"'));
    expect(slide1Content, contains('name="Primary Verse 1"'));
    expect(slide1Content, contains('name="Secondary Verse 1"'));

    // Check texts
    expect(slide1Content, contains('Genesis 1:1'));
    expect(slide1Content, contains('In the beginning God created'));
    expect(slide1Content, contains('ఆదియందు దేవుడు భూమ్యాకాశములను సృజించెను.'));

    // Check distinct font styles
    expect(slide1Content, contains('val="FFFFFF"')); // Primary color
    expect(slide1Content, contains('val="FFE082"')); // Secondary color
    expect(slide1Content, contains('typeface="Gautami"')); // Secondary font
    expect(slide1Content, contains('typeface="Segoe UI"')); // Primary font

    // Verify slide 2 (Side-by-Side) has 3 separate textboxes
    final slide2File = archive.findFile('ppt/slides/slide2.xml')!;
    final slide2Content = utf8.decode(slide2File.content as List<int>);
    expect(() => XmlDocument.parse(slide2Content), returnsNormally);

    expect(slide2Content, contains('name="Dual Chapter 2"'));
    expect(slide2Content, contains('name="Primary Verse 2"'));
    expect(slide2Content, contains('name="Secondary Verse 2"'));
    expect(slide2Content, contains('Psalm 23:1'));
    expect(slide2Content, contains('The LORD is my shepherd'));
    expect(slide2Content, contains('యెహోవా నా కాపరి నాకు లేమి కలుగదు.'));
    expect(slide2Content, contains('val="A5D6A7"'));
  });

  test('PowerpointExportService applies custom line heights to dual scripture and lyrics paragraphs', () {
    final slides = [
      PowerpointSlideData(
        title: 'John 1:1',
        content: 'In the beginning was the Word,\nand the Word was with God,\nand the Word was God.',
        secondaryContent: 'ఆదియందు వాక్యముండెను,\nఆ వాక్యము దేవునియొద్ద ఉండెను,\nఆ వాక్యము దేవుడై యుండెను.',
        isSong: false,
        isDualVersion: true,
        showTitle: true,
        titleLineHeight: 1.1,        // 110%
        lineHeight: 1.6,             // 160% (primary)
        secondaryLineHeight: 1.35,   // 135% (secondary)
      ),
    ];

    final pptxBytes = PowerpointExportService.generatePptxBytes(
      slides: slides,
      aspectRatio: '16:9',
    );

    expect(pptxBytes.isNotEmpty, isTrue);

    final archive = ZipDecoder().decodeBytes(pptxBytes);
    final slide1File = archive.findFile('ppt/slides/slide1.xml')!;
    final slide1Content = utf8.decode(slide1File.content as List<int>);

    expect(() => XmlDocument.parse(slide1Content), returnsNormally);

    // Title line spacing (1.1 -> 110000)
    expect(slide1Content, contains('<a:lnSpc><a:spcPct val="110000"/></a:lnSpc>'));

    // Primary verse line spacing (1.6 -> 160000)
    expect(slide1Content, contains('<a:lnSpc><a:spcPct val="160000"/></a:lnSpc>'));

    // Secondary verse line spacing (1.35 -> 135000)
    expect(slide1Content, contains('<a:lnSpc><a:spcPct val="135000"/></a:lnSpc>'));
  });

  test('PowerpointExportService applies padding insets and normAutofit auto-shrink to textboxes', () {
    final slides = [
      PowerpointSlideData(
        title: 'Genesis 1:1',
        content: 'In the beginning God created the heaven and the earth.',
        secondaryContent: 'ఆదియందు దేవుడు భూమ్యాకాశములను సృజించెను.',
        isSong: false,
        isDualVersion: true,
        showTitle: true,
        // Title padding: 16px -> 101600 EMUs
        titlePadLeft: 16.0,
        titlePadTop: 16.0,
        titlePadRight: 16.0,
        titlePadBottom: 16.0,
        // Primary verse padding: 32px left/right -> 203200 EMUs, 16px top/bottom -> 101600 EMUs
        padLeft: 32.0,
        padTop: 16.0,
        padRight: 32.0,
        padBottom: 16.0,
        // Secondary verse padding: 48px left/right -> 304800 EMUs, 24px top/bottom -> 152400 EMUs
        secondaryPadLeft: 48.0,
        secondaryPadTop: 24.0,
        secondaryPadRight: 48.0,
        secondaryPadBottom: 24.0,
        autoShrinkText: true,
      ),
    ];

    final pptxBytes = PowerpointExportService.generatePptxBytes(
      slides: slides,
      aspectRatio: '16:9',
      slideWidth: 1920,
      slideHeight: 1080,
    );

    expect(pptxBytes.isNotEmpty, isTrue);

    final archive = ZipDecoder().decodeBytes(pptxBytes);
    final slide1File = archive.findFile('ppt/slides/slide1.xml')!;
    final slide1Content = utf8.decode(slide1File.content as List<int>);

    expect(() => XmlDocument.parse(slide1Content), returnsNormally);

    // Verify all textboxes have <a:normAutofit for text auto shrink
    expect(slide1Content, contains('<a:normAutofit'));
    // Should NOT have <a:spAutoFit/>
    expect(slide1Content.contains('<a:spAutoFit/>'), isFalse);

    // Verify Title padding insets (16px * 6350 = 101600, tIns/bIns = 0)
    expect(slide1Content, contains('lIns="101600" tIns="0" rIns="101600" bIns="0"'));

    // Verify Primary verse padding insets (32px * 6350 = 203200, tIns/bIns = 0)
    expect(slide1Content, contains('lIns="203200" tIns="0" rIns="203200" bIns="0"'));

    // Verify Secondary verse padding insets (48px * 6350 = 304800, tIns/bIns = 0)
    expect(slide1Content, contains('lIns="304800" tIns="0" rIns="304800" bIns="0"'));
  });

  test('PowerpointExportService calculates dynamic title height and fontScale for oversized text', () {
    final longVerseContent = List.generate(15, (i) => 'Line $i: This is a very long line of verse text that will wrap multiple times.').join('\n');
    final slides = [
      PowerpointSlideData(
        title: 'John 3:16',
        content: longVerseContent,
        showTitle: true,
        titleFontSize: 20.0,
        fontSize: 48.0, // Large initial font size for long text
        lineHeight: 1.5,
      ),
    ];

    final pptxBytes = PowerpointExportService.generatePptxBytes(
      slides: slides,
      aspectRatio: '16:9',
      slideWidth: 1920,
      slideHeight: 1080,
    );

    expect(pptxBytes.isNotEmpty, isTrue);

    final archive = ZipDecoder().decodeBytes(pptxBytes);
    final slide1File = archive.findFile('ppt/slides/slide1.xml')!;
    final slide1Content = utf8.decode(slide1File.content as List<int>);

    expect(() => XmlDocument.parse(slide1Content), returnsNormally);

    // Title box should have height cy * 0.05 to 0.08 (342900 to 548640 EMUs), NOT hardcoded 14% (960120 EMUs)
    expect(slide1Content.contains('cy="960120"'), isFalse, reason: 'Title height should no longer be hardcoded 14%');

    // Oversized text should have fontScale attribute in normAutofit
    expect(slide1Content, contains('fontScale="'));
  });
}
