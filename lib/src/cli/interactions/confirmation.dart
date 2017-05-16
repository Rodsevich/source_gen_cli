import "../../interactions/base.dart";
import 'dart:async';
import 'package:source_gen_cli/src/cli/interactions/base.dart';
import 'package:console/console.dart';

class CLIConfirmationInteraction extends ConfirmationInteraction with CLIUtils {
  CLIConfirmationInteraction(
      CLInterface clInterface, String message, bool defaultValue)
      : super(clInterface, message, defaultValue);

  Future<bool> execution() {
    // TODO: implement execution
  }
}

class CLIUtils {
  CLInterface clInterface;

  Stream<bool> onEnterPress() {
    clInterface.charCode
        .where((List<int> input) => input == [10])
        .map((_) => true);
  }
}
