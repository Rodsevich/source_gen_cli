import "../../interactions/base.dart";
import "./base.dart";
import 'dart:async';
import 'package:console/console.dart';

class CLISelectionInteraction extends SelectionInteraction with CLIUtilsMixin {
  CLISelectionInteraction(
      CLInterface clInterface, String message, List<String> options)
      : super(clInterface, message, options);

  Future<String> execution() {
    Chooser chooser = new Chooser<String>(options, message: message);
    return chooser.choose();
  }
}
