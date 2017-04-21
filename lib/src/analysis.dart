import 'dart:mirrors';
import 'package:analyzer/analyzer.dart';

class _ArgumentsResolver extends ConstantEvaluator {
  NamedExpression visitNamedExpression(NamedExpression node) {
    node.setProperty("resolution", node.expression.accept(this));
    return node;
  }
}

class ArgumentsResolution {
  List positional = [];
  Map named = {};
  ArgumentsResolution.fromArgumentList(ArgumentList list) {
    _processArgs(list);
  }
  ArgumentsResolution.fromSourceConstants(String source) {
    String funcSrc = "var q = a$source;";
    CompilationUnit c = parseCompilationUnit(funcSrc);
    var t = c.declarations.single as TopLevelVariableDeclaration;
    VariableDeclaration de = t.childEntities.first.variables.first;
    Expression expression = de.initializer;
    ArgumentList args = (expression as MethodInvocation).argumentList;
  }
  _processArgs(ArgumentList list) {
    _ArgumentsResolver resolver = new _ArgumentsResolver();
    for (AstNode arg in list.arguments) {
      var val = arg.accept(resolver);
      if (val is NamedExpression)
        named[new Symbol(val.name.label.token.value())] =
            val.getProperty("resolution");
      else
        positional.add(val);
    }
  }
}

dynamic instanceFromAnnotation(Type annotationType, Annotation annotation) =>
    instantiate(annotationType, annotation.constructorName ?? '',
        new ArgumentsResolution.fromArgumentList(annotation.arguments));

dynamic instantiate(Type type, constructorName, ArgumentsResolution arguments) {
  ClassMirror annotationMirror = reflectClass(type);
  return annotationMirror
      .newInstance(
          (constructorName is Symbol)
              ? constructorName
              : new Symbol(constructorName),
          arguments.positional,
          arguments.named)
      .reflectee;
}
