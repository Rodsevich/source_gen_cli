/// The base class from where the generation will took place. This is the
/// backbone of the generation and is the starting point from where new
/// [Generator]s shall start.
abstract class Generator {
  /// Define the dependencies this generator needs in order to work properly,
  /// they will be automatically included or updated in the local 'pubspec.yaml'
  Set<Dependency> get dependencies;
}
