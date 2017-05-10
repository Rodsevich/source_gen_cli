library interactions.backbone;

import 'dart:async';

/// Father class of every interaction the [Generator]s have with the user.
abstract class Interaction {
  String message;

  void displayMessage();

  void displayInavlidInput();
}

/// The entity in charge of instantiating and handling the [Interaction]s
abstract class InteractionsHandler {
  IOStrategy ioStrategy;
  InteractionsHandler(this.ioStrategy);
  bool askForConfirmation(String message);
  String askForInput(String message, String checkRegExp);
  String askForselection(String message, List<String> options);
}

/// Father class of the interface to the IO operations with the user
abstract class IOStrategy {
  void print(String contents);
  Stream<String> read;
}
