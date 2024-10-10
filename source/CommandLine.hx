package source; // Yeah, I know...

/**
 * The core class for the command line stuff, I think.
 */
class CommandLine
{
  // Wrapper shits!
  inline public static function print(txt:String)
  {
    Sys.println(txt);
  }

  //

  public static function prettyPrint(txt:String)
  {
    var myLines:Array<String> = txt.split("\n");

    var length:Int = -1;

    for (l in myLines)
      if (l.length > length) length = l.length;

    var immaHeadOut:String = "══════";
    for (i in 0...length)
      immaHeadOut += "═";

    Sys.println("");
    Sys.println('╔$immaHeadOut╗');

    for (l in myLines)
      Sys.println('║   ${centerTxt(l, length)}   ║');

    Sys.println('╚$immaHeadOut╝');
  }

  public static function centerTxt(txt:String, width:Int):String
  {
    var theOffset = (width - txt.length) / 2;
    var leftSide = repeatThisThing(' ', Math.floor(theOffset));
    var rightSide = repeatThisThing(' ', Math.ceil(theOffset));

    return leftSide + txt + rightSide;
  }

  public static inline function repeatThisThing(nahbro:String, amounto:Int)
  {
    var stewie = "";
    for (i in 0...amounto)
      stewie += nahbro;

    return stewie;
  }
}
