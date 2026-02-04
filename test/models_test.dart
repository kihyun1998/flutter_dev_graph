import 'package:flutter_dev_graph/flutter_dev_graph.dart';
import 'package:test/test.dart';

void main() {
  group('Node', () {
    test('toJson returns correct map', () {
      final node = Node(id: 'n0', path: 'lib/main.dart', name: 'main');
      expect(node.toJson(), {
        'id': 'n0',
        'path': 'lib/main.dart',
        'name': 'main',
      });
    });
  });

  group('Edge', () {
    test('toJson returns correct map', () {
      final edge = Edge(source: 'n0', target: 'n1');
      expect(edge.toJson(), {
        'source': 'n0',
        'target': 'n1',
      });
    });
  });

  group('Graph', () {
    test('toJson returns correct structure', () {
      final graph = Graph(
        nodes: [
          Node(id: 'n0', path: 'lib/main.dart', name: 'main'),
          Node(id: 'n1', path: 'lib/utils.dart', name: 'utils'),
        ],
        edges: [
          Edge(source: 'n0', target: 'n1'),
        ],
      );

      final json = graph.toJson();
      expect(json['nodes'], hasLength(2));
      expect(json['edges'], hasLength(1));
    });

    test('toJsonString with pretty prints formatted output', () {
      final graph = Graph(
        nodes: [Node(id: 'n0', path: 'lib/main.dart', name: 'main')],
        edges: [],
      );

      final jsonString = graph.toJsonString(pretty: true);
      expect(jsonString, contains('\n'));
      expect(jsonString, contains('  '));
    });
  });
}
