import 'dart:io';
import 'package:source_gen_cli/src/generation/new_file.dart';
import 'package:test/test.dart';

main() => defineTests();

defineTests() {
  group('FileGenerationModule', () {
    FileGenerationModule fgm, fgm1, fgm2;
    File f1 = new File(Directory.systemTemp.path + "/sorp.txt");
    File f2 = new File(Directory.systemTemp.path + "/sorp.txt.mustache");
    if (!f1.existsSync()) f1.createSync();
    if (!f2.existsSync()) f2.createSync();
    f1.writeAsStringSync("SORPI");
    f2.writeAsStringSync("{{var1}}-{{var2}}");
    test('Instantiation from String', () {
      fgm = new FileGenerationModule("sourceString", "test/q.txt");
      expect(fgm.originalRelativePathDestination, equals("test/q.txt"));
      expect(fgm.sourceString, equals("sourceString"));
    });
    test("Instantiation from File", () {
      fgm = new FileGenerationModule.fromExistingFile(f1, "test/w.txt");
      expect(fgm.sourceString, equals("SORPI"));
    });
    test(".fromExistingFile processes well the processMustache flag", () {
      fgm1 = new FileGenerationModule.fromExistingFile(f1, "test/r.txt");
      fgm2 = new FileGenerationModule.fromExistingFile(f2, "test/t.txt");
      expect(fgm1.processMustache, isFalse);
      expect(fgm2.processMustache, isTrue);
    });
    test("destinationFile is setUp properly", () {
      expect(fgm.destinationFile.path,
          equals(Directory.current.path + "/test/w.txt"));
      expect(fgm1.destinationFile.path, endsWith("r.txt"));
      expect(fgm2.destinationFile.path, endsWith("test/t.txt"));
    });
  });
}
