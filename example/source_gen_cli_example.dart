// Copyright (c) 2017, Rodsevich. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:source_gen_cli/generator.dart';
import 'package:source_gen_cli/src/generators/base.dart';
import 'package:source_gen_cli/src/interactions/base.dart';

class DependencyGenerator extends Generator {
  @override
  String get name => "example-dependencies-generator";
  @override
  String get description => " if the generator includes ";
  @override
  List<Dependency> get alwaysNeededDependencies =>
      [new Dependency("github", "any")];
  DependencyGenerator(InteractionsHandler interactionsHandler)
      : super(interactionsHandler) {
    addDependency(new Dependency("gun", "any"));
  }
  // TODO: implement startingVariables
  @override
  Map get startingVariables => null;
  // TODO: implement overridePolicy
  @override
  OverridingPolicy get overridePolicy => OverridingPolicy.ALWAYS;
}

main() {}
