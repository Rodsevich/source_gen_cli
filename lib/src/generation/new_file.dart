import 'dart:io';
import './base.dart';
import '../common.dart';

import 'package:mustache/mustache.dart';
import 'package:path/path.dart' as path;

/// Creates or copies (with processing if neccesary) a [File] when executed.
class FileGenerationModule extends GenerationModule<File> {
  /// The contents to be written in the generated [File]
  final String sourceString;

  /// Wether the generation should process the mustache code or copy it "as is"
  bool processInputWithMustache;

  /// Determine if an already existing [File] should be silently overriden or an
  /// [Exception] been thrown
  bool allowOverride;

  /// This will create a [File] in the provided `relativePathDestination`
  /// (relative to this package location) by copying (or, eventually, processing)
  /// the provided `sourceString` (being the processing determied by the
  /// `processInputWithMustache` flag that defaults to `true`)
  ///
  /// If the [File] to create already exists, by default an [Exception] will be
  /// raised, this can be omitted by setting the `allowOverride` flag to `true`
  FileGenerationModule(String contents, String relativePathDestination,
      {this.processInputWithMustache: true, this.allowOverride: false})
      : super(relativePathDestination),
        this.sourceString = contents;

  /// If the file to copy is named `name.extension.mustache` the generated [File]
  /// will be the result of the processing of the source one into `name.extension`
  /// But if source has only one extension, even `name.mustache`, the generated
  /// [File] will, by default, not be processed and named as the source
  FileGenerationModule.fromExistingFile(
      File source, String relativePathDestination,
      {bool processInputWithMustache: true})
      : this(source.readAsStringSync(), relativePathDestination,
            processInputWithMustache: processInputWithMustache);

  FileGenerationModule.fromExistingDir(
      Directory dir, String generationName, String sourceString,
      {bool processInputWithMustache: true, bool allowOverride: false})
      : this(
            sourceString,
            path.relative(path.join(dir.path, generationName),
                from: getPackageRootPath()),
            allowOverride: allowOverride,
            processInputWithMustache: processInputWithMustache);

  @override
  List<String> get neededVariables => mustacheVars(sourceString);
  @override
  FileGenerationResult execution() {
    File destinationFile = new File(this.pathDestination);
    bool overriden = false;
    logger.finest(
        "destination File instance created: <File>(${destinationFile.path})");
    if (destinationFile.existsSync()) {
      logger.finer("File $pathDestination exists. (Override: $allowOverride)");
      if (allowOverride) {
        logger.warning("$pathDestination already exists (will be overriden)");
      } else {
        String e = "$pathDestination already exists. Overriding isn't allowed.";
        logger.severe(e);
        throw new Exception(e);
      }
    } else {
      logger.finer("File $pathDestination doesn't exists. Creating it...");
      destinationFile.createSync();
    }
    logger.finest("Processing mustache: $processInputWithMustache");
    String output = processInputWithMustache
        ? processMustache(sourceString, varsResolver.getAll)
        : sourceString;
    logger.finer("Writing to file ($pathDestination)...");
    destinationFile.writeAsStringSync(output);
    logger.finest("$pathDestination written.");
    return new FileGenerationResult(
        destinationFile, overriden, processInputWithMustache);
  }
}

class FileGenerationResult extends GenerationResult<File> {
  bool overriden;
  bool processed;
  int lenght;
  FileGenerationResult(File object, this.overriden, this.processed)
      : super(object) {
    this.lenght = this.object.lengthSync();
  }
}
