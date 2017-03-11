import "package:path/path.dart" show dirname;
import 'dart:io' show Platform;

main() {
  print(dirname(Platform.script.toString()));
}
