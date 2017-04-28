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
part "./generationBefore.dart";
part "./generationAfter.dart";

@generationAssignment("generationAnnotations", append: true)
List<Type> fileProcessorSubmodulesTypes = [
  GenerationAssignment,
  GenerationBefore,
  GenerationAfter,
];

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

  void err(String msg, Logger logger) {
    logger.severe(msg);
    throw new Exception(msg);
  }
}

/// Process an annotation, something that annotates an [AnnotatedNode]
abstract class FileProcessorAnnotationSubmodule extends FileProcessorSubmodule {
  FileProcessorAnnotationSubmodule(String inFileTrigger, Type annotation)
      : super(inFileTrigger, annotation);

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

/// Process a marker, some annotation-like marker that doesn't annotates
/// anything, but is rather used to mark the position in the file from which
/// to generate.
abstract class FileProcessorMarkerSubmodule extends FileProcessorSubmodule {
  FileProcessorMarkerSubmodule(String inFileTrigger, Type annotation)
      : super(inFileTrigger, annotation);

  /// Logic that will be executed in order to transform the `input`
  List<String> process(
      Logger logger,
      VariablesResolver vars,
      List<String> input,
      int lineNumber,
      String path,
      String generationTemplate,
      GenerationAnnotation annotationInstance);
}

class SubmoduleInstantiator {
  List<FileProcessorSubmodule> submodules;
}
