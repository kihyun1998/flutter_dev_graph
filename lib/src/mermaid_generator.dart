import 'models.dart';
import 'config_reader.dart';

class MermaidGenerator {
  final FdgConfig? config;

  MermaidGenerator({this.config});

  /// Graph를 Mermaid flowchart 문법으로 변환 (그룹핑 지원)
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

  void _generateFlat(StringBuffer buffer, Graph graph) {
    // 노드 정의
    for (final node in graph.nodes) {
      buffer.writeln('    ${node.id}[${node.name}]');
    }

    buffer.writeln();

    // Edge 정의
    for (final edge in graph.edges) {
      buffer.writeln('    ${edge.source} --> ${edge.target}');
    }
  }

  void _generateWithGroups(StringBuffer buffer, Graph graph) {
    // 노드를 그룹별로 분류
    final groupedNodes = <String, List<Node>>{};

    for (final node in graph.nodes) {
      final groupName = config!.getGroupName(node.path);
      groupedNodes.putIfAbsent(groupName, () => []).add(node);
    }

    // 그룹 순서 정렬 (feature -> core -> shared -> other)
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

    // subgraph로 그룹핑
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

    // Edge 정의
    for (final edge in graph.edges) {
      buffer.writeln('    ${edge.source} --> ${edge.target}');
    }
  }

  String _formatGroupName(String groupName) {
    // feature:auth -> "Auth Feature"
    if (groupName.startsWith('feature:')) {
      final name = groupName.substring('feature:'.length);
      return '"${_capitalize(name)}"';
    }
    // core -> "Core"
    return '"${_capitalize(groupName)}"';
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Markdown 파일용 래퍼
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
