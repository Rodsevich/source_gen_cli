import 'dart:io';
import 'package:source_gen_cli/generator.dart';
import 'package:source_gen_cli/src/common.dart';
import 'package:source_gen_cli/src/cli/interactions/base.dart';
import 'package:source_gen_cli/src/generation/template_dir.dart';
import 'package:source_gen_cli/src/interactions/base.dart';
import 'package:test/test.dart';

main() => defineTests();

class TemplateGenerator extends Generator {
  List<Dependency> get alwaysNeededDependencies => null;

  String get name => "TemplateGenerator tester";

  String get description =>
      "tests that TemplateGenerationModule works correctly";

  OverridingPolicy get overridePolicy => OverridingPolicy.ALWAYS;

  Map get startingVariables => null;

  TemplateGenerator(InteractionsHandler interactionsHandler)
      : super(interactionsHandler) {
    generateTemplateDir("test/template_test", "test/template_generated");
  }
}

defineTests() {
  setUpAll(() {
    Directory d = new Directory(getPackageRootPath() + "test/template_test/d");
    d.create(recursive: true);
    File f1 = new File(d.path + "/f{{num1}}.mustache.mustache");
    f1.writeAsString("{{dontRender}}");
    File f2 = new File(d.path + "/f{{num2}}.dart.mustache");
    f2.writeAsString("{{render}}\nrendered!");
  });
  tearDownAll(() {
    Directory base = new Directory(getPackageRootPath() + "test/template_test");
    Directory generated =
        new Directory(getPackageRootPath() + "test/template_generated");
    base.delete(recursive: true);
    generated.delete(recursive: true);
  });
  group('Template Generator', () {
    CLInterface clInterface;
    CLIInteractionsHandler cliIH;
    TemplateGenerator templateGenerator;
    Directory generated;
    test('creation', () {
      clInterface = new CLInterface(stdin, stdout);
      cliIH = new CLIInteractionsHandler(clInterface);
      templateGenerator = new TemplateGenerator(cliIH);
      expect(templateGenerator, isNotNull);
    });
    test("execution", () {
      templateGenerator.execute();
      generated =
          new Directory(getPackageRootPath() + "test/template_generated");
      expect(generated.existsSync(), isTrue);
    });
    test("dir generation", () {
      List contents = generated.listSync();
      expect(contents, contains("d"));
    });
  });
}
