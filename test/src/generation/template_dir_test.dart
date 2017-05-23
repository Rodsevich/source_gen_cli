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
        "num1": '1',
        "num2": 2,
        "dontRender": "TEST FAIL!",
        "render": "testing successful"
      };

  TemplateGenerator(InteractionsHandler interactionsHandler)
      : super(interactionsHandler) {
    generateTemplateDir("test/template_test", "test/template_generated");
  }
}

defineTests() {
  setUpAll(() {
    Directory d = new Directory(getPackageRootPath() + "test/template_test/d");
    d.createSync(recursive: true);
    File f1 = new File(d.path + "/f{{num1}}.mustache.mustache");
    f1.writeAsString("{{dontRender}}");
    File f2 = new File(d.path + "/f{{num2}}.dart.mustache");
    f2.writeAsString("{{render}}\nrendered!");
  });
  tearDownAll(() {
    Directory base = new Directory(getPackageRootPath() + "test/template_test");
    Directory generated =
        new Directory(getPackageRootPath() + "test/template_generatedd");
    Directory badGenerated =
        new Directory(getPackageRootPath() + "test/template_generatedd");
    generated.delete(recursive: true);
    badGenerated.delete(recursive: true);
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
      print(res.toString());
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
      File f1 = new File(generated.path + "/f1.mustache");
      expect(f1.existsSync(), isTrue);
      expect(f1.readAsStringSync(), contains("{{dontRender}}"));
      expect(f1.readAsStringSync(), isNot(contains("TEST FAIL!")));
    });
    test("f2 created and rendered", () {
      File f2 = new File(generated.path + "/f2.dart");
      expect(f2.existsSync(), isTrue);
      expect(f2.readAsStringSync(), isNot(contains("{{render}}")));
      expect(f2.readAsStringSync(), isNot(contains("testing successful")));
    });
  });
}
