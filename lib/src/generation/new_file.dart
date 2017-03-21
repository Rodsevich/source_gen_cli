import 'dart:io';
import './base.dart';
import '../common.dart';

class FileGenerationModule extends GenerationModule<File> {
  File source, destination;
  String relativePathDestination;

  FileGenerationModule(this.relativePathDestination);
  FileGenerationModule.fromExisting(
      this.source, this.relativePathDestination) {}

  @override
  File execution() {
    String srcStr = (source?.existsSync()) ? source.readAsStringSync() : "";
  }

  @override
  String get generationRelativePathDestination => relativePathDestination;
}
