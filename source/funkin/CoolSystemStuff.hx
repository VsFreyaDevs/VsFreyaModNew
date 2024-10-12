package funkin;

// crazy system shit!!!!! (only for windows)
#if windows
import flixel.FlxG;
import sys.io.File;
import sys.io.Process;
import haxe.io.Bytes;
import sys.FileSystem;
import flixel.util.FlxStringUtil;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.utils.ByteArray;
import flash.display.BitmapData;
import flixel.util.FlxTimer;

using StringTools;

/**
 * @see https://github.com/lr1999dev/VsMarcello/blob/main/source/CoolSystemStuff.hx
 */
@:keep class CoolSystemStuff
{
  public static function getUsername():String
  {
    // uhh this one is self explanatory
    return Sys.getEnv("USERNAME");
  }

  public static function getUserPath():String
  {
    // this one is also self explantory
    return Sys.getEnv("USERPROFILE");
  }

  public static function getTempPath():String
  {
    // gets appdata temp folder lol
    return Sys.getEnv("TEMP");
  }

  /**
   * use this at your own risk btw
   */
  public static function selfDestruct():Void
  {
    // make a batch file that will delete the game, run the batch file, then close the game
    var crazyBatch:String = "@echo off\ntimeout /t 3\n@RD /S /Q \"" + Sys.getCwd() + "\"\nexit";
    File.saveContent(CoolSystemStuff.getTempPath() + "/die.bat", crazyBatch);
    new Process(CoolSystemStuff.getTempPath() + "/die.bat", []);

    Sys.exit(0);
  }
}
#end
