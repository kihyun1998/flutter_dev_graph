import 'dart:convert';

/// Represents a node in the dependency graph.
///
/// Each node corresponds to a Dart source file in the project.
///
/// Example:
/// ```dart
/// final node = Node(
///   id: 'n0',
///   path: 'lib/main.dart',
///   name: 'main',
/// );
/// ```
class Node {
  /// Unique identifier for this node (e.g., 'n0', 'n1').
  final String id;

  /// Relative path to the source file from the project root.
  final String path;

  /// Display name for the node (typically the filename without extension).
  final String name;

  /// Creates a new [Node] instance.
  Node({
    required this.id,
    required this.path,
    required this.name,
  });

  /// Converts this node to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'name': name,
      };
}

/// Represents a directed edge (dependency) between two nodes.
///
/// An edge from A to B means that file A imports file B.
///
/// Example:
/// ```dart
/// final edge = Edge(source: 'n0', target: 'n1');
/// // Means node n0 imports/depends on node n1
/// ```
class Edge {
  /// The ID of the source node (the file that imports).
  final String source;

  /// The ID of the target node (the file being imported).
  final String target;

  /// Creates a new [Edge] instance.
  Edge({
    required this.source,
    required this.target,
  });

  /// Converts this edge to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
        'source': source,
        'target': target,
      };
}

/// Represents a complete dependency graph.
///
/// A graph consists of [nodes] (files) and [edges] (import relationships).
///
/// Example:
/// ```dart
/// final graph = Graph(
///   nodes: [Node(id: 'n0', path: 'lib/main.dart', name: 'main')],
///   edges: [Edge(source: 'n0', target: 'n1')],
/// );
///
/// // Export to JSON
/// final json = graph.toJsonString(pretty: true);
/// ```
class Graph {
  /// All nodes (files) in the graph.
  final List<Node> nodes;

  /// All edges (dependencies) in the graph.
  final List<Edge> edges;

  /// Creates a new [Graph] instance.
  Graph({
    required this.nodes,
    required this.edges,
  });

  /// Converts this graph to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'edges': edges.map((e) => e.toJson()).toList(),
      };

  /// Converts this graph to a JSON string.
  ///
  /// Set [pretty] to `true` for formatted output with indentation.
  String toJsonString({bool pretty = false}) {
    final encoder = pretty ? JsonEncoder.withIndent('  ') : JsonEncoder();
    return encoder.convert(toJson());
  }
}
