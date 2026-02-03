import 'dart:io';
import 'package:path/path.dart' as p;

class ImportParser {
  final String projectPath;
  final String packageName;

  /// import 문 매칭 정규식
  /// import 'path'; 또는 import "path"; 형태 매칭
  static final _importRegex = RegExp(r'''import\s+['"]([^'"]+)['"]''');

  ImportParser({
    required this.projectPath,
    required this.packageName,
  });

  /// 파일에서 내부 import 목록 추출
  /// 외부 패키지(flutter, dart:*, third-party)는 제외
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

  /// import 경로를 절대 경로로 변환
  /// 외부 패키지는 null 반환
  String? _resolveImport(String importPath, String sourceFile) {
    // dart: 내장 라이브러리 제외
    if (importPath.startsWith('dart:')) {
      return null;
    }

    // package: import 처리
    if (importPath.startsWith('package:')) {
      return _resolvePackageImport(importPath);
    }

    // 상대 경로 import 처리
    return _resolveRelativeImport(importPath, sourceFile);
  }

  /// package: import 처리
  /// 내부 패키지만 반환, 외부 패키지는 null
  String? _resolvePackageImport(String importPath) {
    // package:package_name/path 형태
    final withoutPrefix = importPath.substring('package:'.length);
    final slashIndex = withoutPrefix.indexOf('/');

    if (slashIndex == -1) {
      return null;
    }

    final pkgName = withoutPrefix.substring(0, slashIndex);
    final relativePath = withoutPrefix.substring(slashIndex + 1);

    // 내부 패키지인지 확인
    if (pkgName != packageName) {
      return null; // 외부 패키지
    }

    // 절대 경로로 변환
    return p.normalize(p.join(projectPath, 'lib', relativePath));
  }

  /// 상대 경로 import 처리
  String? _resolveRelativeImport(String importPath, String sourceFile) {
    final sourceDir = p.dirname(sourceFile);
    final resolved = p.normalize(p.join(sourceDir, importPath));

    // lib/ 내부 파일인지 확인
    final libPath = p.join(projectPath, 'lib');
    if (!p.isWithin(libPath, resolved)) {
      return null;
    }

    return resolved;
  }

  /// 여러 파일의 import 관계를 Map으로 반환
  Map<String, List<String>> parseFiles(List<String> filePaths) {
    final result = <String, List<String>>{};

    for (final filePath in filePaths) {
      final imports = parseFile(filePath);
      result[filePath] = imports;
    }

    return result;
  }
}
