import "../../interactions/base.dart";
import "./base.dart";
import 'dart:async';
import 'package:console/console.dart';

class CLIInputInteraction extends InputInteraction with CLIUtilsMixin {
  CLIInputInteraction(
      CLInterface clInterface, String message, String checkRegExp)
      : super(clInterface, message, checkRegExp);

  @override
  Future<String> execution() async {
    TextPen pen = new TextPen();
    clInterface.print(message);
    String inputStr = "";
    bool end = false;
    while (!end) {
      int inputCharCode = clInterface.stdin.readByteSync();
      if (inputCharCode == 127) {
        //backspace
        if (inputStr.isNotEmpty)
          inputStr = inputStr.substring(0, inputStr.length - 1);
        else
          continue;
      } else if (inputCharCode == 10) {
        //Enter
        if (inputStr.contains(checkRegExp)) {
          end = true;
          continue;
        }
      } else {
        inputStr += new String.fromCharCode(inputCharCode);
      }
      pen.reset();
      if (inputStr.contains(checkRegExp))
        pen.green();
      else
        pen.red();
      pen(inputStr);
      pen.normal();
      Console.overwriteLine("$message: $pen");
      // stdout.write(pen.buffer);
    }
    clInterface.stdout.writeln();
    return inputStr;
  }
}
