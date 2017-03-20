import 'dart:io';

String getThisPackageName() {
  Directory dir = getPackageRoot();
  File pubspec = dir.listSync().singleWhere((f) => f.path == "pubspec.yaml");
  RegExp regExp = new RegExp(r"^name: ?(.*)$");
  return regExp.firstMatch(pubspec.readAsStringSync()).group(0);
}

Directory getPackageRoot() {
  Directory dir = Directory.current;
  try {
    while (
        dir.listSync().any((f) => f.path.endsWith("pubspec.yaml")) == false &&
            dir.path != "/") dir = dir.parent;
  } catch (e) {
    throw new Exception(
        "Error while trying to find pubspec.yaml from ${dir.path}:\n$e");
  }
  return dir;
}

String getPackageRootPath() => getPackageRoot().path + '/';

String getDifferentLines(String contents1, String contents2) {
  Set<String> str1 = new Set<String>.from(contents1.split('\n')),
      str2 = new Set<String>.from(contents2.split('\n')),
      ret,
      substract;
  ret = (str1.length > str2.length) ? str1 : str2;
  substract = (ret == str1) ? str2 : str1;
  ret.removeAll(substract);
  return ret.join('\n');
}
