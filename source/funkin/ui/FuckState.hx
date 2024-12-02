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
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
#if sys
import sys.FileSystem;
#end
import StringTools;

using StringTools;

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
            var jokes = [
              "Hey look, mom! I'm on a crash report!",
              "This wasn't supposed to go down like this...",
              "Don't look at me that way.. I tried",
              "Ow, that really hurt :(",
              "missingno",
              "Did I ask for your opinion?",
              "Oh lawd he crashing",
              "get stickbugged lmao",
              "Mom? Come pick me up. I'm scared...",
              "It's just standing there... Menacingly.",
              "Are you having fun? I'm having fun.",
              "That crash though",
              "I'm out of ideas.",
              "Where do we go from here?",
              "Coded in Haxe.",
              "Oh what the hell?",
              "I just wanted to have fun.. :(",
              "Oh no, not this again",
              "null object reference is real and haunts us",
              'What is a error exactly?',
              "I just got ratioed :(",
              "L + Ratio + Skill Issue",
              "Now with more crashes",
              "I'm out of ideas.",
              "me when null object reference",
              'you looked at me funny :(',
              'Hey VSauce, Michael here. What is an error?',
              'AAAHHHHHHHHHHHHHH! Don\'t mind me, I\'m practicing my screaming',
              'crash% speedrun less goooo!',
              'hey look, the consequences of my actions are coming to haunt me',
              'time to go to stack overflow for a solution',
              'you\'re mother',
              'the stalemate button was boobytrapped'

            ];
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
        if (err != null && err.indexOf('SYSTEM INFORMATION') != -1)
        {
          trace('Here is generated crash report:\n$err');
        }
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
      // Main.instance
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
    var errorText:FlxText = new FlxText(0, FlxG.height * 0.05, 0, (if (FATAL) 'F' else 'Potentially f') + 'atal error caught', 32);
    errorText.setFormat('vcr', 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    errorText.scrollFactor.set();
    errorText.screenCenter(flixel.util.FlxAxes.X);
    add(errorText);
    trace("-------------------------\nERROR:\n\n" + err + "\n\n-------------------------");

    var txt:FlxText = new FlxText(0, 0, FlxG.width, "\n\nError/Stack:\n\n" + err, 16);

    txt.borderColor = FlxColor.BLACK;
    txt.setFormat("vcr", 16, FlxColor.fromRGB(200, 200, 200), CENTER);
    txt.borderSize = 3;
    txt.borderStyle = FlxTextBorderStyle.OUTLINE;
    txt.screenCenter();
    add(txt);

    var txt:FlxText = new FlxText(0, 0, FlxG.width,
      (if (FATAL) "P" else "Press ENTER to attempt to return to the main menu or") + "ress ESCAPE to close the game", 32);

    txt.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.fromRGB(200, 200, 200), CENTER);
    txt.borderColor = FlxColor.BLACK;
    txt.borderSize = 3;
    txt.borderStyle = FlxTextBorderStyle.OUTLINE;
    txt.screenCenter(X);
    txt.y = 680;
    add(txt);
    if (saved)
    {
      txt.y -= 30;
      var dateNow:String = Date.now().toString();
      dateNow = StringTools.replace(dateNow, " ", "_");
      dateNow = StringTools.replace(dateNow, ":", ".");
      txt.text = 'Crash log saved to "logs/VsFreyaCRASH-${dateNow}.log".\n ' + txt.text.substring(41);
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
        Sys.exit(1);
        useOpenFL = false;
      }
    }
    catch (e) {}
    super.update(elapsed);
  }
}
