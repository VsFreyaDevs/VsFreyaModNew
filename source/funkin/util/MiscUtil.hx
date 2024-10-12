package funkin.util;

import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import openfl.utils.Assets as OpenFlAssets;
#if sys import sys.FileSystem; #end

using StringTools;

/**
 * Utility functions, most that aren't in the OG game, can be used for scripts maybe.
 */
@:keep class MiscUtil
{
  /**
    Formats hours, minutes and seconds to just seconds.
  **/
  @:noUsing public inline static function timeToSeconds(h:Float, m:Float, s:Float):Float
    return h * 3600 + m * 60 + s;

  public inline static function getLastOfArray<T>(a:Array<T>):T
    return a[a.length - 1];

  @:keep inline public static function splitFilenameFromPath(str:String):Array<String>
  {
    return [str.substr(0, str.lastIndexOf("/")), str.substr(str.lastIndexOf("/") + 1)];
  }

  public inline static function getFilenameFromPath(str:String):String
  {
    if (str.lastIndexOf("/") == -1) return str;
    return str.substr(str.lastIndexOf("/") + 1);
  }

  public inline static function removeFileFromPath(str:String):String
  {
    if (str.lastIndexOf("/") == -1) return str;
    return str.substr(0, str.lastIndexOf("/"));
  }

  /**
   * :)
   */
  public static function crash()
  {
    throw new Exception("no bitches error (690)");
  }

  public static function isLibrary(lib:String)
  {
    return OpenFlAssets.hasLibrary(lib);
  }

  public inline static function clearArray<T>(a:Array<T>):Array<T>
  {
    while (a.length > 0)
      a.pop();
    return a;
  }

  public static function floorDecimal(value:Float, decimals:Int):Float
  {
    if (decimals < 1) return Math.floor(value);
    var tempMult:Float = 1;
    for (_ in 0...decimals)
      tempMult *= 10;
    var newValue:Float = Math.floor(value * tempMult);
    return newValue / tempMult;
  }

  public static function getLargestKeyInMap(map:Map<String, Float>):String
  {
    var largestKey:String = null;
    for (key in map.keys())
    {
      if (largestKey == null || map.get(key) > map.get(largestKey)) largestKey = key;
    }
    return largestKey;
  }

  inline public static function scale(x:Float, l1:Float, h1:Float, l2:Float, h2:Float):Float
    return ((x - l1) * (h2 - l2) / (h1 - l1) + l2);

  public static function stringToOgType(s:String):Dynamic
  {
    // if is integer or float
    if (isStringInt(s))
    {
      if (s.contains(".")) return Std.parseFloat(s);
      else
        return Std.parseInt(s);
    }
    // if is a bool
    if (s == "true") return true;
    if (s == "false") return false;
    // if it is null
    if (s == "null") return null;
    // else return the original string
    return s;
  }

  public static function toBool(d):Dynamic
  {
    var s = Std.string(d);
    switch (s.toLowerCase())
    {
      case "true":
        return true;
      case "false":
        return false;
      default:
        return null;
    }
  }

  @:keep inline public static function cleanJSON(input:String):String
  { // blud cant filter a comment in jsons
    return (~/\/\*[\s\S]*?\*\/|\/\/.*/g).replace(input.trim(), '');
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

  inline public static function quantize(f:Float, snap:Float)
  {
    // changed so this actually works lol
    var m:Float = Math.fround(f * snap);
    return (m / snap);
  }

  inline public static function snap(f:Float, snap:Float)
  {
    // changed so this actually works lol
    var m:Float = Math.fround(f / snap);
    return (m * snap);
  }

  inline public static function iclamp(val:Float, min:Int, max:Int):Int
    return Math.floor(Math.max(min, Math.min(max, val)));

  inline public static function curveNumber(input:Float = 1, ?curve:Float = 10):Float
    return Math.sqrt(input) * curve;

  public static function isEmpty(d:Dynamic):Bool
  {
    if (d == "" || d == 0 || d == null || d == "0" || d == "null" || d == "empty" || d == "none") return true;
    return false;
  }

  public static function makeOutlinedGraphic(Width:Int, Height:Int, Color:Int, LineThickness:Int, OutlineColor:Int)
  {
    var rectangle = flixel.graphics.FlxGraphic.fromRectangle(Width, Height, OutlineColor, true);
    rectangle.bitmap.fillRect(new openfl.geom.Rectangle(LineThickness, LineThickness, Width - LineThickness * 2, Height - LineThickness * 2), Color);
    return rectangle;
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

  public static function rotate(x:Float, y:Float, angle:Float, ?point:FlxPoint):FlxPoint
  {
    var p = point == null ? FlxPoint.weak() : point;
    var sin = FlxMath.fastSin(angle);
    var cos = FlxMath.fastCos(angle);
    return p.set((x * cos) - (y * sin), (x * sin) + (y * cos));
  }

  @:keep inline public static function orderList(list:Array<String>):Array<String>
  {
    haxe.ds.ArraySort.sort(list, (a, b) -> (a < b ? -1 : (a > b ? 1 : 0)));
    return list;
  }

  @:keep inline public static function clearFlxGroup(obj:FlxTypedGroup<Dynamic>):FlxTypedGroup<Dynamic>
  { // Destroys all objects inside of a FlxGroup
    while (obj.members.length > 0)
    {
      var e = obj.members.pop();
      if (e != null && e.destroy != null) e.destroy();
    }
    return obj;
  }

  inline public static function quantizeAlpha(f:Float, interval:Float)
  {
    return Std.int((f + interval / 2) / interval) * interval;
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
