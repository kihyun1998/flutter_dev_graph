import 'models.dart';
import 'config_reader.dart';

/// Generates Mermaid flowchart syntax from a dependency graph.
///
/// Mermaid is a diagramming language that can be rendered in Markdown
/// on platforms like GitHub, or using the Mermaid.js library.
///
/// This generator supports grouping nodes into subgraphs based on
/// configuration rules (e.g., by feature or layer).
///
/// Example usage:
/// ```dart
/// final generator = MermaidGenerator(config: config);
/// final mermaid = generator.generate(graph);
/// print(mermaid);
/// // Output:
/// // flowchart TD
/// //     n0[main] --> n1[utils]
/// ```
class MermaidGenerator {
  /// Optional configuration for grouping nodes.
  ///
  /// If provided, nodes will be organized into Mermaid subgraphs
  /// based on the grouping rules.
  final FdgConfig? config;

  /// Creates a new [MermaidGenerator] instance.
  ///
  /// [config] is optional. If not provided, nodes will not be grouped.
  MermaidGenerator({this.config});

  /// Generates Mermaid flowchart syntax from a [Graph].
  ///
  /// Returns a string containing valid Mermaid flowchart syntax.
  /// If [config] is provided, nodes are organized into subgraphs.
  String generate(Graph graph) {
    final buffer = StringBuffer();
    buffer.writeln('flowchart TD');

    if (config != null) {
      _generateWithGroups(buffer, graph);
    } else {
      _generateFlat(buffer, graph);
    }

    return buffer.toString();
  }

  /// Generates flat output without grouping.
  void _generateFlat(StringBuffer buffer, Graph graph) {
    // Define nodes
    for (final node in graph.nodes) {
      buffer.writeln('    ${node.id}[${node.name}]');
    }

    buffer.writeln();

    // Define edges
    for (final edge in graph.edges) {
      buffer.writeln('    ${edge.source} --> ${edge.target}');
    }
  }

  /// Generates output with subgraph grouping.
  void _generateWithGroups(StringBuffer buffer, Graph graph) {
    // Group nodes by their assigned group
    final groupedNodes = <String, List<Node>>{};

    for (final node in graph.nodes) {
      final groupName = config!.getGroupName(node.path);
      groupedNodes.putIfAbsent(groupName, () => []).add(node);
    }

    // Sort groups: features first, then core, shared, other
    final sortedGroups = groupedNodes.keys.toList()
      ..sort((a, b) {
        int priority(String g) {
          if (g.startsWith('feature:')) return 0;
          if (g == 'core') return 1;
          if (g == 'shared') return 2;
          return 3;
        }

        return priority(a).compareTo(priority(b));
      });

    // Generate subgraphs
    for (final groupName in sortedGroups) {
      final nodes = groupedNodes[groupName]!;
      final displayName = _formatGroupName(groupName);

      buffer.writeln('    subgraph $displayName');
      for (final node in nodes) {
        buffer.writeln('        ${node.id}[${node.name}]');
      }
      buffer.writeln('    end');
      buffer.writeln();
    }

    // Define edges
    for (final edge in graph.edges) {
      buffer.writeln('    ${edge.source} --> ${edge.target}');
    }
  }

  /// Formats a group name for display.
  ///
  /// - `feature:auth` → `"Auth"`
  /// - `core` → `"Core"`
  String _formatGroupName(String groupName) {
    if (groupName.startsWith('feature:')) {
      final name = groupName.substring('feature:'.length);
      return '"${_capitalize(name)}"';
    }
    return '"${_capitalize(groupName)}"';
  }

  /// Capitalizes the first letter of a string.
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Generates a complete Markdown document with embedded Mermaid diagram.
  ///
  /// The output can be viewed directly on GitHub or other Markdown renderers
  /// that support Mermaid syntax.
  String generateMarkdown(Graph graph) {
    final buffer = StringBuffer();

    buffer.writeln('# Dependency Graph');
    buffer.writeln();
    buffer.writeln('```mermaid');
    buffer.write(generate(graph));
    buffer.writeln('```');

    return buffer.toString();
  }
}
