import 'dart:io';
import 'package:logging/logging.dart';
import 'package:source_gen_cli/generator.dart';
import 'package:source_gen_cli/src/common.dart';
import 'package:source_gen_cli/src/generation/base.dart';
import 'package:source_gen_cli/src/generation/new_file.dart';
import 'package:source_gen_cli/src/generators/utils/variablesResolver.dart';
import 'package:test/test.dart';

main() => defineTests();

defineTests() {
  group('Own FileGenerationModule variables', () {
    FileGenerationModule fgm, fgm1, fgm2;
    File f1 = new File(Directory.systemTemp.path + "/sorp.txt");
    File f2 = new File(Directory.systemTemp.path + "/sorp.txt.mustache");
    if (!f1.existsSync()) f1.createSync();
    if (!f2.existsSync()) f2.createSync();
    f1.writeAsStringSync("SORPI");
    f2.writeAsStringSync("{{var1}}-{{var2}}");
    test('Instantiation from String', () {
      fgm = new FileGenerationModule("sourceString", "test/q.txt");
      expect(fgm.pathDestination, endsWith("test/q.txt"));
      expect(fgm.sourceString, equals("sourceString"));
    });
    test("Instantiation from File", () {
      fgm = new FileGenerationModule.fromExistingFile(f1, "test/w.txt");
      expect(fgm.sourceString, equals("SORPI"));
    });
  });
  group("Execution:", () {
    Logger logger = new Logger("test");
    VariablesResolver resolver = new VariablesResolver();
    GeneratorModulesInitializer initializer = new GeneratorModulesInitializer(
        resolver, logger, OverridingPolicy.ALWAYS);
    test("Generates processed output where it should", () async {
      String src = "{{#iterate}}{{var}} # {{/iterate}}{{var2}}";
      String dest = "test/ejecucion.txt";
      List<Map> listMap = [
        {"var": "1"},
        {"var": "2"},
        {"var": "3"}
      ];
      resolver["iterate"] = listMap;
      resolver["var2"] = 4;
      FileGenerationModule fgm = new FileGenerationModule(src, dest);
      initializer.initialize(fgm);
      FileGenerationResult res = await fgm.execute();
      File generated = res.object;
      addTearDown(() {
        generated.deleteSync();
      });
      expect(generated.existsSync(), isTrue);
      File comparator = new File(getPackageRootPath() + dest);
      expect(comparator.readAsStringSync(), equals("1 # 2 # 3 # 4"));
    });
    test("Don't processes mustache file contents when specified", () async {
      String src = "{{dontProcessMe}}\n{{! don't erase me}}";
      String dest = "test/ejecucion.txt";
      resolver["dontProcessMe"] = "TEST FAIL";
      FileGenerationModule fgm =
          new FileGenerationModule(src, dest, processInputWithMustache: false);
      initializer.initialize(fgm);
      FileGenerationResult res = await fgm.execute();
      File generated = res.object;
      addTearDown(() {
        generated.deleteSync();
      });
      expect(generated.existsSync(), isTrue);
      File comparator = new File(getPackageRootPath() + dest);
      expect(comparator.readAsStringSync(), isNot(contains("TEST FAIL")));
      expect(comparator.readAsStringSync(), contains("{{dontProcessMe}}"));
      expect(comparator.readAsStringSync(), contains("{{! don't erase me}}"));
    });
  });
}
