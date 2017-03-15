import 'package:source_gen_cli/src/generation/sequencer.dart';
import 'package:test/test.dart';
import 'dart:async';

main() => defineTests();

class Printer extends GenerationStep<int> {
  int index;
  Printer(this.index);
  int execution() {
    // print("PRINTING: $index");
    printerInts.add(this.index);
    return this.index;
  }
}

List<int> printerInts = [];

defineTests() {
  group('Sequencer', () {
    GenerationStepsSequencer sequencer = new GenerationStepsSequencer();
    test('runs in correct order its steps', () async {
      sequencer.addStep(new Printer(0)).then((int index) {});
      sequencer.addStep(new Printer(1)).then((int index) {
        if (index == 1) {
          sequencer.addStep(new Printer(2)).then((int index) {
            sequencer.addStep(new Printer(3));
          });
          sequencer.addStep(new Printer(4)).then((int index) {
            sequencer.addStep(new Printer(5));
            sequencer.addStep(new Printer(6));
          });
        }
      });
      sequencer.addStep(new Printer(7)).then((int index) {});
      Completer completer = new Completer();
      sequencer.execute().then((_) {
        completer.complete(printerInts);
      });
      expect(completer.future, completion(equals([0, 1, 2, 3, 4, 5, 6, 7])));
    });
  });
}
