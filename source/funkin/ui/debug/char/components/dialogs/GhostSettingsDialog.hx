package funkin.ui.debug.char.components.dialogs;

import haxe.ui.core.Screen;
import haxe.ui.containers.Grid;
import haxe.ui.containers.menus.Menu;
import funkin.play.character.CharacterData;
import funkin.play.character.CharacterData.CharacterDataParser;
import funkin.util.SortUtil;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/dialogs/ghost-dialog.xml"))
class GhostSettingsDialog extends DefaultPageDialog
{
  var attachedMenu:GhostCharacterMenu;

  override public function new(daPage:CharCreatorDefaultPage)
  {
    super(daPage);

    var charData = CharacterDataParser.fetchCharacterData(Constants.DEFAULT_CHARACTER);
    ghostTypeButton.icon = (charData == null ? null : CharacterDataParser.getCharPixelIconAsset(Constants.DEFAULT_CHARACTER));
    ghostTypeButton.text = (charData == null ? "None" : charData.name.length > 6 ? '${charData.name.substr(0, 6)}.' : '${charData.name}');

    // callbacks
    ghostEnable.onChange = function(_) {
      ghostDataBox.disabled = !ghostEnable.selected;
    }

    ghostCurChar.onChange = function(_) {
      ghostTypeButton.disabled = ghostCurChar.selected; // no need to check for the other one thankfully
    }

    ghostTypeButton.onClick = function(_) {
      attachedMenu = new GhostCharacterMenu(daPage, this);
      Screen.instance.addComponent(attachedMenu);
    }

    ghostAnimDropdown.onChange = function(_) {
      if (ghostAnimDropdown.selectedIndex == -1) return;
      cast(daPage, CharCreatorGameplayPage).ghostCharacter.playAnimation(ghostAnimDropdown.selectedItem.text);
    }
  }

  function releaseTheGhouls() {}
}

/**
 * Maybe it would be nice to move the character menus to it's own group at some point - this is the third state to use it.
 */
@:xml('
<menu id="iconSelector" width="410" height="185" padding="8">
  <vbox width="100%" height="100%">
    <scrollview id="ghostSelectScroll" width="390" height="150" contentWidth="100%" />
    <label id="ghostIconName" text="(choose a character)" />
  </vbox>
</menu>
')
class GhostCharacterMenu extends Menu
{
  override public function new(page:CharCreatorDefaultPage, parent:GhostSettingsDialog)
  {
    super();

    this.x = Screen.instance.currentMouseX;
    this.y = Screen.instance.currentMouseY;

    var charGrid = new Grid();
    charGrid.columns = 5;
    charGrid.width = this.width;
    ghostSelectScroll.addComponent(charGrid);

    var charIds = CharacterDataParser.listCharacterIds();
    charIds.sort(SortUtil.alphabetically);

    var defaultText:String = '(choose a character)';

    for (charIndex => charId in charIds)
    {
      var charData:CharacterData = CharacterDataParser.fetchCharacterData(charId);

      var charButton = new haxe.ui.components.Button();
      charButton.width = 70;
      charButton.height = 70;
      charButton.padding = 8;
      charButton.iconPosition = "top";

      /*if (charId == state.selectedChar.characterId)
        {
          // Scroll to the character if it is already selected.
          ghostSelectScroll.hscrollPos = Math.floor(charIndex / 5) * 80;
          charButton.selected = true;

          defaultText = '${charData.name} [${charId}]';
      }*/

      var LIMIT = 6;
      charButton.icon = CharacterDataParser.getCharPixelIconAsset(charId);
      charButton.text = charData.name.length > LIMIT ? '${charData.name.substr(0, LIMIT)}.' : '${charData.name}';

      charButton.onClick = _ ->
        {
          // kill and replace
        };

      charButton.onMouseOver = _ -> {
        ghostIconName.text = '${charData.name} [${charId}]';
      };
      charButton.onMouseOut = _ -> {
        ghostIconName.text = defaultText;
      };
      charGrid.addComponent(charButton);
    }

    ghostIconName.text = defaultText;

    this.alpha = 0;
    this.y -= 10;
    FlxTween.tween(this, {alpha: 1, y: this.y + 10}, 0.2, {ease: FlxEase.quartOut});
  }
}
