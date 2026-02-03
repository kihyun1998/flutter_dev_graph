import 'dart:io';
import 'package:path/path.dart' as p;

class FileScanner {
  final String projectPath;
  final List<String> excludePatterns;

  FileScanner({
    required this.projectPath,
    this.excludePatterns = const ['.g.dart', '.freezed.dart'],
  });

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

  bool _isExcluded(String filePath) {
    for (final pattern in excludePatterns) {
      if (filePath.endsWith(pattern)) {
        return true;
      }
    }
    return false;
  }
}
