part of file.generation.annotations;

class generationBefore extends GenerationAnnotation {
  const generationBefore(String id, {String template: null})
      : super(id, template);
}

class GenerationBefore extends FileProcessorMarkerSubmodule {
  GenerationBefore() : super("generationBefore", generationBefore);

  @override
  List<String> process(
      Logger logger,
      VariablesResolver vars,
      List<String> input,
      int lineNumber,
      String path,
      String generationTemplate,
      generationBefore annotationInstance) {
    logger.finest("processing template...");
    String generation = processMustache(
        generationTemplate, vars[annotationInstance.generatorIdentifier]);
    logger.finest("Writing changes...");
    int added = 0;
    for (String adding in generation.split('\n')) {
      input.insert(added++ + lineNumber, adding);
    }
    return input;
  }
}
