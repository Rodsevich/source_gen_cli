/// Father class of every interaction the [Generator]s have with the user.
abstract class Interaction {
  String message;

  void displayMessage();

  void displayInavlidInput();
}

/// The entity in charge of instantiating and handling the [Interaction]s
class InteractionsHandler {}
