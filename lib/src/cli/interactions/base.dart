import "../../interactions/base.dart";
import 'dart:async';
import "dart:io";

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

  Stream<String> get readInput => stdin.readLineSync();
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
