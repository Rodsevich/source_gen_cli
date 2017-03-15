import 'dart:async';
import 'dart:io';
import "package:den_api/den_api.dart";
import "package:pub_semver/pub_semver.dart";
import '../common.dart';

/// A required package for the [Generator] in order to have it's source code
/// working properly.
/// Suppose you need to include `source_gen` as a required dev_dependency:
/// `new Dependency("source_gen", "^0.5.3", true)`
class Dependency {
  PackageDep _pkgDep;
  bool isDevDependency;

  Dependency(String name, String constraint, {this.isDevDependency: false}) {
    VersionConstraint version = new VersionConstraint.parse(constraint);
    _pkgDep = new PackageDep(name, "hosted", version, null);
  }

  String get name => _pkgDep.name;
  String get constraint => _pkgDep.constraint;

  bool operator ==(Dependency other) =>
      this._pkgDep.name == other._pkgDep.name &&
      this.isDevDependency == other.isDevDependency;
}

// In case of need to process the Dependencies outside of this library, use this:
// /// Internal class used to unveil [PackageDep] from [Dependency]
// class PackageDepUnprivator {
//   Dependency dep;
//   PackageDepUnprivator(this.dep);
//
//   PackageDep get packageDep => dep._pkgDep;
//   bool get isDevDependency => dep.idDevDependency;
// }

enum DependencyProcessorStatus {
  NOT_PROCESSED,
  NEED_REPROCESSING,
  INSTALLED,
  CHANGED,
  NOT_CHANGED
}

/// Internal class used to manage [Dependency] classes
class DependenciesProcessor {
  Pubspec pubspec;
  Set<Dependency> deps = new Set();
  DependencyProcessorStatus status = DependencyProcessorStatus.NOT_PROCESSED;
  String _diff = '';

  bool addDependency(Dependency dep, {bool override: false}) {
    if (override) {
      deps.remove(dep);
    }
    if (deps.add(dep)) {
      if (status != DependencyProcessorStatus.NOT_PROCESSED)
        status = DependencyProcessorStatus.NEED_REPROCESSING;
      return true;
    } else
      return false;
  }

  bool addDependencies(List<Dependency> deps, {bool override: false}) => deps
      .map((dep) => addDependency(dep, override: override))
      .reduce((a, b) => a && b);

  /// Adds the specified dependencies to the pubspec.yaml file and executes `pub get`
  /// Returns the pubspec lines that were changed in the operation
  Future<String> processPubspec() async {
    pubspec ??= await Pubspec.load();
    String oldContents = pubspec.contents;
    deps.forEach((Dependency dep) =>
        pubspec.addDependency(dep._pkgDep, dev: dep.isDevDependency));
    if (oldContents == pubspec.contents) {
      this.status = DependencyProcessorStatus.NOT_CHANGED;
    } else {
      _diff = getDifferentLines(oldContents, pubspec.contents);
      this.status = DependencyProcessorStatus.CHANGED;
      pubspec.save();
    }
    return _diff;
  }

  // Took from Aqueduct framework
  /// Runs `pub get` with a 20s timeout. If it fails, it retries with `--offline`
  Future<ProcessResult> runPubGet({bool offline: false}) async {
    var args = ["get"];
    if (offline) {
      args.add("--offline");
    }
    ProcessResult res;
    try {
      res = await Process
          .run("pub", args,
              workingDirectory: getPackageRoot().path, runInShell: true)
          .timeout(new Duration(seconds: 20));
      return res;
    } on TimeoutException {
      if (!offline)
        return runPubGet(offline: true);
      else
        throw new Exception("pub get failed");
    } finally {
      if (res.exitCode > 0) this.status = DependencyProcessorStatus.INSTALLED;
    }
  }
}
