import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../presentation_settings_provider.dart';
import '../../data/presentation_settings.dart';

const List<String> kCommonSystemFonts = [
  'Arial', 'Arial Black', 'Calibri', 'Cambria', 'Candara', 'Century Gothic',
  'Comic Sans MS', 'Consolas', 'Courier New', 'Franklin Gothic Medium',
  'Garamond', 'Georgia', 'Impact', 'Lucida Console', 'Lucida Sans Unicode',
  'Microsoft Sans Serif', 'Palatino Linotype', 'Segoe UI', 'Tahoma',
  'Times New Roman', 'Trebuchet MS', 'Verdana'
];

enum ViewMode { choose, edit }

class PresentationSettingsDialog extends ConsumerStatefulWidget {
  const PresentationSettingsDialog({super.key});

  @override
  ConsumerState<PresentationSettingsDialog> createState() => _PresentationSettingsDialogState();
}

class _PresentationSettingsDialogState extends ConsumerState<PresentationSettingsDialog> {
  ViewMode _mode = ViewMode.choose;
  int _editTabIndex = 0; // 0: Song, 1: Scripture
  final TextEditingController _newPresetCtrl = TextEditingController();

  @override
  void dispose() {
    _newPresetCtrl.dispose();
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
                : _buildEditPresetView(),
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
              ],
              selected: {_editTabIndex},
              onSelectionChanged: (set) => setState(() => _editTabIndex = set.first),
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
            setState(() => _mode = ViewMode.edit);
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
                key: ValueKey('${contextKey}_$label'),
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
                const SizedBox(height: 16),
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
                    child: _buildTitleSettings(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildBodySettings(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text('Save ${_editTabIndex == 0 ? 'Song' : 'Scripture'} Settings'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      final s = ref.read(editingPresetProvider);
                      // Validation
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
                initialUnderline: underline,
                initialHasFill: hasFill,
                initialFillColor: fillColor,
                initialHasStroke: hasStroke,
                initialStrokeColor: strokeColor,
                onChanged: ({fontFamily, fontSize, fontColor, underline, hasFill, fillColor, hasStroke, strokeColor}) {
                  if (fontFamily != null) isSong ? notifier.updateTitleFontFamily(fontFamily) : notifier.updateChapterFontFamily(fontFamily);
                  if (fontSize != null) isSong ? notifier.updateTitleFontSize(fontSize) : notifier.updateChapterFontSize(fontSize);
                  if (fontColor != null) isSong ? notifier.updateTitleFontColor(fontColor) : notifier.updateChapterFontColor(fontColor);
                  if (underline != null) isSong ? notifier.updateTitleUnderline(underline) : notifier.updateChapterUnderline(underline);
                  if (hasFill != null || fillColor != null) {
                    final f = hasFill ?? (isSong ? settings.titleHasFill : settings.chapterHasFill);
                    final fc = fillColor ?? (isSong ? settings.titleFillColor : settings.chapterFillColor);
                    isSong ? notifier.updateTitleFill(f, fc) : notifier.updateChapterFill(f, fc);
                  }
                  if (hasStroke != null || strokeColor != null) {
                    final s = hasStroke ?? (isSong ? settings.titleHasStroke : settings.chapterHasStroke);
                    final sc = strokeColor ?? (isSong ? settings.titleStrokeColor : settings.chapterStrokeColor);
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
                initialUnderline: underline,
                initialHasFill: hasFill,
                initialFillColor: fillColor,
                initialHasStroke: hasStroke,
                initialStrokeColor: strokeColor,
                onChanged: ({fontFamily, fontSize, fontColor, underline, hasFill, fillColor, hasStroke, strokeColor}) {
                  if (fontFamily != null) isSong ? notifier.updateLyricsFontFamily(fontFamily) : notifier.updateVerseFontFamily(fontFamily);
                  if (fontSize != null) isSong ? notifier.updateLyricsFontSize(fontSize) : notifier.updateVerseFontSize(fontSize);
                  if (fontColor != null) isSong ? notifier.updateLyricsFontColor(fontColor) : notifier.updateVerseFontColor(fontColor);
                  if (underline != null) isSong ? notifier.updateLyricsUnderline(underline) : notifier.updateVerseUnderline(underline);
                  if (hasFill != null || fillColor != null) {
                    final f = hasFill ?? (isSong ? settings.lyricsHasFill : settings.verseHasFill);
                    final fc = fillColor ?? (isSong ? settings.lyricsFillColor : settings.verseFillColor);
                    isSong ? notifier.updateLyricsFill(f, fc) : notifier.updateVerseFill(f, fc);
                  }
                  if (hasStroke != null || strokeColor != null) {
                    final s = hasStroke ?? (isSong ? settings.lyricsHasStroke : settings.verseHasStroke);
                    final sc = strokeColor ?? (isSong ? settings.lyricsStrokeColor : settings.verseStrokeColor);
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

    final aspectRatio = isSong ? settings.songAspectRatio : settings.scriptureAspectRatio;
    final customWidth = isSong ? settings.songCustomWidth : settings.scriptureCustomWidth;
    final customHeight = isSong ? settings.songCustomHeight : settings.scriptureCustomHeight;

    return Row(
      children: [
        DropdownMenu<String>(
          initialSelection: aspectRatio,
          label: const Text('Aspect Ratio'),
          onSelected: (val) {
            if (val != null) notifier.updateAspectRatio(val, isSong);
          },
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: '16:9', label: '16:9'),
            DropdownMenuEntry(value: '4:3', label: '4:3'),
            DropdownMenuEntry(value: '4:1', label: '4:1 (Banner)'),
            DropdownMenuEntry(value: 'Custom', label: 'Custom'),
          ],
        ),
        if (aspectRatio == 'Custom') ...[
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: ValueKey('${isSong ? "song" : "scripture"}_cw'),
              controller: TextEditingController(text: customWidth.toStringAsFixed(0)),
              decoration: const InputDecoration(labelText: 'W (px)', isDense: true, border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (v) => notifier.updateCustomWidth(double.tryParse(v) ?? 1920.0, isSong),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: ValueKey('${isSong ? "song" : "scripture"}_ch'),
              controller: TextEditingController(text: customHeight.toStringAsFixed(0)),
              decoration: const InputDecoration(labelText: 'H (px)', isDense: true, border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (v) => notifier.updateCustomHeight(double.tryParse(v) ?? 1080.0, isSong),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildBackgroundControls() {
    final settings = ref.watch(editingPresetProvider);
    final notifier = ref.read(editingPresetProvider.notifier);
    final isSong = _editTabIndex == 0;
    
    final isTransparent = isSong ? settings.isSongTransparent : settings.isScriptureTransparent;
    final backgroundColor = isSong ? settings.songBackgroundColor : settings.scriptureBackgroundColor;
    final isImageEnabled = isSong ? settings.isSongImageEnabled : settings.isScriptureImageEnabled;
    final backgroundImage = isSong ? settings.songBackgroundImage : settings.scriptureBackgroundImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: !isTransparent,
              onChanged: (_) => notifier.updateIsTransparent(false, isSong),
            ),
            const Text('Background Color'),
            const SizedBox(width: 8),
            InkWell(
              onTap: isTransparent ? null : () => _showColorPicker(context, Color(backgroundColor), (c) => notifier.updateBackgroundColor(c.value, isSong)),
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
              onChanged: (_) => notifier.updateIsTransparent(true, isSong),
            ),
            const Text('Transparent'),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: isImageEnabled,
              onChanged: (val) {
                if (val != null) notifier.updateIsImageEnabled(val, isSong);
              },
            ),
            const Text('Image'),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image);
                if (result != null && result.files.single.path != null) {
                  notifier.updateBackgroundImage(result.files.single.path!, isSong);
                }
              },
              child: const Text('Browse'),
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
    required bool initialUnderline,
    required bool initialHasFill,
    required int initialFillColor,
    required bool initialHasStroke,
    required int initialStrokeColor,
    required void Function({
      String? fontFamily,
      double? fontSize,
      int? fontColor,
      bool? underline,
      bool? hasFill,
      int? fillColor,
      bool? hasStroke,
      int? strokeColor,
    }) onChanged,
  }) {
    String fontFamily = initialFontFamily;
    double fontSize = initialFontSize;
    int fontColor = initialFontColor;
    bool underline = initialUnderline;
    bool hasFill = initialHasFill;
    int fillColor = initialFillColor;
    bool hasStroke = initialHasStroke;
    int strokeColor = initialStrokeColor;
    
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
                                final parsed = double.tryParse(v);
                                if (parsed != null) {
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
                                children: List.generate(96, (i) => i + 5)
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
    
    // Calculate aspect ratio
    final aspectRatioStr = isSong ? settings.songAspectRatio : settings.scriptureAspectRatio;
    final cWidth = isSong ? settings.songCustomWidth : settings.scriptureCustomWidth;
    final cHeight = isSong ? settings.songCustomHeight : settings.scriptureCustomHeight;

    double ratio = 16 / 9;
    if (aspectRatioStr == '4:3') ratio = 4 / 3;
    else if (aspectRatioStr == '4:1') ratio = 4 / 1;
    else if (aspectRatioStr == 'Custom' && cHeight > 0) {
      ratio = cWidth / cHeight;
    }

    String previewTitle = isSong ? "Amazing Grace" : "John 3:16";
    String previewText = isSong 
      ? "Amazing grace how sweet the sound\nThat saved a wretch like me"
      : "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.";

    // Apply settings appropriately based on tab selection
    // Note: In real preview we would scale down fonts relative to preview container size, 
    // but AutoSizeText handles some scaling inherently. We will rely on AutoSizeText for now.

    final isTransparent = isSong ? settings.isSongTransparent : settings.isScriptureTransparent;
    final backgroundColor = isSong ? settings.songBackgroundColor : settings.scriptureBackgroundColor;
    final isImageEnabled = isSong ? settings.isSongImageEnabled : settings.isScriptureImageEnabled;
    final backgroundImage = isSong ? settings.songBackgroundImage : settings.scriptureBackgroundImage;

    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Center(
        child: AspectRatio(
          aspectRatio: ratio,
          child: DefaultTextStyle(
            style: const TextStyle(decoration: TextDecoration.none),
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: isTransparent ? Colors.transparent : Color(backgroundColor),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (isTransparent) _buildCheckerboard(),
                  if (isImageEnabled && backgroundImage.isNotEmpty && File(backgroundImage).existsSync())
                    Image.file(
                      File(backgroundImage),
                      fit: BoxFit.cover,
                    ),
                  _buildPreviewContent(settings, isSong, previewTitle, previewText),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContent(PresentationSettings settings, bool isSong, String title, String mainText) {
    // Body Settings
    final topMargin = isSong ? settings.lyricsMarginTop : settings.verseMarginTop;
    final botMargin = isSong ? settings.lyricsMarginBottom : settings.verseMarginBottom;
    final leftMargin = isSong ? settings.lyricsMarginLeft : settings.verseMarginLeft;
    final rightMargin = isSong ? settings.lyricsMarginRight : settings.verseMarginRight;

    final fontSize = isSong ? settings.lyricsFontSize : settings.verseFontSize;
    final fontColor = isSong ? Color(settings.lyricsFontColor) : Color(settings.verseFontColor);
    final fontFamily = isSong ? settings.lyricsFontFamily : settings.verseFontFamily;
    final alignStr = isSong ? settings.lyricsAlignment : settings.verseAlignment;
    final vAlignStr = isSong ? settings.lyricsVerticalAlignment : settings.verseVerticalAlignment;
    final underline = isSong ? settings.lyricsUnderline : settings.verseUnderline;
    final hasFill = isSong ? settings.lyricsHasFill : settings.verseHasFill;
    final fillColor = isSong ? Color(settings.lyricsFillColor) : Color(settings.verseFillColor);
    final hasStroke = isSong ? settings.lyricsHasStroke : settings.verseHasStroke;
    final strokeColor = isSong ? Color(settings.lyricsStrokeColor) : Color(settings.verseStrokeColor);

    // Title Settings
    final showTitle = isSong ? settings.showTitle : settings.showChapter;
    final titleHorizontalStr = isSong ? settings.titleAlignment : settings.chapterAlignment;
    final titleVerticalStr = isSong ? settings.titleVerticalAlignment : settings.chapterVerticalAlignment;
    final titleFontSize = isSong ? settings.titleFontSize : settings.chapterFontSize;
    final titleFontColor = isSong ? Color(settings.titleFontColor) : Color(settings.chapterFontColor);
    final tFontFamily = isSong ? settings.titleFontFamily : settings.chapterFontFamily;
    
    final tTopMargin = isSong ? settings.titleMarginTop : settings.chapterMarginTop;
    final tBotMargin = isSong ? settings.titleMarginBottom : settings.chapterMarginBottom;
    final tLeftMargin = isSong ? settings.titleMarginLeft : settings.chapterMarginLeft;
    final tRightMargin = isSong ? settings.titleMarginRight : settings.chapterMarginRight;
    final tUnderline = isSong ? settings.titleUnderline : settings.chapterUnderline;
    final tHasFill = isSong ? settings.titleHasFill : settings.chapterHasFill;
    final tFillColor = isSong ? Color(settings.titleFillColor) : Color(settings.chapterFillColor);
    final tHasStroke = isSong ? settings.titleHasStroke : settings.chapterHasStroke;
    final tStrokeColor = isSong ? Color(settings.titleStrokeColor) : Color(settings.chapterStrokeColor);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Body Layer
        Align(
          alignment: _getAlignmentGeometry(alignStr, vAlignStr),
          child: Padding(
            padding: EdgeInsets.fromLTRB(leftMargin, topMargin, rightMargin, botMargin),
            child: Stack(
              children: [
                if (hasStroke)
                  AutoSizeText(
                    mainText,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      decoration: underline ? TextDecoration.underline : TextDecoration.none,
                      backgroundColor: hasFill ? fillColor : null,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2.0
                        ..color = strokeColor,
                    ),
                    textAlign: _getAlignment(alignStr),
                    minFontSize: 8,
                  ),
                AutoSizeText(
                  mainText,
                  style: TextStyle(
                    color: fontColor,
                    fontSize: fontSize,
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    decoration: underline ? TextDecoration.underline : TextDecoration.none,
                    backgroundColor: hasFill ? fillColor : null,
                  ),
                  textAlign: _getAlignment(alignStr),
                  minFontSize: 8,
                ),
              ],
            ),
          ),
        ),
        
        // Title Layer
        if (showTitle)
          Align(
            alignment: _getAlignmentGeometry(titleHorizontalStr, titleVerticalStr),
            child: Padding(
              padding: EdgeInsets.fromLTRB(tLeftMargin, tTopMargin, tRightMargin, tBotMargin),
              child: Stack(
                children: [
                  if (tHasStroke)
                    Text(
                      title, 
                      style: TextStyle(
                        fontSize: titleFontSize.clamp(8.0, 32.0), 
                        fontFamily: tFontFamily,
                        decoration: tUnderline ? TextDecoration.underline : TextDecoration.none,
                        backgroundColor: tHasFill ? tFillColor : null,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2.0
                          ..color = tStrokeColor,
                      ),
                      textAlign: _getAlignment(titleHorizontalStr),
                    ),
                  Text(
                    title, 
                    style: TextStyle(
                      fontSize: titleFontSize.clamp(8.0, 32.0), 
                      color: titleFontColor,
                      fontFamily: tFontFamily,
                      decoration: tUnderline ? TextDecoration.underline : TextDecoration.none,
                      backgroundColor: tHasFill ? tFillColor : null,
                    ),
                    textAlign: _getAlignment(titleHorizontalStr),
                  ),
                ],
              ),
            ),
          )
      ],
    );
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

  Widget _buildCheckerboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _CheckerboardPainter(),
        );
      },
    );
  }

  TextAlign _getAlignment(String alignment) {
    switch (alignment) {
      case 'left': return TextAlign.left;
      case 'right': return TextAlign.right;
      case 'center': default: return TextAlign.center;
    }
  }

  Alignment _getVerticalAlignment(String alignment) {
    switch (alignment) {
      case 'top': return Alignment.topCenter;
      case 'bottom': return Alignment.bottomCenter;
      case 'center': default: return Alignment.center;
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
