import 'dart:convert';
import 'dart:developer';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/resolution_map.dart' show ResolutionMap;
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/generated/java_core.dart';
import 'package:source_gen/src/annotation.dart';

class MetadataCrawler extends GeneralizingAstVisitor {
  CompilationUnit source;
  List<AnnotatedNode> annotatedNodes = [];

  MetadataCrawler(this.source) {
    visitCompilationUnit(this.source);
  }

  @override
  visitAnnotatedNode(AnnotatedNode node) {
    if (node.metadata.isNotEmpty) this.annotatedNodes.add(node);
    super.visitAnnotatedNode(node);
  }
}

main(args) {
  // RecursiveAstVisitor visitor = new RecursiveAstVisitor();
  CompilationUnit codigo =
      parseDartFile("/home/nico/src/source_gen_cli/tool/codigo_prueba.dart");
  MetadataCrawler crawler = new MetadataCrawler(codigo);
  TopLevelVariableDeclaration declaration = crawler.annotatedNodes.single;
  Annotation annon = declaration.metadata.single;
  // ElementAnnotation elementAnnotation = annon.element;
  TopLevelVariableElement elem = declaration.element;
  // ConstantEvaluator constantEvaluator = new ConstantEvaluator();
  // ElementLocator_ElementMapper mapper = new ElementLocator_ElementMapper();
  var w = codigo.declarations;
  // var vars = w[0].variables;
  // var elems = mapper.visitCompilationUnit(codigo);
  debugger();
  // var s = constantEvaluator.visitCompilationUnit(codigo);
  // print(s.runtimeType.toString());
  // print(ConstantEvaluator.NOT_A_CONSTANT.toString());
  // print(s is ConstantEvaluator.NOT_A_CONSTANT);
  // if (s.runtimeType != ConstantEvaluator.NOT_A_CONSTANT) {
  //   String t = JSON.encode(s);
  //   print(t);
  // }
  // var q = visitor.visitTopLevelVariableDeclaration(w[0]);
  // PrintWriter printWriter = new PrintStringWriter();
  // ToSourceVisitor tsVisitor = new ToSourceVisitor(printWriter);
  // tsVisitor.visitExpressionStatement(w[0]);
  // debugger();
  // print(printWriter.toString());
}
