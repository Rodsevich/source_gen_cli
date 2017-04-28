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
class GenerationAssignment extends FileProcessorAnnotationSubmodule {
  GenerationAssignment() : super("generationAssignment", generationAssignment);

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
    String location = "[$path: 'line $lineNumber: ${input[lineNumber]}']";
    String template = annotationInstance.template ?? generationTemplate;
    if (template == "" || template == null)
      err("There is no template provided for $location", logger);
    logger.finest("Analizing the node annotated by $location...");
    //DESDE ACA
    TypeName type;
    VariableDeclaration variableDeclaration;
    if (annotatedNode is TopLevelVariableDeclaration) {
      type = annotatedNode.variables.type;
      try {
        variableDeclaration = annotatedNode.variables.variables.single;
      } catch (e) {
        err("@generationAssignment must be used in a single variable declaration",
            logger);
      }
    } else
      err("@generationAssignment must only annotate variables ($location)",
          logger);
    SimpleIdentifier name = variableDeclaration.name;
    Token equalSign = variableDeclaration.equals;
    Expression expression = variableDeclaration.initializer;
    String varStr = "$type $name " + equalSign?.toString() ?? "=",
        assignmentStr;
    logger.finest("processing the line numbers of the assignment...");
    int varLN = lineNumber + 1;
    while (!input[varLN].trimLeft().startsWith(varStr)) varLN++;
    int assigLN = varLN;
    if (equalSign != null) {
      int offset = type?.beginToken.offset ?? name.beginToken.offset;
      int currentCount = offset + input[varLN].length;
      try {
        while (currentCount < expression.endToken.next.offset)
          currentCount += input[++assigLN].length;
      } on RangeError catch (e) {
        if ((e.invalidValue - 1) != e.end)
          err("Impossible error happened. don't know what to do", logger);
        if (input[e.end].contains(
            new RegExp("${expression.endToken} ?${expression.endToken.next}")))
          assigLN = e.end;
        else
          err("Couldn't find end of expression line Number", logger);
      }
    }
    logger.finest("processing the assignment...");
    String assignmentVal = processMustache(template, vars.getAll);
    if (expression is ListLiteral || expression is MapLiteral) {
      bool emptyCollection = (expression is ListLiteral)
          ? expression.elements.isEmpty
          : (expression as MapLiteral).entries.isEmpty;
      if (annotationInstance.append == false || emptyCollection) {
        assignmentStr =
            "${expression.beginToken}$assignmentVal${expression.endToken}";
      } else {
        String f = expression.toString(), r = ", $assignmentVal";
        assignmentStr = f.replaceRange(f.length - 2, f.length - 1, r);
      }
    } else
      assignmentStr = assignmentVal;
    input.replaceRange(varLN, assigLN + 1, ["$varStr $assignmentStr;"]);
    return input;
  }
}
