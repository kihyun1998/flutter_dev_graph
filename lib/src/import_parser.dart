import 'dart:io';
import 'package:path/path.dart' as p;

/// Parses Dart source files to extract internal import dependencies.
///
/// This parser identifies import statements in Dart files and resolves them
/// to absolute file paths. It filters out external dependencies (like `dart:`
/// core libraries and third-party packages) to focus only on internal project
/// dependencies.
///
/// Example usage:
/// ```dart
/// final parser = ImportParser(
///   projectPath: '/path/to/project',
///   packageName: 'my_package',
/// );
/// final imports = parser.parseFile('/path/to/project/lib/main.dart');
/// ```
class ImportParser {
  /// The root path of the Flutter/Dart project.
  final String projectPath;

  /// The package name from pubspec.yaml.
  ///
  /// Used to identify internal `package:` imports.
  final String packageName;

  /// Regular expression to match Dart import statements.
  ///
  /// Matches both single and double quoted import paths:
  /// - `import 'path';`
  /// - `import "path";`
  static final _importRegex = RegExp(r'''import\s+['"]([^'"]+)['"]''');

  /// Creates a new [ImportParser] instance.
  ///
  /// [projectPath] is the root directory of the project.
  /// [packageName] is the name of the package (from pubspec.yaml).
  ImportParser({
    required this.projectPath,
    required this.packageName,
  });

  /// Parses a single Dart file and extracts internal imports.
  ///
  /// [filePath] is the absolute path to the Dart file to parse.
  ///
  /// Returns a list of absolute file paths for all internal dependencies.
  /// External packages and `dart:` imports are excluded.
  List<String> parseFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return [];
    }

    final content = file.readAsStringSync();
    final imports = <String>[];

    for (final match in _importRegex.allMatches(content)) {
      final importPath = match.group(1)!;
      final resolved = _resolveImport(importPath, filePath);
      if (resolved != null) {
        imports.add(resolved);
      }
    }

    return imports;
  }

  /// Resolves an import path to an absolute file path.
  ///
  /// Returns `null` for external dependencies (dart:, third-party packages).
  String? _resolveImport(String importPath, String sourceFile) {
    // Exclude dart: core libraries
    if (importPath.startsWith('dart:')) {
      return null;
    }

    // Handle package: imports
    if (importPath.startsWith('package:')) {
      return _resolvePackageImport(importPath);
    }

    // Handle relative imports
    return _resolveRelativeImport(importPath, sourceFile);
  }

  /// Resolves a `package:` import to an absolute path.
  ///
  /// Only resolves imports from the current package (internal dependencies).
  /// Returns `null` for external package imports.
  String? _resolvePackageImport(String importPath) {
    // Format: package:package_name/path
    final withoutPrefix = importPath.substring('package:'.length);
    final slashIndex = withoutPrefix.indexOf('/');

    if (slashIndex == -1) {
      return null;
    }

    final pkgName = withoutPrefix.substring(0, slashIndex);
    final relativePath = withoutPrefix.substring(slashIndex + 1);

    // Only resolve internal package imports
    if (pkgName != packageName) {
      return null;
    }

    return p.normalize(p.join(projectPath, 'lib', relativePath));
  }

  /// Resolves a relative import to an absolute path.
  ///
  /// Returns `null` if the resolved path is outside the `lib/` directory.
  String? _resolveRelativeImport(String importPath, String sourceFile) {
    final sourceDir = p.dirname(sourceFile);
    final resolved = p.normalize(p.join(sourceDir, importPath));

    // Ensure the file is within lib/
    final libPath = p.join(projectPath, 'lib');
    if (!p.isWithin(libPath, resolved)) {
      return null;
    }

    return resolved;
  }

  /// Parses multiple Dart files and returns a map of dependencies.
  ///
  /// [filePaths] is a list of absolute paths to Dart files.
  ///
  /// Returns a map where keys are file paths and values are lists of
  /// imported file paths (internal dependencies only).
  Map<String, List<String>> parseFiles(List<String> filePaths) {
    final result = <String, List<String>>{};

    for (final filePath in filePaths) {
      final imports = parseFile(filePath);
      result[filePath] = imports;
    }

    return result;
  }
}
