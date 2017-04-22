import 'dart:io';
import 'package:source_gen_cli/generator.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

String sourceStr1 = '''
{[(source file)]}
@generationBefore("people", template: "-{{name}} ({{age}})")
@generationAfter("people")
''';
String sourceStr2 = '''
Animals list:
@generationZone("animals", template: " -{{name}}")
@generationZoneEnd

Last Animal added:
@generationZone("last-animal", template: "{{name}}")
@generationZone("last-animal")
''';

class PeopleFileProcessorTester extends Generator{

  PeopleFileProcessorTester(){
    addStep(new FileProcessor("test/source.dart", defaultTemplate: "+{{name}}: {{age}}"));
  }
}
class AnimalsFileProcessorTester extends Generator{

  AnimalsFileProcessorTester(){
    addStep(new FileProcessor("test/source.dart", directives: [listDir, lastDir]));
  }
}

FileProcessorDirective listDir = new FileProcessorDirective(tag: "animals", processingFunction: sortingFunction);
FileProcessorDirective lastDir = new FileProcessorDirective(tag: "last-animal", processingFunction: replacingFunction);
Function replacingFunction = (String existentString, Map variables){
  existentString.split('\n').map();
};
Function sortingFunction = (String existentString, Map variables) => variables["name"];

main(){
  group("Additions", (){
    File source;
    setUp((){
      source = new File("test/source.dart");
      source.writeAsStringSync(sourceStr);
    });
    tearDown((){
      source.deleteSync();
    });
    test("Insert person both before and after", (){

    });
    test("Insert and sorts well the animals", (){
      List animals = ["zebra", "jaguar", "raven", "elephant"];
      Map variables = {"last-animal" : animals.last, "animals": animals.map((String name) => {"name": name})};

    });
  })
}
