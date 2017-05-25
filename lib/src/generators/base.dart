import "dart:io";
import "dart:async";
import '../generation/base.dart';
import '../interactions/base.dart';
import '../generation/dependency.dart';
import './utils/sequencer.dart';
import './utils/variablesResolver.dart';

import 'package:logging/logging.dart';
import 'package:source_gen_cli/src/generation/fileProcessor.dart';
import 'package:source_gen_cli/src/generation/new_dir.dart';
import 'package:source_gen_cli/src/generation/new_file.dart';
import 'package:source_gen_cli/src/generation/template_dir.dart';

/// The base class from where the generation will took place. This is the
/// backbone of the generation and is the starting point from where new
/// [Generator]s shall start.
abstract class Generator implements InteractionsInterface {
  DependenciesProcessor _depsProcessor;
  GeneratorModulesInitializer _modulesInitializer;
  bool _predefinedDependenciesAdded = false;
  bool _generatorInitizalized = false;
  GenerationStepsSequencer _sequencer;
  InteractionsHandler interactionsHandler;
  VariablesResolver variablesResolver;
  Logger logger;

  Generator(this.interactionsHandler) {
    _depsProcessor = new DependenciesProcessor();
    _sequencer = new GenerationStepsSequencer();
    variablesResolver = new VariablesResolver(this.startingVariables);
    logger = new Logger("generator." + this.runtimeType.toString());
    _modulesInitializer = new GeneratorModulesInitializer(
        variablesResolver, logger, this.overridePolicy);
  }

  /// Here you can define starting variables for the generation
  Map get startingVariables;

  /// The name of this [Generator]
  String get name;

  /// A description for this [Generator]
  String get description;

  /// The, by default, `override` value this [Generator]'s [GeneratorModule]
  /// will have
  OverridingPolicy get overridePolicy;

  /// Define the dependencies this generator needs in order to work properly,
  /// they will be automatically included or updated in the local 'pubspec.yaml'
  List<Dependency> get alwaysNeededDependencies;

  Set<Dependency> get dependencies => _depsProcessor.deps;

  /// Returns true if `dependency` addition was successful and didn't existed before
  bool addDependency(Dependency dependency) {
    _addPredefinedDeps();
    bool ret = _depsProcessor.addDependency(dependency);
    //Split message to prevent warnings
    String logMsg = "Adding dependency '${dependency.name}' ";
    logMsg += ret ? "succeeded" : "failed";
    logger.finer(logMsg);
    return ret;
  }

  /// The principal bone adder, in the very backbone of this [Generator]
  /// (I feel like a poet XD)
  Future addGenerationStep(GenerationStep step) {
    logger.finest("Adding a ${step.runtimeType}");
    if (step is GenerationModule) _modulesInitializer.initialize(step);
    return _sequencer.addStep(step);
  }
  // Future addGenerationStep(GenerationStep step) {
  //   Completer completer = new Completer();
  //   _sequencer.addStep(step).then((generationResult) {
  //     completer.complete(generationResult);
  //   });
  //   return completer.future;
  // }

  /// Syntactic-sugar for standard processing of a file. _Id est_ interacting
  /// with all its annotatons
  Future<FileProcessResult> processFile(String relativePath) {
    FileProcessorModule fileProcessor = new FileProcessorModule(relativePath);
    return addGenerationStep(fileProcessor);
  }

  /// Syntactic-sugar for a new [File] creation
  Future<FileGenerationResult> createFile(
      String contents, String relativePathDestination) {
    FileGenerationModule fileGeneration =
        new FileGenerationModule(contents, relativePathDestination);
    addGenerationStep(fileGeneration);
  }

  /// Syntactic-sugar for a new [Directory] creation
  Future<DirGenerationResult> createDir(String relativePath) {
    DirGenerationModule dirGeneration = new DirGenerationModule(relativePath);
    addGenerationStep(dirGeneration);
  }

  Future<TemplateGenerationResults> generateTemplateDir(
      String sourceRelativePath, String relativePathDestination) {
    TemplateGenerationModule templateGM = new TemplateGenerationModule(
        sourceRelativePath, relativePathDestination);
    addGenerationStep(templateGM);
  }

  void _addPredefinedDeps() {
    if (_predefinedDependenciesAdded == false &&
        alwaysNeededDependencies.isNotEmpty) {
      _depsProcessor.addDependencies(alwaysNeededDependencies);
      _predefinedDependenciesAdded = true;
    }
  }

  Future<GenerationResults> execute({bool runPubGetDependencies: false}) async {
    // Completer completer = new Completer();
    GenerationResults ret = new GenerationResults();
    await _sequencer.execute();
    ret.newPubspecLines = await _depsProcessor.processPubspec();
    if (runPubGetDependencies)
      ret.pubGetResult = await _depsProcessor.runPubGet();
    return ret;
    // return completer.future;
  }

  @override
  Future<bool> askForConfirmation(String message, {bool defaultValue: true}) =>
      interactionsHandler.askForConfirmation(message,
          defaultValue: defaultValue);

  @override
  Future<String> askForInput(String message, String checkRegExp) =>
      interactionsHandler.askForInput(message, checkRegExp);

  @override
  Future<String> askForSelection(String message, List<String> options) =>
      interactionsHandler.askForSelection(message, options);
}

enum OverridingPolicy { NEVER, ASK, ALWAYS }

class GenerationResults {
  String newPubspecLines;
  ProcessResult pubGetResult;
}
