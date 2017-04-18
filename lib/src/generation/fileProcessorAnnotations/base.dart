library file.generation.annotations;

import 'dart:developer';
import 'package:analyzer/analyzer.dart';

// @generationParts("generationAnnotations")
part "./parts.dart";
part "./variableAssignment.dart";

@generationAssignment("generationAnnotations", append: true)
Map<String, FileProcessorSubmodule> generationAnnotations = {
  "generationAssignment": Assignment,
};

///Parent class of the annotations used for in-file generation
abstract class GenerationAnnotation {
  final String generatorIdentifier;
  const GenerationAnnotation(this.generatorIdentifier);
}

/// Backbone class containing the necessary for in-file generation
abstract class FileProcessorSubmodule {
  /// String used as pattern while reading files for matching this submodule
  String get inFileTrigger;

  /// Eventual annotation that will be instantiated
  GenerationAnnotation get annotation;

  /// Logic that will be executed in order to transform the `input`
  List<String> process(List<String> input, int lineNumber, String path,
      AnnotatedNode elementAnnotated, GenerationAnnotation annotationInstance);
}
