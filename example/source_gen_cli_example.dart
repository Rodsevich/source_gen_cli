// Copyright (c) 2017, Rodsevich. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:source_gen_cli/generator.dart';

class DependencyGenerator extends Generator {
  @override
  String get name => "example-dependencies-generator";
  @override
  String get description => " if the generator includes ";
  @override
  List<Dependency> get alwaysNeededDependencies =>
      [new Dependency("github", "any")];
  DependencyGenerator() {
    addDependency(new Dependency("gun", "any"));
  }
  @override
  bool get overridePolicy => false;
  // TODO: implement startingVariables
  @override
  Map get startingVariables => null;
}

main() {}
