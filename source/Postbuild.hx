package source; // Yeah, I know...

import sys.FileSystem;
import sys.io.File;

/**
 * A script which executes after the game is built.
 */
class Postbuild extends CommandLine
{
  static inline final BUILD_TIME_FILE:String = '.build_time';

  static function main():Void
  {
    CommandLine.prettyPrint('Finished building Vs. Freya!');

    if (!FileSystem.exists('.build')) File.saveContent('.build', '620');
    else
      File.saveContent('.build', '${Std.parseInt(File.getContent('.build')) + 1}');

    printBuildTime();
  }

  static function printBuildTime():Void
  {
    // get buildEnd before fs operations since they are blocking
    var end:Float = Sys.time();
    if (FileSystem.exists(BUILD_TIME_FILE))
    {
      var fi:sys.io.FileInput = File.read(BUILD_TIME_FILE);
      var start:Float = fi.readDouble();
      fi.close();

      sys.FileSystem.deleteFile(BUILD_TIME_FILE);

      var buildTime:Float = roundToTwoDecimals(end - start);

      haxe.Log.trace('[ - Build took: ${buildTime} seconds! - ]', null);
    }
  }

  static function roundToTwoDecimals(value:Float):Float
  {
    return Math.round(value * 100) / 100;
  }
}
