part of interactions.backbone;

abstract class ConfirmationInteraction extends Interaction<bool> {
  bool defaultValue;
  ConfirmationInteraction(
      IOInterface ioInterface, String message, this.defaultValue)
      : super(ioInterface, message);
}
