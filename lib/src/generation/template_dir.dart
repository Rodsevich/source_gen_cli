import 'dart:io';
import './base.dart';
import '../common.dart';
import '../generators/base.dart';

import 'package:mustache/mustache.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen_cli/src/generation/new_dir.dart';
import 'package:source_gen_cli/src/generation/new_file.dart';

/// Processes and generates a template directory in the specified `destination`
class TemplateGenerationModule
    extends GenerationModule<List<GenerationResult>> {
  String generationRelativePath;
  List<GenerationModule> templateModules = [];

  TemplateGenerationModule(
      String templateRelativePath, this.generationRelativePath)
      : super(templateRelativePath) {
    Directory sourceDir =
        new Directory(getPackageRootPath() + templateRelativePath);
    for (FileSystemEntity entity in sourceDir.listSync()) {
      if (entity is File)
        this.templateModules.add(new FileGenerationModule.fromExistingFile(
            entity, generationRelativePath));
      else if (entity is Directory) {
        this.templateModules.add(new DirGenerationModule(entity.path));
      }
    }
  }

  GenerationResult<List<GenerationResult>> execution() {}

  @override
  List<String> get neededVariables => this
      .templateModules
      .map((GenerationModule module) => module.neededVariables)
      .reduce((List<String> l1, List<String> l2) => l1.addAll(l2));
}
