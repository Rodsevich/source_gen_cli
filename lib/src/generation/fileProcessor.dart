import 'dart:io';
import 'package:diff/diff.dart';
import 'package:source_gen_cli/src/generation/base.dart';

class FileProcessor extends GenerationModule<FileChanges> {
  String tag;
  String template;
  FileProcessor(String relativePath, {this.template}) : super(relativePath);

  @override
  FileProcessResult execution() {
    // TODO: implement execution
  }

  FileProcessor.fromSorpi() : super('') {
    //@generationAfter("sorp")
  }

  // TODO: implement neededVariables
  @override
  List<String> get neededVariables => null;
}

class generationBefore {
  final String id;

  const generationBefore(this.id);
}

class generationAfter {
  final String id;

  const generationAfter(this.id);
}

/// A line by line changes tracking object
class FileChanges {
  String beforeText, afterText;

  Map<int, String> linesUnchanged = {};
  Map<int, String> linesAdded = {};
  Map<int, String> linesRemoved = {};
  Map<int, LineChange> linesChanged = {};

  /// A patch object that could be applied to the provided old text in order to
  /// obtain the new one.
  /// In a nutshell:
  ///   `beforeText` + `patch` = `afterText`
  ///   `beforeText`.patch(`patch`) // returns `afterText`
  List<PatchResult> patch;

  int get amountAdded => linesAdded.length;
  int get amountRemoved => linesRemoved.length;
  int get amountChanged => linesChanged.length;
  int get amountUnchanged => linesUnchanged.length;

  int totalLinesChanged;

  FileChanges(this.beforeText, this.afterText) {
    this.patch = diffPatch(beforeText.split('\n'), afterText.split('\n'));
    List<CommonOrDifferentThing> analisys =
        diffComm(beforeText.split('\n'), afterText.split('\n'));
    int line = 1;
    for (int i = 0; i < analisys.length; i++) {
      CommonOrDifferentThing step = analisys[i];
      if (!step.common.isEmpty) {
        //same lines
        for (String lineStr in step.common) linesUnchanged[line++] = lineStr;
      } else {
        //differnet lines
        if (step.file1.isEmpty) {
          //There are new lines
          for (String added in step.file2) linesAdded[line++] = added;
        } else if (step.file1.isEmpty) {
          //There are lines removed
          for (String removed in step.file2) linesRemoved[line++] = removed;
        } else {
          //There are lines changed
          for (int j = 0; j < step.file1.length; j++) {
            linesChanged[line++] = new LineChange(step.file1[j], step.file2[j]);
          }
        }
      }
    }
    this.totalLinesChanged = line;
  }
}

class LineChange {
  String before;
  String after;

  //TODO: Detectar qué caracteres cambian y una funcion de impresion con colores
  LineChange(this.before, this.after) {}
}

class FileProcessResult extends GenerationResult<FileChanges> {
  FileProcessResult(FileChanges object) : super(object);
}
