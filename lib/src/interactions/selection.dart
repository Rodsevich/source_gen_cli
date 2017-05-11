part of interactions.backbone;

abstract class SelectionInteraction extends Interaction<String> {
  List<String> options;
  SelectionInteraction(IOInterface ioInterface, String message, this.options)
      : super(ioInterface, message);
}
