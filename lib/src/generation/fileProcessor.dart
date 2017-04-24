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
  String tag;
  Map<String, String> templates;
  List<FileProcessorAnnotationSubmodule> submodules;
  File file;
  List<String> _input;
  List<_FileProcessingStep> _steps;

  FileProcessor(String relativePath,
      {this.templates: null,
      List<FileProcessorAnnotationSubmodule> submodules: const []})
      : super(relativePath) {
    this.submodules = new List.from(submodules, growable: true);
    if (this.submodules.isEmpty)
      this.submodules.addAll(fileProcessorAnnotationSubmodules);
    file = new File(getPackageRootPath() + relativePath);
    _input = file.readAsLinesSync();
    _input.insert(0, null); // Change 0-index to 1-indexed string
    Set<String> anotacionesMatcher =
        new Set.from(this.submodules.map((s) => s.inFileTrigger));
    String matchOptions = anotacionesMatcher.join('|');
    RegExp annotationsMatcher = new RegExp("@($matchOptions)" + r"(\(.*?\))?");
    for (int lineNum = 1; lineNum < _input.length; lineNum++) {
      String line = _input[lineNum];
      Match match = annotationsMatcher.firstMatch(line);
      if (match != null) {
        String name = match.group(1);
        var annotationInstance;
        AnnotatedNode annotatedNode;
        FileProcessorAnnotationSubmodule submodule =
            this.submodules.firstWhere((s) => s.inFileTrigger == name);
        if (line.trim().startsWith('/')) {
          //An annotation in a comment
          String args;
          try {
            args = match.group(2);
          } catch (e) {
            args = null;
          }
          annotationInstance = instantiate(
              submodule.annotation,
              "", //TODO: support also named constructors
              new ArgumentsResolution.fromSourceConstants(args));
        } else {
          _ParsedGenerationAnnotation p =
              _parseGenerationAnnotationWithNode(_input, lineNum, name);
          annotationInstance = p.instance;
          annotatedNode = p.node;
        }
        _steps.add(new _FileProcessingStep(submodule, annotatedNode,
            annotationInstance, lineNum, templates[name]));
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
              .singleWhere((FileProcessorAnnotationSubmodule s) =>
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
      process = step.process(file.path, process, logger, varsResolver);
    }
    logger.finer("${file.path} processed. Generating differences...");
    String processed = process.join('\n');
    FileChanges changes = new FileChanges(_input.join('\n'), processed);
    logger.finer("Differences created. Now rewriting ${file.path}...");
    file.writeAsStringSync(processed, mode: FileMode.WRITE_ONLY);
    logger.finer("${file.path} rewritted successfully");
    return new FileProcessResult(changes);
  }

  @override
  List<String> get neededVariables => _steps
      .map((s) => s.neededVars())
      .reduce((List<String> e, List<String> s) => e.addAll(s));
}

/// Used to return the processing results
class _ParsedGenerationAnnotation {
  GenerationAnnotation instance;
  AnnotatedNode node;
  _ParsedGenerationAnnotation(this.instance, this.node);
}

/// Internal class used by [FileProcessor] for execution when needed
class _FileProcessingStep {
  FileProcessorAnnotationSubmodule submodule;
  AnnotatedNode node;
  dynamic annotation;
  int annotationLine;
  String template;
  _FileProcessingStep(this.submodule, this.node, this.annotation,
      this.annotationLine, this.template);

  List<String> neededVars() => mustacheVars(this.template);

  List<String> process(String path, List<String> input, Logger logger,
          VariablesResolver vars) =>
      submodule.process(logger, vars, input, annotationLine, path, template,
          node, annotation);
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
