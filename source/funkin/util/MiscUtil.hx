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

  public static function getTime()
  {
    var timeNow = Date.now();
    var hour = timeNow.getHours();
    var minute = timeNow.getMinutes();
    var second = timeNow.getSeconds();
    var all = hour + ":" + (minute < 10 ? "0" : "") + minute + ":" + (second < 10 ? "0" : "") + second;

    return all;
  }

  public static function getDate()
  {
    var dateNow = Date.now();
    var year = dateNow.getFullYear();
    var mouth = dateNow.getMonth() + 1;
    var day = dateNow.getDate();
    var all = year + "-" + (mouth < 10 ? "0" : "") + mouth + "-" + (day < 10 ? "0" : "") + day;

    return all;
  }

  public static function getAllPath():String
  {
    var allPath:String = Sys.getCwd();
    allPath = allPath.split("\\").join("/");

    return allPath;
  }
}
