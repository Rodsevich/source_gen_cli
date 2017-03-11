import 'dart:io';
import "package:args/command_runner.dart" show Command;

import 'package:source_gen_cli/src/common.dart';
import 'package:source_gen_cli/src/cli/commands/add/subcommands/';

class AddCommand extends Command {
  String get name => "add";
  String get description =>
      "Creates code in existing projects, adding functionality quickly";

  AddCommand() {
    argParser.addFlag("force",
        abbr: 'f',
        help: "Don't ask for confirmation on overrides",
        defaultsTo: false);

    // addSubcommand(new GeneratorPackageCommand());
  }
}

abstract class AddSubcommand extends Command {
  /// The template directory name that will be processed in the generation
  Directory get templateDir;

  /// The variables that will be used to process the generation
  Map get templateVars;

  /// The path in which code will be generated
  String get generatorOutputDir;

  String resourcePrefix = "package:source_gen_cli/templates/";
}
