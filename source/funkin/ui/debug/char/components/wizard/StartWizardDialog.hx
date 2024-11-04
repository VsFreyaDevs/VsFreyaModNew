package funkin.ui.debug.char.components.wizard;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/wizard/start-dialog.xml"))
class StartWizardDialog extends DefaultWizardDialog
{
  override public function new()
  {
    super(STARTUP, true);

    startupCheckChar.onChange = function(_) params.generateCharacter = startupCheckChar.selected;
    startupCheckData.onChange = function(_) params.generatePlayerData = startupCheckData.selected;
    startupFieldID.onChange = function(_) params.characterID = startupFieldID.text;
  }

  override public function isNextStepAvailable()
  {
    return ((params.generateCharacter || params.generatePlayerData) && params.characterID != "");
  }

  override public function showDialog(modal:Bool = true)
  {
    super.showDialog(modal);

    startupCheckChar.selected = params.generateCharacter;
    startupCheckData.selected = params.generatePlayerData;
  }
}
