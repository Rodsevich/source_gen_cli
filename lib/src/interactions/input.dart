part of interactions.backbone;

abstract class InputInteraction extends Interaction<String> {
  RegExp checkRegExp;
  InputInteraction(IOInterface ioInterface, String message, String checkRegExp)
      : super(ioInterface, message) {
    this.checkRegExp = new RegExp(checkRegExp);
  }
}
