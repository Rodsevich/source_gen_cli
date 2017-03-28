import 'dart:io';
import './base.dart';
import '../common.dart';

import 'package:mustache/mustache.dart';
import 'package:path/path.dart' as path;

/// Creates or copies (with processing if neccesary) a [File] when executed.
class FileGenerationModule extends GenerationModule<File> {
  final String originalRelativePathDestination;
  Directory destinationDir;
  final String sourceString;
  final File destinationFile;

  /// Wether the generation shold process the mustache code or copy it "as is"
  bool processInputWithMustache;

  FileGenerationModule(String sourceString, String relativePathDestination,
      {this.processInputWithMustache: true})
      : this.destinationFile =
            new File(path.join(getPackageRootPath(), relativePathDestination)),
        this.destinationDir = _getDestinationDir(relativePathDestination),
        this.sourceString = sourceString,
        this.originalRelativePathDestination = relativePathDestination;

  /// If the file to copy is named `name.extension.mustache` the generated [File]
  /// will be the result of the processing of the source one into `name.extension`
  /// But if source has only one extension, even `name.mustache`, the generated
  /// [File] will, by default, not be processed and named as the source
  FileGenerationModule.fromExistingFile(
      File source, String relativePathDestination)
      : this(source.readAsStringSync(), relativePathDestination,
            processInputWithMustache: (source.path.endsWith(".mustache") &&
                source.path.split('.').length > 2));

  @override
  File execution() {
    if (!destinationFile.existsSync()) destinationFile.create();
    destinationFile
        .writeAsStringSync(processMustache(sourceString, varsResolver.getAll));
    return destinationFile;
  }

  @override
  List<String> get neededVariables => mustacheVars(sourceString);
}

Directory _getDestinationDir(String relativePathDestination) {
  String filePath = path.join(getPackageRootPath(), relativePathDestination);
  String dirPath = path.dirname(filePath);
  Directory destinationDir = new Directory(dirPath);
  destinationDir.exists().then((bool exists) {
    if (exists == false)
      throw new Exception("${destinationDir.path} must exists");
  });
  return destinationDir;
}
