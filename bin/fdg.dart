import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_dev_graph/src/file_scanner.dart';
import 'package:flutter_dev_graph/src/import_parser.dart';
import 'package:flutter_dev_graph/src/pubspec_reader.dart';
import 'package:flutter_dev_graph/src/graph_builder.dart';
import 'package:flutter_dev_graph/src/mermaid_generator.dart';
import 'package:flutter_dev_graph/src/html_generator.dart';
import 'package:flutter_dev_graph/src/config_reader.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption(
      'format',
      abbr: 'f',
      help: 'Output format',
      allowed: ['json', 'mermaid', 'html', 'all'],
      defaultsTo: 'html',
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Output file path (without extension)',
      defaultsTo: 'graph',
    )
    ..addMultiOption(
      'exclude',
      abbr: 'e',
      help: 'Exclude patterns (can be used multiple times)',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      help: 'Show detailed output',
      defaultsTo: false,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show help',
      negatable: false,
    );

  late ArgResults args;
  try {
    args = parser.parse(arguments);
  } catch (e) {
    print('Error: $e\n');
    _printUsage(parser);
    exit(1);
  }

  if (args['help'] as bool) {
    _printUsage(parser);
    return;
  }

  // 프로젝트 경로 (나머지 인자에서 첫 번째)
  final projectPath = args.rest.isNotEmpty ? args.rest[0] : Directory.current.path;
  final format = args['format'] as String;
  final outputBase = args['output'] as String;
  final excludePatterns = args['exclude'] as List<String>;
  final verbose = args['verbose'] as bool;

  if (verbose) {
    print('Scanning: $projectPath\n');
  }

  // 패키지 이름 읽기
  final packageName = readPackageName(projectPath);
  if (packageName == null) {
    print('Error: pubspec.yaml not found or invalid.');
    exit(1);
  }

  if (verbose) {
    print('Package: $packageName\n');
  }

  // 파일 스캔 (추가 exclude 패턴 적용)
  final defaultExclude = ['.g.dart', '.freezed.dart'];
  final allExclude = [...defaultExclude, ...excludePatterns];
  final scanner = FileScanner(projectPath: projectPath, excludePatterns: allExclude);
  final files = scanner.scan();

  if (files.isEmpty) {
    print('No dart files found.');
    exit(1);
  }

  if (verbose) {
    print('Found ${files.length} dart files:\n');
  }

  // Import 파싱
  final importParser = ImportParser(
    projectPath: projectPath,
    packageName: packageName,
  );
  final importMap = importParser.parseFiles(files);

  // verbose 모드일 때만 상세 출력
  if (verbose) {
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
  }

  // 그래프 빌드
  final builder = GraphBuilder(projectPath: projectPath);
  final graph = builder.build(importMap);

  print('Graph: ${graph.nodes.length} nodes, ${graph.edges.length} edges\n');

  // 설정 파일 읽기
  final config = readConfig(projectPath) ?? FdgConfig.defaultConfig();
  if (verbose) {
    print('Config: fdg.yaml ${File(p.join(projectPath, 'fdg.yaml')).existsSync() ? 'found' : 'not found (using defaults)'}');
  }

  // 출력
  final outputDir = p.dirname(p.join(projectPath, outputBase));
  final outputName = p.basename(outputBase);

  if (format == 'json' || format == 'all') {
    final jsonPath = p.join(outputDir, '$outputName.json');
    File(jsonPath).writeAsStringSync(graph.toJsonString(pretty: true));
    print('Output: $jsonPath');
  }

  if (format == 'mermaid' || format == 'all') {
    final mermaidGenerator = MermaidGenerator(config: config);
    final mermaidPath = p.join(outputDir, '$outputName.md');
    File(mermaidPath).writeAsStringSync(mermaidGenerator.generateMarkdown(graph));
    print('Output: $mermaidPath');
  }

  if (format == 'html' || format == 'all') {
    final htmlGenerator = HtmlGenerator(config: config);
    final htmlPath = p.join(outputDir, '$outputName.html');
    File(htmlPath).writeAsStringSync(htmlGenerator.generate(graph, title: '$packageName - Dependency Graph'));
    print('Output: $htmlPath');
  }
}

void _printUsage(ArgParser parser) {
  print('''
fdg - Flutter Dependency Graph

Usage: fdg [options] [project_path]

Options:
${parser.usage}

Examples:
  fdg                          # Scan current directory, output graph.html
  fdg ./my_app                 # Scan my_app directory
  fdg -f all                   # Output all formats (json, md, html)
  fdg -f json -o deps          # Output deps.json
  fdg -e "*.test.dart"         # Exclude test files
  fdg -v                       # Verbose output
''');
}
