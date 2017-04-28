import 'dart:io';
import 'package:analyzer/analyzer.dart';
import 'package:logging/logging.dart';
import 'package:diff/diff.dart';
import '../common.dart';
import '../analysis.dart';
import '../generation/base.dart';
import './fileProcessorAnnotations/base.dart';
import '../generators/utils/variablesResolver.dart';

class FileProcessor extends GenerationModule<FileChanges> {
  final List generationIdsExcluded, generationIds;
  final Map<String, String> templates;
  List<FileProcessorSubmodule> submodules;
  final File file;
  List<String> _input;
  List<_FileProcessingStep> _steps = [];

  FileProcessor(String relativePath,
      {Map<String, String> templates,
      List<FileProcessorSubmodule> processingSubmodules: const [],
      List generationIds: const [],
      List generationIdsExcluded: const []})
      : super(relativePath),
        this.generationIds = generationIds,
        this.generationIdsExcluded = generationIdsExcluded,
        this.file = new File(getPackageRootPath() + relativePath),
        this.templates = templates {
    //Join the submodules by default with the provided ones (if any)
    this.submodules = processingSubmodules.isNotEmpty
        ? processingSubmodules
        : fileProcessorSubmodules;

    //Read onlu once the file
    _input = file.readAsLinesSync();
    _input.insert(0, null); // Change 0-index to 1-indexed string

    //Make an annotation matcher used to search for annotations in the file
    RegExp annotationsMatcher = _makeAnnotationMatcher(this.submodules);

    //Scan line by line for matching annotations
    for (int lineNum = 1; lineNum < _input.length; lineNum++) {
      String line = _input[lineNum];
      Match match = annotationsMatcher.firstMatch(line);
      if (match != null) {
        String name = match.group(1);
        var annotationInstance;
        AnnotatedNode annotatedNode;
        FileProcessorSubmodule submodule =
            this.submodules.firstWhere((s) => s.inFileTrigger == name);
        ArgumentsResolution args;
        try {
          String src = match.group(2);
          args = new ArgumentsResolution.fromSourceConstants(src);
        } catch (e) {
          args = null;
        }
        if (!shouldProcessId(args.positional.first)) // The ID
          continue;
        if (line.trim().startsWith('/') ||
            submodule is FileProcessorMarkerSubmodule) {
          //An annotation in a comment
          annotationInstance = instantiate(
              submodule.annotation,
              "", //TODO: support also named constructors
              args);
        } else {
          _ParsedGenerationAnnotation p =
              _parseGenerationAnnotationWithNode(_input, lineNum, name);
          annotationInstance = p.instance;
          annotatedNode = p.node;
        }
        _steps.add(new _FileProcessingStep(
            submodule,
            annotatedNode,
            annotationInstance,
            lineNum,
            annotationInstance.template ??
                templates[annotationInstance.generatorIdentifier]));
      }
    }
  }

  _ParsedGenerationAnnotation _parseGenerationAnnotationWithNode(
      List<String> lines, int lineNum, String annotationName) {
    int tries = 1;
    while (true) {
      String s = lines.sublist(lineNum, lineNum + tries).join('\n');
      try {
        CompilationUnit c = parseCompilationUnit(s);
        AnnotatedNode node = c.declarations.first;
        Annotation annotation = node.metadata
            .firstWhere((Annotation a) => lines[lineNum].contains(a.name.name));
        if (annotation != null) {
          Type type = this
              .submodules
              .singleWhere((FileProcessorSubmodule s) =>
                  s.inFileTrigger == annotation.name.name)
              .annotation;
          var instance = instanceFromAnnotation(type, annotation);
          return new _ParsedGenerationAnnotation(instance, node);
        }
      } on AnalyzerErrorGroup catch (e) {
        if (tries < 10)
          tries++;
        else {
          rethrow;
        }
      } on RangeError catch (e) {}
    }
  }

  @override
  FileProcessResult execution() {
    logger.finest("Starting ${file.path} processing in ${_steps.length} steps");
    List<String> process = _input.sublist(0, _input.length);
    for (_FileProcessingStep step in _steps) {
      logger.finest(
          "Processing 'line ${step.annotationLine}: ${_input[step.annotationLine]}'");
      step.annotationLine += process.length - _input.length; //+ generated lines
      process = step.process(file.path, process, logger, varsResolver);
    }
    logger.finer("${file.path} processed. Generating differences...");
    String processed = process.sublist(1, process.length).join('\n');
    FileChanges changes =
        new FileChanges(_input.sublist(1, _input.length).join('\n'), processed);
    logger.finer("Differences created. Now rewriting ${file.path}...");
    file.writeAsStringSync(processed, mode: FileMode.WRITE_ONLY);
    logger.finer("${file.path} rewritted successfully");
    return new FileProcessResult(changes);
  }

