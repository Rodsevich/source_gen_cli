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
  List<FileGenerationModule> fileTemplateModules = [];
  List<DirGenerationModule> dirTemplateModules = [];

  TemplateGenerationModule(
      String templateRelativePath, this.generationRelativePath)
      : super(templateRelativePath) {
    Directory sourceDir =
        new Directory(getPackageRootPath() + templateRelativePath);
    for (FileSystemEntity entity in sourceDir.listSync()) {
      if (entity is File)
        this.fileTemplateModules.add(new FileGenerationModule.fromExistingFile(
            entity, generationRelativePath,
            processInputWithMustache: (entity.path.endsWith(".mustache") &&
                entity.path.split('.').length > 2)));
      else if (entity is Directory) {
        this.dirTemplateModules.add(new DirGenerationModule(entity.path));
      }
    }
  }

  GenerationResult<List<GenerationResult>> execution() {
    GeneratorModulesInitializer initializer = new GeneratorModulesInitializer(
        this.varsResolver, this.logger, this.override);
    List<DirGenerationResult> dirResults = [];
    List<FileGenerationResult> fileResults = [];
    for (DirGenerationModule dirGM in dirTemplateModules) {
      initializer.initialize(dirGM);
      dirResults.add(dirGM.execution());
    }
    for (FileGenerationModule fileGM in fileTemplateModules) {
      initializer.initialize(fileGM);
      fileResults.add(fileGM.execution());
    }
  }

  @override
  List<String> get neededVariables => fileTemplateModules
      .map((GenerationModule module) => module.neededVariables)
      .reduce((List<String> l1, List<String> l2) => l1.addAll(l2))
      .addAll(dirTemplateModules
          .map((GenerationModule module) => module.neededVariables)
          .reduce((List<String> l1, List<String> l2) => l1.addAll(l2)));
}
