import 'dart:convert';

class Node {
  final String id;
  final String path;
  final String name;

  Node({
    required this.id,
    required this.path,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'name': name,
      };
}

class Edge {
  final String source;
  final String target;

  Edge({
    required this.source,
    required this.target,
  });

  Map<String, dynamic> toJson() => {
        'source': source,
        'target': target,
      };
}

class Graph {
  final List<Node> nodes;
  final List<Edge> edges;

  Graph({
    required this.nodes,
    required this.edges,
  });

  Map<String, dynamic> toJson() => {
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'edges': edges.map((e) => e.toJson()).toList(),
      };

  String toJsonString({bool pretty = false}) {
    final encoder = pretty ? JsonEncoder.withIndent('  ') : JsonEncoder();
    return encoder.convert(toJson());
  }
}
