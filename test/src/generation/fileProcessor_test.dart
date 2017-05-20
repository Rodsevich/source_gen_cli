import 'dart:io';
import 'package:source_gen_cli/generator.dart';
import 'package:source_gen_cli/src/generation/fileProcessor.dart';
import 'package:source_gen_cli/src/generators/base.dart';
import 'package:source_gen_cli/src/generators/utils/variablesResolver.dart';
import 'package:source_gen_cli/src/common.dart';
import 'package:source_gen_cli/src/interactions/base.dart';
import 'package:test/test.dart';

main() => defineTests();

class PersonGenerator extends Generator {
  @override
  List<Dependency> get alwaysNeededDependencies => null;

  @override
  String get description => "Persons-Generation";

  @override
  String get name => "PeopleGeneration";

  PersonGenerator(InteractionsHandler interactionsHandler)
      : super(interactionsHandler) {
    addGenerationStep(new FileProcessor("test/persons.log",
        templates: {"person-adder": "+{{name}} ({{age}})"},
        generationIds: [new RegExp("person-.*")]));
  }

  @override
  Map get startingVariables => {
        "person-adder": {"name": "John", "age": "20"},
        "person-remover": {"name": "John", "age": "20"}
      };
  // TODO: implement overridePolicy
  @override
  OverridingPolicy get overridePolicy => OverridingPolicy.ALWAYS;
}

class SecondPersonGenerator extends Generator {
  @override
  List<Dependency> get alwaysNeededDependencies => null;

  @override
  String get description =>
      "generates all but no-id annotations (just the persons, then)";

  @override
  String get name => "Second Person-Generation";

  @override
  OverridingPolicy get overridePolicy => OverridingPolicy.ALWAYS;

  SecondPersonGenerator() : super(null) {
    addGenerationStep(new FileProcessor("test/persons.log",
        templates: {"person-adder": "+{{name}} ({{age}})"},
        generationIdsExcluded: ["no-id"]));
  }

  Map jack = {"name": "Jack", "age": "21"};

  @override
  Map get startingVariables =>
      {"person-adder": jack, "person-remover": this.jack};
}

class AllGenerator extends Generator {
  @override
  List<Dependency> get alwaysNeededDependencies => null;

  @override
  String get description => "Generates all the tested annotations";

  @override
  String get name => "AllGenerator";

  @override
  OverridingPolicy get overridePolicy => OverridingPolicy.ALWAYS;

  AllGenerator() : super(null) {
    addGenerationStep(new FileProcessor("test/persons.log",
        templates: {"person-adder": "+{{name}} ({{age}})"}));
  }

  Map nico = {"name": "Nico", "age": "25"};

  @override
  Map get startingVariables =>
      {"person-adder": nico, "person-remover": this.nico};
}

String animalSorter = '''
Animals list:
@generationZone("animals", template: " -{{name}}")
@generationZoneEnd

Last Animal added:
@generationZone("last-animal", template: "{{name}}")
@generationZone("last-animal")
''';

String personLogFileContents = '''
@generationAfter("no-id", template: "Uno\\ndos.")
@generationBefore("no-id", template: "..\\nCatorce!")
+Jane (29)
@generationBefore("person-adder")
@generationAfter("person-remover", template: "-{{name}} ({{age}})")
-Jane (29)
''';
String expectedPersonGeneration = '''
@generationAfter("no-id", template: "Uno\\ndos.")
@generationBefore("no-id", template: "..\\nCatorce!")
+Jane (29)
+John (20)
@generationBefore("person-adder")
@generationAfter("person-remover", template: "-{{name}} ({{age}})")
-John (20)
-Jane (29)''';
String expectedSecondPersonGeneration = '''
@generationAfter("no-id", template: "Uno\\ndos.")
@generationBefore("no-id", template: "..\\nCatorce!")
+Jane (29)
+John (20)
+Jack (21)
@generationBefore("person-adder")
@generationAfter("person-remover", template: "-{{name}} ({{age}})")
-Jack (21)
-John (20)
-Jane (29)''';
String expectedAllGeneration = '''
@generationAfter("no-id", template: "Uno\\ndos.")
Uno
dos.
..
Catorce!
@generationBefore("no-id", template: "..\\nCatorce!")
+Jane (29)
+John (20)
+Jack (21)
+Nico (25)
@generationBefore("person-adder")
@generationAfter("person-remover", template: "-{{name}} ({{age}})")
-Nico (25)
-Jack (21)
-John (20)
-Jane (29)''';

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
    test('first person generation', () async {
      PersonGenerator generator = new PersonGenerator(null);
      GenerationResults results = await generator.execute();
      expect(
          personsLogFile.readAsStringSync(), equals(expectedPersonGeneration));
    });
    test('second person generation', () async {
      SecondPersonGenerator generator = new SecondPersonGenerator();
      GenerationResults results = await generator.execute();
      expect(personsLogFile.readAsStringSync(),
          equals(expectedSecondPersonGeneration));
    });
    test("Generation of all tags", () async {
      AllGenerator allGenerator = new AllGenerator();
      GenerationResults result = await allGenerator.execute();
      expect(personsLogFile.readAsStringSync(), equals(expectedAllGeneration));
    });
  });
}
