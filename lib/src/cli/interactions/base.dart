import 'dart:async';
import "dart:io";
import "../../interactions/base.dart";
import './confirmation.dart';
import './selection.dart';
import './input.dart';

class CLInterface extends IOInterface {
  Stdin stdin;
  Stdout stdout;

  bool echoMode;
  bool lineMode;

  CLInterface(this.stdin, this.stdout);

  bool setUp() {
    echoMode = stdin.echoMode;
    lineMode = stdin.lineMode;
    stdin.echoMode = false;
    stdin.lineMode = false;
  }

  bool tearDown() {
    stdin.echoMode = echoMode;
    stdin.lineMode = lineMode;
  }

  void print(String contents) => stdout.write(contents);

  Stream<String> get readChar => stdin
      .asBroadcastStream()
      .map((List<int> i) => new String.fromCharCodes(i));

  Stream<List<int>> get charCode => stdin.asBroadcastStream();

  Stream<String> get readInput async* {
    while (true) yield stdin.readLineSync();
  }
}

class CLIInteractionsHandler extends InteractionsHandler {
  CLIInteractionsHandler(CLInterface clInterface) : super(clInterface);

  CLInterface get clInterface => ioInterface;

  @override
  Future<bool> askForConfirmation(String message, {bool defaultValue: true}) {
    CLIConfirmationInteraction interaction =
        new CLIConfirmationInteraction(clInterface, message, defaultValue);
    return interaction.execution();
  }

  @override
  Future<String> askForInput(String message, String checkRegExp) {
    CLIInputInteraction interaction =
        new CLIInputInteraction(clInterface, message, checkRegExp);
    return interaction.execution();
  }

  @override
  Future<String> askForSelection(String message, List<String> options) {
    CLISelectionInteraction interaction =
        new CLISelectionInteraction(clInterface, message, options);
    return interaction.execution();
  }
}

class CLIUtilsMixin {
  IOInterface ioInterface;
  CLInterface get clInterface => this.ioInterface;

  Stream<bool> onEnterPress() {
    clInterface.charCode
        .where((List<int> input) => input == [10])
        .map((_) => true);
  }
}
