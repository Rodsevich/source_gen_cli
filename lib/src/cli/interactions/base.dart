import "../../interactions/base.dart";
import 'dart:async';
import "dart:io";

class CLInterface extends IOInterface {
  Stdin stdin;
  Stdout stdout;

  CLInterface(this.stdin, this.stdout) {
    stdin.echoMode = false;
    stdin.lineMode = false;
  }

  void print(String contents) => stdout.write(contents);

  Stream<String> get read => stdin
      .asBroadcastStream()
      .map((List<int> i) => new String.fromCharCodes(i));
}

class CLIInteractionsHandler extends InteractionsHandler {
  CLIInteractionsHandler(CLInterface clInterface) : super(clInterface);

  @override
  Future<bool> askForConfirmation(String message) {
    // TODO: implement askForConfirmation
  }

  @override
  Future<String> askForInput(String message, String checkRegExp) {
    // TODO: implement askForInput
  }

  @override
  Future<String> askForSelection(String message, List<String> options) {
    // TODO: implement askForSelection
  }
}
