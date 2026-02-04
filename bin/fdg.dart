import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_dev_graph/src/file_scanner.dart';
import 'package:flutter_dev_graph/src/import_parser.dart';
import 'package:flutter_dev_graph/src/pubspec_reader.dart';
import 'package:flutter_dev_graph/src/graph_builder.dart';
import 'package:flutter_dev_graph/src/mermaid_generator.dart';
import 'package:flutter_dev_graph/src/html_generator.dart';
import 'package:flutter_dev_graph/src/config_reader.dart';

void main(List<String> arguments) {
  // 경로 인자 처리
  final projectPath = arguments.isNotEmpty ? arguments[0] : Directory.current.path;

  print('Scanning: $projectPath\n');

  // 패키지 이름 읽기
  final packageName = readPackageName(projectPath);
  if (packageName == null) {
    print('Error: pubspec.yaml not found or invalid.');
    return;
  }
  print('Package: $packageName\n');

  // 파일 스캔
  final scanner = FileScanner(projectPath: projectPath);
  final files = scanner.scan();

  if (files.isEmpty) {
    print('No dart files found.');
    return;
  }

  print('Found ${files.length} dart files:\n');

  // Import 파싱
  final parser = ImportParser(
    projectPath: projectPath,
    packageName: packageName,
  );
  final importMap = parser.parseFiles(files);

  // 결과 출력
  for (final file in files) {
    final relativePath = p.relative(file, from: projectPath);
    final imports = importMap[file] ?? [];

    print('$relativePath');
    if (imports.isEmpty) {
      print('  (no internal imports)');
    } else {
      for (final imp in imports) {
        final relImp = p.relative(imp, from: projectPath);
        print('  -> $relImp');
      }
    }
    print('');
  }

  // 그래프 빌드
  final builder = GraphBuilder(projectPath: projectPath);
  final graph = builder.build(importMap);

  print('Graph: ${graph.nodes.length} nodes, ${graph.edges.length} edges\n');

  // JSON 출력
  final jsonPath = p.join(projectPath, 'graph.json');
  File(jsonPath).writeAsStringSync(graph.toJsonString(pretty: true));
  print('Output: $jsonPath');

  // 설정 파일 읽기
  final config = readConfig(projectPath) ?? FdgConfig.defaultConfig();
  print('Config: fdg.yaml ${File(p.join(projectPath, 'fdg.yaml')).existsSync() ? 'found' : 'not found (using defaults)'}');

  // Mermaid 출력
  final mermaidGenerator = MermaidGenerator(config: config);
  final mermaidPath = p.join(projectPath, 'graph.md');
  File(mermaidPath).writeAsStringSync(mermaidGenerator.generateMarkdown(graph));
  print('Output: $mermaidPath');

  // HTML 출력
  final htmlGenerator = HtmlGenerator(config: config);
  final htmlPath = p.join(projectPath, 'graph.html');
  File(htmlPath).writeAsStringSync(htmlGenerator.generate(graph, title: '$packageName - Dependency Graph'));
  print('Output: $htmlPath');
}
