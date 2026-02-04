import 'package:path/path.dart' as p;
import 'models.dart';

class GraphBuilder {
  final String projectPath;

  GraphBuilder({required this.projectPath});

  /// import 맵을 Graph로 변환
  Graph build(Map<String, List<String>> importMap) {
    final nodes = <Node>[];
    final edges = <Edge>[];
    final pathToId = <String, String>{};

    // 모든 파일을 Node로 변환
    var idCounter = 0;
    for (final filePath in importMap.keys) {
      final id = 'n${idCounter++}';
      final relativePath = p.relative(filePath, from: projectPath);
      final name = p.basenameWithoutExtension(filePath);

      nodes.add(Node(
        id: id,
        path: relativePath,
        name: name,
      ));
      pathToId[filePath] = id;
    }

    // import 관계를 Edge로 변환
    for (final entry in importMap.entries) {
      final sourceId = pathToId[entry.key];
      if (sourceId == null) continue;

      for (final importPath in entry.value) {
        final targetId = pathToId[importPath];
        if (targetId == null) continue; // 외부 파일은 스킵

        edges.add(Edge(
          source: sourceId,
          target: targetId,
        ));
      }
    }

    return Graph(nodes: nodes, edges: edges);
  }
}
