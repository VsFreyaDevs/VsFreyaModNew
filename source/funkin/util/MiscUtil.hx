package funkin.util;

import flixel.util.FlxColor;

using StringTools;

@:keep class MiscUtil
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
    #if sys
    var allPath:String = Sys.getCwd();
    allPath = allPath.split("\\").join("/");

    return allPath;
    #else
    return null;
    #end
  }

  public static function stringToBool(str:String):Bool
  {
    str = str.toLowerCase();
    if (str == "true" || str == "1") return true;
    return false;
  }

  public static function stringToFloat(str:String, ?backup:Float = 0):Float
  {
    var num:Float = Std.parseFloat(str);
    if (!Std.isOfType(num, Float)) num = backup;
    return num;
  }

  public static function stringToInt(str:String, ?backup:Int = 0):Int
  {
    var num:Int = Std.parseInt(str);
    if (!Std.isOfType(num, Int)) num = backup;
    return num;
  }

  public static function stringToColor(str:String):Int
  {
    if (str.startsWith('#') || str.startsWith('0x')) return FlxColor.fromString(str);
    else
      return switch (str.toLowerCase())
      {
        case 'black': 0xFF000000;
        case 'silver': 0xFFC0C0C0;
        case 'gray': 0xFF808080;
        case 'red': 0xFFFF0000;
        case 'purple': 0xFF800080;
        case 'pink': 0xFFFF00FF;
        case 'green': 0xFF008000;
        case 'lime': 0xFF00FF00;
        case 'yellow': 0xFFFFFF00;
        case 'blue': 0xFF0000FF;
        case 'aqua': 0xFF00FFFF;
        default: 0xFFFFFFFF;
      }
  }

  inline public static function boundTo(value:Float, min:Float, max:Float):Float
    return Math.max(min, Math.min(max, value));

  public static function coolTextFile(key:String):Array<String>
  {
    var daList:Array<String> = Paths.txt(key).split('\n');

    for (i in 0...daList.length)
      daList[i] = daList[i].trim();

    return daList;
  }

  public static function numberArray(max:Int, ?min = 0):Array<Int>
  {
    var dumbArray:Array<Int> = [];

    for (i in min...max)
      dumbArray.push(i);

    return dumbArray;
  }

  inline public static function displayName(song:String):String
    return song.toUpperCase().replace("-", " ");

  inline public static function formatChar(char:String):String
    return char.substring(0, char.lastIndexOf('-'));

  public static function listFromString(string:String):Array<String>
  {
    var daList:Array<String> = [];
    daList = string.trim().split('\n');

    for (i in 0...daList.length)
      daList[i] = daList[i].trim();

    return daList;
  }

  public static function coolStringFile(path:String):String
  {
    var daList:String = Assets.getText(path).trim();
    return daList;
  }
}
