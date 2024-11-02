package funkin.ui.debug;

import flixel.FlxG;
import flixel.math.FlxMath;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.Font;
import openfl.text.TextFormatAlign;
import funkin.util.MemoryUtil;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

/**
  Based off on the `openfl.display.FPS` class.
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class MemoryCounter extends TextField
{
  /**
    The current frame-rate, expressed using frames-per-second (FPS).
  **/
  public var currentFPS(default, null):Int;

  /**
    The current usage of RAM/memory. (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
  **/
  #if !html5 public var memoryMegas(get, never):Float; #end

  @:noCompletion private var cacheCount:Int;
  @:noCompletion private var currentTime:Float;
  var memPeak:Float = 0;
  @:noCompletion private var times:Array<Float>;

  public var currentState(default, null):String = "";

  public static var showFPS:Bool = true;
  public static var showMiscText:Bool = true;
  public static var showSongText:Bool = true;
  #if !html5 public static var showRAM:Bool = true; #end

  public var align(default, set):TextFormatAlign;

  function set_align(val)
  {
    return align = defaultTextFormat.align = switch (val)
    {
      default:
        this.x = 10;
        autoSize = LEFT;
        LEFT;
      case CENTER:
        this.x = (this.stage.stageWidth - this.textWidth) * 0.5;
        autoSize = CENTER;
        CENTER;
      case RIGHT:
        this.x = (this.stage.stageWidth - this.textWidth) - 10;
        autoSize = RIGHT;
        RIGHT;
    }
  }

  function onGameResized(windowWidth, ?windowHeight)
    align = align;

  static final BYTES_PER_MEG:Float = 1024 * 1024;
  static final ROUND_TO:Float = 1 / 100;

  public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
  {
    super();

    this.x = x;
    this.y = y;

    currentFPS = 0;
    selectable = mouseEnabled = false;
    defaultTextFormat = new TextFormat("_sans", 12, color);
    autoSize = LEFT;
    multiline = true;
    text = "";
    width += 200;

    cacheCount = 0;
    currentTime = 0;
    times = [];

    #if flash
    addEventListener(Event.ENTER_FRAME, (e) -> {
      var time = Lib.getTimer();
      __enterFrame(time - currentTime);
    });
    #end

    addEventListener(Event.ADDED_TO_STAGE, (e:Event) -> {
      if (align == null) align = #if mobile CENTER #else LEFT #end;
    });

    addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e) -> {
      if (e.keyCode == flixel.input.keyboard.FlxKey.F3) this.align = switch (this.align)
      {
        case LEFT: CENTER;
        case CENTER: RIGHT;
        case RIGHT: LEFT;
        default: LEFT;
      }
    });

    FlxG.signals.gameResized.add(onGameResized);

    FlxG.signals.preStateCreate.add((nextState) -> currentState = Type.getClassName(Type.getClass(nextState)));
  }

  @:noCompletion
  private #if !flash override #end function __enterFrame(deltaTime:Float):Void
  {
    if (!visible) return;

    currentTime += deltaTime;
    times.push(currentTime);

    while (times[0] < currentTime - 1000)
      times.shift();

    var currentCount = times.length;
    currentFPS = Math.round((currentCount + cacheCount) / 2);

    // var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
    var mem:Float = Math.fround(MemoryUtil.getMemoryUsed() / BYTES_PER_MEG / ROUND_TO) * ROUND_TO;
    if (mem > memPeak) memPeak = mem;

    if (currentCount != cacheCount)
    {
      if (showFPS) text = "FPS: " + currentFPS;
      #if !html5
      if (showRAM)
      {
        if (memPeak != mem) text += ' • RAM: ${mem}mb / ${memPeak}mb';
        else
          text += ' • RAM: ${mem}mb';
      }
      #end
      if (showMiscText)
      {
        text += '\nSTATE: $currentState';
        if (FlxG.state.subState != null) text += ' • SUBSTATE: ${Type.getClassName(Type.getClass(FlxG.state.subState))}';
        text += '\nOBJ: ${FlxG.state.members.length} • CAM: ${FlxG.cameras.list.length}';
      }

      if (showSongText) text += '\nSONG POS: ${Conductor.instance.frameSongPosition} • ${Conductor.instance.bpm} BPM';

      if (currentFPS <= FlxG.drawFramerate * 0.5) textColor = 0xFFFF0000;
      else
        textColor = 0xFFFFFFFF;

      #if (gl_stats && !disable_cffi && (!html5 || !canvas))
      if (showFPS)
      {
        text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
        text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
        text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
      }
      #end
    }

    cacheCount = currentCount;

    // prevents the overlay from updating every frame, why would you need to anyways @crowplexus
    /*
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
     */
  }

  #if !html5
  inline function get_memoryMegas():Float
    return cast(System.totalMemory, UInt);
  #end
}
