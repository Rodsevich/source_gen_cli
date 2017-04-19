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
class Assignment extends FileProcessorSubmodule {
  Assignment() : super("generationAssignment", generationAssignment);

  @override
  List<String> process(
      List<String> input,
      int lineNumber,
      String path,
      String generationTemplate,
      AnnotatedNode elementAnnotated,
      generationAssignment annotationInstance) {
    debugger(message: "A ver cómo escribís esta funcion...");
  }
}
