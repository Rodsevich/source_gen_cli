import 'package:source_gen_cli/src/generation/sequencer.dart';
import 'package:test/test.dart';
import 'dart:async';

main() => defineTests();

class Printer extends Sequentiable<int> {
  int index;
  Printer(this.index);
  int execute() {
    printerInts.add(this.index);
    return this.index;
  }
}

List<int> printerInts = [];

defineTests() {
  group('Sequencer', () {
    Sequencer sequencer = new Sequencer();
    test('runs in correct order its steps', () {
      sequencer.addStep(new Printer(0));
      sequencer.addStep(new Printer(1)).then((int index) {
        sequencer.addStep(new Printer(2));
      });
      sequencer.addStep(new Printer(3));
    });
  });
}
