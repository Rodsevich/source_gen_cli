import 'dart:developer';
import 'dart:io';
import 'package:mustache/mustache.dart';

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

Map gatherTemplateRequiredVars(Template template, [Map vars]) {
  RegExp nameRegExp = new RegExp(r": (.*).$");
  while (true) {
    TemplateException error = _failing_gathering(template, vars,
        printMessage: true, printReturn: true);
    if (error == null)
      return vars;
    else {
      String e = error.message;
      String name = nameRegExp.firstMatch(e).group(1);
      if (e.contains("for variable tag")) {
        vars[name] = "#VarOf$name#";
      } else if (e.contains("for inverse section")) {
        vars[name] = [];
      } else { //Just normal section
        vars[name] = {};
      }
    }
  }
}

TemplateException _failing_gathering(Template template, Map vars,
    {bool printMessage = false, bool printReturn = false}) {
  try {
    String ret = template.renderString(vars);
    if (printReturn) print(ret);
    return null;
  } on TemplateException catch (e) {
    if (printMessage) print(e.message);
    return e;
  }
}
