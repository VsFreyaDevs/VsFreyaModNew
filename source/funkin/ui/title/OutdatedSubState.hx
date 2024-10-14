package funkin.ui.title;

import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.ui.MusicBeatState;
import funkin.graphics.FunkinSprite;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
  public static var leftState:Bool = false;

  override function create()
  {
    super.create();

    var bg:FunkinSprite = new FunkinSprite().makeSolidColor(FlxG.width, FlxG.height, FlxColor.BLACK);
    add(bg);

    var txt:FlxText = new FlxText(0, 0, FlxG.width,
      "HEY! This mod is currently work in progress! \nSome things may be unfinished for now, \nand yeah, beware of some bugs & glitches that will be \nfixed in the future.\nPress SPACE or ESCAPE to continue.",
      32);
    txt.setFormat("Arial", 32, FlxColor.WHITE, CENTER);
    txt.screenCenter();
    add(txt);
  }

  override function update(elapsed:Float)
  {
    if (controls.ACCEPT || controls.BACK)
    {
      leftState = true;
      FlxG.switchState(() -> new funkin.ui.mainmenu.MainMenuState());
    }
    super.update(elapsed);
  }
}
