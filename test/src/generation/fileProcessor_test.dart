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

  @override
  Map get startingVariables => {"name": "John", "age": "20"};
}

String personLogFileContents = '''
This is persons.log file. Logged persons:
+Jane (29)
@generationBefore("persons-adder")
@generationAfter("persons-remover", template: "-{{name}} ({{age}})")
-Jane (29)
''';

defineTests() {
  File personsLogFile = new File(getPackageRootPath() + "test/persons.log");
  group('generator', () {
    setUpAll(() {
      personsLogFile.createSync();
      personsLogFile.writeAsStringSync(personLogFileContents);
    });
    tearDownAll(() {
      personsLogFile.deleteSync();
    });
    test('todo', () {
      PersonGenerator generator = new PersonGenerator();
      generator.execute();
      expect(personsLogFile.readAsStringSync(), contains("+John (20)"));
      expect(personsLogFile.readAsStringSync(), contains("-John (20)"));
    });
  });
}
