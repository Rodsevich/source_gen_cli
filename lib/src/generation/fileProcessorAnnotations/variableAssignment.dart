part of file.generation.annotations;

class generationAssignment extends GenerationAnnotation {
  const generationAssignment(String id) : super(id);
}

class Assignment extends FileProcessorSubmodule {
  @override
  GenerationAnnotation get annotation => generationAssignment;

  @override
  List<String> process(String path, int lineNumber, List<String> input,
      AnnotatedNode elementAnnotated) {
    // TODO: implement process
  }
}
