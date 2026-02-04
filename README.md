# flutter_dev_graph (fdg)

A CLI tool to visualize Flutter/Dart project dependencies as an interactive graph.

## Features

- **Scan** Flutter/Dart projects for internal dependencies
- **Group** files by feature, layer, or custom rules
- **Output** in multiple formats: JSON, Mermaid, HTML
- **Configurable** via `fdg.yaml`

## Installation

```bash
dart pub global activate flutter_dev_graph
```

## Quick Start

```bash
# Generate HTML graph (default)
fdg /path/to/flutter/project

# Open in browser
open graph.html
```

## Usage

```
fdg [options] [project_path]

Options:
  -f, --format    Output format: json, mermaid, html, all (default: html)
  -o, --output    Output file name without extension (default: graph)
  -e, --exclude   Exclude patterns (can be used multiple times)
  -v, --verbose   Show detailed output
  -h, --help      Show help
```

### Examples

```bash
# Generate all formats
fdg -f all ./my_flutter_app

# Generate JSON only with custom filename
fdg -f json -o dependencies ./my_flutter_app

# Exclude test files
fdg -e "*.test.dart" -e "*_test.dart" ./my_flutter_app

# Verbose output
fdg -v ./my_flutter_app
```

## Output Formats

| Format | File | Description |
|--------|------|-------------|
| HTML | `graph.html` | Interactive graph, open in browser |
| Mermaid | `graph.md` | Markdown with Mermaid diagram, renders on GitHub |
| JSON | `graph.json` | Raw data for custom tooling |

## Configuration (fdg.yaml)

Create `fdg.yaml` in your project root to customize grouping:

```yaml
# Group files by pattern
groups:
  # Feature-based grouping
  - pattern: "lib/features/([^/]+)/.*"
    name: "feature:$1"

  # Core modules
  - pattern: "lib/core/.*"
    name: "core"

  # Shared code
  - pattern: "lib/shared/.*"
    name: "shared"

# Exclude patterns
exclude:
  - "*.g.dart"
  - "*.freezed.dart"
```

### Pattern Syntax

- Patterns use regular expressions
- Use `([^/]+)` to capture folder names
- Reference captures with `$1`, `$2`, etc.

### Example Patterns

| Pattern | Matches | Group Name |
|---------|---------|------------|
| `lib/features/([^/]+)/.*` | `lib/features/auth/login.dart` | `feature:auth` |
| `lib/core/.*` | `lib/core/network/api.dart` | `core` |
| `lib/screens/.*` | `lib/screens/home.dart` | `screens` |

## Programmatic Usage

```dart
import 'package:flutter_dev_graph/flutter_dev_graph.dart';

void main() {
  final projectPath = '/path/to/project';
  final packageName = readPackageName(projectPath)!;

  // Scan for Dart files
  final scanner = FileScanner(projectPath: projectPath);
  final files = scanner.scan();

  // Parse imports
  final parser = ImportParser(
    projectPath: projectPath,
    packageName: packageName,
  );
  final importMap = parser.parseFiles(files);

  // Build graph
  final builder = GraphBuilder(projectPath: projectPath);
  final graph = builder.build(importMap);

  print('Found ${graph.nodes.length} files');
  print('Found ${graph.edges.length} dependencies');

  // Generate Mermaid output
  final config = FdgConfig.defaultConfig();
  final generator = MermaidGenerator(config: config);
  print(generator.generateMarkdown(graph));
}
```

## How It Works

1. **Scan**: Recursively finds all `.dart` files in `lib/`
2. **Parse**: Extracts `import` statements from each file
3. **Filter**: Keeps only internal imports (excludes `dart:`, external packages)
4. **Build**: Creates a directed graph of dependencies
5. **Group**: Organizes nodes by configured patterns
6. **Render**: Outputs in the requested format

## Similar Tools

- [lakos](https://pub.dev/packages/lakos) - Another dependency visualization tool

## License

MIT License
