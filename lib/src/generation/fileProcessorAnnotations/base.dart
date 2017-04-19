library file.generation.annotations;

import 'dart:developer';
import 'package:analyzer/analyzer.dart';

// @generationParts("generationAnnotations")
part "./parts.dart";
part "./variableAssignment.dart";

@generationAssignment("generationAnnotations", append: true)
Map<String, FileProcessorSubmodule> generationAnnotations = {
  "generationAssignment": new Assignment(),
};

///Parent class of the annotations used for in-file generation
abstract class GenerationAnnotation {
  final String generatorIdentifier;
  final String template;
  const GenerationAnnotation(this.generatorIdentifier, this.template);
}

/// Backbone class containing the necessary for in-file generation
abstract class FileProcessorSubmodule {
  /// String used as pattern while reading files for matching this submodule
  String inFileTrigger;

  /// Eventual annotation that will be instantiated
  Type annotation;

  FileProcessorSubmodule(this.inFileTrigger, this.annotation);

  /// Logic that will be executed in order to transform the `input`
  List<String> process(
      List<String> input,
      int lineNumber,
      String path,
      String generationTemplate,
      AnnotatedNode elementAnnotated,
      GenerationAnnotation annotationInstance);
}
