import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/media_sync_manager.dart';
import '../../live_controller/domain/slide.dart';
import '../../live_controller/presentation/live_projector_providers.dart';
import '../../live_controller/presentation/slide_utils.dart';
import '../../presentation/presentation/widgets/projector_view.dart';
import '../../settings/data/presentation_settings.dart';
import '../../settings/presentation/presentation_settings_provider.dart';
import '../../settings/presentation/projection_provider.dart';
import '../data/powerpoint_export_service.dart';
import '../data/setlist_item.dart';
import 'setlist_providers.dart';

enum _ExportStep { configure, exporting, completed, error }
enum _ExportScope { entireSetlist, selectedItem }
enum _ExportFormat { textboxes, images }

class ExportPowerpointDialog extends ConsumerStatefulWidget {
  /// Optional pre-filtered slides (e.g. from an individual song)
  final List<Slide>? initialSlides;
  final String? defaultTitle;

  const ExportPowerpointDialog({
    super.key,
    this.initialSlides,
    this.defaultTitle,
  });

  @override
  ConsumerState<ExportPowerpointDialog> createState() => _ExportPowerpointDialogState();
}

class _ExportPowerpointDialogState extends ConsumerState<ExportPowerpointDialog> {
  _ExportStep _currentStep = _ExportStep.configure;
  _ExportScope _selectedScope = _ExportScope.entireSetlist;
  _ExportFormat _selectedFormat = _ExportFormat.textboxes;

  int? _selectedPresetId;
  bool _includeBlankSlides = true;

  // Export progress state
  int _currentSlideIndex = 0;
  int _totalSlides = 0;
  String _currentSlideTitle = '';
  Slide? _renderingSlide;
  bool _isCancelled = false;
  String? _exportedFilePath;
  String? _errorMessage;

  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Default preset from Monitor 1 configuration
    final projectionState = ref.read(projectionProvider);
    _selectedPresetId = projectionState.config.monitor1PresetId;

