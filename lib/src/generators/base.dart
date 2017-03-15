import "dart:async";
import "dart:io";
import '../generation/dependency.dart';

/// The base class from where the generation will took place. This is the
/// backbone of the generation and is the starting point from where new
/// [Generator]s shall start.
abstract class Generator {
  DependenciesProcessor _depsProcessor = new DependenciesProcessor();
  bool _predefinedDependenciesAdded = false;

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
    return _depsProcessor.addDependency(dependency);
  }

  void _addPredefinedDeps() {
    if (_predefinedDependenciesAdded == false &&
        alwaysNeededDependencies.isNotEmpty) {
      _depsProcessor.addDependencies(alwaysNeededDependencies);
      _predefinedDependenciesAdded = true;
    }
  }

  Future<GenerationResults> execute({bool runPubGetDependencies: false}) async {
    GenerationResults ret = new GenerationResults();
    ret.newPubspecLines = await _depsProcessor.processPubspec();
    if (runPubGetDependencies)
      ret.pubGetResult = await _depsProcessor.runPubGet();
  }
}

class GenerationResults {
  String newPubspecLines;
  ProcessResult pubGetResult;
}