  @override
  List<String> get neededVariables => _steps
      .map((s) => s.neededVars())
      .reduce((List<String> e, List<String> s) => e.addAll(s));

  bool shouldProcessId(String id) {
    if (this.generationIds.isNotEmpty)
      return generationIds.any((match) => id.contains(match));
    else if (this.generationIdsExcluded.isNotEmpty)
      return !generationIdsExcluded.any((match) => id.contains(match));
    else
      return true;
  }

  RegExp _makeAnnotationMatcher(List<FileProcessorSubmodule> submodules) {
    Set<String> anotacionesMatcher = new Set.from(
        submodules.map((FileProcessorSubmodule s) => s.inFileTrigger));
    String matchOptions = anotacionesMatcher.join('|');
    return new RegExp("@($matchOptions)" + r"(\(.*\))?");
  }
}

/// Used to return the processing results
class _ParsedGenerationAnnotation {
  GenerationAnnotation instance;
  AnnotatedNode node;
  _ParsedGenerationAnnotation(this.instance, this.node);
}

/// Internal class used by [FileProcessor] for execution when needed
class _FileProcessingStep {
  FileProcessorSubmodule submodule;
  AnnotatedNode node;
  dynamic annotation;
  int annotationLine;
  String template;
  _FileProcessingStep(this.submodule, this.node, this.annotation,
      this.annotationLine, this.template);

  List<String> neededVars() => mustacheVars(this.template);

  List<String> process(String path, List<String> input, Logger logger,
          VariablesResolver vars) =>
      (submodule is FileProcessorAnnotationSubmodule)
          ? (submodule as FileProcessorAnnotationSubmodule).process(logger,
              vars, input, annotationLine, path, template, node, annotation)
          : (submodule as FileProcessorMarkerSubmodule).process(
              logger, vars, input, annotationLine, path, template, annotation);
}

/// A line by line changes tracking object
class FileChanges {
  String beforeText, afterText;

  Map<int, String> linesUnchanged = {};
  Map<int, String> linesAdded = {};
  Map<int, String> linesRemoved = {};
  Map<int, LineChange> linesChanged = {};

  /// A patch object that could be applied to the provided old text in order to
  /// obtain the new one.
  /// In a nutshell:
  ///   `beforeText` + `patch` = `afterText`
  ///   `beforeText`.patch(`patch`) // returns `afterText`
  List<PatchResult> patch;

  int get amountAdded => linesAdded.length;
  int get amountRemoved => linesRemoved.length;
  int get amountChanged => linesChanged.length;
  int get amountUnchanged => linesUnchanged.length;

  int totalLinesChanged;

  FileChanges(this.beforeText, this.afterText) {
    this.patch = diffPatch(beforeText.split('\n'), afterText.split('\n'));
    List<CommonOrDifferentThing> analisys =
        diffComm(beforeText.split('\n'), afterText.split('\n'));
    int line = 1;
    for (int i = 0; i < analisys.length; i++) {
      CommonOrDifferentThing step = analisys[i];
      if (!step.common.isEmpty) {
        //same lines
        for (String lineStr in step.common) linesUnchanged[line++] = lineStr;
      } else {
        //differnet lines
        if (step.file1.isEmpty) {
          //There are new lines
          for (String added in step.file2) linesAdded[line++] = added;
        } else if (step.file1.isEmpty) {
          //There are lines removed
          for (String removed in step.file2) linesRemoved[line++] = removed;
        } else {
          //There are lines changed
          for (int j = 0; j < step.file1.length; j++) {
            linesChanged[line++] = new LineChange(step.file1[j], step.file2[j]);
          }
        }
      }
    }
    this.totalLinesChanged = line;
  }
}

class LineChange {
  String before;
  String after;

  //TODO: Detectar qué caracteres cambian y una funcion de impresion con colores
  LineChange(this.before, this.after) {}
}

class FileProcessResult extends GenerationResult<FileChanges> {
  FileProcessResult(FileChanges object) : super(object);
}
