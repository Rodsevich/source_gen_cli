import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:mirrors';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:logging/logging.dart';
import "package:path/path.dart" as path;
import '../lib/src/common.dart';
import 'package:source_gen/src/annotation.dart';
import 'package:console/console.dart';
import "../lib/src/generation/fileProcessorAnnotations/base.dart";

main(args) {
  return stdinStream();
  // return probarStds();
  // return asignarConTokens();
  // return pruebaMaps();
  // return checkearInstantiacionAnotacion();
  // return procesadorDeArgs();
}

stdinStream() {
  stdin.lineMode = false;
  stdin.echoMode = false;
  int c = 0;
  stdin
      .asBroadcastStream()
      .map((List<int> i) => new String.fromCharCodes(i))
      .listen((String input) {
    TextPen pen = new TextPen();
    if (c++ == 8) c = 0;
    pen.setColor(new Color(c));
    pen(input);
    pen.normal();
    stdout.write(pen.toString());
  });
}

probarStds() {
  TextPen pen = new TextPen();
  TimeDisplay timer;
  String message = "Escribí un número";
  stdout.write(message);
  RegExp regExp = new RegExp(r"^[0-9]+$");
  String inputStr = "";
  stdin.lineMode = false;
  stdin.echoMode = false;
  bool end = false;
  while (!end) {
    int inputCharCode = stdin.readByteSync();
    if (inputCharCode == 127) {
      //backspace
      if (inputStr.isNotEmpty)
        inputStr = inputStr.substring(0, inputStr.length - 1);
    } else if (inputCharCode == 10) {
      //Enter
      if (inputStr.contains(regExp)) {
        end = true;
        continue;
      }
    } else {
      inputStr += new String.fromCharCode(inputCharCode);
    }
    pen.reset();
    if (inputStr.contains(regExp))
      pen.green();
    else
      pen.red();
    pen(inputStr);
    pen.normal();
    Console.overwriteLine("$message: $pen");
    // stdout.write(pen.buffer);
  }
  print("");
  stdin.lineMode = true;
  stdin.echoMode = true;
  // .map((List<int> i) => i.map((q) => q + 1))
  // .map((List<int> i) => new String.fromCharCodes(i))
  // .map((i) => "\e[5m\e[1m\e[93m\e[101m$i\e[0m")
  // .pipe(stdout);
}

void err(String s, int n) {
  print(s);
}

asignarConTokens() {
  String asignarEsto = '"SORPI; PEDAZO DE PUTO!"';
  String location = "<LOCATION>";
  int lineNumber = 6;
  var logger = new Logger("l");
  File f = new File("tool/codigo_prueba.dart");
  CompilationUnit c = parseCompilationUnit(f.readAsStringSync());
  List<String> input = f.readAsLinesSync();
  input.insert(0, null);
  var annotatedNode = c.declarations.single; // as TopLevelVariableDeclaration;

  print(input.join('\n'));
}

pruebaMaps() {
  Map sorp = {};
  print(null);
  print(sorp["nulo"]);
}

procesadorDeArgs() {
  String source = "(1,'dos',#tres)";
  String funcSrc = "var q = a$source;";
  CompilationUnit c = parseCompilationUnit(funcSrc);
  var t = c.declarations.single as TopLevelVariableDeclaration;
  VariableDeclaration de = t.childEntities.first.variables.first;
  Expression expression = de.initializer;
  ArgumentList args = (expression as MethodInvocation).argumentList;
  exit(0);
}

class Clazz {
  int number;
  Clazz(this.number);
}

checkClassInstantiation() {
  var reflec = reflectClass(Clazz);
  Clazz instance = reflec.newInstance(new Symbol(''), [1]).reflectee;
  assert(instance.number == 1);
}

// // for var i in ... works
// List<String> s = ["sorp", "longa", "ponga"];
// for (String i in s) print(i);
// // Lista con numeros arbitrarios (no puede ser List, tiene que ser Map)
// Map<int, String> lista = {};
// lista[12] = "doce";
// lista[100] = "cien";
// lista[30] = "treinta";
// lista.forEach((int linea, String nombre) {
//   // int linea = lista.indexOf(nombre);
//   print("$linea: $nombre");
// });
// // Logger logea objetos
// Logger logger = new Logger("prueba");
// logger.onRecord.listen((LogRecord record) {
//   print(record);
//   if (record.object is Map)
//     print((record.object as Map)["sirp"]);
//   else
//     print("El tipo es: ${record.object.runtimeType}");
//   // print(JSON.encode(record));
// });
// logger.info("info");
// logger.warning({"sirp": "sorp"});
// // Se sobreescriben los Files
// File f = new File("/tmp/sorp.txt");
// f.writeAsString(args[0] ?? "defaultString");

// //Paths
// String normalizado = path.normalize(args.first);
// String absoluto =
//     path.normalize(path.join(getPackageRootPath(), normalizado));
// print("normalizado:\n$normalizado");
// print("absoluto:\n" + absoluto);
// if (absoluto.startsWith(getPackageRootPath()) == false) throw new Error();

// final String q;
// q = "aorq";
// print(q);
//   String str = '''{{var1}}
// {{#seccion}}
//  -{{var1}}
//  -{{var2}}
// {{/seccion}}''';
//   RegExp re = new RegExp(r"seccion}}([\S\s]*){{\/seccion}}");
//   print(re.hasMatch(str));
