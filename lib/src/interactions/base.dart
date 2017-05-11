library interactions.backbone;

part "./confirmation.dart";
part "./selection.dart";
part "./input.dart";

import 'dart:async';

/// Father class of every interaction the [Generator]s have with the user.
abstract class Interaction {
  String message;

  void displayMessage(String message);

  void handleInvalidInput(String input);

  Future<String> finalValue;
}

abstract class InteractionsInterface {
  Future<bool> askForConfirmation(String message);
  Future<String> askForInput(String message, String checkRegExp);
  Future<String> askForSelection(String message, List<String> options);
}

/// The entity in charge of instantiating and handling the [Interaction]s
abstract class InteractionsHandler implements InteractionsInterface {
  IOStrategy ioStrategy;
  InteractionsHandler(this.ioStrategy);
  Future<bool> askForConfirmation(String message);
  Future<String> askForInput(String message, String checkRegExp);
  Future<String> askForSelection(String message, List<String> options);
}

/// Father class of the interface to the IO operations with the user
abstract class IOStrategy {
  void print(String contents);
  Stream<String> read;
}
