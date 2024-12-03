package funkin.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.app.Application as LimeApp;
import haxe.CallStack;
import funkin.util.logging.CrashHandler;
import funkin.audio.FunkinSound;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
#if sys
import sys.FileSystem;
#end
import StringTools;

using StringTools;

/**
 * this is the state the game switches to whenever a crash would normally happpen
 * replaces the old crash handler, we don't need a message box, just show a screen thats all folks
 *
 * from super engine / superpowers04's V-Slice/Funkin' fork
 */
class FuckState extends FlxState
{
  public var err:String = "";
  public var info:String = "";

  public static var currentStateName:String = "";
  public static var FATAL:Bool = false;
  public static var forced:Bool = false;
  public static var showingError:Bool = false;
  public static var useOpenFL:Bool = false;
  public static var lastERROR = "";

  public static var jokes:Array<String> = [
    "fatal error",
    "i love haxe",
    "i love hscript",
    "i love flixel",
    "i love openfl",
    "i love polymod",
    "i love lime",
    "kaboom.",
    "WHY",
    "fuck yeah im in a crash report",
    "get stickbugged lmao",
    "cuh",
    "all done in haxe, can u believe it?",
    "JELP",
    "HELP",
    "GELP",
    "PLEH",
    "GELRP",
    "l + ratio",
    "DEATH IS APPROACHING HIDE RIGHT FUCKING NOW", // - @cyborghenrystickmin
    "epic fail", // - @cyborghenrystickmin
    "what the actual fuck", // - @cyborghenrystickmin
    "i hope you go mooseing and get fucked by a campfire", // - @cyborghenrystickmin
    "ya gotta be kidding me bro",
    "beautiful.", // - @breadboyoo
    "PETAH HOW DARE YOU", // - @animateagain
    'crash% speedrun lesss goooooo',
    "null object reference is real and haunts us",
    "yep it is indeed a null object reference",
    "also known as N.O.R.",
    "ah shit here we go again",
    "googoo gaagaa", // - @sylvinekitsune
    'time to go to stack overflow for a solution',
    'only real fnf fans get this... wait',
    "fuck you",
    "eat shit",
    "i wonder why...",
    "old was better", // - @animateagain
    "i tried, okay, I TRIED!",
    "bro what is this",
    ":sadedd:",
    ":sadtord:",
    "did i ask for ur opinion?"
  ];

