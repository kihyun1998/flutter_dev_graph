import 'dart:io';
import 'package:path/path.dart' as p;

/// Represents a grouping rule for organizing nodes in the graph.
///
/// Each rule consists of a regex pattern and a name template.
/// When a file path matches the pattern, it is assigned to the group
/// specified by the name template.
///
/// Example:
/// ```dart
/// final rule = GroupRule(
///   pattern: RegExp(r'lib/features/([^/]+)/.*'),
///   nameTemplate: 'feature:\$1',
/// );
/// final group = rule.getGroupName('lib/features/auth/login.dart');
/// // Returns 'feature:auth'
/// ```
class GroupRule {
  /// Regular expression pattern to match file paths.
  final RegExp pattern;

  /// Template for the group name.
  ///
  /// Can include capture group references like `$1`, `$2`, etc.
  final String nameTemplate;

  /// Creates a new [GroupRule] instance.
  GroupRule({required this.pattern, required this.nameTemplate});

  /// Gets the group name for a file path.
  ///
  /// [relativePath] should use forward slashes (Unix-style).
  ///
  /// Returns the group name if the path matches, or `null` if it doesn't.
  String? getGroupName(String relativePath) {
    // Normalize Windows paths to Unix-style
    final normalizedPath = relativePath.replaceAll('\\', '/');
    final match = pattern.firstMatch(normalizedPath);
    if (match == null) return null;

    var result = nameTemplate;
    // Replace $1, $2, etc. with captured groups
    for (var i = 1; i <= match.groupCount; i++) {
      result = result.replaceAll('\$$i', match.group(i) ?? '');
    }
    return result;
  }
}

/// Configuration for fdg loaded from fdg.yaml.
///
/// Contains grouping rules and exclude patterns for customizing
/// how the dependency graph is generated and displayed.
class FdgConfig {
  /// List of grouping rules applied in order.
  ///
  /// The first matching rule determines the group for a file.
  final List<GroupRule> groups;

  /// Patterns for files to exclude from scanning.
  final List<String> exclude;

  /// Creates a new [FdgConfig] instance.
  FdgConfig({required this.groups, required this.exclude});

  /// Gets the group name for a file path.
  ///
  /// Applies grouping rules in order and returns the first match.
  /// Returns 'other' if no rules match.
  String getGroupName(String relativePath) {
    for (final rule in groups) {
      final name = rule.getGroupName(relativePath);
      if (name != null) return name;
    }
    return 'other';
  }

  /// Creates a default configuration for common Flutter project structures.
  ///
  /// Default rules:
  /// - `lib/features/{name}/**` → group `feature:{name}`
  /// - `lib/core/**` → group `core`
  /// - `lib/shared/**` → group `shared`
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

/// Reads configuration from fdg.yaml in the project directory.
///
/// [projectPath] is the root directory of the project.
///
/// Returns the parsed [FdgConfig], or `null` if no config file exists.
FdgConfig? readConfig(String projectPath) {
  final configPath = p.join(projectPath, 'fdg.yaml');
  final file = File(configPath);

  if (!file.existsSync()) {
    return null;
  }

  final content = file.readAsStringSync();
  return _parseYaml(content);
}

/// Parses fdg.yaml content into an [FdgConfig].
FdgConfig _parseYaml(String content) {
  final groups = <GroupRule>[];
  final exclude = <String>[];

  // Parse groups section
  final groupsMatch =
      RegExp(r'groups:\s*\n((?:\s+-[^\n]+\n?)+)', multiLine: true)
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

  // Parse exclude section
  final excludeMatch =
      RegExp(r'exclude:\s*\n((?:\s+-[^\n]+\n?)+)', multiLine: true)
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
