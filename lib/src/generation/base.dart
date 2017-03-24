import 'dart:async';

import '../generators/utils/sequencer.dart';

/// The base class of any operation that will be performed in the workflow of
/// the [Generator]s.
/// `T` should be the Type of the generated thing of this module
abstract class GenerationModule<T> extends GenerationStep<T> {
  /// This package's relative path in which to do the generation
  String get generationRelativePathDestination;
}
