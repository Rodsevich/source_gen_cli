import "dart:async";
import "dart:io";
import '../generation/dependency.dart';
import './utils/sequencer.dart';
import './utils/variablesResolver.dart';

import 'package:logging/logging.dart';

/// The base class from where the generation will took place. This is the
/// backbone of the generation and is the starting point from where new
/// [Generator]s shall start.
abstract class Generator {
  DependenciesProcessor _depsProcessor = new DependenciesProcessor();
  bool _predefinedDependenciesAdded = false;
  GenerationStepsSequencer _sequencer;
  Logger logger;

  /// The name of this [Generator]
  String get name;

  /// A description for this [Generator]
  String get description;

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
  Future addGenerationStep(GenerationStep step) {
    logger.finest("Adding a ${step.runtimeType}");
    return _sequencer.addStep(step);
  }
  // Future addGenerationStep(GenerationStep step) {
  //   Completer completer = new Completer();
  //   _sequencer.addStep(step).then((generationResult) {
  //     completer.complete(generationResult);
  //   });
  //   return completer.future;
  // }

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
}

class GenerationResults {
  String newPubspecLines;
  ProcessResult pubGetResult;
}
