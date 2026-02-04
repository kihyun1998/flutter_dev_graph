import 'package:flutter_dev_graph/flutter_dev_graph.dart';
import 'package:test/test.dart';

void main() {
  group('MermaidGenerator', () {
    test('generates valid flowchart syntax', () {
      final graph = Graph(
        nodes: [
          Node(id: 'n0', path: 'lib/main.dart', name: 'main'),
          Node(id: 'n1', path: 'lib/utils.dart', name: 'utils'),
        ],
        edges: [
          Edge(source: 'n0', target: 'n1'),
        ],
      );

      final generator = MermaidGenerator();
      final output = generator.generate(graph);

      expect(output, contains('flowchart TD'));
      expect(output, contains('n0[main]'));
      expect(output, contains('n1[utils]'));
      expect(output, contains('n0 --> n1'));
    });

    test('generates subgraphs when config is provided', () {
      final graph = Graph(
        nodes: [
          Node(id: 'n0', path: 'lib/features/auth/login.dart', name: 'login'),
          Node(id: 'n1', path: 'lib/core/api.dart', name: 'api'),
        ],
        edges: [
          Edge(source: 'n0', target: 'n1'),
        ],
      );

      final config = FdgConfig.defaultConfig();
      final generator = MermaidGenerator(config: config);
      final output = generator.generate(graph);

      expect(output, contains('subgraph "Auth"'));
      expect(output, contains('subgraph "Core"'));
    });

    test('generateMarkdown wraps in code block', () {
      final graph = Graph(nodes: [], edges: []);
      final generator = MermaidGenerator();
      final output = generator.generateMarkdown(graph);

      expect(output, contains('# Dependency Graph'));
      expect(output, contains('```mermaid'));
      expect(output, contains('```'));
    });
  });
}
