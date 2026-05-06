import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/presentation_settings_provider.dart';
import '../../../settings/presentation/projection_provider.dart';

class MonitorSettingsPopup extends ConsumerStatefulWidget {
  final int monitorIndex; // 1 or 2
  final int? initialPresetId;

  const MonitorSettingsPopup({
    super.key,
    required this.monitorIndex,
    this.initialPresetId,
  });

  @override
  ConsumerState<MonitorSettingsPopup> createState() => _MonitorSettingsPopupState();
}

class _MonitorSettingsPopupState extends ConsumerState<MonitorSettingsPopup> {
  int? _selectedPresetId;
  int _maxVerses = 1;
  final TextEditingController _maxCharsController = TextEditingController();
  String _format = 'Verse';

  @override
  void initState() {
    super.initState();
    _selectedPresetId = widget.initialPresetId;
    
    // Initialize current settings
    final config = ref.read(projectionProvider).config;
    if (widget.monitorIndex == 1) {
      _maxVerses = config.monitor1MaxVerses;
      _maxCharsController.text = config.monitor1MaxChars == 0 ? '' : config.monitor1MaxChars.toString();
      _format = config.monitor1Format;
    } else {
      _maxVerses = config.monitor2MaxVerses;
      _maxCharsController.text = config.monitor2MaxChars == 0 ? '' : config.monitor2MaxChars.toString();
      _format = config.monitor2Format;
    }
  }

  @override
  void dispose() {
    _maxCharsController.dispose();
    super.dispose();
  }

  void _apply() {
    int maxChars = int.tryParse(_maxCharsController.text) ?? 0;
    
    ref.read(projectionProvider.notifier).updateMonitorConfig(
      monitorIndex: widget.monitorIndex,
      presetId: _selectedPresetId,
      updatePreset: true,
      maxVerses: _maxVerses,
      maxChars: maxChars,
      format: _format,
    );
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final presetsAsync = ref.watch(presetsListProvider);

    const double popupWidth = 320;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: popupWidth,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Monitor ${widget.monitorIndex} Settings',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, size: 16, color: Colors.grey),
                  )
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
                    
                    // Dropdown 1: Preset
                    const Text('Preset', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 36,
                      child: presetsAsync.when(
                        data: (presets) {
                          if (presets.isEmpty) {
                            return const Text('No presets available', style: TextStyle(color: Colors.white70));
                          }
                          _selectedPresetId ??= presets.firstOrNull?.id;
                          return DropdownMenu<int>(
                            initialSelection: _selectedPresetId,
                            requestFocusOnTap: true,
                            enableFilter: true,
                            width: popupWidth - 32, // Padding 16 on each side
                            textStyle: const TextStyle(color: Colors.white, fontSize: 13),
                            menuStyle: MenuStyle(
                              backgroundColor: WidgetStatePropertyAll(Colors.grey[800]),
                            ),
                            inputDecorationTheme: InputDecorationTheme(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                              filled: true,
                              fillColor: Colors.grey[900],
                              constraints: const BoxConstraints(maxHeight: 36),
                            ),
                            onSelected: (int? val) {
                              if (val != null) setState(() => _selectedPresetId = val);
                            },
                            dropdownMenuEntries: presets.map<DropdownMenuEntry<int>>((p) {
                              return DropdownMenuEntry<int>(
                                value: p.id,
                                label: p.presetName,
                                style: MenuItemButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        error: (_, __) => const Text('Error loading presets', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dropdown 2: Max No. of Verses / Slide
                    const Text('Max No. of Verses / Slide', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 36,
                      child: DropdownButtonFormField<int>(
                        value: _maxVerses,
                        isExpanded: true,
                        dropdownColor: Colors.grey[800],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                          filled: true,
                          fillColor: Colors.grey[900],
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        items: [1, 2, 3].map((val) => DropdownMenuItem<int>(
                          value: val,
                          child: Text(val.toString()),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _maxVerses = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Textbox 1: Max No. of Characters / Slide
                    const Text('Max No. of Characters / Slide', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 36,
                      child: TextFormField(
                        controller: _maxCharsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                          filled: true,
                          fillColor: Colors.grey[900],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dropdown 3: Format
                    const Text('Format', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 36,
                      child: DropdownButtonFormField<String>(
                        value: _format,
                        isExpanded: true,
                        dropdownColor: Colors.grey[800],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                          filled: true,
                          fillColor: Colors.grey[900],
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        items: ['Verse', 'Paragraph'].map((val) => DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _format = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[400],
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _apply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
