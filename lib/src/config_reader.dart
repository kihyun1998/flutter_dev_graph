import 'dart:io';
import 'package:path/path.dart' as p;

class GroupRule {
  final RegExp pattern;
  final String nameTemplate;

  GroupRule({required this.pattern, required this.nameTemplate});

  /// 파일 경로에서 그룹 이름 추출
  String? getGroupName(String relativePath) {
    // 윈도우 경로를 유닉스 스타일로 변환
    final normalizedPath = relativePath.replaceAll('\\', '/');
    final match = pattern.firstMatch(normalizedPath);
    if (match == null) return null;

    var result = nameTemplate;
    // $1, $2 등을 매치 그룹으로 치환
    for (var i = 1; i <= match.groupCount; i++) {
      result = result.replaceAll('\$$i', match.group(i) ?? '');
    }
    return result;
  }
}

class FdgConfig {
  final List<GroupRule> groups;
  final List<String> exclude;

  FdgConfig({required this.groups, required this.exclude});

  /// 파일 경로에서 그룹 이름 결정
  String getGroupName(String relativePath) {
    for (final rule in groups) {
      final name = rule.getGroupName(relativePath);
      if (name != null) return name;
    }
    return 'other';
  }

  /// 기본 설정 (설정 파일 없을 때)
  factory FdgConfig.defaultConfig() {
    return FdgConfig(
      groups: [
        GroupRule(
          pattern: RegExp(r'lib/features/([^/]+)/.*'),
          nameTemplate: 'feature:\$1',
        ),
        GroupRule(
          pattern: RegExp(r'lib/core/.*'),
          nameTemplate: 'core',
        ),
        GroupRule(
          pattern: RegExp(r'lib/shared/.*'),
          nameTemplate: 'shared',
        ),
      ],
      exclude: ['.g.dart', '.freezed.dart'],
    );
  }
}

/// fdg.yaml 파일 파싱
FdgConfig? readConfig(String projectPath) {
  final configPath = p.join(projectPath, 'fdg.yaml');
  final file = File(configPath);

  if (!file.existsSync()) {
    return null;
  }

  final content = file.readAsStringSync();
  return _parseYaml(content);
}

FdgConfig _parseYaml(String content) {
  final groups = <GroupRule>[];
  final exclude = <String>[];

  // 간단한 YAML 파싱 (groups 섹션)
  final groupsMatch = RegExp(r'groups:\s*\n((?:\s+-[^\n]+\n?)+)', multiLine: true)
      .firstMatch(content);
  if (groupsMatch != null) {
    final groupsSection = groupsMatch.group(1)!;
    final ruleMatches = RegExp(
      r'-\s*pattern:\s*"([^"]+)"\s*\n\s*name:\s*"([^"]+)"',
      multiLine: true,
    ).allMatches(groupsSection);

    for (final match in ruleMatches) {
      groups.add(GroupRule(
        pattern: RegExp(match.group(1)!),
        nameTemplate: match.group(2)!,
      ));
    }
  }

  // exclude 섹션 파싱
  final excludeMatch = RegExp(r'exclude:\s*\n((?:\s+-[^\n]+\n?)+)', multiLine: true)
      .firstMatch(content);
  if (excludeMatch != null) {
    final excludeSection = excludeMatch.group(1)!;
    final patterns = RegExp(r'-\s*"([^"]+)"').allMatches(excludeSection);
    for (final match in patterns) {
      exclude.add(match.group(1)!);
    }
  }

  if (groups.isEmpty) {
    return FdgConfig.defaultConfig();
  }

  return FdgConfig(groups: groups, exclude: exclude);
}
