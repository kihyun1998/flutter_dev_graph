import 'package:flutter_dev_graph/flutter_dev_graph.dart';
import 'package:test/test.dart';

void main() {
  group('GroupRule', () {
    test('matches feature pattern and extracts group name', () {
      final rule = GroupRule(
        pattern: RegExp(r'lib/features/([^/]+)/.*'),
        nameTemplate: 'feature:\$1',
      );

      expect(
        rule.getGroupName('lib/features/auth/login.dart'),
        equals('feature:auth'),
      );
      expect(
        rule.getGroupName('lib/features/product/models/item.dart'),
        equals('feature:product'),
      );
    });

    test('returns null for non-matching paths', () {
      final rule = GroupRule(
        pattern: RegExp(r'lib/features/([^/]+)/.*'),
        nameTemplate: 'feature:\$1',
      );

      expect(rule.getGroupName('lib/core/utils.dart'), isNull);
    });

    test('handles Windows-style paths', () {
      final rule = GroupRule(
        pattern: RegExp(r'lib/features/([^/]+)/.*'),
        nameTemplate: 'feature:\$1',
      );

      expect(
        rule.getGroupName('lib\\features\\auth\\login.dart'),
        equals('feature:auth'),
      );
    });
  });

  group('FdgConfig', () {
    test('defaultConfig has feature, core, and shared rules', () {
      final config = FdgConfig.defaultConfig();

      expect(
        config.getGroupName('lib/features/auth/login.dart'),
        equals('feature:auth'),
      );
      expect(
        config.getGroupName('lib/core/network/api.dart'),
        equals('core'),
      );
      expect(
        config.getGroupName('lib/shared/widgets/button.dart'),
        equals('shared'),
      );
    });

    test('returns "other" for unmatched paths', () {
      final config = FdgConfig.defaultConfig();

      expect(
        config.getGroupName('lib/main.dart'),
        equals('other'),
      );
    });
  });
}
