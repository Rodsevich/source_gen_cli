library interactions.backbone;

import 'dart:async';

//@generationParts("generationBaseInteractions")
part "./confirmation.dart";
part "./selection.dart";
part "./input.dart";

/// Father class of every interaction the [Generator]s have with the user.
abstract class Interaction<R> {
  IOInterface ioInterface;
  String message;

  Interaction(this.ioInterface, this.message);

  Future<R> execution();
}

/// The interface that should be primarily implemented by the [InteractionsHandler]
abstract class InteractionsInterface {
  Future<bool> askForConfirmation(String message, {bool defaultValue: true});
  Future<String> askForInput(String message, String checkRegExp);
  Future<String> askForSelection(String message, List<String> options);
}

// /// The interface that should be implemented by [Generator] in order to provide
// /// an easy-to-use API in the programming of [Generator]s
// abstract class SynchronousInteractionsInterface {
//   bool askForConfirmation(String message, {bool defaultValue: true});
//   String askForInput(String message, String checkRegExp);
//   String askForSelection(String message, List<String> options);
// }

/// The entity in charge of instantiating and handling the [Interaction]s
abstract class InteractionsHandler implements InteractionsInterface {
  IOInterface ioInterface;
  InteractionsHandler(this.ioInterface);
}

/// Father class of the interface to the IO operations with the user. It's used
/// to provide a common interface to every platform in which the generators
/// could be ran in order to provide universal execution
abstract class IOInterface {
  IOInterface() {
    setUp();
  }

  /// Function to be executed at the beginning of this [IOInterface] usage
  bool setUp();

  /// Function to be executed at the end of this [IOInterface] usage
  bool tearDown();

  /// Show to the user the provided `contents` parameter [String]
  void print(String contents);

  /// Get from the user single readable chars inputted
  Stream<String> get readChar;

  /// Get from the user a complete inputted [String], an example could be readLn
  Stream<String> get readInput;

  /// Get from the user every char key code inputted
  Stream<List<int>> get charCode;
}
