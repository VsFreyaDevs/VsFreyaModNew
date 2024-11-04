package funkin.ui.debug.char.components.wizard;

import haxe.ui.components.Label;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/wizard/confirm-wizard.xml"))
class ConfirmDialog extends DefaultWizardDialog
{
  override public function new()
  {
    super(CONFIRM);
  }

  override public function showDialog(modal:Bool = true)
  {
    super.showDialog(modal);

    while (viewAllAssets.childComponents.length > 0)
      viewAllAssets.removeComponent(viewAllAssets.childComponents[0]);

    for (file in params.files)
    {
      var fname = new Label();
      fname.text = file.name;
      fname.percentWidth = 100;
      viewAllAssets.addComponent(fname);
    }
  }

  override public function isNextStepAvailable()
    return true;
}
