import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../setlist/presentation/image_slide_dialog.dart';
import '../../../setlist/data/setlist_item.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:keryxpro/features/presentation/presentation/widgets/projector_view.dart';
import '../presentation_settings_provider.dart';
import '../../data/presentation_settings.dart';
import 'package:keryxpro/core/sync/media_sync_manager.dart';


const List<String> kCommonSystemFonts = [
  'Arial', 'Arial Black', 'Calibri', 'Cambria', 'Candara', 'Century Gothic',
  'Comic Sans MS', 'Consolas', 'Courier New', 'Franklin Gothic Medium',
  'Garamond', 'Georgia', 'Impact', 'Lucida Console', 'Lucida Sans Unicode',
  'Microsoft Sans Serif', 'Palatino Linotype', 'Roboto', 'Segoe UI', 'Tahoma',
  'Times New Roman', 'Trebuchet MS', 'Verdana'
];

enum ViewMode { choose, edit, editTheme }

class PresentationSettingsDialog extends ConsumerStatefulWidget {
  const PresentationSettingsDialog({super.key});

  @override
  ConsumerState<PresentationSettingsDialog> createState() => _PresentationSettingsDialogState();
}

class _PresentationSettingsDialogState extends ConsumerState<PresentationSettingsDialog> {
  ViewMode _mode = ViewMode.choose;
  int _editTabIndex = 0; // 0: Song, 1: Scripture
  final TextEditingController _newPresetCtrl = TextEditingController();
  final TextEditingController _widthCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  
  final FocusNode _widthFocusNode = FocusNode(debugLabel: 'CustomWidthField');
  final FocusNode _heightFocusNode = FocusNode(debugLabel: 'CustomHeightField');

  String _editingThemeName = '';
  PresentationSettings _themeSettings = PresentationSettings();
  final TextEditingController _themeNameCtrl = TextEditingController();
  bool _previewThemeAsSong = true;
  int _marginRevision = 0;

  void _updateControllers() {
    _marginRevision++;
    final isThemeMode = _mode == ViewMode.editTheme;
    final settings = isThemeMode ? _themeSettings : ref.read(editingPresetProvider);
    final isSong = isThemeMode ? true : (_editTabIndex == 0);
    final isBlank = isThemeMode ? false : (_editTabIndex == 2);
    _widthCtrl.text = (isBlank ? settings.blankCustomWidth : (isSong ? settings.songCustomWidth : settings.scriptureCustomWidth)).toStringAsFixed(0);
    _heightCtrl.text = (isBlank ? settings.blankCustomHeight : (isSong ? settings.songCustomHeight : settings.scriptureCustomHeight)).toStringAsFixed(0);
  }

