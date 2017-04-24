part of file.generation.annotations;

class generationBefore extends GenerationAnnotation {
  const generationBefore(String id, {String template: null})
      : super(id, template, false);
}

class GenerationBefore extends FileProcessorAnnotationSubmodule {
  GenerationBefore() : super("generationBefore", generationBefore);

  @override
  List<String> process(
      Logger logger,
      VariablesResolver vars,
      List<String> input,
      int lineNumber,
      String path,
      String generationTemplate,
      AnnotatedNode annotatedNode,
      generationBefore annotationInstance) {
    logger.finest("processing template...");
    String generation = processMustache(generationTemplate, vars.getAll);
    logger.finest("Writing changes...");
    input.insert(lineNumber - 1, generation);
    return input;
  }
}
