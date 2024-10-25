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
   * The sound that plays whenever a note gets hit.
   * @default `"none"`
   */
  public static var noteHitSound(get, set):String;

  static function get_noteHitSound():String
  {
    return Save?.instance?.options?.noteHitSound;
  }

  static function set_noteHitSound(value:String):String
  {
    var save:Save = Save.instance;
    save.options.noteHitSound = value;
    save.flush();
    return value;
  }

  /**
   * The input system, self-explanatory.
   * Legacy, Week 7, and P.B.O.T. (stands for `Points Based on Timing`)
   * @default `"pbot"`
   */
  public static var inputSystem(get, set):String;

  static function get_inputSystem():String
  {
    return Save?.instance?.options?.inputSystem;
  }

  static function set_inputSystem(value:String):String
  {
    var save:Save = Save.instance;
    save.options.inputSystem = value;
    save.flush();
    return value;
  }

  /**
   * The volume of the click sound that would play whenever a note gets hit.
   * @default `100`
   */
  public static var noteHitSoundVolume(get, set):Int;

  static function get_noteHitSoundVolume():Int
  {
    return Save?.instance?.options?.noteHitSoundVolume;
  }

  static function set_noteHitSoundVolume(value:Int):Int
  {
    var save:Save = Save.instance;
    save.options.noteHitSoundVolume = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, it will hide the opponent notes and put the player strums to the middle.
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
   * Whether some particularly foul language is displayed.
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
   * If enabled, the score display will be centered and extended to show your combo breaks and accuracy.
   * @default `true`
   */
  public static var extraScoreText(get, set):Bool;

  static function get_extraScoreText():Bool
  {
    return Save?.instance?.options?.extraScoreText ?? true;
  }

  static function set_extraScoreText(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.extraScoreText = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, there will be a display showing your NPS & judgements that you've gotten during gameplay.
   * @default `true`
   */
  public static var judgeCounter(get, set):Bool;

  static function get_judgeCounter():Bool
  {
    return Save?.instance?.options?.judgeCounter ?? true;
  }

  static function set_judgeCounter(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.judgeCounter = value;
    save.flush();
    return value;
  }

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
   * @default `true`
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
   * If enabled, the health bar colors will be based off the characters' icons. Otherwise, go with the default red & green colors.
   * @default `false`
   */
  public static var coloredHealthBar(get, set):Bool;

  static function get_coloredHealthBar():Bool
  {
    return Save?.instance?.options?.coloredHealthBar ?? true;
  }

  static function set_coloredHealthBar(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.coloredHealthBar = value;
    save.flush();
    return value;
  }

  /**
   * If enable, the judgements and combo will be rendered on top of `camHUD`.
   * @default `true`
   */
  public static var comboHUD(get, set):Bool;

  static function get_comboHUD():Bool
  {
    return Save?.instance?.options?.comboHUD;
  }

  static function set_comboHUD(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.comboHUD = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, an FPS and memory counter will be displayed even if this is not a debug build.
   * @default `true`
   */
  public static var debugDisplay(get, set):Bool;

  static function get_debugDisplay():Bool
  {
    return Save?.instance?.options?.debugDisplay;
  }

  static function set_debugDisplay(value:Bool):Bool
  {
    var save = Save.instance;
    if (value != save.options.debugDisplay) toggleDebugDisplay(value);

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
    var save:Save = Save.instance;
    if (value != Save.instance.options.autoPause) FlxG.autoPause = value;

    save.options.autoPause = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, the game will automatically launch in fullscreen on startup.
   *
   * This does not apply on mobile devices.
   * @default `false`
   */
  public static var autoFullscreen(get, set):Bool;

  static function get_autoFullscreen():Bool
  {
    return Save?.instance?.options?.autoFullscreen ?? false;
  }

  static function set_autoFullscreen(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.autoFullscreen = value;
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
    return Save?.instance?.options?.badsShitsCauseMiss ?? false;
  }

  static function set_badsShitsCauseMiss(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.badsShitsCauseMiss = value;
    save.flush();
    return value;
  }

  /**
   * If enabled, there will be text on the screen at the middle, displaying your last input timing in milliseconds.
   * @default `true`
   */
  public static var showTimings(get, set):Bool;

  static function get_showTimings():Bool
  {
    return Save?.instance?.options?.showTimings ?? true;
  }

  static function set_showTimings(value:Bool):Bool
  {
    var save:Save = Save.instance;
    save.options.showTimings = value;
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

  /**
   * How transparent should the strums be?
   *
   * Somebody suggested this in the main Funkin' repo, so why not?
   * @see https://github.com/FunkinCrew/Funkin/issues/3124
   * @default `100`
   */
  public static var strumAlpha(get, set):Int;

  static function get_strumAlpha():Int
  {
    return Save?.instance?.options?.strumAlpha ?? 100;
  }

  static function set_strumAlpha(value:Int):Int
  {
    var save:Save = Save.instance;
    save.options.strumAlpha = value;
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
    // Apply the autoPause setting (enables automatic pausing when losing focus).
    FlxG.autoPause = Preferences.autoPause;
    flixel.FlxSprite.defaultAntialiasing = Preferences.antialiasing;
    // Apply the debugDisplay setting (enables the FPS and RAM display).
    toggleDebugDisplay(Preferences.debugDisplay);
    #if web
    toggleFramerateCap(Preferences.unlockedFramerate);
    #end
    // Apply the autoFullscreen setting (launches the game in fullscreen automatically)
    FlxG.fullscreen = Preferences.autoFullscreen;
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
    if (show) #if mobile FlxG.game.addChild(Main.fpsCounter); #else FlxG.stage.addChild(Main.fpsCounter); #end // Enable the debug display.
    else
      #if mobile FlxG.game.removeChild(Main.fpsCounter); #else FlxG.stage.removeChild(Main.fpsCounter); #end // Disable the debug display.

    if (Main.fpsCounter.alpha == 0) Main.tweenFPS();
  }

  #if mobile
  /**
   * If disabled, the device won't sleep automatically by the screen timeout set by the user, despite not being interacted by them.
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
   * If enabled, the device will vibrate in some situations.
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
