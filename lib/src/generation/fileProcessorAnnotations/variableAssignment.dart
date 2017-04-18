part of file.generation.annotations;

/// The marked variable will be assigned with the processed value
///   `append`: wether to supress the previously assigned value with the
/// processed one or to append it to the end of `List` or `Map`
class generationAssignment extends GenerationAnnotation {
  final bool append;
  const generationAssignment(String id, {this.append: true}) : super(id);
}

/// Will process what will be assigned to a variable
class Assignment extends FileProcessorSubmodule {
  @override
  String get inFileTrigger => "generationAssignment";

  @override
  generationAssignment get annotation =>
      generationAssignment as generationAssignment;

  @override
  List<String> process(List<String> input, int lineNumber, String path,
      AnnotatedNode elementAnnotated, generationAssignment annotationInstance) {
    debugger(message: "A ver cómo escribís esta funcion...");
  }
}
