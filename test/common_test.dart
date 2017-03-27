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
    test("Returns missing vars from section in that section key", () {
      String templateSrc = '''{{var1}}
      {{#seccion}}
        -{{var1}}
        -{{var2}}
      {{/seccion}}''';
      Template template = new Template(templateSrc);
      Map missingVars = gatherTemplateRequiredVars(template);
      expect(
          missingVars,
          equals({
            "var1": "#ValueOfvar1#",
            "seccion": {"var1": "#ValueOfvar1#", "var2": "#ValueOfvar2#"}
          }));
    });
    test("Behaves well with inverse section keys", () {
      String templateSrc = '''{{var1}}
      {{#seccion}}
        -{{var1}}
        -{{var2}}
      {{/seccion}}
      {{^seccion}}
        -{{var3}}
      {{/seccion}}
      ''';
      Template template = new Template(templateSrc);
      Map missingVars = gatherTemplateRequiredVars(template);
      expect(
          missingVars,
          equals({
            "var1": "#ValueOfvar1#",
            "seccion": {"var1": "#ValueOfvar1#", "var2": "#ValueOfvar2#"},
            "^seccion": {"var3": "#ValueOfvar3#"}
          }));
    });
    test("Behaves well with several (inverse) section keys", () {
      String templateSrc = '''{{var1}}
      {{#seccion}}
        -{{var1}}
        -{{var2}}
      {{/seccion}}
      {{^seccion}}
        -{{var3}}
      {{/seccion}}
      {{#seccion}}
        -{{var4}}
      {{/seccion}}
      {{^seccion}}
        -{{var5}}
      {{/seccion}}
      ''';
      Template template = new Template(templateSrc);
      Map missingVars = gatherTemplateRequiredVars(template);
      expect(
          missingVars,
          equals({
            "var1": "#ValueOfvar1#",
            "seccion": {
              "var1": "#ValueOfvar1#",
              "var2": "#ValueOfvar2#",
              "var4": "#ValueOfvar4#"
            },
            "^seccion": {"var3": "#ValueOfvar3#", "var5": "#ValueOfvar5#"}
          }));
    });
  });
}
