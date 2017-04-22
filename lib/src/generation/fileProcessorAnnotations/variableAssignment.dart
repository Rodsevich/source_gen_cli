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
    logger.finest("Analizing the node annotated by $location...");
    TypeName type;
    VariableDeclaration variableDeclaration;
    if (annotatedNode is TopLevelVariableDeclaration) {
      type = annotatedNode.variables.type;
      try {
        variableDeclaration = annotatedNode.variables.variables.single;
      } on IterableElementError catch (e) {
        err("@generationAssignment must be used in a single variable declaration",
            logger);
      }
    } else
      err("@generationAssignment must only annotate variables ($location)",
          logger);
    SimpleIdentifier name = variableDeclaration.name;
    Token equalSign = variableDeclaration.equals;
    Expression expression = variableDeclaration.initializer;
    String variableStr = "$type $name $equalSign",
        assignmentStr = "$expression";
    logger.finest("processing the line numbers of the assignment...");
    int varLN = lineNumber + 1;
    while (!input[varLN].trimLeft().startsWith(variableStr)) varLN++;
    int assigLN = varLN;
    while (!input[assigLN].contains(assignmentStr)) assigLN++;
    logger.finest("processing the assignment...");
    String assignment = processMustache(template, vars.getAll);
  }

  void err(String msg, Logger logger) {
    logger.severe(msg);
    throw new Exception(msg);
  }
}
