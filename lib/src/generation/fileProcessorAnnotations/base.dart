library file.generation.annotations;

import 'dart:developer';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:logging/logging.dart';
import 'package:source_gen_cli/src/common.dart';
import 'package:source_gen_cli/src/generators/utils/variablesResolver.dart';

// @generationParts("generationAnnotations")
part "./parts.dart";
part "./variableAssignment.dart";

@generationAssignment("generationAnnotations", append: true)
List<FileProcessorAnnotationSubmodule> fileProcessorAnnotationSubmodules = [
  new Assignment(),
];

///Parent class of the annotations used for in-file generation
abstract class GenerationAnnotation {
  final String generatorIdentifier;
  final String template;
  const GenerationAnnotation(this.generatorIdentifier, this.template);
}

/// Backbone class containing the necessary for in-file generation
abstract class FileProcessorAnnotationSubmodule {
  /// String used as pattern while reading files for matching this submodule
  String inFileTrigger;

  /// Eventual annotation that will be instantiated
  Type annotation;

  FileProcessorAnnotationSubmodule(this.inFileTrigger, this.annotation);

  /// Logic that will be executed in order to transform the `input`
  List<String> process(
      Logger logger,
      VariablesResolver vars,
      List<String> input,
      int lineNumber,
      String path,
      String generationTemplate,
      AnnotatedNode annotatedNode,
      GenerationAnnotation annotationInstance);
}
