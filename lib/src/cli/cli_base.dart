// Copyright (c) 2017, Rodsevich. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library generatorCli;

import 'dart:io';
import 'dart:async';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:build_runner/build_runner.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_gen/generators/json_serializable_generator.dart';
import 'package:console/console.dart';
import 'package:dart_config/default_server.dart';

import './commands/new/new.dart';

class SourceGenCli extends CommandRunner {
  String _generatedExtension = ".g.dart";

  //CLI setup
  SourceGenCli()
      : super("source_gen",
            "A generic source generation command for helping you develop easier") {
    argParser
      ..addSeparator("Arguments:")
      ..addFlag("help", help: "Show this help", abbr: 'h', negatable: false)
      ..addFlag("watch",
          help: "Watch for changes for continuous building",
          abbr: 'w',
          negatable: false)
      ..addOption("config-file",
          help: "Name of the configuration file to load",
          abbr: 'c',
          defaultsTo: "source_gen.yaml")
      ..addOption("generated-extension",
          help: "Extension of the generated files by this generator",
          abbr: 'e',
          defaultsTo: _generatedExtension);
  }
}

class Sorpi {
  ArgParser _parser;
  ArgResults _args;
  String _packageName;
  PhaseGroup _phases;
  List<Generator> _generators;
  Map<String, dynamic> _configs;
  List<String> _paths;
  String _generatedExtension;

  Future delegate(List<String> plainArgs) async {
    try {
      Console.init();
    } catch (e) {
      printError(e);
      exit(1);
    }

    try {
      _args = _parser.parse(plainArgs);
    } catch (e) {
      printError(e.toString());
      exit(2);
    }

    if (_args["help"]) {
      await _printUsage();
      exit(0);
    }

    try {
      _packageName = await _getPackageName();
    } catch (e) {
      printError(e.toString());
      exit(3);
    }

    try {
      _configs = await _getConfiguration(_args["config-file"]);
      _paths = (_configs["paths"] as String).split(" ");
      _paths.addAll(_args.rest);
    } catch (e) {
      printError(e.toString());
      exit(4);
    }

    if (_args["generated-extension"] != null)
      _generatedExtension = _args["generated-extension"];
    _phases = new PhaseGroup.singleAction(
        new GeneratorBuilder(_generators,
            generatedExtension: _generatedExtension),
        new InputSet(_packageName, _paths));
    if (_args["watch"])
      watch(_phases, deleteFilesByDefault: true);
    else
      build(_phases, deleteFilesByDefault: true);
  }

  Future<Map> _getConfiguration([String path = "source_gen.yaml"]) async {
    Map conf = await loadConfig(path);
    if (conf.containsKey("source_gen")) conf = conf["source_gen"];
    return conf;
  }

  Future<String> _getPackageName() async {
    Map conf = await loadConfig("pubspec.yaml");
    return conf['name'];
  }

  void print(String s) {
    stdout.writeln(s);
  }

  void printError(String s) {
    StringBuffer buf = new StringBuffer();
    TextPen pen = new TextPen(buffer: buf); //print with colors
    pen.red();
    pen(s);
    pen.normal();
    pen('');
    stderr.writeln(pen.toString());
  }

  Future _printUsage() async {
    String pkgName = await _getPackageName();
    print('''
This is source_gen's generators runner.

  Usage: pub run $pkgName:generator [arguments] [<path>...]
''');
    print(_parser.usage);
  }
}
