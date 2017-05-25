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
      String templateRelativePath, this.generationRelativePath,
      [OverridingPolicy overridingPolicy])
      : super(templateRelativePath, overridingPolicy) {
    Directory sourceDir =
        new Directory(getPackageRootPath() + templateRelativePath);
    for (FileSystemEntity entity in sourceDir.listSync(recursive: true)) {
      String name = path.relative(entity.path, from: sourceDir.path);
      String relativeDestination = "$generationRelativePath/$name";
      if (entity is File) {
        bool render = false;
        if (name.endsWith(".mustache")) {
          if (name.split('.').length > 2) {
            render = true;
            name = name.substring(0, name.length - 9);
          }
        }
        relativeDestination = "$generationRelativePath/$name";
        this.fileTemplateModules.add(new FileGenerationModule.fromExistingFile(
            entity, relativeDestination,
            processInputWithMustache: render));
      } else if (entity is Directory) {
        this.dirTemplateModules.add(new DirGenerationModule(relativeDestination,
            generateRecursively: true));
      }
    }
  }

  TemplateGenerationResults execution() {
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
    List<GenerationResult> results = [];
    results.addAll(dirResults);
    results.addAll(fileResults);
    // debugger();
    return new TemplateGenerationResults(results);
  }

  @override
  List<String> get neededVariables => fileTemplateModules
      .map((GenerationModule module) => module.neededVariables)
      .reduce((List<String> l1, List<String> l2) => l1.addAll(l2))
      .addAll(dirTemplateModules
          .map((GenerationModule module) => module.neededVariables)
          .reduce((List<String> l1, List<String> l2) => l1.addAll(l2)));
}

class TemplateGenerationResults
    extends GenerationResult<List<GenerationResult>> {
  TemplateGenerationResults(List<GenerationResult> object) : super(object);

  List<GenerationResult> addResult(GenerationResult result) {
    object.add(result);
    return object;
  }
}
