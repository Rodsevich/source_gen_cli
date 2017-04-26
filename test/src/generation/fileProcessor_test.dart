import 'dart:io';
import 'package:source_gen_cli/generator.dart';
import 'package:source_gen_cli/src/generation/fileProcessor.dart';
import 'package:source_gen_cli/src/generators/base.dart';
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
        templates: {"person-adder": "+{{name}} ({{age}})"}));
  }

  @override
  Map get startingVariables => {
        "person-adder": {"name": "John", "age": "20"},
        "person-remover": {"name": "John", "age": "20"}
      };
}

String personLogFileContents = '''
@generationAfter("no-id", template: "Uno\\ndos.")
@generationBefore("no-id", template: "..\\nCatorce!")
+Jane (29)
@generationBefore("person-adder")
@generationAfter("person-remover", template: "-{{name}} ({{age}})")
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
      // personsLogFile.deleteSync();
    });
    test('generates once', () async {
      PersonGenerator generator = new PersonGenerator();
      GenerationResults results = await generator.execute();
      expect(personsLogFile.readAsStringSync(), contains("+John (20)"));
      expect(personsLogFile.readAsStringSync(), contains("-John (20)"));
    });
  });
}
