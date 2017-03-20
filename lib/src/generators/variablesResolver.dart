import 'dart:async';

/// Will hold a bunch of variables and provide tools to obtain them
class VariablesResolver {
  Map _mem;
  Function missingResolver;

  VariablesResolver([Map initialVars, Function demandingMissingVarsResolver]) {
    this._mem = initialVars;
    this.missingResolver = demandingMissingVarsResolver;
  }

  /// Returns the requested variable, or `null` if it's not defined
  get(String varName) => _mem[varName];
  // get(String varName) => _mem[varName] ?? null;
  // get(String varName) => _mem.containsKey(varName) ? _mem[varName] : null;

  Future demand(String varName,
      {Type type: dynamic, String message, Function constraintsChecker}) {
    Completer completer = new Completer();
    new Future(() {
      if (_mem[varName] == null) {
        DemandingVariable demandingVariable =
            new DemandingVariable(varName, type: type);
        if (message == null) {
          demandingVariable.message =
              "please provide the variable value for '$varName'";
        } else {
          demandingVariable.message = message;
        }
        if (constraintsChecker != null)
          demandingVariable.constraintsChecker = constraintsChecker;
        demandingVariable.type = type;
        completer.complete(missingResolver(demandingVariable));
      } else {
        completer.complete(_mem[varName]);
      }
    });
    return completer.future;
  }

  operator [](key) => get(key);

  void operator []=(key, value) {
    _mem[key] = value;
  }
}

class DemandingVariable {
  String name;
  Type type;
  Function constraintsChecker;
  String message;
  DemandingVariable(this.name,
      {this.type, this.message, this.constraintsChecker});
}
