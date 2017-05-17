import "../../interactions/base.dart";
import "./base.dart";
import 'dart:async';
import 'package:console/console.dart';

class CLIConfirmationInteraction extends ConfirmationInteraction
    with CLIUtilsMixin {
  CLIConfirmationInteraction(
      CLInterface clInterface, String message, bool defaultValue)
      : super(clInterface, message, defaultValue);

  Future<bool> execution() async {
    message = message.trim();
    if (message.endsWith("?") == false) message += '?';
    String hints = "(";
    hints += (defaultValue == true) ? 'Y/n)' : 'y/N)';
    clInterface.print("$message $hints");
    await for (List<int> inputCharCodes in clInterface.charCode) {
      if (inputCharCodes == [10]) {
        //enter
        return confirmation();
      }
      String char = new String.fromCharCodes(inputCharCodes);
      if (char.toUpperCase() == "Y") {
        return confirmation();
      }
      if (char.toUpperCase() == "N") {
        return negation();
      }
    }
  }

  bool confirmation() {
    String checkmark = format("{color.green}${Icon.CHECKMARK}{color.normal}");
    Console.overwriteLine("$message $checkmark");
    return true;
  }

  bool negation() {
    String cross = format("{color.red}${Icon.BALLOT_X}{color.normal}");
    Console.overwriteLine("$message $cross");
    return false;
  }
}
