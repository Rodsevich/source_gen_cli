import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:analyzer/dart/element/element.dart';
import 'package:logging/logging.dart';
import 'package:analyzer/analyzer.dart';
import "package:path/path.dart" as path;
import '../lib/src/common.dart';
import 'package:source_gen/src/annotation.dart';
import "../lib/src/generation/fileProcessorAnnotations/base.dart" as fpa;
import 'dart:mirrors';

main(args) {
  return procesadorDeMetadatos();
}

procesadorDeMetadatos() {
  File f = new File(getPackageRootPath() + "tool/codigo_prueba.dart");
  // CompilationUnit parse = parseCompilationUnit(f.readAsStringSync());
  // List<CompilationUnitMember> declaraciones = parse.declarations.toList();
  // List<Directive> directivas = parse.directives.toList();
  // ClassDeclaration abstracta = declaraciones[0];
  // ClassDeclaration metada = declaraciones[1];
  // FunctionDeclaration main = declaraciones[2];
  // VariableDeclarationStatement lista = main.functionExpression.
  List<String> lines = f.readAsLinesSync();
  lines.insert(0, null); // Change 0-index to 1-indexed string
  Set<String> anotacionesMatcher = new Set.from(fpa.generationAnnotations.keys);
  String matchOptions = anotacionesMatcher.join('|');
  RegExp annotationsMatcher = new RegExp("@($matchOptions)" + r"(\(.*?\))?");
  for (int lineNum = 1; lineNum < lines.length; lineNum++) {
    String line = lines[lineNum];
    Match match = annotationsMatcher.firstMatch(line);
    if (match != null) {
      String args, name = match.group(1);
      try {
        args = match.group(2);
        args = args.substring(1, args.length - 1);
      } catch (e) {
        args = null;
      }
      print("line $lineNum: $name" + ((args == null) ? '' : '($args)'));
      fpa.GenerationAnnotation ga = parseGenerationAnnotation(lines, lineNum);
    }
  }
  exit(0);
}

fpa.GenerationAnnotation parseGenerationAnnotation(
    List<String> lines, int lineNum) {
  if (lines[lineNum].trim().startsWith('/')) return null;
  int tries = 1;
  while (true) {
    String s = lines.sublist(lineNum, lineNum + tries).join('\n');
    try {
      CompilationUnit c = parseCompilationUnit(s);
      AnnotatedNode node = c.declarations.first ?? null;
      Annotation annotation = node.metadata
          .firstWhere((Annotation a) => lines[lineNum].contains(a.name.name));
      if (annotation != null) {
        ClassMirror annotationMirror = reflectClass(
            fpa.generationAnnotations[annotation.name.name].annotation);
        Symbol ctor = const Symbol(""); //annotation.constructorName ?? '');
        List pos = [];
        Map named = {};
        //CONSEGUIR LO NECESARIO PARA INSTANCIAR LA ANOTACION
        var q = annotation.arguments;
        var qq = q.correspondingStaticParameters;
        var qw = q.correspondingPropagatedParameters;
        var w = q.arguments;
        // for (Expression param in annotation.arguments.arguments) {
        //   if (param is Literal) {
        //     pos.add(param?.value ?? null);
        //   } else {
        //     named[param.name.label.token.toString()] =
        //         param.expression.elements;
        //     debugger();
        //     print(param.runtimeType);
        //   }
        // }
        fpa.GenerationAnnotation annotationInstance =
            annotationMirror.newInstance(ctor, pos, named);
      }
      debugger();
      return null;
    } on AnalyzerErrorGroup catch (e) {
      if (tries < 10)
        tries++;
      else {
        print(s);
        rethrow;
      }
    }
  }
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
