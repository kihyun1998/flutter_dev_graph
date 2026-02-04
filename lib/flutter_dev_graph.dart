/// A CLI tool to visualize Flutter/Dart project dependencies as a graph.
///
/// This library provides tools to scan a Flutter/Dart project, parse import
/// statements, build a dependency graph, and generate visualizations in
/// multiple formats (JSON, Mermaid, HTML).
///
/// ## Quick Start
///
/// ```bash
/// # Install globally
/// dart pub global activate flutter_dev_graph
///
/// # Generate dependency graph
/// fdg /path/to/flutter/project
/// ```
///
/// ## Programmatic Usage
///
/// ```dart
/// import 'package:flutter_dev_graph/flutter_dev_graph.dart';
///
/// void main() {
///   final projectPath = '/path/to/project';
///   final packageName = readPackageName(projectPath)!;
///
///   // Scan for Dart files
///   final scanner = FileScanner(projectPath: projectPath);
///   final files = scanner.scan();
///
///   // Parse imports
///   final parser = ImportParser(
///     projectPath: projectPath,
///     packageName: packageName,
///   );
///   final importMap = parser.parseFiles(files);
///
///   // Build graph
///   final builder = GraphBuilder(projectPath: projectPath);
///   final graph = builder.build(importMap);
///
///   // Generate output
///   final config = readConfig(projectPath) ?? FdgConfig.defaultConfig();
///   final generator = MermaidGenerator(config: config);
///   print(generator.generateMarkdown(graph));
/// }
/// ```
library;

export 'src/config_reader.dart' show FdgConfig, GroupRule, readConfig;
export 'src/file_scanner.dart' show FileScanner;
export 'src/graph_builder.dart' show GraphBuilder;
export 'src/html_generator.dart' show HtmlGenerator;
export 'src/import_parser.dart' show ImportParser;
export 'src/mermaid_generator.dart' show MermaidGenerator;
export 'src/models.dart' show Node, Edge, Graph;
export 'src/pubspec_reader.dart' show readPackageName;
