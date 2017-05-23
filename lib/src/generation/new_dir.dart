import 'dart:io';
import 'dart:async';
import './base.dart';
import '../common.dart';

import 'package:source_gen_cli/src/generators/base.dart';

class DirGenerationModule extends GenerationModule<Directory> {
  Directory directory;

  /// Wether to generate all the required [Directory]ies implicit in the
  /// `relativePath` from this constructor(s) when there are missing ones.
  /// i.e.:
  ///   Given a `relativePath` foo/bar/baz and the only existing [Directory] of
  ///   them being foo, if this is set to `true`, bar will be generated. An
  ///   Exception will be raised otherwise
  bool generateRecursively;

  /// Determine if an already existing [Directory] should be deleted and
  /// generated again by this [DirGenerationModule]
  OverridingPolicy override;

  DirGenerationModule(String relativePath,
      {this.override: OverridingPolicy.NEVER, this.generateRecursively: false})
      : super(relativePath, override) {
    this.directory = new Directory(this.pathDestination);
  }

  DirGenerationModule.fromParentDir(Directory parentDirectory, String name,
      {OverridingPolicy override: OverridingPolicy.NEVER,
      bool generateRecursively: false})
      : this("${parentDirectory.path}/$name",
            override: override, generateRecursively: generateRecursively);
  // {
  //   if (name.contains('/'))
  //     throw new Exception(
  //         "$name should only contains the name of the directory");
  // }

  DirGenerationResult execution() {
    bool overriden;
    if (directory.existsSync()) {
      logger.warning("${directory.path} already exists (override: $override)");
      if (override == OverridingPolicy.ALWAYS) {
        logger.fine("Overriding existing Dir: ${directory.path}");
        for (FileSystemEntity ent in directory.listSync()) {
          logger.finer("Deleting ${ent.path}");
          ent.deleteSync(recursive: true);
        }
      }
    } else {
      logger.fine(directory.path + " didn't exist. Creating it.");
      directory.createSync(recursive: generateRecursively);
    }
    return new DirGenerationResult(directory, overriden);
  }

  List<String> get neededVariables => mustacheVars(directory.path);
}

class DirGenerationResult extends GenerationResult<Directory> {
  bool overriden;
  DirGenerationResult(object, this.overriden) : super(object);
}
