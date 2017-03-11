import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:source_gen_cli/src/cli/commands/new/new.dart';

class GeneratorPackageCommand extends NewSubcommand {
  @override
  String get name => 'generator-package';
  @override
  String get description => "Scaffolds a new source_gen's generator";
  @override
  Directory get templateDir => null;
  @override
  String get generatorOutputDir => null;
  @override
  Map get templateVars => null;

  GeneratorPackageCommand() {
    argParser.addFlag('mustache',
        help: 'Simplify generator with the assistance of mustache templates',
        negatable: true,
        defaultsTo: true);
  }
}
