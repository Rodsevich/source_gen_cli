part of interactions.backbone;

abstract class ConfirmationInteraction extends Interaction<bool> {
  ConfirmationInteraction(IOInterface ioInterface, String message)
      : super(ioInterface, message);
}