  public static function hook()
  {
    trace('[LOG] Enabling standard uncaught error handler...');
    Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, FUCK_OPENFL);
    #if cpp
    trace('[LOG] Enabling C++ critical error handler...');
    untyped __global__.__hxcpp_set_critical_error_handler(FUCK);
    #end
  }

  public static function FUCK_OPENFL(E:UncaughtErrorEvent)
  {
    FUCK(E);
  }

  // This function has a lot of try statements.
  // The game just crashed, we need as many failsafes as possible to prevent the game from closing or crash looping
  @:keep inline public static function FUCK(e:Dynamic, ?info:String = "unknown", _forced:Bool = false, _FATAL:Bool = false, _rawError:Bool = false)
  {
    if (forced && !_forced && !_FATAL) return;
    if (_forced) forced = _forced;
    if (_FATAL)
    {
      forced = true;
      FATAL = true;
    }
    var _stack:String = "";
    try
    {
      var callStack:Array<StackItem> = CallStack.exceptionStack(true);
      var errMsg:String = "";
      if (callStack.length > 0)
      {
        _stack += '\nhaxe Stack:\n';
        for (stackItem in callStack)
        {
          switch (stackItem)
          {
            case FilePos(s, file, line, column):
              _stack += '\n$file:${line}:${column}';
            default:
              _stack += '$stackItem';
          }
        }
      }
    }
    catch (e) {}
    var exception = "Unable to grab exception!";
    if (e != null && e.message != null)
    {
      try
      {
        exception = 'Message:${e.message}\nStack:${e.stack}\nDetails: ${e.details()}';
      }
      catch (_e)
      {
        try
        {
          exception = '${e.details()}';
        }
        catch (_e)
        {
          try
          {
            exception = '${e.message}\n${e.stack}';
          }
          catch (_e)
          {
            try
            {
              exception = '${e}';
            }
            catch (e)
            {
              exception = 'I tried to grab the exception but got another exception, ${e}';
            }
          }
        }
      }
    }
    else
    {
      try
      {
        exception = '${e}';
      }
      catch (e) {}
    }
    var saved = false;
    var dateNow:String = "";
    var err = "";
    exception += _stack;
    var _date = Date.now();
    // Crash log
    if (lastERROR != exception)
    {
      lastERROR = exception;
      try
      {
        if (!FileSystem.exists('logs/'))
        {
          FileSystem.createDirectory('logs/');
        }
        dateNow = StringTools.replace(StringTools.replace(_date.toString(), " ", "_"), ":", ".");
        try
        { // Too many instances of this unironically throwing an error, fallback to normal one
          err = CrashHandler.buildCrashReport(exception);
        }
        catch (e)
        {
          var funnyQuip = "insert funny line here";
          var _date = Date.now();
          try
          {
            funnyQuip = jokes[Std.int(Math.random() * jokes.length - 1)]; // I know, this isn't FlxG.random but fuck you the game just crashed
          }
          catch (e) {}

          err = '# Vs Freya Crash Reporter: \n# $funnyQuip\n${exception}\nThis happened in ${info}';

          try
          {
            currentStateName = haxe.rtti.Rtti.getRtti(cast FlxG.state).path;
          }
          catch (e)
          {
            // nope.
          }

          try
          {
            err += "\n\n # ---------- SYSTEM INFORMATION --------";

            err += '\n Operating System: ${Sys.systemName()}';
            err += '\n Current Working Directory: ${Sys.getCwd()}';
            err += '\n Executable path: ${Sys.programPath()}';
            err += '\n Cur. Arguments: ${Sys.args()}';
            err += '\n # --------------------------------------';
          }
          catch (e)
          {
            trace('Unable to get system information! ${e.message}');
          }
        }

        sys.io.File.saveContent('logs/VsFreyaCRASH-${dateNow}.log', err);

        saved = true;

        trace('Wrote a crash report to ./logs/VsFreyaCRASH-${dateNow}.log!');
        trace('Crash Report:\n$err');
      }
      catch (e)
      {
        trace('Unable to write a crash report!');

        if (err != null && err.indexOf('SYSTEM INFORMATION') != -1) trace('Here is generated crash report:\n$err');
      }
    }
    if (Main.game == null || _rawError || useOpenFL)
    {
      try
      {
        Main.instance.removeChild(Main.game);
      }
      catch (e) {};

      if (Main.game != null)
      {
        Main.game.blockUpdate = Main.game.blockDraw = true;
      }
      Main.game = null;

      trace('OpenFL error screen');

      try
      {
        if (!showingError)
        {
          var addChild = Main.instance.addChild;

          showingError = true;

          var textField = new TextField();
          addChild(textField);
          textField.width = 1280;
          textField.text = '${exception}\nThis happened in ${info}';
          textField.y = 720 * 0.3;

          var textFieldTop = new TextField();
          addChild(textFieldTop);
          textFieldTop.width = 1280;
          textFieldTop.text = "A fatal error occurred!";
          textFieldTop.textColor = 0xFFFF0000;
          textFieldTop.y = 30;

          var textFieldBot = new TextField();
          addChild(textFieldBot);
          textFieldBot.width = 1280;
          textFieldBot.text = "Please take a screenshot and report this!!!!";
          textFieldBot.y = 720 * 0.8;

          if (saved)
          {
            var dateNow:String = StringTools.replace(StringTools.replace(Date.now().toString(), " ", "_"), ":", ".");
            textFieldBot.text = 'Saved crash log to "logs/VsFreyaCRASH-${dateNow}.log".\nPlease send this file to the devs when reporting this crash.';
          }

          // textField.x = (1280 * 0.5);
          var tf = new TextFormat("VCR OSD Mono", 24, 0xFFFFFF);
          tf.align = "center";
          textFieldBot.embedFonts = textFieldTop.embedFonts = textField.embedFonts = true;
          textFieldBot.defaultTextFormat = textFieldTop.defaultTextFormat = textField.defaultTextFormat = tf;
        }
        // Main.instance.addChild(new se.ErrorSprite('${exception}\nThis happened in ${info}',saved));
      }
      catch (e)
      {
        trace('FUCK $e');
      }
      return;
    }

    // try{LoadingScreen.hide();}catch(e){}
    Main.game.forceStateSwitch(new FuckState(exception, info, saved));
  }

  var saved:Bool = false;

  override function new(e:String, info:String, saved:Bool = false)
  {
    err = '${e}\nThis happened in ${info}';
    this.saved = saved;
    // LoadingScreen.hide();
    super();
  }

  override function create()
  {
    super.create();

    FunkinSound.playOnce(Paths.soundRandom('badnoise', 1, 3), 1.0);

    try
    {
      var menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
      menuBG.color = 0xFF852E2E;
      menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
      menuBG.updateHitbox();
      menuBG.screenCenter();
      menuBG.scrollFactor.set(0, 0);
      add(menuBG);
    }
    catch (e)
    {
      // nope.
    }

    var poopoo:String = "why";
    poopoo = jokes[Std.int(Math.random() * jokes.length - 1)];

    var errorText:FlxText = new FlxText(0, FlxG.height * 0.05, 0, poopoo, 32);
    errorText.setFormat(Paths.font('impact.otf'), 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    errorText.scrollFactor.set();
    errorText.screenCenter(flixel.util.FlxAxes.X);
    add(errorText);

    trace("-------------------------\nERROR:\n\n" + err + "\n\n-------------------------");

    if (FlxG.random.bool(14)) trace("fun fact: just press R to restart the game from this screen no close needed lol");

    var txt:FlxText = new FlxText(0, 0, FlxG.width, "\n\nError/Stack:\n\n" + err, 8);
    txt.setFormat(Paths.font('vcr.ttf'), 12, FlxColor.WHITE, CENTER);
    txt.borderColor = FlxColor.BLACK;
    txt.borderSize = 3;
    txt.borderStyle = FlxTextBorderStyle.OUTLINE;
    txt.screenCenter();
    add(txt);

    var txt2:FlxText = new FlxText(0, 0, FlxG.width,
      (if (FATAL) "Press ENTER to attempt to return to the main menu or ESCAPE to close the game" else
        "Press ESCAPE to close the game, nope u are not goin back to main menu nuh uh"),
      32);
    txt2.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, CENTER);
    txt2.borderColor = FlxColor.BLACK;
    txt2.borderSize = 3;
    txt2.borderStyle = FlxTextBorderStyle.OUTLINE;
    txt2.screenCenter(X);
    txt2.y = 680;
    add(txt2);

    if (saved)
    {
      txt2.y -= 30;
      var dateNow:String = Date.now().toString();
      dateNow = StringTools.replace(dateNow, " ", "_");
      dateNow = StringTools.replace(dateNow, ":", ".");
      txt2.text = 'Crash log saved to "logs/VsFreyaCRASH-${dateNow}.log".\n ' + txt2.text.substring(41);
    }

    useOpenFL = true;
  }

  override function update(elapsed:Float)
  {
    try
    {
      if (FlxG.keys.justPressed.ENTER && !FATAL)
      {
        // var _main = Main.instance;
        forced = false;
        FlxG.switchState(new funkin.ui.mainmenu.MainMenuState());
        useOpenFL = false;
        return;
      }
      if (FlxG.keys.justPressed.ESCAPE)
      {
        trace('Exit requested!');
        lime.system.System.exit(1);
        useOpenFL = false;
      }
      if (FlxG.keys.justPressed.R)
      {
        trace('finna reset like a god');
        forced = false;
        FlxG.resetGame();
        return;
      }
    }
    catch (e) {}
    super.update(elapsed);
  }
}
