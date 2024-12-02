package funkin.modding;

import openfl.Lib;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.ui.FlxBar;
import flixel.FlxCamera;
import sys.FileSystem;
import sys.io.File;
import openfl.media.Sound;
import funkin.ui.MusicBeatSubState;
import funkin.ui.MusicBeatState;

using StringTools;

class WaitToError extends FlxObject
{
  var state:FlxState;

  public override function new(x:Int = 0, y:Int = 0, ?state:FlxState)
  {
    super(0, 0);
    this.state = state;
  }

  public override function update(e:Float)
  {
    super.update(e);
    FlxG.state.remove(this);
    Main.game.setState(state);
    destroy();
  }
}

class ErrorSubState extends MusicBeatSubState
{
  public var curSelected:Int = 0;
  public var music:FlxSound;
  public var perSongOffset:FlxText;
  public var offsetChanged:Bool = false;
  public var win:Bool = true;
  public var ready = false;
  public var readyTimer:Float = 0;
  public var errorMsg:String = "";
  public var lastState:FlxState;

  public static var instance:ErrorSubState;

  public static function showError(?error:String = "Unknown Error!", ?title = "Error caught!")
  {
    trace(title);
    trace(error);
    var state = FlxG.state;

    FlxG.state.add(new WaitToError(new ErrorSubState(0, 0, error, title, state)));
  }

  public function new(x:Float, y:Float, ?error:String = "", ?title = "Error caught!", ?state:FlxState, force:Bool = false)
  {
    instance = this;

    errorMsg = error;

    trace(error);
    trace('meower ${error}');

    lastState = state ?? FlxG.state;

    super();

    var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    bg.alpha = 0;
    bg.scrollFactor.set();

    var finishedText:FlxText = new FlxText(20, -55, 0, title);
    finishedText.size = 32;
    finishedText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
    finishedText.color = FlxColor.RED;
    finishedText.scrollFactor.set();
    finishedText.screenCenter(X);

    var errText:FlxText = new FlxText(20, 150, 0, 'Error Message:\n${errorMsg}');
    errText.size = 20;
    errText.wordWrap = true;
    errText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
    errText.color = FlxColor.WHITE;
    errText.scrollFactor.set();
    errText.fieldWidth = FlxG.width - errText.x;
    errText.screenCenter(X);

    var _errText_X = errText.x;

    errText.x = FlxG.width;

    contText = new FlxText(FlxG.width * 0.5, FlxG.height + 100, 0,
      #if android 'Tap the left of the screen to return to the main menu or the right of the screen to reload' #else 'Press Escape to return to the menu, enter to ignore, or R to reload the state' #end);
    contText.size = 24;
    contText.screenCenter(X);
    contText.alpha = 0.3;
    contText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);

    var reportText = new FlxText(0, FlxG.height - 180, 0, 'Please report this to the developer of the script listed above.');
    reportText.size = 24;
    reportText.screenCenter(X);

    var rep_x = reportText.x;

    reportText.x = FlxG.width;
    reportText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);

    contText.color = FlxColor.WHITE;
    contText.scrollFactor.set();

    bg.alpha = 0.6;

    finishedText.y = 20;
    errText.x = _errText_X;
    contText.y = FlxG.height - 90;
    reportText.x = rep_x;

    add(bg);
    add(finishedText);
    add(errText);
    add(contText);
    add(reportText);
  }

  public var cam:FlxCamera;

  var optionsisyes:Bool = false;
  var shownResults:Bool = false;

  public var contText:FlxText;

  var shouldveLeft = false;

  function retMenu()
  {
    Main.game.forceStateSwitch(new funkin.ui.mainmenu.MainMenuState());

    shouldveLeft = true;

    return;
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    if (FlxG.keys.pressed.ESCAPE) retMenu();

    if (ready)
    {
      if (controls.ACCEPT || controls.PAUSE || FlxG.keys.justPressed.ENTER)
      {
        Main.game.setState(lastState);
        destroy();
        // close();
      }

      if (FlxG.keys.justPressed.ESCAPE) retMenu();

      #if android
      if (FlxG.mouse.justPressed)
      {
        trace(FlxG.mouse.screenX / FlxG.width);
        if ((FlxG.mouse.screenX / FlxG.width) <= .5) retMenu();
        else
        {
          Main.game.setState(lastState);
          FlxG.resetState();
        }
      }
      #end

      if (FlxG.keys.justPressed.R)
      {
        Main.game.setState(lastState);
        FlxG.resetState();
      }
    }
    else
    {
      if (readyTimer > 2) ready = true;

      readyTimer += elapsed;
      contText.alpha = readyTimer - 1;
    }
  }

  override function draw()
  {
    super.draw();
  }

  function restart()
  {
    ready = false;

    FlxG.resetState();

    if (shouldveLeft) // Error if the state hasn't changed and the user pressed r already
    {
      throw("FUCK I GOT SOFTLOCKED, DO A STRAIGHT CRASH");
    }

    shouldveLeft = true;
  }

  override function destroy()
  {
    super.destroy();
  }
}
