import 'dart:convert';
import 'dart:io';
import 'package:mustache/mustache.dart';
import "package:path/path.dart" as path;

String getThisPackageName() {
  Directory dir = getPackageRoot();
  File pubspec =
      dir.listSync().singleWhere((f) => f.path.endsWith("pubspec.yaml"));
  RegExp regExp = new RegExp(r"^name: (.*)");
  var ret = regExp.firstMatch(pubspec.readAsStringSync());
  return ret?.group(1);
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

String getPackageRootPath() => getPackageRoot().path + path.separator;

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

String processMustache(String source, Map vars) {
  Template template = new Template(source);
  return template.renderString(vars);
}

List<String> mustacheVars(String source) {
  Template template = new Template(source);
  Map varsMap = gatherTemplateRequiredVars(template);
  return varsMap.keys;
}

Map gatherTemplateRequiredVars(Template template, [Map variables]) {
  Map vars = variables ?? {};
  RegExp nameRegExp = new RegExp(r": (.*).$");
  while (true) {
    TemplateException error = _failing_gathering(template, vars);
    if (error == null)
      return vars;
    else {
      String e = error.message;
      String name = nameRegExp.firstMatch(e).group(1);
      if (e.contains("for variable tag")) {
        vars[name] = "#ValueOf$name#";
      } else {
        //up to this version, if not a variable, only a Section is possible
        RegExp inSectionSrc =
            new RegExp("{{([#^])$name}}([\\s\\S]*?){{/$name}}");
        List<Match> matches = inSectionSrc.allMatches(error.source).toList();
        for (int i = 0; i < matches.length; i++) {
          String type = matches[i].group(1);
          String contents = matches[i].group(2);
          Template sectionSourceTemplate = new Template(contents);
          // if (e.contains("for inverse section")) {
          // } else if (e.contains("for section")) {
          if (type == '^') {
            //inverse section
            vars["^$name"] ??= {};
            vars["^$name"]
                .addAll(gatherTemplateRequiredVars(sectionSourceTemplate));
          } else {
            vars[name] ??= {};
            vars[name]
                .addAll(gatherTemplateRequiredVars(sectionSourceTemplate));
          }
        }
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
