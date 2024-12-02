package funkin.ui.title;

import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.ui.MusicBeatState;
import funkin.graphics.FunkinSprite;
import lime.app.Application;

class FirstTimeState extends MusicBeatState
{
  public static var leftState:Bool = false;

  override function create()
  {
    super.create();

    var bg:FunkinSprite = new FunkinSprite().makeSolidColor(FlxG.width, FlxG.height, FlxColor.BLACK);
    add(bg);

    var txt:FlxText = new FlxText(0, 0, FlxG.width,
      "HEY! This mod is currently in a WIP state! Some things may be \nunfinished for now, watch out for some bugs & glitches!\nNow with that out of the way, I hope you'll enjoy this Funkin' mod, funk all the way!\nPress ESCAPE or ENTER to proceed.",
      26);
    txt.setFormat(Paths.font("arial.ttf"), 32, FlxColor.WHITE, CENTER);
    txt.screenCenter();
    add(txt);
  }

  override function update(elapsed:Float)
  {
    if (controls.ACCEPT || controls.BACK)
    {
      funkin.save.Save.instance.firstTime = false;
      leftState = true;
      FlxG.switchState(() -> new funkin.ui.mainmenu.MainMenuState());
    }
    super.update(elapsed);
  }
}