    if (widget.initialSlides != null) {
      _selectedScope = _ExportScope.selectedItem;
    }
  }

  List<Slide> _gatherSlidesToExport(PresentationSettings settings) {
    if (widget.initialSlides != null) {
      return _filterBlankSlides(widget.initialSlides!);
    }

    final setlist = ref.read(setlistProvider);
    final selection = ref.read(setlistSelectionProvider);

    if (_selectedScope == _ExportScope.selectedItem && selection.isNotEmpty) {
      final selectedItemIndex = selection.first;
      if (selectedItemIndex >= 0 && selectedItemIndex < setlist.length) {
        final item = setlist[selectedItemIndex];
        final itemSlides = _extractSlidesFromItem(item);
        return _filterBlankSlides(itemSlides);
      }
    }

    // Default: Entire setlist
    final allSlides = ref.read(currentSlidesProvider);
    return _filterBlankSlides(allSlides);
  }

  List<Slide> _extractSlidesFromItem(SetlistItem item) {
    switch (item) {
      case SongSetlistItem(:final song, :final isFavorite):
        final isSong = song.author != 'Bible';
        return SlideUtils.parseLyrics(
          song.lyrics,
          song.title,
          isSong: isSong,
          isFavorite: isFavorite,
          isDualVersion: song.isDualVersion,
          secondaryTitle: song.secondaryTitle,
          secondaryLyrics: song.secondaryLyrics,
        );
      case ImageSetlistItem(:final imagePath, :final layout, :final alignment, :final isFavorite):
        final title = imagePath.split(RegExp(r'[/\\]')).last;
        return [
          Slide(
            title: title,
            shortcut: 'IMG',
            content: 'IMAGE:$imagePath|$layout|$alignment',
            type: SlideType.other,
            isBlank: false,
            isSong: false,
            isFavorite: isFavorite,
          ),
          Slide.blank(title: title, isSong: false, isFavorite: isFavorite),
        ];
      case WindowSetlistItem(:final windowHandle, :final windowTitle, :final layout, :final contentOnly, :final isFavorite):
        return [
          Slide(
            title: windowTitle,
            shortcut: 'WIN',
            content: 'WINDOW:$windowHandle|${Uri.encodeComponent(windowTitle)}|$layout|${contentOnly ? '1' : '0'}',
            type: SlideType.other,
            isBlank: false,
            isSong: false,
            isFavorite: isFavorite,
          ),
          Slide.blank(title: windowTitle, isSong: false, isFavorite: isFavorite),
        ];
    }
  }

  List<Slide> _filterBlankSlides(List<Slide> slides) {
    if (_includeBlankSlides) return List.from(slides);
    return slides.where((s) => !s.isBlank && s.content.trim().isNotEmpty).toList();
  }

  String _suggestFileName() {
    if (widget.defaultTitle != null && widget.defaultTitle!.isNotEmpty) {
      return widget.defaultTitle!;
    }
    final activeSetlistName = ref.read(activeSetlistNameProvider);
    if (activeSetlistName != null && activeSetlistName.trim().isNotEmpty) {
      return activeSetlistName.trim();
    }
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return 'KeryxPro_Setlist_$dateStr';
  }

  static String _intToHex(int colorValue) {
    final r = ((colorValue >> 16) & 0xFF).toRadixString(16).padLeft(2, '0');
    final g = ((colorValue >> 8) & 0xFF).toRadixString(16).padLeft(2, '0');
    final b = (colorValue & 0xFF).toRadixString(16).padLeft(2, '0');
    return '$r$g$b'.toUpperCase();
  }

  Future<void> _startExport(PresentationSettings settings) async {
    final slidesToExport = _gatherSlidesToExport(settings);
    if (slidesToExport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No slides to export.')),
      );
      return;
    }

    // Prompt user for file save destination
    final suggestedName = _suggestFileName().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    String? outputPath = await FilePicker.saveFile(
      dialogTitle: 'Export PowerPoint Presentation',
      fileName: '$suggestedName.pptx',
      type: FileType.custom,
      allowedExtensions: ['pptx'],
    );

    if (outputPath == null || outputPath.trim().isEmpty) return; // User cancelled

    if (!outputPath.toLowerCase().endsWith('.pptx')) {
      outputPath = '$outputPath.pptx';
    }

    setState(() {
      _currentStep = _ExportStep.exporting;
      _currentSlideIndex = 0;
      _totalSlides = slidesToExport.length;
      _currentSlideTitle = slidesToExport.first.title;
      _renderingSlide = slidesToExport.first;
      _isCancelled = false;
      _exportedFilePath = outputPath;
      _errorMessage = null;
    });

    final mediaSync = ref.read(mediaSyncManagerProvider);
    final List<PowerpointSlideData> generatedSlides = [];

    try {
      if (_selectedFormat == _ExportFormat.textboxes) {
        // ── MODE A: Native Text Boxes (Editable, Copyable, 0 Repair Warnings) ──
        final Map<String, Uint8List> imageCache = {};

        Future<Uint8List?> loadImage(String rawPath) async {
          if (rawPath.isEmpty) return null;
          final path = mediaSync.resolveMediaPath(rawPath);
          if (path.isEmpty) return null;
          if (imageCache.containsKey(path)) return imageCache[path];
          final file = File(path);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            imageCache[path] = bytes;
            return bytes;
          }
          return null;
        }

        // Preload preset background images
        Uint8List? songBgBytes;
        if (settings.isSongImageEnabled && settings.songBackgroundImage.isNotEmpty) {
          songBgBytes = await loadImage(settings.songBackgroundImage);
        }

        Uint8List? scriptureBgBytes;
        if (settings.isScriptureImageEnabled && settings.scriptureBackgroundImage.isNotEmpty) {
          scriptureBgBytes = await loadImage(settings.scriptureBackgroundImage);
        }

        Uint8List? dualScriptureBgBytes;
        if (settings.isDualScriptureImageEnabled && settings.dualScriptureBackgroundImage.isNotEmpty) {
          dualScriptureBgBytes = await loadImage(settings.dualScriptureBackgroundImage);
        }

        Uint8List? blankBgBytes;
        if (settings.isBlankImageEnabled && settings.blankBackgroundImage.isNotEmpty) {
          blankBgBytes = await loadImage(settings.blankBackgroundImage);
        }

        for (int i = 0; i < slidesToExport.length; i++) {
          if (_isCancelled) return;
          final slide = slidesToExport[i];

          setState(() {
            _currentSlideIndex = i + 1;
            _currentSlideTitle = slide.title;
            _renderingSlide = slide;
          });

          // Check for image slide
          if (slide.content.startsWith('IMAGE:')) {
            final rawPath = slide.content.split('|')[0].substring(6);
            final imgBytes = await loadImage(rawPath);
            generatedSlides.add(PowerpointSlideData(
              title: slide.title,
              imageSlideBytes: imgBytes,
            ));
            continue;
          }

          if (slide.isBlank) {
            generatedSlides.add(PowerpointSlideData(
              title: slide.title,
              isBlank: true,
              backgroundColorHex: _intToHex(settings.blankBackgroundColor),
              backgroundImageBytes: blankBgBytes,
            ));
            continue;
          }

          if (slide.isDualVersion && !slide.isSong) {
            // ── DUAL SCRIPTURE: Separate textboxes & distinct styles ──
            String primaryText = slide.content;
            String secText = slide.secondaryContent ?? '';
            if (primaryText.contains('\n[DUAL_SEP]\n')) {
              final parts = primaryText.split('\n[DUAL_SEP]\n');
              primaryText = parts[0];
              if (parts.length > 1 && secText.isEmpty) {
                secText = parts[1];
              }
            }

            final isTopBottom = settings.dualScriptureLayoutDirection == 'topBottom';
            final isPrimaryFirst = isTopBottom
                ? (settings.dualScripturePrimaryPosition == 'top' || settings.dualScripturePrimaryPosition == 'primaryFirst')
                : (settings.dualScripturePrimaryPosition == 'left' || settings.dualScripturePrimaryPosition == 'primaryFirst');

            generatedSlides.add(PowerpointSlideData(
              title: slide.title,
              content: primaryText,
              isSong: false,
              isDualVersion: true,
              secondaryTitle: slide.secondaryTitle,
              secondaryContent: secText,
              // Layout settings
              dualLayoutDirection: settings.dualScriptureLayoutDirection,
              isPrimaryFirst: isPrimaryFirst,
              primaryRatio: settings.dualScripturePrimaryRatio,
              // Primary Verse Styling
              fontFamily: settings.primaryVerseFontFamily.isNotEmpty ? settings.primaryVerseFontFamily : 'Segoe UI',
              fontSize: (settings.primaryVerseFontSize * 0.5).clamp(14.0, 72.0),
              fontColorHex: _intToHex(settings.primaryVerseFontColor),
              isBold: settings.primaryVerseBold,
              isItalic: settings.primaryVerseItalic,
              isUnderline: settings.primaryVerseUnderline,
              horizontalAlign: settings.primaryVerseAlignment,
              verticalAlign: settings.primaryVerseVerticalAlignment,
              lineHeight: settings.primaryVerseLineHeight > 0 ? settings.primaryVerseLineHeight : 1.4,
              // Secondary Verse Styling
              secondaryFontFamily: settings.secVerseFontFamily.isNotEmpty ? settings.secVerseFontFamily : 'Segoe UI',
              secondaryFontSize: (settings.secVerseFontSize * 0.5).clamp(14.0, 72.0),
              secondaryFontColorHex: _intToHex(settings.secVerseFontColor),
              secondaryBold: settings.secVerseBold,
              secondaryItalic: settings.secVerseItalic,
              secondaryUnderline: settings.secVerseUnderline,
              secondaryHorizontalAlign: settings.secVerseAlignment,
              secondaryVerticalAlign: settings.secVerseVerticalAlignment,
              secondaryLineHeight: settings.secVerseLineHeight > 0 ? settings.secVerseLineHeight : 1.4,
              // Dual Chapter Reference (Title) Styling
              showTitle: settings.showDualChapter,
              titleFontFamily: settings.dualChapterFontFamily.isNotEmpty ? settings.dualChapterFontFamily : 'Segoe UI',
              titleFontSize: (settings.dualChapterFontSize * 0.5).clamp(12.0, 36.0),
              titleColorHex: _intToHex(settings.dualChapterFontColor),
              titleBold: settings.dualChapterBold,
              titleItalic: settings.dualChapterItalic,
              titleAlign: settings.dualChapterAlignment,
              titleVerticalAlign: settings.dualChapterVerticalAlignment,
              titleLineHeight: settings.dualChapterLineHeight > 0 ? settings.dualChapterLineHeight : 1.2,
              // Background
              backgroundColorHex: _intToHex(settings.dualScriptureBackgroundColor),
              backgroundImageBytes: dualScriptureBgBytes,
            ));
          } else if (slide.isSong) {
            generatedSlides.add(PowerpointSlideData(
              title: slide.title,
              content: slide.content,
              isSong: true,
              isDualVersion: slide.isDualVersion,
              secondaryTitle: slide.secondaryTitle,
              secondaryContent: slide.secondaryContent,
              // Font styling
              fontFamily: settings.lyricsFontFamily.isNotEmpty ? settings.lyricsFontFamily : 'Segoe UI',
              fontSize: (settings.lyricsFontSize * 0.5).clamp(16.0, 72.0),
              fontColorHex: _intToHex(settings.lyricsFontColor),
              isBold: settings.lyricsBold,
              isItalic: settings.lyricsItalic,
              isUnderline: settings.lyricsUnderline,
              horizontalAlign: settings.lyricsAlignment,
              verticalAlign: settings.lyricsVerticalAlignment,
              lineHeight: settings.lyricsLineHeight > 0 ? settings.lyricsLineHeight : 1.4,
              // Secondary font styling (if dual version song)
              secondaryFontFamily: settings.lyricsFontFamily.isNotEmpty ? settings.lyricsFontFamily : 'Segoe UI',
              secondaryFontSize: (settings.lyricsFontSize * 0.45).clamp(14.0, 60.0),
              secondaryFontColorHex: _intToHex(settings.lyricsFontColor),
              secondaryBold: false,
              secondaryItalic: true,
              secondaryLineHeight: settings.lyricsLineHeight > 0 ? settings.lyricsLineHeight : 1.4,
              // Title styling
              showTitle: settings.showTitle,
              titleFontFamily: settings.titleFontFamily.isNotEmpty ? settings.titleFontFamily : 'Segoe UI',
              titleFontSize: (settings.titleFontSize * 0.5).clamp(12.0, 36.0),
              titleColorHex: _intToHex(settings.titleFontColor),
              titleBold: settings.titleBold,
              titleItalic: settings.titleItalic,
              titleAlign: settings.titleAlignment,
              titleVerticalAlign: settings.titleVerticalAlignment,
              titleLineHeight: settings.titleLineHeight > 0 ? settings.titleLineHeight : 1.2,
              // Background
              backgroundColorHex: _intToHex(settings.songBackgroundColor),
              backgroundImageBytes: songBgBytes,
            ));
          } else {
            // Standard Single-Version Scripture
            generatedSlides.add(PowerpointSlideData(
              title: slide.title,
              content: slide.content,
              isSong: false,
              isDualVersion: false,
              secondaryTitle: slide.secondaryTitle,
              secondaryContent: slide.secondaryContent,
              // Font styling
              fontFamily: settings.verseFontFamily.isNotEmpty ? settings.verseFontFamily : 'Segoe UI',
              fontSize: (settings.verseFontSize * 0.5).clamp(16.0, 72.0),
              fontColorHex: _intToHex(settings.verseFontColor),
              isBold: settings.verseBold,
              isItalic: settings.verseItalic,
              isUnderline: settings.verseUnderline,
              horizontalAlign: settings.verseAlignment,
              verticalAlign: settings.verseVerticalAlignment,
              lineHeight: settings.verseLineHeight > 0 ? settings.verseLineHeight : 1.4,
              // Title / Chapter reference styling
              showTitle: settings.showChapter,
              titleFontFamily: settings.chapterFontFamily.isNotEmpty ? settings.chapterFontFamily : 'Segoe UI',
              titleFontSize: (settings.chapterFontSize * 0.5).clamp(12.0, 36.0),
              titleColorHex: _intToHex(settings.chapterFontColor),
              titleBold: settings.chapterBold,
              titleItalic: settings.chapterItalic,
              titleAlign: settings.chapterAlignment,
              titleVerticalAlign: settings.chapterVerticalAlignment,
              titleLineHeight: settings.chapterLineHeight > 0 ? settings.chapterLineHeight : 1.2,
              // Background
              backgroundColorHex: _intToHex(settings.scriptureBackgroundColor),
              backgroundImageBytes: scriptureBgBytes,
            ));
          }

          if (i % 5 == 0) {
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }
      } else {
        // ── MODE B: Rendered Slide Images (Off-screen render) ─────────────
        _precachePresetImages(settings, mediaSync);

        for (int i = 0; i < slidesToExport.length; i++) {
          if (_isCancelled) return;
          final slide = slidesToExport[i];

          setState(() {
            _currentSlideIndex = i + 1;
            _currentSlideTitle = slide.title;
            _renderingSlide = slide;
          });

          // Give Flutter 2 frames to paint
          await WidgetsBinding.instance.endOfFrame;
          await Future.delayed(const Duration(milliseconds: 40));

          if (_isCancelled) return;

          final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
          if (boundary == null) {
            throw Exception('Failed to find RenderRepaintBoundary for slide ${i + 1}');
          }

          final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
          final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData == null) {
            throw Exception('Failed to encode PNG for slide ${i + 1}');
          }
          final Uint8List pngBytes = byteData.buffer.asUint8List();

          generatedSlides.add(PowerpointSlideData(
            imageSlideBytes: pngBytes,
            title: slide.title,
          ));
        }
      }

      if (_isCancelled) return;

      // Determine aspect ratio and size from presentation settings
      final hasDualScripture = slidesToExport.any((s) => s.isDualVersion && !s.isSong);
      final isSong = slidesToExport.any((s) => s.isSong);
      final size = ProjectorView.getCanvasSize(
        settings,
        isSong: isSong,
        isBlank: false,
        isDualVersion: hasDualScripture,
      );

      final aspectRatioStr = hasDualScripture
          ? settings.dualScriptureAspectRatio
          : (isSong ? settings.songAspectRatio : settings.scriptureAspectRatio);

      await PowerpointExportService.exportPresentation(
        outputPath: outputPath,
        slides: generatedSlides,
        aspectRatio: aspectRatioStr,
        slideWidth: size.width,
        slideHeight: size.height,
      );

      if (mounted) {
        setState(() {
          _currentStep = _ExportStep.completed;
        });
      }
    } catch (e, stack) {
      debugPrint('Error exporting presentation: $e\n$stack');
      if (mounted) {
        setState(() {
          _currentStep = _ExportStep.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _precachePresetImages(PresentationSettings settings, MediaSyncManager mediaSync) {
    final imagesToPrecache = [
      if (settings.isBlankImageEnabled && settings.blankBackgroundImage.isNotEmpty)
        settings.blankBackgroundImage,
      if (settings.isSongImageEnabled && settings.songBackgroundImage.isNotEmpty)
        settings.songBackgroundImage,
      if (settings.isScriptureImageEnabled && settings.scriptureBackgroundImage.isNotEmpty)
        settings.scriptureBackgroundImage,
    ];

    for (final rawPath in imagesToPrecache) {
      final path = mediaSync.resolveMediaPath(rawPath);
      if (path.isNotEmpty && File(path).existsSync()) {
        precacheImage(FileImage(File(path)), context);
      }
    }
  }

  void _cancelExport() {
    setState(() {
      _isCancelled = true;
      _currentStep = _ExportStep.configure;
    });
  }

  static Future<void> _openFile(String filePath) async {
    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', filePath], runInShell: true);
      } else if (Platform.isMacOS) {
        await Process.run('open', [filePath]);
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
    }
  }

  static Future<void> _openFolder(String filePath) async {
    try {
      if (Platform.isWindows) {
        await Process.run('explorer.exe', ['/select,', filePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', filePath]);
      }
    } catch (e) {
      debugPrint('Error opening folder: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final presetsAsync = ref.watch(presetsListProvider);
    final setlist = ref.watch(setlistProvider);
    final selection = ref.watch(setlistSelectionProvider);

    return presetsAsync.when(
      data: (presets) {
        final currentPresetId = _selectedPresetId ?? presets.firstOrNull?.id;
        final selectedSettings = presets.firstWhere(
          (p) => p.id == currentPresetId,
          orElse: () => PresentationSettings(),
        );

        return Dialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title bar
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.slideshow_rounded,
                          color: Colors.deepOrangeAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Export Slides to PowerPoint (.pptx)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Clean OpenXML presentation with selectable, editable text boxes.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_currentStep == _ExportStep.configure || _currentStep == _ExportStep.completed)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Colors.white10),
                  const SizedBox(height: 16),

                  // Main Content based on step
                  Expanded(
                    child: switch (_currentStep) {
                      _ExportStep.configure => _buildConfigureView(presets, selectedSettings, setlist, selection),
                      _ExportStep.exporting => _buildExportingView(selectedSettings),
                      _ExportStep.completed => _buildCompletedView(),
                      _ExportStep.error => _buildErrorView(),
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Error loading presets', style: TextStyle(color: Colors.white)),
        content: Text('$e', style: const TextStyle(color: Colors.white70)),
      ),
    );
  }

  // ── Step 1: Configuration Form ──────────────────────────────────────────
  Widget _buildConfigureView(
    List<PresentationSettings> presets,
    PresentationSettings selectedSettings,
    List<SetlistItem> setlist,
    Set<int> selection,
  ) {
    final hasSingleSelection = selection.length == 1;
    final selectedItemName = hasSingleSelection
        ? (setlist[selection.first] is SongSetlistItem
            ? (setlist[selection.first] as SongSetlistItem).song.title
            : (setlist[selection.first] is ImageSetlistItem
                ? (setlist[selection.first] as ImageSetlistItem).displayName
                : (setlist[selection.first] as WindowSetlistItem).displayName))
        : null;

    final totalSlidesCount = _gatherSlidesToExport(selectedSettings).length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Format Selection
          const Text(
            'SLIDE FORMAT',
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D3E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _buildFormatOption(
                  format: _ExportFormat.textboxes,
                  icon: Icons.text_fields_rounded,
                  title: 'Native Text Boxes (Recommended)',
                  subtitle: 'Editable & copyable text. Users can highlight & copy lyrics (Ctrl+C)',
                ),
                const Divider(height: 1, color: Colors.white10),
                _buildFormatOption(
                  format: _ExportFormat.images,
                  icon: Icons.image_outlined,
                  title: 'Slide Images',
                  subtitle: 'Flattened image captures of the live projection screen',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Preset selection dropdown
          const Text(
            'STYLE PRESET (FONTS, COLORS & BACKGROUND)',
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D3E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: selectedSettings.id,
                dropdownColor: const Color(0xFF2D2D3E),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                items: presets.map((p) {
                  return DropdownMenuItem<int>(
                    value: p.id,
                    child: Row(
                      children: [
                        Icon(Icons.palette_outlined, size: 16, color: Colors.deepPurpleAccent.withValues(alpha: 0.8)),
                        const SizedBox(width: 8),
                        Text(p.presetName, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(width: 8),
                        Text(
                          '(${p.songAspectRatio})',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedPresetId = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Scope Selection
          const Text(
            'EXPORT SCOPE',
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D3E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _buildScopeOption(
                  scope: _ExportScope.entireSetlist,
                  title: 'Entire Setlist (${setlist.length} items, $totalSlidesCount slides)',
                  subtitle: 'Exports all songs, scriptures, and media in order',
                ),
                if (hasSingleSelection) ...[
                  const Divider(height: 1, color: Colors.white10),
                  _buildScopeOption(
                    scope: _ExportScope.selectedItem,
                    title: 'Selected Item: $selectedItemName',
                    subtitle: 'Exports slides for this item only',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Options Checkboxes
          const Text(
            'OPTIONS',
            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D3E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: CheckboxListTile(
              value: _includeBlankSlides,
              dense: true,
              activeColor: Colors.deepPurpleAccent,
              title: const Text(
                'Include blank transition slides',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              subtitle: const Text(
                'Maintains pauses between songs in the presentation',
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
              onChanged: (val) => setState(() => _includeBlankSlides = val ?? true),
            ),
          ),
          const SizedBox(height: 20),

          // 5. Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.file_download_outlined, size: 16),
                label: const Text('Export Presentation (.pptx)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _startExport(selectedSettings),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption({
    required _ExportFormat format,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedFormat == format;
    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.deepPurpleAccent : Colors.white38,
              size: 18,
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.white54),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeOption({
    required _ExportScope scope,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedScope == scope;
    return InkWell(
      onTap: () => setState(() => _selectedScope = scope),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.deepPurpleAccent : Colors.white38,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Export Progress View with Live Slide Render ───────────────────
  Widget _buildExportingView(PresentationSettings settings) {
    final progress = _totalSlides > 0 ? (_currentSlideIndex / _totalSlides).clamp(0.0, 1.0) : 0.0;
    final isSong = _renderingSlide?.isSong ?? true;
    final isBlank = _renderingSlide?.isBlank ?? false;
    final isDual = _renderingSlide?.isDualVersion ?? false;
    final isWindowSlide = _renderingSlide?.content.startsWith('WINDOW:') ?? false;

    final size = ProjectorView.getCanvasSize(
      settings,
      isSong: isSong,
      isBlank: isBlank,
      isWindow: isWindowSlide,
      isDualVersion: isDual,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Live Render Surface
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: size.width / size.height,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: _renderingSlide != null
                          ? ProjectorView(
                              settings: settings,
                              activeSlideText: isBlank ? "" : _renderingSlide!.content,
                              secondarySlideText: _renderingSlide!.secondaryContent,
                              titleText: _renderingSlide!.title,
                              isSong: _renderingSlide!.isSong,
                              isDualVersion: _renderingSlide!.isDualVersion,
                              isPreviewMode: true,
                              showCheckerboard: false,
                            )
                          : Container(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Progress Details
        Text(
          'Processing slide $_currentSlideIndex of $_totalSlides',
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _currentSlideTitle,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white10,
          color: Colors.deepOrangeAccent,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 16),

        // Cancel button
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.cancel_outlined, size: 14, color: Colors.white54),
            label: const Text('Cancel Export', style: TextStyle(color: Colors.white54, fontSize: 12)),
            onPressed: _cancelExport,
          ),
        ),
      ],
    );
  }

  // ── Step 3: Completed View ───────────────────────────────────────────────
  Widget _buildCompletedView() {
    final isTextboxes = _selectedFormat == _ExportFormat.textboxes;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 56),
        const SizedBox(height: 16),
        const Text(
          'Export Complete!',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          isTextboxes
              ? 'Successfully exported $_totalSlides slides with editable, copyable text boxes.'
              : 'Successfully exported $_totalSlides slides with live projection styling.',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        if (_exportedFilePath != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D3E),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.file_present_rounded, color: Colors.deepOrangeAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _exportedFilePath!,
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.folder_open_rounded, size: 16),
                label: const Text('Show in Folder', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: () => _openFolder(_exportedFilePath!),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.slideshow_rounded, size: 16),
                label: const Text('Open Presentation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () => _openFile(_exportedFilePath!),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ),
      ],
    );
  }

  // ── Step 4: Error View ───────────────────────────────────────────────────
  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 56),
        const SizedBox(height: 16),
        const Text(
          'Export Failed',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Text(
            _errorMessage ?? 'Unknown error occurred while exporting.',
            style: const TextStyle(color: Colors.redAccent, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _currentStep = _ExportStep.configure;
                  _errorMessage = null;
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ],
    );
  }
}
