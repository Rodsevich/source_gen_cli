part of file.generation.annotations;

/// The marked variable will be assigned with the processed value
///   `append`: wether to supress the previously assigned value with the
/// processed one or to append it to the end of `List` or `Map`
class generationAssignment extends GenerationAnnotation {
  final bool append;
  const generationAssignment(String id,
      {this.append: true, String template: null})
      : super(id, template);
}

/// Will process what will be assigned to a variable
class Assignment extends FileProcessorAnnotationSubmodule {
  Assignment() : super("generationAssignment", generationAssignment);

  @override
  List<String> process(
      Logger logger,
      VariablesResolver vars,
      List<String> input,
      int lineNumber,
      String path,
      String generationTemplate,
      AnnotatedNode annotatedNode,
      generationAssignment annotationInstance) {
    String location = "$path: 'line $lineNumber: ${input[lineNumber]}'";
    String template = annotationInstance.template ?? generationTemplate;
    if (template == "" || template == null)
      err("There is no template provided for $location", logger);
    if (annotatedNode is! VariableDeclaration)
      err("@generationAssignment must only annotate variables ($location)",
          logger);
    logger.finest("Analizing the node annotated by $location...");
    String variableStr, assignmentStr, aux;
    Token token = annotatedNode.beginToken;
    while (token.type != TokenType.SEMICOLON) {
      if (token.type == TokenType.EQ) {
        variableStr = aux;
        aux = '';
        token = token.next;
      }
      aux += token.toString();
      token = token.next;
    }
    if (variableStr == null)
      variableStr = aux;
    else
      assignmentStr = aux;
    logger.finest("processing the line number of the assignment...");
    int assigLN = lineNumber + 1;
    while (!input[assigLN].trimLeft().startsWith(variableStr)) assigLN++;
    logger.finest("processing the assignment...");
    String assignment = processMustache(template, vars.getAll);
    //TODO: asignar a lo ultimo de la lista/map/lo q sea teniendo en cuenta
    //a las lineas multiples
  }

  void err(String msg, Logger logger) {
    logger.severe(msg);
    throw new Exception(msg);
  }
}
