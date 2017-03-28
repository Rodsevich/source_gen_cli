import 'dart:async';

import '../generators/utils/sequencer.dart';
import '../generators/utils/variablesResolver.dart';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

/// The base class of any operation that will be performed in the workflow of
/// the [Generator]s.
/// `T` should be the Type of the generated thing of this module
abstract class GenerationModule<T> extends GenerationStep<T> {
  VariablesResolver _varsResolver;
  Logger _logger;

  Logger get logger => _logger;
  VariablesResolver get varsResolver => _varsResolver;

  /// This package's relative path in which to do the generation
  String get generationRelativePathDestination;
  void set generationRelativePathDestination(String p) {
    String norm = path.normalize(p);
    String thisPkg = getPackageRootPath();
    String abs = path.normalize(path.join(thisPkg, norm));
    if (!abs.startsWith(getPackageRootPath()))
      throw new Exception("$p goes outtside of current package ($thisPkg)");
  }

  /// Declare the names of the variables required for execution
  List<String> get neededVariables;
}

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
