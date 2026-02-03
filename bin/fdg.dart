import 'dart:io';
import 'package:flutter_dev_graph/src/file_scanner.dart';

void main(List<String> arguments) {
  // 경로 인자 처리
  final projectPath = arguments.isNotEmpty ? arguments[0] : Directory.current.path;

  print('Scanning: $projectPath\n');

  final scanner = FileScanner(projectPath: projectPath);
  final files = scanner.scan();

  if (files.isEmpty) {
    print('No dart files found.');
    return;
  }

  print('Found ${files.length} dart files:\n');
  for (final file in files) {
    print('  $file');
  }
}
