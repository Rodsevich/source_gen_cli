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

  Map get startingVariables => {
        "dirName": "d",
        "num1": '1',
        "num2": 2,
        "dontRender": "TEST FAIL!",
        "render": "testing successful",
        "templateVar": "{{fillMe}}",
      };

  TemplateGenerator(InteractionsHandler interactionsHandler)
      : super(interactionsHandler) {
    generateTemplateDir("test/template_test", "test/template_generated");
  }
}

defineTests() {
  setUpAll(() {
    Directory d =
        new Directory(getPackageRootPath() + "test/template_test/{{dirName}}");
    d.createSync(recursive: true);
    File f1 = new File(d.path + "/f{{num1}}.mustache");
    f1.writeAsString("{{dontRender}}");
    File f2 = new File(d.path + "/f{{num2}}.dart.mustache");
    f2.writeAsString("{{render}}\nrendered!");
    File f3 = new File(d.path + "/f3.mustache.mustache");
    f3.writeAsString("{{! dissapear me}}{{templateVar}}");
  });
  tearDownAll(() {
    Directory base = new Directory(getPackageRootPath() + "test/template_test");
    Directory generated =
        new Directory(getPackageRootPath() + "test/template_generated");
    generated.delete(recursive: true);
    base.delete(recursive: true);
  });
  group("TemplateDirGenerationModule", () {
    CLInterface clInterface;
    CLIInteractionsHandler cliIH;
    TemplateGenerator templateGenerator;
    Directory generated;
    List<FileSystemEntity> generatedDirList;
    test('creation', () {
      clInterface = new CLInterface(stdin, stdout);
      cliIH = new CLIInteractionsHandler(clInterface);
      templateGenerator = new TemplateGenerator(cliIH);
      expect(templateGenerator, isNotNull);
    });
    test("execution", () async {
      GenerationResults res = await templateGenerator.execute();
      generated =
          new Directory(getPackageRootPath() + "test/template_generated");
      expect(generated.existsSync(), isTrue);
    });
    test("dir generation", () {
      generatedDirList = generated.listSync();
      expect(generatedDirList.singleWhere((e) => e is Directory).path,
          endsWith("d"));
    });
    test("f1 created and not rendered", () {
      File f1 = new File(generated.path + "/d/f1.mustache");
      expect(f1.existsSync(), isTrue);
      expect(f1.readAsStringSync(), contains("{{dontRender}}"));
      expect(f1.readAsStringSync(), isNot(contains("TEST FAIL!")));
    });
    test("f2 created and rendered", () {
      File f2 = new File(generated.path + "/d/f2.dart");
      expect(f2.existsSync(), isTrue);
      expect(f2.readAsStringSync(), isNot(contains("{{render}}")));
      expect(f2.readAsStringSync(), contains("testing successful"));
    });
    test("f3 created and rendered", () {
      File f3 = new File(generated.path + "/d/f3.mustache");
      expect(f3.existsSync(), isTrue);
      expect(f3.readAsStringSync(), contains("{{fillMe}}"));
      expect(f3.readAsStringSync(), isNot(contains("{{! dissapear me}}")));
    });
  });
}
