import 'dart:io';
import "package:source_gen_cli/generator.dart";
import 'package:source_gen_cli/src/interactions/base.dart';

class AnnotationGeneration extends Generator {
  String get name => "generationAnnotation's generator";
  String get description =>
      "Generates an annotation that could be used to generate code in the annotated files";

  List<Dependency> get alwaysNeededDependencies => null;
  OverridingPolicy get overridePolicy => OverridingPolicy.ALWAYS;
  Map get startingVariables => null;

  AnnotationGeneration(InteractionsHandler interactionsHandler)
      : super(interactionsHandler) {
    String base = "lib/src/generation/fileProcessorAnnotation";
    String contents = new File("$base/template.mustache").readAsStringSync();
    String name = variablesResolver.get("name");
    createFile(contents, "$base/$name");
  }
}
