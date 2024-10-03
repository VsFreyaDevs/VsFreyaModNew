package funkin.util;

using StringTools;

class MiscUtil
{
  /**
    Formats hours, minutes and seconds to just seconds.
  **/
  @:noUsing public inline static function timeToSeconds(h:Float, m:Float, s:Float):Float
    return h * 3600 + m * 60 + s;

  public inline static function getLastOfArray<T>(a:Array<T>):T
    return a[a.length - 1];

  public inline static function clearArray<T>(a:Array<T>):Array<T>
  {
    while (a.length > 0)
      a.pop();
    return a;
  }
}
