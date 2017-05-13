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

  Stream<String> get read => stdin.listen(onData);
}
