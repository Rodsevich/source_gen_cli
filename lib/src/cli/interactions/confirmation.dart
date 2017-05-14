import "../../interactions/base.dart";
import 'package:source_gen_cli/src/cli/interactions/base.dart';
import 'package:console/console.dart';

class CLIConfirmationInteraction extends ConfirmationInteraction {
  CLIConfirmationInteraction(CLInterface ioInterface, String message)
      : super(ioInterface, message);

  @override
  void displayMessage(String message) {
    // TODO: implement displayMessage
  }

  @override
  void handleInvalidInput(String input) {
    // TODO: implement handleInvalidInput
  }
}
