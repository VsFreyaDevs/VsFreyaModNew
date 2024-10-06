package funkin;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.events.Event;

class FunkinGame extends FlxGame
{
  public function new(gameWidth:Int = 0, gameHeight:Int = 0, ?initialState:Class<FlxState>, updateFramerate:Int = 60, drawFramerate:Int = 60,
      skipSplash:Bool = false, startFullscreen:Bool = false)
  {
    super(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen);
  }

  override function create(_:Event)
  {
    super.create(_);

    FlxG.stage.quality = LOW;
  }
}
