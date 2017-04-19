import 'dart:io';
import 'package:source_gen_cli/generator.dart';
import 'package:source_gen_cli/src/generation/fileProcessor.dart';
import 'package:source_gen_cli/src/generators/utils/variablesResolver.dart';
import 'package:source_gen_cli/src/common.dart';
import 'package:test/test.dart';

main() => defineTests();

class PersonGenerator extends Generator {
  @override
  List<Dependency> get alwaysNeededDependencies => null;

  @override
  String get description => "desc";

  @override
  String get name => "test";

  @override
  bool get overridePolicy => true;

  PersonGenerator() {
    addGenerationStep(new FileProcessor("test/persons.log",
        templates: {"persons-adder": "+{{name}} ({{age}})"}));
  }
  // TODO: implement startingVariables
  @override
  Map get startingVariables => null;
}

String personLogFile = '''
This is persons.log file. Logged persons:
+Jane (29)
@generationBefore("persons-adder")
''';

defineTests() {
  File personsLog = new File(getPackageRootPath() + "test/persons.log");
  setUpAll(() {});
  tearDownAll(() {});
  Map vars = {"name": "John", "age": "20"};
  VariablesResolver res = new VariablesResolver();
  group('fileProcessor', () {
    test('todo', () {
      // TODO: Implement test.
    });
  });
}
