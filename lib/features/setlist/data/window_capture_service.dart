import 'dart:typed_data';

import 'package:desktop_multi_window/desktop_multi_window.dart'; 
import 'package:flutter/services.dart';

class CapturableWindow {
  final String handle; 
  final String title; 
  final String processName;

  const CapturableWindow({
    required this.handle, 
    required this.title, 
    this.processName = '', 
  });

  factory CapturableWindow.fromMap(Map<Object?, Object?> map) {
    return CapturableWindow(
      handle: (map["handle"] ?? "").toString(),
      title: (map["title"] ?? "").toString(),
      processName: (map['processName'] ?? "").toString(),
    );
  }

  String get displayLabel {
    if (processName.isEmpty) return title; 
    return "$title ($processName)";
  }
}

class WindowCaptureFrame {
  final int width; 
  final int height; 
  final Uint8List pixels;

  const WindowCaptureFrame({ 
    required this.width,
    required this.height, 
    required this.pixels,
    });

  factory WindowCaptureFrame.fromMap(Map<Object?, Object?> map) {
    final pixels = map['pixels']; 
    final normalizedPixels = pixels is Uint8List 
       ? pixels 
       : pixels is List 
           ? Uint8List.fromList(
               pixels
               .whereType<num>() 
               .map((value) => value.toInt()) 
               .toList(growable: false),
             )
           : Uint8List(0);
    return WindowCaptureFrame( 
        width: (map['width'] as num?)?.toInt() ?? 0, 
        height: (map['height'] as num?)?.toInt() ?? 0, 
        pixels: normalizedPixels,
    );
  }

  bool get isValid => width > 0 && height > 0 && pixels.isNotEmpty;
}

class WindowCaptureService { 
    WindowCaptureService._();

  static const MethodChannel _channel = MethodChannel("keryx/window"); 
  static final WindowCaptureService instance = WindowCaptureService._();

  Future<List<CapturableWindow>> listCapturableWindows() async { 
    final raw = await _channel.invokeMethod<List<Object?>>("list_capturable_windows");
    if (raw == null) return const [];

    return raw
         .whereType<Map<Object?, Object?>>() 
         .map(CapturableWindow.fromMap) 
         .where((w) => w.handle.isNotEmpty && w.title.isNotEmpty) 
         .toList(growable: false);
  }

  Future<WindowCaptureFrame?> captureWindow(
    String handle,
    {String? bridgeWindowId}
  ) async {

    if (handle.isEmpty) {
      return null;
    }

    try {
      final raw = await _channel.invokeMethod<Map<Object?, Object?>>( 
        'capture_window_frame', {'handle': handle},
      );
      if (raw == null) return null; 
      final frame = WindowCaptureFrame.fromMap(raw); 
      return frame.isValid ? frame : null; 
    } on MissingPluginException {
        return _captureWindowFrameViaBridge(handle, bridgeWindowId); 
    } on PlatformException { 
        if (bridgeWindowId == null || bridgeWindowId.isEmpty) return null; 
        return _captureWindowFrameViaBridge(handle, bridgeWindowId);
    }

  }

  Future<WindowCaptureFrame?> _captureWindowFrameViaBridge(String handle, String? bridgeWindowId) async { 

    if (bridgeWindowId == null || bridgeWindowId.isEmpty) return null; 

    try {
      final raw = await WindowController.fromWindowId(bridgeWindowId).invokeMethod(
        'window_capture_frame', {'handle' : handle}, 
      );
      
      if (raw is! Map) return null; 
      final map = Map<Object?, Object?>.from(raw); 
      final frame = WindowCaptureFrame.fromMap(map); 
      return frame.isValid? frame : null; 
    } catch (_) { 
        return null;
    }
  }
}
