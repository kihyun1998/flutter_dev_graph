import 'package:path/path.dart' as p;
import 'models.dart';

/// Builds a dependency graph from parsed import data.
///
/// The builder takes a map of file paths to their imports and constructs
/// a [Graph] with [Node]s and [Edge]s representing the dependency relationships.
///
/// Example usage:
/// ```dart
/// final builder = GraphBuilder(projectPath: '/path/to/project');
/// final importMap = {
///   '/path/to/project/lib/main.dart': ['/path/to/project/lib/utils.dart'],
/// };
/// final graph = builder.build(importMap);
/// ```
class GraphBuilder {
  /// The root path of the project.
  ///
  /// Used to generate relative paths for display.
  final String projectPath;

  /// Creates a new [GraphBuilder] instance.
  GraphBuilder({required this.projectPath});

  /// Builds a [Graph] from the import map.
  ///
  /// [importMap] is a map where keys are absolute file paths and values
  /// are lists of absolute paths of imported files.
  ///
  /// Returns a [Graph] containing all files as nodes and import
  /// relationships as edges.
  Graph build(Map<String, List<String>> importMap) {
    final nodes = <Node>[];
    final edges = <Edge>[];
    final pathToId = <String, String>{};

    // Create nodes for all files
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

    // Create edges for import relationships
    for (final entry in importMap.entries) {
      final sourceId = pathToId[entry.key];
      if (sourceId == null) continue;

      for (final importPath in entry.value) {
        final targetId = pathToId[importPath];
        if (targetId == null) continue; // Skip external files

        edges.add(Edge(
          source: sourceId,
          target: targetId,
        ));
      }
    }

    return Graph(nodes: nodes, edges: edges);
  }
}
