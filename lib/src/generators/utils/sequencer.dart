import 'dart:async';

import 'package:logging/logging.dart';

/// Internal class that holds the execution logic of the [Generator], it will
/// handle the execution order of the [GenerationModule]s
class GenerationStepsSequencer {
  List<GenerationStep> _steps = [];
  int _currentIndex, _duringExecutionAddedIndex;
  bool _executionStarted = false;
  Completer _completer = new Completer();

  GenerationStep get _current =>
      (_currentIndex < _steps.length) ? _steps[_currentIndex] : null;

  Future addStep(GenerationStep step) {
    if (_executionStarted) {
      _duringExecutionAddedIndex ??= _currentIndex;
      _steps.insert(++_duringExecutionAddedIndex, step);
    } else {
      _steps.add(step);
    }
    // return step.futureExecution;
    return step._completer.future;
  }

  Future execute() {
    _executionStarted = true;
    _currentIndex = 0;
    _current.execute().then(_processCurrentExecutionResult);
    return _completer.future;
  }

  _processCurrentExecutionResult(var executionResult) {
    new Future(() {
      _currentIndex++;
      _duringExecutionAddedIndex = null;
      if (_current == null) {
        _completer.complete();
      } else {
        _current.execute().then(_processCurrentExecutionResult);
      }
    });
  }
}

/// Only subclasses of this class may be used by a [GenerationStepsSequencer]
/// `T` would be the Type of the result of executing this
abstract class GenerationStep<T> {
  Completer _completer = new Completer();
  Logger get logger;

  /// This operation must hold the operational logic of the subclass that, when
  /// executed, will complete the [Future] with the *eventually needed* value
  /// for the [GenerationStepsSequencer]
  T execution();

  // Future<T> get futureExecution => _completer.future;

  Future<T> execute() {
    new Future(() {
      logger.finer("starting execution of ${this.runtimeType}");
      var ending = execution();
      logger.finest("ending execution of ${this.runtimeType}");
      _completer.complete(ending);
    });
    return _completer.future;
  }
}
