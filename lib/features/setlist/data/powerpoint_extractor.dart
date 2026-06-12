import 'dart:io';
import 'package:path/path.dart' as p;

class PowerpointExtractor {
  /// Extracts all slides of a PowerPoint file as PNGs into [outputDir].
  /// Returns a list of absolute file paths to the generated PNGs, sorted numerically.
  static Future<List<String>> extractSlides(String pptxPath, String outputDir) async {
    final outDir = Directory(outputDir);
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }

    if (Platform.isWindows) {
      await _extractWindows(pptxPath, outputDir);
    } else if (Platform.isMacOS) {
      await _extractMacOS(pptxPath, outputDir);
    } else {
      throw UnsupportedError('PowerPoint extraction is only supported on Windows and macOS.');
    }

    // List and sort the generated image files numerically (e.g., Slide1, Slide2, Slide10)
    final files = outDir.listSync().whereType<File>().toList();
    
    files.sort((a, b) {
      final nameA = p.basename(a.path);
      final nameB = p.basename(b.path);
      final numA = _extractNumber(nameA);
      final numB = _extractNumber(nameB);
      
      if (numA != null && numB != null) {
        return numA.compareTo(numB);
      }
      return nameA.compareTo(nameB);
    });

    return files.map((f) => f.path).toList();
  }

  static int? _extractNumber(String fileName) {
    final match = RegExp(r'\d+').firstMatch(fileName);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }

  static Future<void> _extractWindows(String pptxPath, String outputDir) async {
    // Windows PowerShell COM Interop script
    // Note: We use absolute paths to ensure PowerShell locates the files correctly.
    final absPptxPath = File(pptxPath).absolute.path;
    final absOutputDir = Directory(outputDir).absolute.path;

    final psCommand = '''
\$ErrorActionPreference = "Stop"
try {
    \$ppt = New-Object -ComObject PowerPoint.Application
    # 1 = msoTrue (Open read-only), 0 = msoFalse (WithWindow: hidden/headless), 0 = msoFalse (Untitled)
    \$pres = \$ppt.Presentations.Open("$absPptxPath", 1, 0, 0)
    # 17 = ppSaveAsPNG
    \$pres.SaveAs("$absOutputDir", 17)
    \$pres.Close()
    \$ppt.Quit()
} catch {
    if (\$ppt) { \$ppt.Quit() }
    throw \$_
}
''';

    final result = await Process.run('powershell', ['-Command', psCommand]);
    if (result.exitCode != 0) {
      throw Exception(
        'PowerPoint extraction failed on Windows.\n'
        'Error: ${result.stderr}\n'
        'Please verify that Microsoft PowerPoint is installed and licensed on this computer.'
      );
    }
  }

  static Future<void> _extractMacOS(String pptxPath, String outputDir) async {
    final absPptxPath = File(pptxPath).absolute.path;
    final absOutputDir = Directory(outputDir).absolute.path;

    // AppleScript for PowerPoint automation on macOS
    final appleScript = '''
tell application "Microsoft PowerPoint"
    activate
    open file "${absPptxPath}"
    save active presentation in "${absOutputDir}" as save as PNG
    close active presentation
    quit
end tell
''';

    final result = await Process.run('osascript', ['-e', appleScript]);
    if (result.exitCode != 0) {
      throw Exception(
        'PowerPoint extraction failed on macOS.\n'
        'Error: ${result.stderr}\n'
        'Please verify that Microsoft PowerPoint is installed and licensed on this computer.'
      );
    }
  }
}
