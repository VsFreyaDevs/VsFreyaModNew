package funkin.ui.debug.char.components.wizard;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/wizard/sprite-support.xml"))
class RenderWizardDialog extends DefaultWizardDialog
{
  override public function new()
  {
    super(SELECT_CHAR_TYPE);

    renderOptionSparrow.onChange = function(_) params.renderType = "sparrow";
    renderOptionPacker.onChange = function(_) params.renderType = "packer";
    renderOptionAtlas.onChange = function(_) params.renderType = "atlas";
    renderOptionMulti.onChange = function(_) params.renderType = "multisparrow";
  }

  override public function showDialog(modal:Bool = true)
  {
    super.showDialog(modal);
    renderOptionSparrow.disabled = renderOptionPacker.disabled = renderOptionAtlas.disabled = renderOptionMulti.disabled = !params.generateCharacter;

    renderOptionSparrow.selected = params.renderType == "sparrow";
    renderOptionPacker.selected = params.renderType == "packer";
    renderOptionAtlas.selected = params.renderType == "atlas";
    renderOptionMulti.selected = params.renderType == "multisparrow";
  }

  override public function isNextStepAvailable()
    return true;
}
