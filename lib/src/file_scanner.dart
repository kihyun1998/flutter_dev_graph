import 'dart:io';
import 'package:path/path.dart' as p;

/// Scans a Flutter/Dart project directory for Dart source files.
///
/// The scanner looks for `.dart` files in the `lib/` directory and can
/// exclude files matching certain patterns (e.g., generated files).
///
/// Example usage:
/// ```dart
/// final scanner = FileScanner(projectPath: '/path/to/project');
/// final files = scanner.scan();
/// print('Found ${files.length} dart files');
/// ```
class FileScanner {
  /// The root path of the Flutter/Dart project to scan.
  final String projectPath;

  /// Patterns to exclude from scanning.
  ///
  /// Files ending with any of these patterns will be excluded.
  /// Defaults to common generated file patterns like `.g.dart` and `.freezed.dart`.
  final List<String> excludePatterns;

  /// Creates a new [FileScanner] instance.
  ///
  /// [projectPath] is the root directory of the project to scan.
  /// [excludePatterns] is an optional list of file suffixes to exclude.
  FileScanner({
    required this.projectPath,
    this.excludePatterns = const ['.g.dart', '.freezed.dart'],
  });

  /// Scans the project's `lib/` directory for Dart files.
  ///
  /// Returns a sorted list of absolute file paths for all `.dart` files found,
  /// excluding any files that match the [excludePatterns].
  ///
  /// Returns an empty list if the `lib/` directory doesn't exist.
  List<String> scan() {
    final libPath = p.join(projectPath, 'lib');
    final libDir = Directory(libPath);

    if (!libDir.existsSync()) {
      print('Error: lib/ directory not found in $projectPath');
      return [];
    }

    final dartFiles = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        if (!_isExcluded(entity.path)) {
          dartFiles.add(entity.path);
        }
      }
    }

    dartFiles.sort();
    return dartFiles;
  }

  /// Checks if a file should be excluded based on [excludePatterns].
  bool _isExcluded(String filePath) {
    for (final pattern in excludePatterns) {
      if (filePath.endsWith(pattern)) {
        return true;
      }
    }
    return false;
  }
}
