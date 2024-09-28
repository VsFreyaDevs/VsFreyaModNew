package funkin;

import funkin.save.Save;

/**
 * A core class which provides a store of user-configurable, globally relevant values.
 */
class Preferences
{
  /*
   * If enabled, makes the graphics look sharper, however it can reduce performance.
   * @default `true`
   */
  public static var antialiasing(get, set):Bool;

  static function get_antialiasing():Bool
  {
    return Save?.instance?.options?.antialiasing;
  }

  static function set_antialiasing(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.antialiasing = value;
    save.flush();
    return value;
  }

  /**
   * Whenever to display a splash animation when perfectly hitting a note.
   * @default `true`
   */
  public static var noteSplash(get, set):Bool;

  static function get_noteSplash():Bool
  {
    return Save?.instance?.options?.noteSplash;
  }

  static function set_noteSplash(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.noteSplash = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, hides the opponent notes and puts the player strums to the middle.
   * @default `false`
   */
  public static var middlescroll(get, set):Bool;

  static function get_middlescroll():Bool
  {
    return Save?.instance?.options?.middlescroll;
  }

  static function set_middlescroll(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.middlescroll = value;
    save.flush();
    return value;
  }

  /**
   * The cap of your framerate, self-explanatory.
   * @default `60`
   */
  public static var framerate(get, set):Int;

  static function get_framerate():Int
  {
    #if (web || CHEEMS)
    return 60;
    #else
    return Save?.instance?.options?.framerate ?? 60;
    #end
  }

  static function set_framerate(value:Int):Int
  {
    #if (web || CHEEMS)
    return 60;
    #else
    var save:Save = Save.instance;
    save.options.framerate = value;
    save.flush();
    FlxG.updateFramerate = value;
    FlxG.drawFramerate = value;
    return value;
    #end
  }

  /**
   * Whether some particularly fowl language is displayed.
   * @default `true`
   */
  public static var naughtyness(get, set):Bool;

  static function get_naughtyness():Bool
  {
    return Save?.instance?.options?.naughtyness;
  }

  static function set_naughtyness(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.naughtyness = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the strumline is at the bottom of the screen rather than the top.
   * @default `false`
   */
  public static var downscroll(get, set):Bool;

  static function get_downscroll():Bool
  {
    return Save?.instance?.options?.downscroll;
  }

  static function set_downscroll(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.downscroll = value;
    save.flush();
    return value;
  }

  #if FEATURE_GHOST_TAPPING
  /**
   * If enabled, the player will be allowed to press their note controls without any penalty.
   * @default `true`
   */
  public static var ghostTapping(get, set):Bool;

  static function get_ghostTapping():Bool
  {
    return Save?.instance?.options?.ghostTapping ?? true;
  }

  static function set_ghostTapping(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.ghostTapping = value;
    save.flush();
    return value;
  }
  #end

  /**
   * If disabled, flashing lights in the main menu and other areas will be less intense.
   * @default `true`
   */
  public static var flashingLights(get, set):Bool;

  static function get_flashingLights():Bool
  {
    return Save?.instance?.options?.flashingLights ?? true;
  }

  static function set_flashingLights(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.flashingLights = value;
    save.flush();
    return value;
  }

  /**
   * If disabled, the camera bump won't synchronize to the beat.
   * @default `false`
   */
  public static var zoomCamera(get, set):Bool;

  static function get_zoomCamera():Bool
  {
    return Save?.instance?.options?.zoomCamera;
  }

  static function set_zoomCamera(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.zoomCamera = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, an FPS and memory counter will be displayed even if this is not a debug build.
   * @default `false`
   */
  public static var debugDisplay(get, set):Bool;

  static function get_debugDisplay():Bool
  {
    return Save?.instance?.options?.debugDisplay;
  }

  static function set_debugDisplay(value:Bool):Bool
  {
    if (value != Save.instance.options.debugDisplay)
    {
      toggleDebugDisplay(value);
    }

    var save = Save.instance;
    save.options.debugDisplay = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the game will automatically pause when tabbing out.
   * @default `true`
   */
  public static var autoPause(get, set):Bool;

  static function get_autoPause():Bool
  {
    return Save?.instance?.options?.autoPause ?? true;
  }

  static function set_autoPause(value:Bool):Bool
  {
    if (value != Save.instance.options.autoPause) FlxG.autoPause = value;

    var save:Save = Save.instance;
    save.options.autoPause = value;
    save.flush();
    return value;
  }

  public static var unlockedFramerate(get, set):Bool;

  static function get_unlockedFramerate():Bool
  {
    return Save?.instance?.options?.unlockedFramerate;
  }

  static function set_unlockedFramerate(value:Bool):Bool
  {
    if (value != Save.instance.options.unlockedFramerate)
    {
      #if web
      toggleFramerateCap(value);
      #end
    }

    var save:Save = Save.instance;
    save.options.unlockedFramerate = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, bads and shits will count as combo breaks.
   * @default `true`
   */
  public static var badsShitsCauseMiss(get, set):Bool;

  static function get_badsShitsCauseMiss():Bool
  {
    return Save?.instance?.options?.badsShitsCauseMiss ?? true;
  }

  static function set_badsShitsCauseMiss(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.badsShitsCauseMiss = value;
    save.flush();
    return value;
  }

  /**
   * How transparent should the black underlay be under the lanes?
   *
   * 0 = fully transparent, 100 = opaque.
   * @default `0`
   */
  public static var laneAlpha(get, set):Int;

  static function get_laneAlpha():Int
  {
    return Save?.instance?.options?.laneAlpha ?? 0;
  }

  static function set_laneAlpha(value:Int):Int
  {
    var save:Save = Save.instance;
    save.options.laneAlpha = value;
    save.flush();
    return value;
  }

  #if web
  // We create a haxe version of this just for readability.
  // We use these to override `window.requestAnimationFrame` in Javascript to uncap the framerate / "animation" request rate
  // Javascript is crazy since u can just do stuff like that lol

  public static function unlockedFramerateFunction(callback, element)
  {
    var currTime = Date.now().getTime();
    var timeToCall = 0;
    var id = js.Browser.window.setTimeout(function() {
      callback(currTime + timeToCall);
    }, timeToCall);
    return id;
  }

  // Lime already implements their own little framerate cap, so we can just use that
  // This also gets set in the init function in Main.hx, since we need to definitely override it
  public static var lockedFramerateFunction = untyped js.Syntax.code("window.requestAnimationFrame");
  #end

  /**
   * Loads the user's preferences from the save data and apply them.
   */
  public static function init():Void
  {
    // Apply the autoPause setting (enables automatic pausing on focus lost).
    FlxG.autoPause = Preferences.autoPause;
    FlxSprite.defaultAntialiasing = Preferences.antialiasing;
    // Apply the debugDisplay setting (enables the FPS and RAM display).
    toggleDebugDisplay(Preferences.debugDisplay);
    #if web
    toggleFramerateCap(Preferences.unlockedFramerate);
    #end
    #if mobile
    // Apply the allowScreenTimeout setting (enables screen timeout).
    lime.system.System.allowScreenTimeout = Preferences.screenTimeout;
    #end
  }

  static function toggleFramerateCap(unlocked:Bool):Void
  {
    #if web
    var framerateFunction = unlocked ? unlockedFramerateFunction : lockedFramerateFunction;
    untyped js.Syntax.code("window.requestAnimationFrame = framerateFunction;");
    #end
  }

  static function toggleDebugDisplay(show:Bool):Void
  {
    if (show)
    {
      // Enable the debug display.
      #if mobile
      FlxG.game.addChild(Main.fpsCounter);
      #else
      FlxG.stage.addChild(Main.fpsCounter);
      #end

      #if !html5
      #if mobile
      FlxG.game.addChild(Main.memoryCounter);
      #else
      FlxG.stage.addChild(Main.memoryCounter);
      #end
      #end
    }
    else
    {
      // Disable the debug display.
      #if mobile
      FlxG.game.removeChild(Main.fpsCounter);
      #else
      FlxG.stage.removeChild(Main.fpsCounter);
      #end

      #if !html5
      #if mobile
      FlxG.game.removeChild(Main.memoryCounter);
      #else
      FlxG.stage.removeChild(Main.memoryCounter);
      #end
      #end
    }
  }

  #if mobile
  /**
   * If enabled, device will be able to sleep on its own.
   * @default `false`
   */
  public static var screenTimeout(get, set):Bool;

  static function get_screenTimeout():Bool
  {
    return Save?.instance?.mobileOptions?.screenTimeout ?? false;
  }

  static function set_screenTimeout(value:Bool):Bool
  {
    if (value != Save.instance.mobileOptions.screenTimeout) lime.system.System.allowScreenTimeout = value;

    var save:Save = Save.instance;
    save.mobileOptions.screenTimeout = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, vibration will be enabled.
   * @default `true`
   */
  public static var vibration(get, set):Bool;

  static function get_vibration():Bool
  {
    return Save?.instance?.mobileOptions?.vibration ?? true;
  }

  static function set_vibration(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.mobileOptions.vibration = value;
    save.flush();
    return value;
  }
  #end
}
