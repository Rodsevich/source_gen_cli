import '../common.dart';
import 'dart:async';

import '../generators/utils/sequencer.dart';
import '../generators/utils/variablesResolver.dart';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

/// The internal base class of any operation that will be performed in the
/// workflow of the [Generator]s.
/// `T` should be the Type of the generated thing of this module
abstract class GenerationModule<T> extends GenerationStep<GenerationResult<T>> {
  VariablesResolver _varsResolver;
  String _pathDestination;
  Logger _logger;

  /// The [Logger] used to write the logs
  Logger get logger => _logger;

  /// The [VariablesResolver] used to get the variables for the generation
  VariablesResolver get varsResolver => _varsResolver;

  /// This package's absolute path in which to do the generation
  String get pathDestination => _pathDestination;

  /// Normalizes and absolutizes a relative to the package path and sets it
  GenerationModule(String relativePath) {
    String norm = path.normalize(relativePath);
    String thisPkg = getPackageRootPath();
    String abs = path.normalize(path.join(thisPkg, norm));
    if (!abs.startsWith(getPackageRootPath()))
      throw new Exception("$p goes outtside of current package ($thisPkg)");
    this._pathDestination = abs;
  }

  /// Declare the names of the variables required for execution
  List<String> get neededVariables;
}

/// Internal class used to provide [GenerationModule]s with [Logger] and
/// [VariablesResolver]
class GeneratorModulesInitializer {
  VariablesResolver varsResolver;
  Logger logger;

  GeneratorModulesInitializer(VariablesResolver varsResolver, Logger logger) {
    this.varsResolver = varsResolver;
    this.logger = logger;
  }

  void initialize(GenerationModule module) {
    module._logger = this.logger;
    module._varsResolver = this.varsResolver;
  }
}

class GenerationResult<T> {
  T object;
  GenerationResult(this.object);
}
