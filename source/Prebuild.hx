package source; // Yeah, I know...

import sys.io.File;
import sys.io.Process;
import sys.io.FileOutput;

/**
 * A script which executes before the game is built.
 */
class Prebuild extends CommandLine
{
  static inline final BUILD_TIME_FILE:String = '.build_time';

  /**
   * Just a few messages to keep your motivation up!
   * Don't ever give up on programming, it may be hard, but with dedication, you'll get where you want.
   * Some of these are silly, LOL.
   */
  public static var motivationMsgs:Array<String> = [
    "Don't worry, the game will probably compile fine.",
    "You are handsome.",
    "Time to get funky!",
    "It looks fine.",
    "Imagine a FNF Vs. You... I bet it'd be awesome.",
    "Imagine how happy Boyfriend/Girlfriend must be, knowing that soon they'll see you.",
    "Don't forget to drink some water!",
    "Don't forget to drink some milk! ...Milky asked me to put this here by the way, really?",
    "You're almost there!",
    "Hopefully, nothing will go wrong, right?",
    "How's your code going? We'll see...",
    "Why do we brainstorm with ideas only when we're not working?",
    "Ah, would ya look at that! If it isn't my favorite coder...",
    "Your smile is just as bright as the sun, I love seeing it.",
    "It'll be neat to see your great ideas come to life.",
    "Don't disturb the fox, please don't... :("
  ];

  static function main():Void
  {
    saveBuildTime();

    final message = motivationMsgs[Std.random(motivationMsgs.length)];

    CommandLine.prettyPrint('Building Vs. Freya (on ${Sys.systemName})'); // Check if your Haxe version is outdated.

    CommandLine.prettyPrint(message);

    #if !macro
    haxe.Log.trace('You are not in macro mode, ok.', null);
    #else
    haxe.Log.trace("You're on macro mode, WHY are you macro mode?!?!?!?", null);
    #end

    var theProcess:Process = new Process('haxe --version');
    theProcess.exitCode(true);
    var haxer = theProcess.stdout.readLine();
    if (haxer != "4.3.6")
    {
      var curHaxe = [for (augh in haxer.split(".")) Std.parseInt(augh)];
      var dudeWanted = [4, 3, 6];
      for (bro in 0...dudeWanted.length)
      {
        if (curHaxe[bro] < dudeWanted[bro])
        {
          CommandLine.prettyPrint("-- !! W A R N I N G !! --");
          Sys.println("Your current haXe version is outdated!");
          Sys.println('So, you\'re using ${haxer}, while the required version is 4.3.6.');
          Sys.println('The mod has no guarantee of compiling with your current version.');
          Sys.println('So, we recommend upgrading to 4.3.6.');
          break;
        }
      }
    }

    Sys.println('This might take a while, just be patient.');
  }

  static function saveBuildTime():Void
  {
    var fo:FileOutput = File.write(BUILD_TIME_FILE);
    var now:Float = Sys.time();
    fo.writeDouble(now);
    fo.close();
  }
}
