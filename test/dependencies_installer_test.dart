import '../example/source_gen_cli_example.dart';
import 'dart:developer';
import 'dart:io';
import 'package:den_api/den_api.dart';
import 'package:source_gen_cli/generator.dart';
import 'package:source_gen_cli/src/common.dart';
import 'package:source_gen_cli/src/generators/base.dart';
import 'package:test/test.dart';

main() => defineTests();

defineTests() {
  File pubspec, pubspecLock, pubspecBackup, pubspecLockBackup;
  String pkgRootPath = getPackageRoot().path + '/';
  setUpAll(() async {
    pubspec = new File(pkgRootPath + "pubspec.yaml");
    pubspecBackup = pubspec.renameSync(pkgRootPath + "pubspec.yaml.testbackup");
    Pubspec cleanPubspec = await Pubspec.init();
    cleanPubspec.save();
    pubspecLock = new File(pkgRootPath + "pubspec.lock");
    pubspecLockBackup =
        pubspecLock.renameSync(pkgRootPath + "pubspec.lock.testbackup");
  });
  tearDownAll(() {
    pubspecBackup.renameSync(pkgRootPath + "pubspec.yaml");
    pubspecLockBackup.renameSync(pkgRootPath + "pubspec.lock");
    Process.run("pub", ["get"]);
  });
  group('Generator Dependencies Installer:', () {
    DependencyGenerator depGenerator = new DependencyGenerator(null);
    List<String> pkgNames =
        depGenerator.dependencies.map((Dependency dep) => dep.name).toList();
    test('Installs dependencies in pubspec.yaml', () async {
      //Becoase setUpAll() should clear it.
      expect(pubspec.readAsStringSync(), isNot(contains("unittest")));
      if (!pkgNames.contains("unittest")) {
        depGenerator.addDependency(new Dependency("unittest", "any"));
        pkgNames.add("unittest");
      }
      GenerationResults res = await depGenerator.execute();
      expect(pubspec.readAsStringSync(), contains("unittest"));
    });
    test("Install dependencies in pubspec.lock with pub get", () async {
      //Becoase previous test shouldn't have ran `pub get` and setUpAll()
      // should've clear it.
      if (pubspecLock.existsSync())
        expect(pubspecLock.readAsStringSync(), isNot(contains("unittest")));
      GenerationResults res =
          await depGenerator.execute(runPubGetDependencies: true);
      print(res?.pubGetResult?.exitCode);
      expect(pubspecLock.readAsStringSync(), contains("unittest"));
    }, testOn: "vm");
  });
}
