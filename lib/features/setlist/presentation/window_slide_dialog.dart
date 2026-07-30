import 'package:flutter/material.dart';

import '../data/setlist_item.dart';
import '../data/window_capture_service.dart';

class WindowSlideDialog extends StatefulWidget {
  const WindowSlideDialog({super.key});

  @override
  State<WindowSlideDialog> createState() => _WindowSlideDialogState();
}

class _WindowSlideDialogState extends State<WindowSlideDialog> {
  bool _isLoading = true;
  String? _errorText;
  List<CapturableWindow> _windows = const [];
  CapturableWindow? _selected;

  @override
  void initState() {
    super.initState();
    _loadWindows();
  }

  Future<void> _loadWindows() async {
     setState(() {
        _isLoading = true;
        _errorText = null;
      });

    try {
      final windows = await WindowCaptureService.instance.listCapturableWindows();
      if (!mounted) return;
      setState(() {
        _windows = windows;
        _selected = _windows.isNotEmpty ? _windows.first : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = "Unable to load windows";
        _windows = const [];
        _selected = null;
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }



@override
Widget build(BuildContext context) {
  return AlertDialog(
    backgroundColor: const Color(0xFF2D2D2D),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    title: const Text(
      "Add Window Slide",
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
    content: SizedBox(
      width: 420,
      child: _isLoading
        ? const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator())
        )
        : _errorText != null 
          ? SizedBox(
            height: 80,
            child: Center(
              child: Text(
                _errorText!,
                style: TextStyle(color: Colors.red[300], fontSize: 12),
              ),
            ),
           )
        : _windows.isEmpty
          ? const SizedBox(
            height: 80,
            child: Center(
              child: Text("No capturable windows found", 
              style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          )
          : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Window',
                style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CapturableWindow>(
                value: _selected,
                isExpanded: true,
                dropdownColor: const Color(0xFF2D2D3E),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
                selectedItemBuilder: (context) => _windows
                    .map( 
                        (window) => Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                           window.displayLabel,
                           maxLines: 1, 
                           overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    )
                    .toList(growable: false),
                items: _windows
                   .map(
                     (window) => DropdownMenuItem<CapturableWindow>(
                       value: window,
                       child: Text(
                        window.displayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        ),
                     ),
                   ).toList(growable: false),
                onChanged: (value) {
                  setState(() => _selected = value);
                },
              )
            ],
          )
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
      ),
      ElevatedButton(
        onPressed: _selected == null
            ? null
            : () {
                final selected = _selected!;
                Navigator.pop(
                  context,
                  WindowSetlistItem(
                    windowHandle: selected.handle,
                    windowTitle: selected.title,
                    processName: selected.processName,
                  ),
                );
            },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            disabledBackgroundColor: Colors.white12,
            foregroundColor: Colors.white,
          ),
        child: const Text("Add to Setlist"),
      ),
    ],
  );
}
}