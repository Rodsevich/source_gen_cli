import 'dart:async';

/// Internal class that holds the execution logic of the [Generator], it will
/// handle the execution order of the [GenerationModule]s
class Sequencer {
  List<Sequentiable> _steps = [];
  Sequentiable _current;
  bool _executionStarted = false;

  Future addStep(Sequentiable step){
    if(_executionStarted){
      var index = _steps.indexOf(_current);
      _steps.insert(index + 1, step);
    }else{
      _steps.add(step);
    }
    // return step.futureExecution;
    return step._completer.future;
  }

  execute(){
    _executionStarted = true;

  }
}

/// Only subclasses of this class may be used by a [Sequencer]
abstract class Sequentiable<T> {
  Completer _completer = new Completer();

  /// This operation must hold the operational logic of the subclass that, when
  /// executed, will complete the [Future] with the *eventually needed* value
  /// for the [Sequencer]
  T execution();

  // Future<T> get futureExecution => _completer.future;

  Future<T> execute(){
    new Future((){_completer.complete(execution())});
    return _completer.future;
  }
}
