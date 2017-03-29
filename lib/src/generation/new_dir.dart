import 'dart:io';
import 'dart:async';
import './base.dart';
import '../common.dart';

class DirGenerationModule extends GenerationModule<Directory> {
  Directory directory;
  bool generateRecursively = false;

  /// Determine if an already existing [Directory] should be deleted and
  /// generated again by this [DirGenerationModule]
  bool allowOverride;

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
  DirGenerationResult execution() {
    if (directory.existsSync()) {
      logger.warning("${directory.path} already exists");
    } else {
      logger.fine(directory.path + " didn't exist. Creating it.");
      directory.createSync(recursive: generateRecursively);
    }
    return new DirGenerationResult(directory);
  }

  @override
  List<String> get neededVariables => mustacheVars(directory.path);
}

class DirGenerationResult extends GenerationResult<File> {
  bool overriden;
  FileGenerationResult(object, this.overriden) : super(object);
}
