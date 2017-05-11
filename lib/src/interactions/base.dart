library interactions.backbone;

import 'dart:async';

//@generationParts("generationBaseInteractions")
part "./confirmation.dart";
part "./selection.dart";
part "./input.dart";

/// Father class of every interaction the [Generator]s have with the user.
abstract class Interaction<R> {
  String message;
  IOInterface ioInterface;

  Interaction(this.ioInterface, this.message);

  void displayMessage(String message);

  void handleInvalidInput(String input);

  Future<R> finalValue;
}

abstract class InteractionsInterface {
  Future<bool> askForConfirmation(String message);
  Future<String> askForInput(String message, String checkRegExp);
  Future<String> askForSelection(String message, List<String> options);
}

/// The entity in charge of instantiating and handling the [Interaction]s
abstract class InteractionsHandler implements InteractionsInterface {
  IOInterface ioInterface;
  InteractionsHandler(this.ioInterface);
  Future<bool> askForConfirmation(String message);
  Future<String> askForInput(String message, String checkRegExp);
  Future<String> askForSelection(String message, List<String> options);
}

/// Father class of the interface to the IO operations with the user
abstract class IOInterface {
  void print(String contents);
  Stream<String> read;
}
