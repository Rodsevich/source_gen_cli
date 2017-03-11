import 'dart:io';

String getThisPackageName() {
  Directory dir = new Directory('.');

  try {
    while (!dir.listSync().any((f) => f.path == "pubspec.yaml"))
      dir = dir.parent;
  } catch (e) {
    throw new Exception(
        "Error while trying to find pubspec.yaml from ${dir.path}:\n$e");
  }
  File pubspec = dir.listSync().singleWhere((f) => f.path == "pubspec.yaml");
  RegExp regExp = new RegExp(r"^name: ?(.*)$");
  return regExp.firstMatch(pubspec.readAsStringSync()).group(0);
}