  @override
  void dispose() {
    _newPresetCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _widthFocusNode.dispose();
    _heightFocusNode.dispose();
    _themeNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 800,
        height: 600,
        child: Column(
          children: [
            _buildTitleBar(),
            Expanded(
              child: _mode == ViewMode.choose 
                ? _buildChoosePresetView() 
                : (_mode == ViewMode.editTheme ? _buildEditThemeView() : _buildEditPresetView()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    if (_mode == ViewMode.choose) {
      return Container(
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Text('Choose Preset', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    } else if (_mode == ViewMode.editTheme) {
      return Container(
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          children: [
            InkWell(
              onTap: () => setState(() => _mode = ViewMode.choose),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Theme: $_editingThemeName', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            IgnorePointer(
              child: SegmentedButton<int>(
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: Colors.white12,
                  side: const BorderSide(color: Colors.transparent),
                ),
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 0, label: Text('Theme settings')),
                ],
                selected: const {0},
                onSelectionChanged: (_) {},
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    } else {
      final settings = ref.watch(editingPresetProvider);
      return Container(
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          children: [
            InkWell(
              onTap: () => setState(() => _mode = ViewMode.choose),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(settings.presetName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SegmentedButton<int>(
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white70,
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: Colors.white12,
                side: const BorderSide(color: Colors.transparent),
              ),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 0, label: Text('Song')),
                ButtonSegment(value: 1, label: Text('Scripture')),
                ButtonSegment(value: 2, label: Text('Blank Screen')),
              ],
              selected: {_editTabIndex},
              onSelectionChanged: (set) {
                setState(() {
                  _editTabIndex = set.first;
                  _updateControllers(); // Sync when switching tabs
                });
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    }
  }

  Widget _buildChoosePresetView() {
    final presetsAsync = ref.watch(presetsListProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (kDebugMode) ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.palette),
                  label: const Text('Create Theme'),
                  onPressed: _showCreateThemeDialog,
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Import Theme'),
                onPressed: _importTheme,
              ),
              const Spacer(),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _newPresetCtrl,
                  decoration: const InputDecoration(
                    labelText: 'New Preset Name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add New Preset'),
                onPressed: () async {
                  if (_newPresetCtrl.text.trim().isNotEmpty) {
                    await ref.read(editingPresetProvider.notifier).createNewPreset(_newPresetCtrl.text.trim());
                    _newPresetCtrl.clear();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: presetsAsync.when(
              data: (presets) {
                // Ensure default is always first
                final defaultPreset = presets.firstWhere((p) => p.isDefault, orElse: () => presets.first);
                final others = presets.where((p) => p.id != defaultPreset.id).toList();
                
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildPresetButton(defaultPreset),
                    ...others.map((p) => _buildPresetButton(p)),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Text('Error: $err'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPresetButton(PresentationSettings preset) {
    final name = preset.presetName.trim().isEmpty ? 'Preset ${preset.id}' : preset.presetName;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            ref.read(editingPresetProvider.notifier).setPresetToEdit(preset);
            setState(() {
              _mode = ViewMode.edit;
              _updateControllers(); // Sync when entering edit mode
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!preset.isDefault) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _deletePreset(preset),
                    child: const Icon(Icons.close, size: 18, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deletePreset(PresentationSettings preset) {
    final name = preset.presetName.trim().isEmpty ? 'Preset ${preset.id}' : preset.presetName;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(editingPresetProvider.notifier).deletePreset(preset.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentGridWidget(String horizontal, String vertical, void Function(String, String) onChanged) {
    const horizontals = ['left', 'center', 'right'];
    const verticals = ['top', 'center', 'bottom'];
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: verticals.map((v) => Row(
        mainAxisSize: MainAxisSize.min,
        children: horizontals.map((h) {
          final isSelected = horizontal == h && vertical == v;
          return InkWell(
            onTap: () => onChanged(h, v),
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.5)),
                color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
              ),
            ),
          );
        }).toList(),
      )).toList(),
    );
  }

  Widget _buildMarginMatrixWidget(double top, double bottom, double left, double right, String contextKey, void Function({double? t, double? b, double? l, double? r}) onChanged) {
    Widget buildMarginBox(String label, EdgeInsets borderHighlight, double value, void Function(double) onValue) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36, 
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black12,
              border: Border(
                top: BorderSide(color: borderHighlight.top > 0 ? Colors.blue : Colors.grey, width: borderHighlight.top > 0 ? 3 : 1),
                bottom: BorderSide(color: borderHighlight.bottom > 0 ? Colors.blue : Colors.grey, width: borderHighlight.bottom > 0 ? 3 : 1),
                left: BorderSide(color: borderHighlight.left > 0 ? Colors.blue : Colors.grey, width: borderHighlight.left > 0 ? 3 : 1),
                right: BorderSide(color: borderHighlight.right > 0 ? Colors.blue : Colors.grey, width: borderHighlight.right > 0 ? 3 : 1),
              ),
            ),
            child: Center(
              child: TextFormField(
                key: ValueKey('${contextKey}_${label}_$_marginRevision'),
                initialValue: value.toInt().toString(),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                onChanged: (v) {
                   final parsed = double.tryParse(v);
                   if (parsed != null) onValue(parsed);
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text('px', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildMarginBox('Top', const EdgeInsets.only(top: 1), top, (v) => onChanged(t: v)),
            const SizedBox(width: 16),
            buildMarginBox('Bottom', const EdgeInsets.only(bottom: 1), bottom, (v) => onChanged(b: v)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildMarginBox('Left', const EdgeInsets.only(left: 1), left, (v) => onChanged(l: v)),
            const SizedBox(width: 16),
            buildMarginBox('Right', const EdgeInsets.only(right: 1), right, (v) => onChanged(r: v)),
          ],
        )
      ],
    );
  }

  Widget _buildEditPresetView() {
    return Row(
      children: [
        // Left Half
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildAspectRatioSelector(),
                const SizedBox(height: 12),
                if (_editTabIndex != 2) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.palette_outlined),
                      label: const Text('Apply Theme'),
                      onPressed: _showApplyThemeDialog,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(child: _buildPreviewPane()),
                const SizedBox(height: 16),
                _buildBackgroundControls(),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        // Right Half
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
                    child: _editTabIndex == 2 ? const SizedBox.shrink() : _buildTitleSettings(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _editTabIndex == 2 ? const SizedBox.shrink() : _buildBodySettings(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text('Save ${_editTabIndex == 0 ? 'Song' : _editTabIndex == 1 ? 'Scripture' : 'Blank Screen'} Settings'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      final s = ref.read(editingPresetProvider);
                      // Validation
                      if (_editTabIndex != 2) {
                        bool isValid = s.titleFontFamily.isNotEmpty && s.titleFontSize > 0 &&
                                      s.lyricsFontFamily.isNotEmpty && s.lyricsFontSize > 0 &&
                                      s.chapterFontFamily.isNotEmpty && s.chapterFontSize > 0 &&
                                      s.verseFontFamily.isNotEmpty && s.verseFontSize > 0;
                        
                        if (!isValid) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please ensure Font and Size are selected for all sections.'),
                              backgroundColor: Colors.red,
                            )
                          );
                          return;
                        }
                      }

                      ref.read(editingPresetProvider.notifier).saveSettings();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preset Saved')));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSettings() {
    final settings = ref.watch(editingPresetProvider);
    final notifier = ref.read(editingPresetProvider.notifier);
    final isSong = _editTabIndex == 0;
    
    final showTitle = isSong ? settings.showTitle : settings.showChapter;
    final alignment = isSong ? settings.titleAlignment : settings.chapterAlignment;
    final valignment = isSong ? settings.titleVerticalAlignment : settings.chapterVerticalAlignment;
    
    final mTop = isSong ? settings.titleMarginTop : settings.chapterMarginTop;
    final mBottom = isSong ? settings.titleMarginBottom : settings.chapterMarginBottom;
    final mLeft = isSong ? settings.titleMarginLeft : settings.chapterMarginLeft;
    final mRight = isSong ? settings.titleMarginRight : settings.chapterMarginRight;

    final fontFamily = isSong ? settings.titleFontFamily : settings.chapterFontFamily;
    final fontSize = isSong ? settings.titleFontSize : settings.chapterFontSize;
    final fontColor = isSong ? settings.titleFontColor : settings.chapterFontColor;
    final bold = isSong ? settings.titleBold : settings.chapterBold;
    final italic = isSong ? settings.titleItalic : settings.chapterItalic;
    final underline = isSong ? settings.titleUnderline : settings.chapterUnderline;
    final hasFill = isSong ? settings.titleHasFill : settings.chapterHasFill;
    final fillColor = isSong ? settings.titleFillColor : settings.chapterFillColor;
    final hasStroke = isSong ? settings.titleHasStroke : settings.chapterHasStroke;
    final strokeColor = isSong ? settings.titleStrokeColor : settings.chapterStrokeColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              _showTypographyDialog(
                context: context,
                initialFontFamily: fontFamily,
                initialFontSize: fontSize,
                initialFontColor: fontColor,
                initialBold: bold,
                initialItalic: italic,
                initialUnderline: underline,
                initialHasFill: hasFill,
                initialFillColor: fillColor,
                initialHasStroke: hasStroke,
                initialStrokeColor: strokeColor,
                onChanged: ({fontFamily, fontSize, fontColor, bold, italic, underline, hasFill, fillColor, hasStroke, strokeColor, lineBreak}) {
                  final currentSettings = ref.read(editingPresetProvider);
                  if (fontFamily != null) isSong ? notifier.updateTitleFontFamily(fontFamily) : notifier.updateChapterFontFamily(fontFamily);
                  if (fontSize != null) isSong ? notifier.updateTitleFontSize(fontSize) : notifier.updateChapterFontSize(fontSize);
                  if (fontColor != null) isSong ? notifier.updateTitleFontColor(fontColor) : notifier.updateChapterFontColor(fontColor);
                  if (bold != null) isSong ? notifier.updateTitleBold(bold) : notifier.updateChapterBold(bold);
                  if (italic != null) isSong ? notifier.updateTitleItalic(italic) : notifier.updateChapterItalic(italic);
                  if (underline != null) isSong ? notifier.updateTitleUnderline(underline) : notifier.updateChapterUnderline(underline);
                  if (hasFill != null || fillColor != null) {
                    final f = hasFill ?? (isSong ? currentSettings.titleHasFill : currentSettings.chapterHasFill);
                    final fc = fillColor ?? (isSong ? currentSettings.titleFillColor : currentSettings.chapterFillColor);
                    isSong ? notifier.updateTitleFill(f, fc) : notifier.updateChapterFill(f, fc);
                  }
                  if (hasStroke != null || strokeColor != null) {
                    final s = hasStroke ?? (isSong ? currentSettings.titleHasStroke : currentSettings.chapterHasStroke);
                    final sc = strokeColor ?? (isSong ? currentSettings.titleStrokeColor : currentSettings.chapterStrokeColor);
                    isSong ? notifier.updateTitleStroke(s, sc) : notifier.updateChapterStroke(s, sc);
                  }
                },
              );
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: isSong ? 'Title' : 'Chapter',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(16.0),
              ),
              child: Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: Text(
                  '$fontFamily ${fontSize.toInt()}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlignmentGridWidget(alignment, valignment, (h, v) {
              if (isSong) {
                notifier.updateTitleAlignment(h);
                notifier.updateTitleVerticalAlignment(v);
              } else {
                notifier.updateChapterAlignment(h);
                notifier.updateChapterVerticalAlignment(v);
              }
            }),
            const SizedBox(width: 24),
            _buildMarginMatrixWidget(mTop, mBottom, mLeft, mRight, isSong ? 'song_title' : 'scripture_title', ({b, l, r, t}) {
              if (isSong) {
                notifier.updateTitleMargins(top: t, bottom: b, left: l, right: r);
              } else {
                notifier.updateChapterMargins(top: t, bottom: b, left: l, right: r);
              }
            }),
            const Spacer(),
            Row(
              children: [
                Checkbox(
                  value: showTitle,
                  onChanged: (v) {
                    if (v != null) {
                      if (isSong) notifier.updateShowTitle(v); else notifier.updateShowChapter(v);
                    }
                  },
                ),
                Text(isSong ? 'Title' : 'Chapter'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodySettings() {
    final settings = ref.watch(editingPresetProvider);
    final notifier = ref.read(editingPresetProvider.notifier);
    final isSong = _editTabIndex == 0;
    
    final alignment = isSong ? settings.lyricsAlignment : settings.verseAlignment;
    final valignment = isSong ? settings.lyricsVerticalAlignment : settings.verseVerticalAlignment;
    
    final mTop = isSong ? settings.lyricsMarginTop : settings.verseMarginTop;
    final mBottom = isSong ? settings.lyricsMarginBottom : settings.verseMarginBottom;
    final mLeft = isSong ? settings.lyricsMarginLeft : settings.verseMarginLeft;
    final mRight = isSong ? settings.lyricsMarginRight : settings.verseMarginRight;

    final fontFamily = isSong ? settings.lyricsFontFamily : settings.verseFontFamily;
    final fontSize = isSong ? settings.lyricsFontSize : settings.verseFontSize;
    final fontColor = isSong ? settings.lyricsFontColor : settings.verseFontColor;
    final bold = isSong ? settings.lyricsBold : settings.verseBold;
    final italic = isSong ? settings.lyricsItalic : settings.verseItalic;
    final underline = isSong ? settings.lyricsUnderline : settings.verseUnderline;
    final hasFill = isSong ? settings.lyricsHasFill : settings.verseHasFill;
    final fillColor = isSong ? settings.lyricsFillColor : settings.verseFillColor;
    final hasStroke = isSong ? settings.lyricsHasStroke : settings.verseHasStroke;
    final strokeColor = isSong ? settings.lyricsStrokeColor : settings.verseStrokeColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              _showTypographyDialog(
                context: context,
                initialFontFamily: fontFamily,
                initialFontSize: fontSize,
                initialFontColor: fontColor,
                initialBold: bold,
                initialItalic: italic,
                initialUnderline: underline,
                initialHasFill: hasFill,
                initialFillColor: fillColor,
                initialHasStroke: hasStroke,
                initialStrokeColor: strokeColor,
                showLineBreakOption: isSong,
                initialLineBreak: isSong ? settings.lyricsLineBreak : false,
                onChanged: ({fontFamily, fontSize, fontColor, bold, italic, underline, hasFill, fillColor, hasStroke, strokeColor, lineBreak}) {
                  final currentSettings = ref.read(editingPresetProvider);
                  if (fontFamily != null) isSong ? notifier.updateLyricsFontFamily(fontFamily) : notifier.updateVerseFontFamily(fontFamily);
                  if (fontSize != null) isSong ? notifier.updateLyricsFontSize(fontSize) : notifier.updateVerseFontSize(fontSize);
                  if (fontColor != null) isSong ? notifier.updateLyricsFontColor(fontColor) : notifier.updateVerseFontColor(fontColor);
                  if (bold != null) isSong ? notifier.updateLyricsBold(bold) : notifier.updateVerseBold(bold);
                  if (italic != null) isSong ? notifier.updateLyricsItalic(italic) : notifier.updateVerseItalic(italic);
                  if (underline != null) isSong ? notifier.updateLyricsUnderline(underline) : notifier.updateVerseUnderline(underline);
                  if (lineBreak != null && isSong) notifier.updateLyricsLineBreak(lineBreak);
                  if (hasFill != null || fillColor != null) {
                    final f = hasFill ?? (isSong ? currentSettings.lyricsHasFill : currentSettings.verseHasFill);
                    final fc = fillColor ?? (isSong ? currentSettings.lyricsFillColor : currentSettings.verseFillColor);
                    isSong ? notifier.updateLyricsFill(f, fc) : notifier.updateVerseFill(f, fc);
                  }
                  if (hasStroke != null || strokeColor != null) {
                    final s = hasStroke ?? (isSong ? currentSettings.lyricsHasStroke : currentSettings.verseHasStroke);
                    final sc = strokeColor ?? (isSong ? currentSettings.lyricsStrokeColor : currentSettings.verseStrokeColor);
                    isSong ? notifier.updateLyricsStroke(s, sc) : notifier.updateVerseStroke(s, sc);
                  }
                },
              );
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: isSong ? 'Body' : 'Verse',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(16.0),
              ),
              child: Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: Text(
                  '$fontFamily ${fontSize.toInt()}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlignmentGridWidget(alignment, valignment, (h, v) {
              if (isSong) {
                notifier.updateLyricsAlignment(h);
                notifier.updateLyricsVerticalAlignment(v);
              } else {
                notifier.updateVerseAlignment(h);
                notifier.updateVerseVerticalAlignment(v);
              }
            }),
            const SizedBox(width: 24),
            _buildMarginMatrixWidget(mTop, mBottom, mLeft, mRight, isSong ? 'song_body' : 'scripture_body', ({b, l, r, t}) {
              if (isSong) {
                notifier.updateLyricsMargins(top: t, bottom: b, left: l, right: r);
              } else {
                notifier.updateVerseMargins(top: t, bottom: b, left: l, right: r);
              }
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildAspectRatioSelector() {
    final settings = ref.watch(editingPresetProvider);
    final notifier = ref.read(editingPresetProvider.notifier);
    final isSong = _editTabIndex == 0;
    final isBlank = _editTabIndex == 2;

    final aspectRatio = isBlank ? settings.blankAspectRatio : (isSong ? settings.songAspectRatio : settings.scriptureAspectRatio);

    return Row(
      children: [
        DropdownMenu<String>(
          initialSelection: aspectRatio,
          label: const Text('Aspect Ratio'),
          onSelected: (val) {
            if (val != null) {
              notifier.updateAspectRatio(val, _editTabIndex);
              if (val == 'Custom') {
                _updateControllers();
              }
            }
          },
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: '16:9', label: '16:9'),
            DropdownMenuEntry(value: '4:3', label: '4:3'),
            DropdownMenuEntry(value: '4:1', label: '4:1 (Banner)'),
            DropdownMenuEntry(value: 'Custom', label: 'Custom'),
            DropdownMenuEntry(value: 'Fit to screen', label: 'Fit to screen'),
          ],
        ),
        if (aspectRatio == 'Custom') ...[
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const ValueKey('custom_width_field'),
              focusNode: _widthFocusNode,
              controller: _widthCtrl,
              decoration: const InputDecoration(labelText: 'W (px)', isDense: true, border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) notifier.updateCustomWidth(parsed, _editTabIndex);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const ValueKey('custom_height_field'),
              focusNode: _heightFocusNode,
              controller: _heightCtrl,
              decoration: const InputDecoration(labelText: 'H (px)', isDense: true, border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) notifier.updateCustomHeight(parsed, _editTabIndex);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBackgroundControls() {
    final settings = ref.watch(editingPresetProvider);
    final notifier = ref.read(editingPresetProvider.notifier);
    final isSong = _editTabIndex == 0;
    final isBlank = _editTabIndex == 2;
    
    final isTransparent = isBlank ? settings.isBlankTransparent : (isSong ? settings.isSongTransparent : settings.isScriptureTransparent);
    final backgroundColor = isBlank ? settings.blankBackgroundColor : (isSong ? settings.songBackgroundColor : settings.scriptureBackgroundColor);
    final isImageEnabled = isBlank ? settings.isBlankImageEnabled : (isSong ? settings.isSongImageEnabled : settings.isScriptureImageEnabled);
    final backgroundImage = isBlank ? settings.blankBackgroundImage : (isSong ? settings.songBackgroundImage : settings.scriptureBackgroundImage);
    final backgroundImageLayout = isBlank ? settings.blankBackgroundImageLayout : (isSong ? settings.songBackgroundImageLayout : settings.scriptureBackgroundImageLayout);
    final backgroundImageAlignment = isBlank ? settings.blankBackgroundImageAlignment : (isSong ? settings.songBackgroundImageAlignment : settings.scriptureBackgroundImageAlignment);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: !isTransparent,
              onChanged: (_) => notifier.updateIsTransparent(false, _editTabIndex),
            ),
            const Text('Background Color'),
            const SizedBox(width: 8),
            InkWell(
              onTap: isTransparent ? null : () => _showColorPicker(context, Color(backgroundColor), (c) => notifier.updateBackgroundColor(c.value, _editTabIndex)),
              child: Container(
                width: 48, height: 24,
                decoration: BoxDecoration(
                  color: Color(backgroundColor),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: isTransparent,
              onChanged: (_) => notifier.updateIsTransparent(true, _editTabIndex),
            ),
            const Text('Transparent'),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: isImageEnabled,
              onChanged: (val) {
                if (val != null) notifier.updateIsImageEnabled(val, _editTabIndex);
              },
            ),
            const Text('Image'),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final result = await showDialog<ImageSetlistItem>(
                  context: context,
                  builder: (context) => ImageSlideDialog(
                    isForBackground: true,
                    initialImagePath: backgroundImage,
                    initialLayout: backgroundImageLayout.isEmpty ? 'stretch' : backgroundImageLayout,
                    initialAlignment: backgroundImageAlignment.isEmpty ? 'center' : backgroundImageAlignment,
                  ),
                );
                if (result != null && result.imagePath.isNotEmpty) {
                  notifier.updateBackgroundImage(result.imagePath, result.layout, result.alignment, _editTabIndex);
                }
              },
              child: const Text('Add'),
            ),
            if (backgroundImage.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  backgroundImage.split(Platform.pathSeparator).last,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context, Color current, ValueChanged<Color> onChanged) {
    // If the color was unintentionally saved as fully transparent (alpha = 0)
    // due to initial database defaults, force it to solid (alpha = 255).
    Color selectedColor = current.alpha == 0 ? current.withAlpha(255) : current;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Pick Background Color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: selectedColor,
                onColorChanged: (newColor) {
                  setState(() {
                    selectedColor = newColor;
                  }); 
                },
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  onChanged(selectedColor);
                  Navigator.pop(ctx);
                },
                child: const Text('Done'),
              )
            ],
          );
        },
      ),
    );
  }

  void _showTypographyDialog({
    required BuildContext context,
    required String initialFontFamily,
    required double initialFontSize,
    required int initialFontColor,
    required bool initialBold,
    required bool initialItalic,
    required bool initialUnderline,
    required bool initialHasFill,
    required int initialFillColor,
    required bool initialHasStroke,
    required int initialStrokeColor,
    bool showLineBreakOption = false,
    bool initialLineBreak = false,
    required void Function({
      String? fontFamily,
      double? fontSize,
      int? fontColor,
      bool? bold,
      bool? italic,
      bool? underline,
      bool? hasFill,
      int? fillColor,
      bool? hasStroke,
      int? strokeColor,
      bool? lineBreak,
    }) onChanged,
  }) {
    String fontFamily = initialFontFamily;
    double fontSize = initialFontSize;
    int fontColor = initialFontColor;
    bool bold = initialBold;
    bool italic = initialItalic;
    bool underline = initialUnderline;
    bool hasFill = initialHasFill;
    int fillColor = initialFillColor;
    bool hasStroke = initialHasStroke;
    int strokeColor = initialStrokeColor;
    bool lineBreak = initialLineBreak;
    
    final TextEditingController fontCtrl = TextEditingController(text: fontFamily);
    final TextEditingController sizeCtrl = TextEditingController(text: fontSize.toInt().toString());

    bool hasEditedFont = false;
    bool hasEditedSize = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          Widget buildColorBox(int color, ValueChanged<Color> onC) {
            return InkWell(
              onTap: () => _showColorPicker(context, Color(color), onC),
              child: Container(
                width: 48, height: 24,
                decoration: BoxDecoration(
                  color: Color(color),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey),
                ),
              ),
            );
          }

          return AlertDialog(
            title: const Text('Typography'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: fontCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Font Family',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (v) {
                                setState(() {
                                  hasEditedFont = true;
                                  fontFamily = v;
                                });
                                onChanged(fontFamily: v);
                              },
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListView(
                                children: kCommonSystemFonts
                                    .where((f) => !hasEditedFont || f.toLowerCase().contains(fontCtrl.text.toLowerCase()))
                                    .map((f) => ListTile(
                                          title: Text(f, style: TextStyle(fontFamily: f)),
                                          dense: true,
                                          selected: fontFamily == f,
                                          onTap: () {
                                            setState(() {
                                              hasEditedFont = false; // Reset to show all after selection? or keep false.
                                              fontFamily = f;
                                              fontCtrl.text = f;
                                            });
                                            onChanged(fontFamily: f);
                                          },
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: sizeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Size',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (v) {
                                setState(() {
                                  hasEditedSize = true;
                                });
                                var parsed = double.tryParse(v);
                                if (parsed != null) {
                                  if (parsed > 300.0) {
                                    parsed = 300.0;
                                    sizeCtrl.text = '300';
                                    sizeCtrl.selection = TextSelection.fromPosition(
                                      TextPosition(offset: sizeCtrl.text.length),
                                    );
                                  }
                                  fontSize = parsed;
                                  onChanged(fontSize: parsed);
                                }
                              },
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListView(
                                children: List.generate(296, (i) => i + 5)
                                    .where((s) => !hasEditedSize || sizeCtrl.text.isEmpty || s.toString().contains(sizeCtrl.text))
                                    .map((s) => ListTile(
                                          title: Text(s.toString()),
                                          dense: true,
                                          selected: fontSize.toInt() == s,
                                          onTap: () {
                                            setState(() {
                                              hasEditedSize = false;
                                              fontSize = s.toDouble();
                                              sizeCtrl.text = s.toString();
                                            });
                                            onChanged(fontSize: s.toDouble());
                                          },
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Text Color: '),
                      const SizedBox(width: 8),
                      buildColorBox(fontColor, (c) {
                        setState(() => fontColor = c.value);
                        onChanged(fontColor: c.value);
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: underline,
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => underline = v);
                                      onChanged(underline: v);
                                    }
                                  },
                                ),
                                const Text('Underline'),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: hasFill,
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => hasFill = v);
                                      onChanged(hasFill: v);
                                    }
                                  },
                                ),
                                const Text('Fill'),
                                const SizedBox(width: 16),
                                if (hasFill) buildColorBox(fillColor, (c) {
                                  setState(() => fillColor = c.value);
                                  onChanged(fillColor: c.value);
                                }),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: hasStroke,
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => hasStroke = v);
                                      onChanged(hasStroke: v);
                                    }
                                  },
                                ),
                                const Text('Stroke'),
                                const SizedBox(width: 16),
                                if (hasStroke) buildColorBox(strokeColor, (c) {
                                  setState(() => strokeColor = c.value);
                                  onChanged(strokeColor: c.value);
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: bold,
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => bold = v);
                                      onChanged(bold: v);
                                    }
                                  },
                                ),
                                const Text('Bold'),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: italic,
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => italic = v);
                                      onChanged(italic: v);
                                    }
                                  },
                                ),
                                const Text('Italic'),
                              ],
                            ),
                            if (showLineBreakOption)
                              Row(
                                children: [
                                  Checkbox(
                                    value: lineBreak,
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => lineBreak = v);
                                        onChanged(lineBreak: v);
                                      }
                                    },
                                  ),
                                  const Text('Line Break'),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done'),
              )
            ],
          );
        });
      },
    );
  }

  Widget _buildPreviewPane() {
    final settings = ref.watch(editingPresetProvider);
    final isSong = _editTabIndex == 0;
    final isBlank = _editTabIndex == 2;
    
    final previewTitle = isSong ? "Amazing Grace" : "John 3:16";
    final previewText = isBlank ? "" : (isSong 
      ? "Amazing grace how sweet the sound\nThat saved a wretch like me"
      : "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.");

    final aspectRatioStr = isBlank ? settings.blankAspectRatio : (isSong ? settings.songAspectRatio : settings.scriptureAspectRatio);
    double aspectRatio = 16 / 9;
    if (aspectRatioStr == '4:3') {
      aspectRatio = 4 / 3;
    } else if (aspectRatioStr == '4:1') {
      aspectRatio = 4 / 1;
    } else if (aspectRatioStr == 'Custom') {
      final w = isBlank ? settings.blankCustomWidth : (isSong ? settings.songCustomWidth : settings.scriptureCustomWidth);
      final h = isBlank ? settings.blankCustomHeight : (isSong ? settings.songCustomHeight : settings.scriptureCustomHeight);
      aspectRatio = (w > 0 && h > 0) ? w / h : 16 / 9;
    }

    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white10),
          ),
          child: ProjectorView(
            settings: settings,
            activeSlideText: previewText,
            titleText: previewTitle,
            isSong: isSong,
            showCheckerboard: true,
          ),
        ),
      ),
    );
  }

  // --- THEME SUPPORT METHODS ---

  Future<Directory> _getThemesDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final themesDir = Directory(p.join(appDocDir.path, 'KeryxPro', 'Themes'));
    if (!await themesDir.exists()) {
      await themesDir.create(recursive: true);
    }
    return themesDir;
  }

  void _showCreateThemeDialog() {
    _themeNameCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Theme'),
        content: TextField(
          controller: _themeNameCtrl,
          decoration: const InputDecoration(
            labelText: 'Theme Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _themeNameCtrl.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx);
                setState(() {
                  _editingThemeName = name;
                  _themeSettings = PresentationSettings()..presetName = name;
                  _mode = ViewMode.editTheme;
                  _updateControllers();
                });
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _importTheme() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      ArchiveFile? themeJsonFile;
      for (final f in archive) {
        if (f.name.endsWith('theme.json')) {
          themeJsonFile = f;
          break;
        }
      }
      
      if (themeJsonFile == null) {
        throw Exception('Invalid theme package: theme.json not found.');
      }
      
      final contentStr = utf8.decode(themeJsonFile.content as List<int>);
      final Map<String, dynamic> json = jsonDecode(contentStr);
      final themeName = json['themeName'] as String?;
      if (themeName == null || themeName.trim().isEmpty) {
        throw Exception('Invalid theme package: themeName is missing in theme.json.');
      }
      
      final appDocDir = await getApplicationDocumentsDirectory();
      final themeDir = Directory(p.join(appDocDir.path, 'KeryxPro', 'Themes', themeName));
      if (await themeDir.exists()) {
        await themeDir.delete(recursive: true);
      }
      await themeDir.create(recursive: true);
      
      for (final f in archive) {
        final filename = p.basename(f.name);
        if (f.isFile && filename.isNotEmpty) {
          final outFile = File(p.join(themeDir.path, filename));
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(f.content as List<int>);
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Theme "$themeName" imported successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing theme: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Map<String, dynamic> _themeToJson(PresentationSettings s, String themeName) {
    return {
      'themeName': themeName,
      'aspectRatio': s.songAspectRatio,
      'customWidth': s.songCustomWidth,
      'customHeight': s.songCustomHeight,
      'backgroundColor': s.songBackgroundColor,
      'backgroundImage': s.songBackgroundImage,
      'backgroundImageLayout': s.songBackgroundImageLayout,
      'backgroundImageAlignment': s.songBackgroundImageAlignment,
      'isImageEnabled': s.isSongImageEnabled,
      'isTransparent': s.isSongTransparent,
      
      'showTitle': s.showTitle,
      'titleAlignment': s.titleAlignment,
      'titleVerticalAlignment': s.titleVerticalAlignment,
      'titleFontSize': s.titleFontSize,
      'titleFontFamily': s.titleFontFamily,
      'titleFontColor': s.titleFontColor,
      'titleBold': s.titleBold,
      'titleItalic': s.titleItalic,
      'titleUnderline': s.titleUnderline,
      'titleHasFill': s.titleHasFill,
      'titleFillColor': s.titleFillColor,
      'titleHasStroke': s.titleHasStroke,
      'titleStrokeColor': s.titleStrokeColor,
      'titleMarginTop': s.titleMarginTop,
      'titleMarginBottom': s.titleMarginBottom,
      'titleMarginLeft': s.titleMarginLeft,
      'titleMarginRight': s.titleMarginRight,
      
      'bodyAlignment': s.lyricsAlignment,
      'bodyVerticalAlignment': s.lyricsVerticalAlignment,
      'bodyFontSize': s.lyricsFontSize,
      'bodyFontFamily': s.lyricsFontFamily,
      'bodyFontColor': s.lyricsFontColor,
      'bodyBold': s.lyricsBold,
      'bodyItalic': s.lyricsItalic,
      'bodyUnderline': s.lyricsUnderline,
      'bodyHasFill': s.lyricsHasFill,
      'bodyFillColor': s.lyricsFillColor,
      'bodyHasStroke': s.lyricsHasStroke,
      'bodyStrokeColor': s.lyricsStrokeColor,
      'bodyMarginTop': s.lyricsMarginTop,
      'bodyMarginBottom': s.lyricsMarginBottom,
      'bodyMarginLeft': s.lyricsMarginLeft,
      'bodyMarginRight': s.lyricsMarginRight,
      'bodyLineBreak': s.lyricsLineBreak,
    };
  }

  PresentationSettings _themeFromJson(Map<String, dynamic> json, String themeFolder) {
    final s = PresentationSettings();
    s.presetName = json['themeName'] as String? ?? 'Imported Theme';
    
    final ratio = json['aspectRatio'] as String? ?? '16:9';
    final w = (json['customWidth'] as num?)?.toDouble() ?? 1920.0;
    final h = (json['customHeight'] as num?)?.toDouble() ?? 1080.0;
    
    s.songAspectRatio = ratio;
    s.songCustomWidth = w;
    s.songCustomHeight = h;
    s.scriptureAspectRatio = ratio;
    s.scriptureCustomWidth = w;
    s.scriptureCustomHeight = h;
    
    final bgColor = json['backgroundColor'] as int? ?? 0xFF000000;
    final isTransparent = json['isTransparent'] as bool? ?? false;
    final isImgEnabled = json['isImageEnabled'] as bool? ?? false;
    final imgLayout = json['backgroundImageLayout'] as String? ?? 'stretch';
    final imgAlign = json['backgroundImageAlignment'] as String? ?? 'center';
    
    final imgRel = json['backgroundImage'] as String? ?? '';
    final imgAbs = imgRel.isNotEmpty ? p.join(themeFolder, imgRel) : '';
    
    s.songBackgroundColor = bgColor;
    s.isSongTransparent = isTransparent;
    s.isSongImageEnabled = isImgEnabled;
    s.songBackgroundImage = imgAbs;
    s.songBackgroundImageLayout = imgLayout;
    s.songBackgroundImageAlignment = imgAlign;
    
    s.scriptureBackgroundColor = bgColor;
    s.isScriptureTransparent = isTransparent;
    s.isScriptureImageEnabled = isImgEnabled;
    s.scriptureBackgroundImage = imgAbs;
    s.scriptureBackgroundImageLayout = imgLayout;
    s.scriptureBackgroundImageAlignment = imgAlign;
    
    s.showTitle = json['showTitle'] as bool? ?? true;
    s.titleAlignment = json['titleAlignment'] as String? ?? 'center';
    s.titleVerticalAlignment = json['titleVerticalAlignment'] as String? ?? 'bottom';
    s.titleFontSize = (json['titleFontSize'] as num?)?.toDouble() ?? 24.0;
    s.titleFontFamily = json['titleFontFamily'] as String? ?? 'Arial';
    s.titleFontColor = json['titleFontColor'] as int? ?? 0x8FFFFFFF;
    s.titleBold = json['titleBold'] as bool? ?? true;
    s.titleItalic = json['titleItalic'] as bool? ?? false;
    s.titleUnderline = json['titleUnderline'] as bool? ?? false;
    s.titleHasFill = json['titleHasFill'] as bool? ?? false;
    s.titleFillColor = json['titleFillColor'] as int? ?? 0;
    s.titleHasStroke = json['titleHasStroke'] as bool? ?? false;
    s.titleStrokeColor = json['titleStrokeColor'] as int? ?? 0xFF000000;
    s.titleMarginTop = (json['titleMarginTop'] as num?)?.toDouble() ?? 16.0;
    s.titleMarginBottom = (json['titleMarginBottom'] as num?)?.toDouble() ?? 16.0;
    s.titleMarginLeft = (json['titleMarginLeft'] as num?)?.toDouble() ?? 16.0;
    s.titleMarginRight = (json['titleMarginRight'] as num?)?.toDouble() ?? 16.0;
    
    s.showChapter = s.showTitle;
    s.chapterAlignment = s.titleAlignment;
    s.chapterVerticalAlignment = s.titleVerticalAlignment;
    s.chapterFontSize = s.titleFontSize;
    s.chapterFontFamily = s.titleFontFamily;
    s.chapterFontColor = s.titleFontColor;
    s.chapterBold = s.titleBold;
    s.chapterItalic = s.titleItalic;
    s.chapterUnderline = s.titleUnderline;
    s.chapterHasFill = s.titleHasFill;
    s.chapterFillColor = s.titleFillColor;
    s.chapterHasStroke = s.titleHasStroke;
    s.chapterStrokeColor = s.titleStrokeColor;
    s.chapterMarginTop = s.titleMarginTop;
    s.chapterMarginBottom = s.titleMarginBottom;
    s.chapterMarginLeft = s.titleMarginLeft;
    s.chapterMarginRight = s.titleMarginRight;
    
    s.lyricsAlignment = json['bodyAlignment'] as String? ?? 'center';
    s.lyricsVerticalAlignment = json['bodyVerticalAlignment'] as String? ?? 'center';
    s.lyricsFontSize = (json['bodyFontSize'] as num?)?.toDouble() ?? 80.0;
    s.lyricsFontFamily = json['bodyFontFamily'] as String? ?? 'Arial';
    s.lyricsFontColor = json['bodyFontColor'] as int? ?? 0xFFFFFFFF;
    s.lyricsBold = json['bodyBold'] as bool? ?? true;
    s.lyricsItalic = json['bodyItalic'] as bool? ?? false;
    s.lyricsUnderline = json['bodyUnderline'] as bool? ?? false;
    s.lyricsHasFill = json['bodyHasFill'] as bool? ?? false;
    s.lyricsFillColor = json['bodyFillColor'] as int? ?? 0;
    s.lyricsHasStroke = json['bodyHasStroke'] as bool? ?? false;
    s.lyricsStrokeColor = json['bodyStrokeColor'] as int? ?? 0xFF000000;
    s.lyricsMarginTop = (json['bodyMarginTop'] as num?)?.toDouble() ?? 32.0;
    s.lyricsMarginBottom = (json['bodyMarginBottom'] as num?)?.toDouble() ?? 32.0;
    s.lyricsMarginLeft = (json['bodyMarginLeft'] as num?)?.toDouble() ?? 32.0;
    s.lyricsMarginRight = (json['bodyMarginRight'] as num?)?.toDouble() ?? 32.0;
    s.lyricsLineBreak = json['bodyLineBreak'] as bool? ?? false;
    
    s.verseAlignment = s.lyricsAlignment;
    s.verseVerticalAlignment = s.lyricsVerticalAlignment;
    s.verseFontSize = s.lyricsFontSize;
    s.verseFontFamily = s.lyricsFontFamily;
    s.verseFontColor = s.lyricsFontColor;
    s.verseBold = s.lyricsBold;
    s.verseItalic = s.lyricsItalic;
    s.verseUnderline = s.lyricsUnderline;
    s.verseHasFill = s.lyricsHasFill;
    s.verseFillColor = s.lyricsFillColor;
    s.verseHasStroke = s.lyricsHasStroke;
    s.verseStrokeColor = s.lyricsStrokeColor;
    s.verseMarginTop = s.lyricsMarginTop;
    s.verseMarginBottom = s.lyricsMarginBottom;
    s.verseMarginLeft = s.lyricsMarginLeft;
    s.verseMarginRight = s.lyricsMarginRight;
    
    return s;
  }

  Future<List<PresentationSettings>> _loadThemes() async {
    final themesDir = await _getThemesDirectory();
    final list = <PresentationSettings>[];
    if (await themesDir.exists()) {
      final dirs = themesDir.listSync();
      for (final dir in dirs) {
        if (dir is Directory) {
          final jsonFile = File(p.join(dir.path, 'theme.json'));
          if (await jsonFile.exists()) {
            try {
              final content = await jsonFile.readAsString();
              final json = jsonDecode(content) as Map<String, dynamic>;
              list.add(_themeFromJson(json, dir.path));
            } catch (e) {
              // ignore invalid theme
            }
          }
        }
      }
    }
    return list;
  }

  Widget _buildEditThemeView() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Preview Mode:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: true, label: Text('Song')),
                        ButtonSegment(value: false, label: Text('Scripture')),
                      ],
                      selected: {_previewThemeAsSong},
                      onSelectionChanged: (set) {
                        setState(() {
                          _previewThemeAsSong = set.first;
                        });
                      },
                    )
                  ],
                ),
                const SizedBox(height: 12),
                _buildAspectRatioSelectorTheme(),
                const SizedBox(height: 16),
                Expanded(child: _buildPreviewPaneTheme()),
                const SizedBox(height: 16),
                _buildBackgroundControlsTheme(),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
                    child: _buildTitleSettingsTheme(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildBodySettingsTheme(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Save Theme'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: _saveTheme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.archive),
                          label: const Text('Export (Zip)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: _exportTheme,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAspectRatioSelectorTheme() {
    final settings = _themeSettings;
    final aspectRatio = settings.songAspectRatio;

    return Row(
      children: [
        DropdownMenu<String>(
          initialSelection: aspectRatio,
          label: const Text('Aspect Ratio'),
          onSelected: (val) {
            if (val != null) {
              setState(() {
                _themeSettings.songAspectRatio = val;
                _themeSettings.scriptureAspectRatio = val;
                if (val == 'Custom') {
                  _updateControllers();
                }
              });
            }
          },
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: '16:9', label: '16:9'),
            DropdownMenuEntry(value: '4:3', label: '4:3'),
            DropdownMenuEntry(value: '4:1', label: '4:1 (Banner)'),
            DropdownMenuEntry(value: 'Custom', label: 'Custom'),
            DropdownMenuEntry(value: 'Fit to screen', label: 'Fit to screen'),
          ],
        ),
        if (aspectRatio == 'Custom') ...[
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const ValueKey('theme_custom_width_field'),
              controller: _widthCtrl,
              decoration: const InputDecoration(labelText: 'W (px)', isDense: true, border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) {
                  setState(() {
                    _themeSettings.songCustomWidth = parsed;
                    _themeSettings.scriptureCustomWidth = parsed;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const ValueKey('theme_custom_height_field'),
              controller: _heightCtrl,
              decoration: const InputDecoration(labelText: 'H (px)', isDense: true, border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) {
                  setState(() {
                    _themeSettings.songCustomHeight = parsed;
                    _themeSettings.scriptureCustomHeight = parsed;
                  });
                }
              },
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildBackgroundControlsTheme() {
    final settings = _themeSettings;
    final isTransparent = settings.isSongTransparent;
    final backgroundColor = settings.songBackgroundColor;
    final isImageEnabled = settings.isSongImageEnabled;
    final backgroundImage = settings.songBackgroundImage;
    final backgroundImageLayout = settings.songBackgroundImageLayout;
    final backgroundImageAlignment = settings.songBackgroundImageAlignment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: !isTransparent,
              onChanged: (_) {
                setState(() {
                  _themeSettings.isSongTransparent = false;
                  _themeSettings.isScriptureTransparent = false;
                });
              },
            ),
            const Text('Background Color'),
            const SizedBox(width: 8),
            InkWell(
              onTap: isTransparent ? null : () => _showColorPicker(context, Color(backgroundColor), (c) {
                setState(() {
                  _themeSettings.songBackgroundColor = c.value;
                  _themeSettings.scriptureBackgroundColor = c.value;
                  _themeSettings.isSongTransparent = false;
                  _themeSettings.isScriptureTransparent = false;
                });
              }),
              child: Container(
                width: 48, height: 24,
                decoration: BoxDecoration(
                  color: Color(backgroundColor),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: isTransparent,
              onChanged: (_) {
                setState(() {
                  _themeSettings.isSongTransparent = true;
                  _themeSettings.isScriptureTransparent = true;
                });
              },
            ),
            const Text('Transparent'),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: isImageEnabled,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _themeSettings.isSongImageEnabled = val;
                    _themeSettings.isScriptureImageEnabled = val;
                  });
                }
              },
            ),
            const Text('Image'),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final result = await showDialog<ImageSetlistItem>(
                  context: context,
                  builder: (context) => ImageSlideDialog(
                    isForBackground: true,
                    initialImagePath: backgroundImage,
                    initialLayout: backgroundImageLayout.isEmpty ? 'stretch' : backgroundImageLayout,
                    initialAlignment: backgroundImageAlignment.isEmpty ? 'center' : backgroundImageAlignment,
                  ),
                );
                if (result != null && result.imagePath.isNotEmpty) {
                  setState(() {
                    _themeSettings.songBackgroundImage = result.imagePath;
                    _themeSettings.songBackgroundImageLayout = result.layout;
                    _themeSettings.songBackgroundImageAlignment = result.alignment;
                    _themeSettings.isSongImageEnabled = true;

                    _themeSettings.scriptureBackgroundImage = result.imagePath;
                    _themeSettings.scriptureBackgroundImageLayout = result.layout;
                    _themeSettings.scriptureBackgroundImageAlignment = result.alignment;
                    _themeSettings.isScriptureImageEnabled = true;
                  });
                }
              },
              child: const Text('Add'),
            ),
            if (backgroundImage.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  backgroundImage.split(Platform.pathSeparator).last,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTitleSettingsTheme() {
    final settings = _themeSettings;
    final showTitle = settings.showTitle;
    final alignment = settings.titleAlignment;
    final valignment = settings.titleVerticalAlignment;
    
    final mTop = settings.titleMarginTop;
    final mBottom = settings.titleMarginBottom;
    final mLeft = settings.titleMarginLeft;
    final mRight = settings.titleMarginRight;

    final fontFamily = settings.titleFontFamily;
    final fontSize = settings.titleFontSize;
    final fontColor = settings.titleFontColor;
    final bold = settings.titleBold;
    final italic = settings.titleItalic;
    final underline = settings.titleUnderline;
    final hasFill = settings.titleHasFill;
    final fillColor = settings.titleFillColor;
    final hasStroke = settings.titleHasStroke;
    final strokeColor = settings.titleStrokeColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              _showTypographyDialog(
                context: context,
                initialFontFamily: fontFamily,
                initialFontSize: fontSize,
                initialFontColor: fontColor,
                initialBold: bold,
                initialItalic: italic,
                initialUnderline: underline,
                initialHasFill: hasFill,
                initialFillColor: fillColor,
                initialHasStroke: hasStroke,
                initialStrokeColor: strokeColor,
                onChanged: ({fontFamily, fontSize, fontColor, bold, italic, underline, hasFill, fillColor, hasStroke, strokeColor, lineBreak}) {
                  setState(() {
                    if (fontFamily != null) {
                      _themeSettings.titleFontFamily = fontFamily;
                      _themeSettings.chapterFontFamily = fontFamily;
                    }
                    if (fontSize != null) {
                      _themeSettings.titleFontSize = fontSize;
                      _themeSettings.chapterFontSize = fontSize;
                    }
                    if (fontColor != null) {
                      _themeSettings.titleFontColor = fontColor;
                      _themeSettings.chapterFontColor = fontColor;
                    }
                    if (bold != null) {
                      _themeSettings.titleBold = bold;
                      _themeSettings.chapterBold = bold;
                    }
                    if (italic != null) {
                      _themeSettings.titleItalic = italic;
                      _themeSettings.chapterItalic = italic;
                    }
                    if (underline != null) {
                      _themeSettings.titleUnderline = underline;
                      _themeSettings.chapterUnderline = underline;
                    }
                    if (hasFill != null || fillColor != null) {
                      final f = hasFill ?? _themeSettings.titleHasFill;
                      final fc = fillColor ?? _themeSettings.titleFillColor;
                      _themeSettings.titleHasFill = f;
                      _themeSettings.titleFillColor = fc;
                      _themeSettings.chapterHasFill = f;
                      _themeSettings.chapterFillColor = fc;
                    }
                    if (hasStroke != null || strokeColor != null) {
                      final s = hasStroke ?? _themeSettings.titleHasStroke;
                      final sc = strokeColor ?? _themeSettings.titleStrokeColor;
                      _themeSettings.titleHasStroke = s;
                      _themeSettings.titleStrokeColor = sc;
                      _themeSettings.chapterHasStroke = s;
                      _themeSettings.chapterStrokeColor = sc;
                    }
                  });
                },
              );
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Title / Chapter Settings',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16.0),
              ),
              child: Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: Text(
                  '$fontFamily ${fontSize.toInt()}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlignmentGridWidget(alignment, valignment, (h, v) {
              setState(() {
                _themeSettings.titleAlignment = h;
                _themeSettings.titleVerticalAlignment = v;
                _themeSettings.chapterAlignment = h;
                _themeSettings.chapterVerticalAlignment = v;
              });
            }),
            const SizedBox(width: 24),
            _buildMarginMatrixWidget(mTop, mBottom, mLeft, mRight, 'theme_title', ({b, l, r, t}) {
              setState(() {
                if (t != null) {
                  _themeSettings.titleMarginTop = t;
                  _themeSettings.chapterMarginTop = t;
                }
                if (b != null) {
                  _themeSettings.titleMarginBottom = b;
                  _themeSettings.chapterMarginBottom = b;
                }
                if (l != null) {
                  _themeSettings.titleMarginLeft = l;
                  _themeSettings.chapterMarginLeft = l;
                }
                if (r != null) {
                  _themeSettings.titleMarginRight = r;
                  _themeSettings.chapterMarginRight = r;
                }
              });
            }),
            const Spacer(),
            Row(
              children: [
                Checkbox(
                  value: showTitle,
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _themeSettings.showTitle = v;
                        _themeSettings.showChapter = v;
                      });
                    }
                  },
                ),
                const Text('Visible'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodySettingsTheme() {
    final settings = _themeSettings;
    final alignment = settings.lyricsAlignment;
    final valignment = settings.lyricsVerticalAlignment;
    
    final mTop = settings.lyricsMarginTop;
    final mBottom = settings.lyricsMarginBottom;
    final mLeft = settings.lyricsMarginLeft;
    final mRight = settings.lyricsMarginRight;

    final fontFamily = settings.lyricsFontFamily;
    final fontSize = settings.lyricsFontSize;
    final fontColor = settings.lyricsFontColor;
    final bold = settings.lyricsBold;
    final italic = settings.lyricsItalic;
    final underline = settings.lyricsUnderline;
    final hasFill = settings.lyricsHasFill;
    final fillColor = settings.lyricsFillColor;
    final hasStroke = settings.lyricsHasStroke;
    final strokeColor = settings.lyricsStrokeColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              _showTypographyDialog(
                context: context,
                initialFontFamily: fontFamily,
                initialFontSize: fontSize,
                initialFontColor: fontColor,
                initialBold: bold,
                initialItalic: italic,
                initialUnderline: underline,
                initialHasFill: hasFill,
                initialFillColor: fillColor,
                initialHasStroke: hasStroke,
                initialStrokeColor: strokeColor,
                showLineBreakOption: true,
                initialLineBreak: settings.lyricsLineBreak,
                onChanged: ({fontFamily, fontSize, fontColor, bold, italic, underline, hasFill, fillColor, hasStroke, strokeColor, lineBreak}) {
                  setState(() {
                    if (fontFamily != null) {
                      _themeSettings.lyricsFontFamily = fontFamily;
                      _themeSettings.verseFontFamily = fontFamily;
                    }
                    if (fontSize != null) {
                      _themeSettings.lyricsFontSize = fontSize;
                      _themeSettings.verseFontSize = fontSize;
                    }
                    if (fontColor != null) {
                      _themeSettings.lyricsFontColor = fontColor;
                      _themeSettings.verseFontColor = fontColor;
                    }
                    if (bold != null) {
                      _themeSettings.lyricsBold = bold;
                      _themeSettings.verseBold = bold;
                    }
                    if (italic != null) {
                      _themeSettings.lyricsItalic = italic;
                      _themeSettings.verseItalic = italic;
                    }
                    if (underline != null) {
                      _themeSettings.lyricsUnderline = underline;
                      _themeSettings.verseUnderline = underline;
                    }
                    if (lineBreak != null) {
                      _themeSettings.lyricsLineBreak = lineBreak;
                    }
                    if (hasFill != null || fillColor != null) {
                      final f = hasFill ?? _themeSettings.lyricsHasFill;
                      final fc = fillColor ?? _themeSettings.lyricsFillColor;
                      _themeSettings.lyricsHasFill = f;
                      _themeSettings.lyricsFillColor = fc;
                      _themeSettings.verseHasFill = f;
                      _themeSettings.verseFillColor = fc;
                    }
                    if (hasStroke != null || strokeColor != null) {
                      final s = hasStroke ?? _themeSettings.lyricsHasStroke;
                      final sc = strokeColor ?? _themeSettings.lyricsStrokeColor;
                      _themeSettings.lyricsHasStroke = s;
                      _themeSettings.lyricsStrokeColor = sc;
                      _themeSettings.verseHasStroke = s;
                      _themeSettings.verseStrokeColor = sc;
                    }
                  });
                },
              );
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Body / Verse Settings',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16.0),
              ),
              child: Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: Text(
                  '$fontFamily ${fontSize.toInt()}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlignmentGridWidget(alignment, valignment, (h, v) {
              setState(() {
                _themeSettings.lyricsAlignment = h;
                _themeSettings.lyricsVerticalAlignment = v;
                _themeSettings.verseAlignment = h;
                _themeSettings.verseVerticalAlignment = v;
              });
            }),
            const SizedBox(width: 24),
            _buildMarginMatrixWidget(mTop, mBottom, mLeft, mRight, 'theme_body', ({b, l, r, t}) {
              setState(() {
                if (t != null) {
                  _themeSettings.lyricsMarginTop = t;
                  _themeSettings.verseMarginTop = t;
                }
                if (b != null) {
                  _themeSettings.lyricsMarginBottom = b;
                  _themeSettings.verseMarginBottom = b;
                }
                if (l != null) {
                  _themeSettings.lyricsMarginLeft = l;
                  _themeSettings.verseMarginLeft = l;
                }
                if (r != null) {
                  _themeSettings.lyricsMarginRight = r;
                  _themeSettings.verseMarginRight = r;
                }
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewPaneTheme() {
    final settings = _themeSettings;
    final isSong = _previewThemeAsSong;
    
    final previewTitle = isSong ? "Amazing Grace" : "John 3:16";
    final previewText = isSong 
      ? "Amazing grace how sweet the sound\nThat saved a wretch like me"
      : "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.";

    final aspectRatioStr = settings.songAspectRatio;
    double aspectRatio = 16 / 9;
    if (aspectRatioStr == '4:3') {
      aspectRatio = 4 / 3;
    } else if (aspectRatioStr == '4:1') {
      aspectRatio = 4 / 1;
    } else if (aspectRatioStr == 'Custom') {
      final w = settings.songCustomWidth;
      final h = settings.songCustomHeight;
      aspectRatio = (w > 0 && h > 0) ? w / h : 16 / 9;
    }

    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white10),
          ),
          child: ProjectorView(
            settings: settings,
            activeSlideText: previewText,
            titleText: previewTitle,
            isSong: isSong,
            showCheckerboard: true,
          ),
        ),
      ),
    );
  }

  Future<void> _saveTheme() async {
    try {
      final themesDir = await _getThemesDirectory();
      final themeDir = Directory(p.join(themesDir.path, _editingThemeName));
      if (!await themeDir.exists()) {
        await themeDir.create(recursive: true);
      }
      
      final originalBg = _themeSettings.songBackgroundImage;
      final mediaSync = ref.read(mediaSyncManagerProvider);
      final resolvedBg = originalBg.isNotEmpty ? mediaSync.resolveMediaPath(originalBg) : '';
      String relativeBg = '';
      if (resolvedBg.isNotEmpty && File(resolvedBg).existsSync()) {
        final filename = p.basename(resolvedBg);
        final destinationFile = File(p.join(themeDir.path, filename));
        if (p.canonicalize(resolvedBg) != p.canonicalize(destinationFile.path)) {
          await File(resolvedBg).copy(destinationFile.path);
        }
        relativeBg = filename;
      }
      
      final serializedSettings = _themeSettings;
      serializedSettings.songBackgroundImage = relativeBg;
      serializedSettings.scriptureBackgroundImage = relativeBg;
      
      final jsonMap = _themeToJson(serializedSettings, _editingThemeName);
      final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonMap);
      
      final jsonFile = File(p.join(themeDir.path, 'theme.json'));
      await jsonFile.writeAsString(jsonStr);
      
      if (relativeBg.isNotEmpty) {
        _themeSettings.songBackgroundImage = p.join(themeDir.path, relativeBg);
        _themeSettings.scriptureBackgroundImage = p.join(themeDir.path, relativeBg);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Theme "$_editingThemeName" saved successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving theme: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _exportTheme() async {
    try {
      await _saveTheme();
      
      final themesDir = await _getThemesDirectory();
      final themeDir = Directory(p.join(themesDir.path, _editingThemeName));
      if (!await themeDir.exists()) {
        throw Exception('Theme folder does not exist.');
      }
      
      final result = await FilePicker.saveFile(
        dialogTitle: 'Export Theme Zip',
        fileName: '$_editingThemeName.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      if (result == null) return;
      
      final encoder = ZipFileEncoder();
      encoder.create(result);
      final files = themeDir.listSync();
      for (final f in files) {
        if (f is File) {
          encoder.addFile(f);
        }
      }
      encoder.close();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Theme exported successfully to $result')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting theme: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showApplyThemeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Theme to Apply'),
        content: SizedBox(
          width: 700,
          height: 500,
          child: FutureBuilder<List<PresentationSettings>>(
            future: _loadThemes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final themes = snapshot.data ?? [];
              if (themes.isEmpty) {
                return const Center(child: Text('No themes found. Import a theme first!'));
              }
              
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  final isSong = _editTabIndex == 0;
                  
                  final previewTitle = isSong ? "Amazing Grace" : "John 3:16";
                  final previewText = isSong 
                    ? "Amazing grace how sweet the sound\nThat saved a wretch like me"
                    : "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.";
                  
                  final aspectRatioStr = theme.songAspectRatio;
                  double aspectRatio = 16 / 9;
                  if (aspectRatioStr == '4:3') {
                    aspectRatio = 4 / 3;
                  } else if (aspectRatioStr == '4:1') {
                    aspectRatio = 4 / 1;
                  } else if (aspectRatioStr == 'Custom') {
                    final w = theme.songCustomWidth;
                    final h = theme.songCustomHeight;
                    aspectRatio = (w > 0 && h > 0) ? w / h : 16 / 9;
                  }

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            theme.presetName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.black,
                            alignment: Alignment.center,
                            child: AspectRatio(
                              aspectRatio: aspectRatio,
                              child: ProjectorView(
                                settings: theme,
                                activeSlideText: previewText,
                                titleText: previewTitle,
                                isSong: isSong,
                                showCheckerboard: false,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _applyThemeToActiveTab(theme);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Apply'),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  void _applyThemeToActiveTab(PresentationSettings theme) {
    final notifier = ref.read(editingPresetProvider.notifier);
    final isSong = _editTabIndex == 0;
    
    if (isSong) {
      notifier.updateAspectRatio(theme.songAspectRatio, 0);
      notifier.updateCustomWidth(theme.songCustomWidth, 0);
      notifier.updateCustomHeight(theme.songCustomHeight, 0);
      
      notifier.updateBackgroundColor(theme.songBackgroundColor, 0);
      notifier.updateIsTransparent(theme.isSongTransparent, 0);
      notifier.updateIsImageEnabled(theme.isSongImageEnabled, 0);
      if (theme.isSongImageEnabled && theme.songBackgroundImage.isNotEmpty) {
        notifier.updateBackgroundImage(
          theme.songBackgroundImage,
          theme.songBackgroundImageLayout,
          theme.songBackgroundImageAlignment,
          0,
        );
      }
      
      notifier.updateShowTitle(theme.showTitle);
      notifier.updateTitleAlignment(theme.titleAlignment);
      notifier.updateTitleVerticalAlignment(theme.titleVerticalAlignment);
      notifier.updateTitleFontSize(theme.titleFontSize);
      notifier.updateTitleFontFamily(theme.titleFontFamily);
      notifier.updateTitleFontColor(theme.titleFontColor);
      notifier.updateTitleBold(theme.titleBold);
      notifier.updateTitleItalic(theme.titleItalic);
      notifier.updateTitleUnderline(theme.titleUnderline);
      notifier.updateTitleFill(theme.titleHasFill, theme.titleFillColor);
      notifier.updateTitleStroke(theme.titleHasStroke, theme.titleStrokeColor);
      notifier.updateTitleMargins(
        top: theme.titleMarginTop,
        bottom: theme.titleMarginBottom,
        left: theme.titleMarginLeft,
        right: theme.titleMarginRight,
      );
      
      notifier.updateLyricsAlignment(theme.lyricsAlignment);
      notifier.updateLyricsVerticalAlignment(theme.lyricsVerticalAlignment);
      notifier.updateLyricsFontSize(theme.lyricsFontSize);
      notifier.updateLyricsFontFamily(theme.lyricsFontFamily);
      notifier.updateLyricsFontColor(theme.lyricsFontColor);
      notifier.updateLyricsBold(theme.lyricsBold);
      notifier.updateLyricsItalic(theme.lyricsItalic);
      notifier.updateLyricsUnderline(theme.lyricsUnderline);
      notifier.updateLyricsFill(theme.lyricsHasFill, theme.lyricsFillColor);
      notifier.updateLyricsStroke(theme.lyricsHasStroke, theme.lyricsStrokeColor);
      notifier.updateLyricsLineBreak(theme.lyricsLineBreak);
      notifier.updateLyricsMargins(
        top: theme.lyricsMarginTop,
        bottom: theme.lyricsMarginBottom,
        left: theme.lyricsMarginLeft,
        right: theme.lyricsMarginRight,
      );
    } else {
      notifier.updateAspectRatio(theme.scriptureAspectRatio, 1);
      notifier.updateCustomWidth(theme.scriptureCustomWidth, 1);
      notifier.updateCustomHeight(theme.scriptureCustomHeight, 1);
      
      notifier.updateBackgroundColor(theme.scriptureBackgroundColor, 1);
      notifier.updateIsTransparent(theme.isScriptureTransparent, 1);
      notifier.updateIsImageEnabled(theme.isScriptureImageEnabled, 1);
      if (theme.isScriptureImageEnabled && theme.scriptureBackgroundImage.isNotEmpty) {
        notifier.updateBackgroundImage(
          theme.scriptureBackgroundImage,
          theme.scriptureBackgroundImageLayout,
          theme.scriptureBackgroundImageAlignment,
          1,
        );
      }
      
      notifier.updateShowChapter(theme.showChapter);
      notifier.updateChapterAlignment(theme.chapterAlignment);
      notifier.updateChapterVerticalAlignment(theme.chapterVerticalAlignment);
      notifier.updateChapterFontSize(theme.chapterFontSize);
      notifier.updateChapterFontFamily(theme.chapterFontFamily);
      notifier.updateChapterFontColor(theme.chapterFontColor);
      notifier.updateChapterBold(theme.chapterBold);
      notifier.updateChapterItalic(theme.chapterItalic);
      notifier.updateChapterUnderline(theme.chapterUnderline);
      notifier.updateChapterFill(theme.chapterHasFill, theme.chapterFillColor);
      notifier.updateChapterStroke(theme.chapterHasStroke, theme.chapterStrokeColor);
      notifier.updateChapterMargins(
        top: theme.chapterMarginTop,
        bottom: theme.chapterMarginBottom,
        left: theme.chapterMarginLeft,
        right: theme.chapterMarginRight,
      );
      
      notifier.updateVerseAlignment(theme.verseAlignment);
      notifier.updateVerseVerticalAlignment(theme.verseVerticalAlignment);
      notifier.updateVerseFontSize(theme.verseFontSize);
      notifier.updateVerseFontFamily(theme.verseFontFamily);
      notifier.updateVerseFontColor(theme.verseFontColor);
      notifier.updateVerseBold(theme.verseBold);
      notifier.updateVerseItalic(theme.verseItalic);
      notifier.updateVerseUnderline(theme.verseUnderline);
      notifier.updateVerseFill(theme.verseHasFill, theme.verseFillColor);
      notifier.updateVerseStroke(theme.verseHasStroke, theme.verseStrokeColor);
      notifier.updateVerseMargins(
        top: theme.verseMarginTop,
        bottom: theme.verseMarginBottom,
        left: theme.verseMarginLeft,
        right: theme.verseMarginRight,
      );
    }
    setState(() {
      _updateControllers();
    });
  }
}
