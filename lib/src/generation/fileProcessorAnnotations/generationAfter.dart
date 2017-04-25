part of file.generation.annotations;

class generationAfter extends GenerationAnnotation {
  const generationAfter(String id, {String template: null})
      : super(id, template);
}

class GenerationAfter extends FileProcessorMarkerSubmodule {
  GenerationAfter() : super("generationAfter", generationAfter);

  @override
  List<String> process(
      Logger logger,
      VariablesResolver vars,
      List<String> input,
      int lineNumber,
      String path,
      String generationTemplate,
      generationAfter annotationInstance) {
    logger.finest("processing template...");
    String generation = processMustache(generationTemplate, vars.getAll);
    logger.finest("Writing changes...");
    input.insert(lineNumber + 1, generation);
    return input;
  }
}