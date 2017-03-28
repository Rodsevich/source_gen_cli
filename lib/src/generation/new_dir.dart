import 'dart:io';
import 'dart:async';
import './base.dart';
import '../common.dart';

class DirGenerationModule extends GenerationModule<Directory> {
  Directory directory;
  bool generateRecursively = false;

  DirGenerationModule.fromParentDir(Directory parentDirectory, String name) {
    if (name.contains('/'))
      throw new Exception(
          "$name should only contains the name of the directory");
    this.directory = new Directory(parentDirectory.path + '/' + name);
  }
  DirGenerationModule.fromExisting(this.directory);
  DirGenerationModule.fromRelativePath(String relativePath) {
    this.directory = new Directory(getPackageRootPath() + relativePath);
  }

  @override
  Directory execution() {
    if (directory.existsSync() == false) {
      logger.fine(directory.path + " didn't exist. Creating it.");
      directory.createSync(recursive: generateRecursively);
    }
    return this.directory;
  }

  @override
  List<String> get neededVariables => mustacheVars(directory.path);
}
