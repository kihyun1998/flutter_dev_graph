import 'dart:io';
import 'package:path/path.dart' as p;

/// Reads the package name from a project's pubspec.yaml file.
///
/// [projectPath] is the root directory of the Flutter/Dart project.
///
/// Returns the package name if found, or `null` if the pubspec.yaml
/// doesn't exist or is invalid.
///
/// Example usage:
/// ```dart
/// final name = readPackageName('/path/to/project');
/// if (name != null) {
///   print('Package: $name');
/// }
/// ```
String? readPackageName(String projectPath) {
  final pubspecPath = p.join(projectPath, 'pubspec.yaml');
  final file = File(pubspecPath);

  if (!file.existsSync()) {
    return null;
  }

  final content = file.readAsStringSync();

  // Extract "name: package_name" from pubspec.yaml
  final nameRegex = RegExp(r'^name:\s*(\S+)', multiLine: true);
  final match = nameRegex.firstMatch(content);

  return match?.group(1);
}
