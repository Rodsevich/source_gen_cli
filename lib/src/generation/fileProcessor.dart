import 'dart:io';
import 'package:source_gen_cli/src/generation/base.dart';

class FileProcessor extends GenerationModule<File> {
  FileProcessor(String relativePath) : super(relativePath);

  @override
  FileProcessResult<File> execution() {
    // TODO: implement execution
  }

  // TODO: implement neededVariables
  @override
  List<String> get neededVariables => null;
}

class FileChanges {
  Map<int, String> linesAdded, linesRemoved;
  Map<int, LineChange> linesChanged;
  int get added => linesAdded.length;
  int get removed => linesRemoved.length;
  int get changed => linesChanged.length;

  process() {
    List<PatchResult> p = diffPatch(s1.split('\n'), s2.split('\n'));
    for (int i = 0; i < p.length; i++) {
      assert(p[i].file1.length == 2);
      s1 = p[i].file1.chunk.join("\\n");
      assert(p[i].file2.length == 2);
      s2 = p[i].file2.chunk.join("\\n");
      if (s1 == '') {
        print("added: $s2 (${p[i].file2.offset})");
      } else {
        if (s2 == '') {
          print("removed: $s1 (${p[i].file1.offset})");
        } else {
          print("changed from '$s1' to '$s2'");
        }
      }
    }
  }
}

class LineChange {
  String before;
  String after;

  LineChange(this.before, this.after) {}
}

class FileProcessResult extends GenerationResult<File> {}
