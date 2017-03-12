import 'dart:async';

/// The base class of any operation that will be performed in the workflow of
/// the [Generator]s
abstract class GenerationModule {
  /// Where to find the required source from which do the generation
  String source;

  /// The code to be executed in order to have the purpose of the module achieved.
  ///
  /// Return `true` if the execution was successful, `false` otherwise
  Future<bool> run();
}
