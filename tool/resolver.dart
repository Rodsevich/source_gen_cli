import 'dart:developer';
import 'dart:io';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:resolver/resolver.dart';
import 'package:source_gen_cli/src/common.dart';
import 'package:source_gen/src/annotation.dart';
import 'pruebas.dart';

class AnnotationCrawler extends GeneralizingElementVisitor {
  final LibraryElement library;
  Set<Element> _annotatedElements = new Set();

  Set<Element> get annotatedElements => _annotatedElements;

  AnnotationCrawler(LibraryElement lib) : this.library = lib {
    library.accept(this);
  }

  @override
  visitElement(Element node) {
    if (node.metadata.isNotEmpty) _annotatedElements.add(node);
    super.visitElement(node);
  }
}

class ResolvedElement {
  final List annotationInstances;
  final Element element;
  ResolvedElement(this.element, this.annotationInstances);
}

main(args) async {
  Resolver resolver = new Resolver.forPackage('.', analyzeFunctionBodies: true);
  LibraryElement lib = await resolver.resolveSourceCode(
      new File("./tool/codigo_prueba.dart").readAsStringSync());
  AnnotationCrawler annotationCrawler = new AnnotationCrawler(lib);
  List<ResolvedElement> elems = [];
  annotationCrawler.annotatedElements.forEach((Element elem) {
    List<GenerationAnnotation> annons = [];
    elem.metadata
        // .where((ElementAnnotation a) => a is GenerationAnnotation)
        .forEach((ElementAnnotation annotation) {
      var instance = instantiateAnnotation(annotation);
      if (instance is GenerationAnnotation) annons.add(instance);
    });
    elems.add(new ResolvedElement(elem, annons));
  });
  print(elems.length);
  // AggregateTransformController controller =
  //     new AggregateTransformController(null);
  // Transform t = await newTransform(controller.transform);
  // PhysicalResourceProvider resourceProvider = PhysicalResourceProvider.INSTANCE;
  // DartSdk sdk = new FolderBasedDartSdk(
  //     resourceProvider, resourceProvider.getFolder("/opt/dart-sdk/"));
  // ResolverImpl resolver = new ResolverImpl(sdk, new DartUriResolver(sdk));
  // resolver.resolve(t, ['tool/codigo_prueba.dart']);
  // AssetId assetId =
  //     new AssetId(getThisPackageName(), 'tool/codigo_prueba.dart');
  // Asset asset =
  //     new Asset.fromFile(assetId, new File('./tool/codigo_prueba.dart'));
  // LibraryElement library = resolver.getLibrary(assetId);
  // debugger();
}
