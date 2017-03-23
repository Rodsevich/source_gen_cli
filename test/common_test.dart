import 'package:mustache/mustache.dart';
import 'package:source_gen_cli/src/common.dart';
import 'package:test/test.dart';

main() => defineTests();

defineTests() {
  group('Mustache variablesGathering', () {
    test('returns the 3 missing vars', () {
      String templSrc = "{{sorp}}-{{longa}}-{{sorpi}}";
      Template template = new Template(templSrc);
      Map missingVars = gatherTemplateRequiredVars(template);
      expect(missingVars.keys, equals(["sorp", "longa", "sorpi"]));
    });
    test('returns the 3 missing vars only once', () {
      String templSrc =
          "{{sorp}}-{{longa}}-{{sorpi}}{{sorp}}-{{longa}}-{{sorpi}}{{sorp}}-{{longa}}-{{sorpi}}";
      Template template = new Template(templSrc);
      Map missingVars = gatherTemplateRequiredVars(template);
      expect(missingVars.keys, equals(["sorp", "longa", "sorpi"]));
    });
  });
}
