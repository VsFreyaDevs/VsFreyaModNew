package funkin.ui.debug;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;

/**
  Based off on the `openfl.display.FPS` class.

  Part of this is taken from Psych/Nightmare Vision, lol.
**/
class MemoryCounter extends TextField
{
  /**
    The current frame rate, expressed using frames-per-second.
  **/
  public var currentFPS(default, null):Int;

  /**
    The current usage of RAM/memory. (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
  **/
  #if html5 public var memoryMegas(get, never):Float; #end

  @:noCompletion private var times:Array<Float>;

  public static var showFPS:Bool = false;
  #if html5 public static var showRAM:Bool = true; #end

  public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
  {
    super();

    this.x = x;
    this.y = y;

    currentFPS = 0;
    selectable = mouseEnabled = false;
    defaultTextFormat = new TextFormat(_sans, 12, color);
    autoSize = LEFT;
    multiline = true;
    text = "";

    times = [];
  }

  var deltaTimeout:Float = 0.0;

  private override function __enterFrame(deltaTime:Float):Void
  {
    if (!visible) return;

    // prevents the overlay from updating every frame, why would you need to anyways @crowplexus
    if (deltaTimeout < 1000)
    {
      deltaTimeout += deltaTime;
      return;
    }

    final now:Float = haxe.Timer.stamp() * 1000;
    times.push(now);
    while (times[0] < now - 1000)
      times.shift();

    currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
    updateText();
    deltaTimeout = 0.0;
  }

  public dynamic function updateText():Void // so people can override it in hscript
  {
    if (showFPS) text = 'FPS: $currentFPS ';
    #if !html5 (showRAM) text += 'RAM: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}'; #end
    textColor = 0xFFFFFFFF;
    if (currentFPS < FlxG.drawFramerate * 0.5) textColor = 0xFFFF0000;
  }

  #if html5
  inline function get_memoryMegas():Float
    return cast(System.totalMemory, UInt);
  #end
}
