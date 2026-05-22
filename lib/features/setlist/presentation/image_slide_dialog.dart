import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../data/setlist_item.dart';

class ImageSlideDialog extends StatefulWidget {
  final bool isForBackground;
  final String initialImagePath;
  final String initialLayout;
  final String initialAlignment;

  const ImageSlideDialog({
    super.key,
    this.isForBackground = false,
    this.initialImagePath = '',
    this.initialLayout = 'contain',
    this.initialAlignment = 'center',
  });

  @override
  State<ImageSlideDialog> createState() => _ImageSlideDialogState();
}

class _ImageSlideDialogState extends State<ImageSlideDialog> {
  late String _imagePath;
  late String _layout;
  late String _alignment;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
    _layout = widget.initialLayout;
    _alignment = widget.initialAlignment;
  }

  static const _layouts = [
    ('stretch', 'Stretch', Icons.aspect_ratio),
    ('contain', 'Keep Aspect Ratio', Icons.crop_free),
  ];

  static const _alignments = [
    'topLeft', 'topCenter', 'topRight',
    'centerLeft', 'center', 'centerRight',
    'bottomLeft', 'bottomCenter', 'bottomRight',
  ];

  static const _alignmentIcons = [
    Icons.north_west, Icons.north, Icons.north_east,
    Icons.west, Icons.circle, Icons.east,
    Icons.south_west, Icons.south, Icons.south_east,
  ];

  Future<void> _browse() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _imagePath = result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imagePath.isNotEmpty;
    return AlertDialog(
      backgroundColor: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(widget.isForBackground ? 'Background Image Settings' : 'Add Image Slide', style: const TextStyle(color: Colors.white, fontSize: 16)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      hasImage ? _imagePath.split(RegExp(r'[/\\]')).last : 'No image selected',
                      style: TextStyle(
                        color: hasImage ? Colors.white70 : Colors.white24,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _browse,
                  icon: const Icon(Icons.folder_open_rounded, size: 16),
                  label: const Text('Browse'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Layout selection
            const Text('Layout', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: _layouts.map((entry) {
                final (value, label, icon) = entry;
                final selected = _layout == value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _layout = value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? Colors.deepPurpleAccent : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? Colors.deepPurpleAccent : Colors.white12,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 20, color: selected ? Colors.white : Colors.white38),
                          const SizedBox(height: 4),
                          Text(label,
                            style: TextStyle(
                              fontSize: 10,
                              color: selected ? Colors.white : Colors.white38,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Alignment grid
            const Text('Alignment', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: 108,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, i) {
                    final value = _alignments[i];
                    final selected = _alignment == value;
                    return GestureDetector(
                      onTap: () => setState(() => _alignment = value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        decoration: BoxDecoration(
                          color: selected ? Colors.deepPurpleAccent : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: selected ? Colors.deepPurpleAccent : Colors.white12,
                          ),
                        ),
                        child: Icon(
                          _alignmentIcons[i],
                          size: 14,
                          color: selected ? Colors.white : Colors.white38,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
        ),
        ElevatedButton(
          onPressed: hasImage
              ? () {
                  Navigator.pop(
                    context,
                    ImageSetlistItem(
                      imagePath: _imagePath,
                      layout: _layout,
                      alignment: _alignment,
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            disabledBackgroundColor: Colors.white12,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.isForBackground ? 'Done' : 'Add to SetList'),
        ),
      ],
    );
  }
}
