import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:logging/logging.dart';
import "package:path/path.dart" as path;
import '../lib/src/common.dart';
import 'package:source_gen/src/annotation.dart';
import "../lib/src/generation/fileProcessorAnnotations/base.dart";

main(args) {
  return asignarConTokens();
  // return pruebaMaps();
  // return checkearInstantiacionAnotacion();
  // return procesadorDeArgs();
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
  TypeName type;
  VariableDeclaration variableDeclaration;
  if (annotatedNode is TopLevelVariableDeclaration) {
    type = annotatedNode.variables.type;
    try {
      variableDeclaration = annotatedNode.variables.variables.single;
    } catch (e) {
      err("@generationAssignment must be used in a single variable declaration",
          logger);
    }
  } else
    err("@generationAssignment must only annotate variables ($location)",
        logger);
  SimpleIdentifier name = variableDeclaration.name;
  Token equalSign = variableDeclaration.equals;
  Expression expression = variableDeclaration.initializer;
  String variableStr = "$type $name $equalSign", assignmentStr = "$expression";
  logger.finest("processing the line numbers of the assignment...");
  int varLN = lineNumber + 1;
  while (!input[varLN].trimLeft().startsWith(variableStr)) varLN++;
  int assigLN = varLN;
  if (equalSign != null) {
    int offset = type?.beginToken.offset ?? name.beginToken.offset;
    int currentCount = offset + input[varLN].length;
    int llegar = expression.endToken.next.offset;
    try {
      while (currentCount < expression.endToken.next.offset)
        currentCount += input[++assigLN].length;
    } on RangeError catch (e) {
      if ((e.invalidValue - 1) != e.end)
        throw new Exception("Impossible error happened. don't know what to do");
      if (input[e.end].contains(
          new RegExp("${expression.endToken} ?${expression.endToken.next}")))
        assigLN = e.end;
      else
        throw new Exception("Couldn't find end of expression line Number");
    }
  }
  logger.finest("processing the assignment...");
}

// pruebaMaps() {
//   Map sorp = {};
//   print(null);
//   print(sorp["nulo"]);
// }

// procesadorDeArgs() {
//   String source = "(1,'dos',#tres)";
//   String funcSrc = "var q = a$source;";
//   CompilationUnit c = parseCompilationUnit(funcSrc);
//   var t = c.declarations.single as TopLevelVariableDeclaration;
//   VariableDeclaration de = t.childEntities.first.variables.first;
//   Expression expression = de.initializer;
//   ArgumentList args = (expression as MethodInvocation).argumentList;
//   exit(0);
// }

// class Clazz {
//   int number;
//   Clazz(this.number);
// }
//
// checkClassInstantiation() {
//   var reflec = reflectClass(Clazz);
//   Clazz instance = reflec.newInstance(new Symbol(''), [1]).reflectee;
//   assert(instance.number == 1);
// }

// checkearInstantiacionAnotacion() {
//   Type clase = GenerationAssignment;
//   var reflejador = reflectClass(clase);
//   GenerationAssignment instancia =
//       reflejador.newInstance(new Symbol(''), []).reflectee;
//   assert(instancia.generatorIdentifier == "sorp");
// }

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
