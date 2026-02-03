import 'dart:io';
import 'package:path/path.dart' as p;

/// pubspec.yaml에서 패키지 이름 읽기
String? readPackageName(String projectPath) {
  final pubspecPath = p.join(projectPath, 'pubspec.yaml');
  final file = File(pubspecPath);

  if (!file.existsSync()) {
    return null;
  }

  final content = file.readAsStringSync();

  // name: package_name 형태 추출
  final nameRegex = RegExp(r'^name:\s*(\S+)', multiLine: true);
  final match = nameRegex.firstMatch(content);

  return match?.group(1);
}
