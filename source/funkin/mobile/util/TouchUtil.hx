package funkin.mobile.util;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
#if FLX_TOUCH
import flixel.input.touch.FlxTouch;
#end
import flixel.math.FlxPoint;

/**
 * Utility class for handling touch input within the FlxG context.
 */
class TouchUtil
{
  /**
   * Indicates if any touch is currently pressed.
   */
  public static var pressed(get, never):Bool;

  /**
   * Indicates if any touch was just pressed this frame.
   */
  public static var justPressed(get, never):Bool;

  /**
   * Indicates if any touch was just released this frame.
   */
  public static var justReleased(get, never):Bool;

  /**
   * The first touch in the FlxG.touches list.
   */
  public static var touch(get, never):FlxTouch;

  /**
   * Checks if the specified object overlaps with any active touch.
   *
   * @param object The FlxBasic object to check for overlap.
   * @param camera Optional camera for the overlap check. Defaults to the object's camera.
   *
   * @return `true` if there is an overlap with any touch; `false` otherwise.
   */
  public static function overlaps(object:FlxBasic, ?camera:FlxCamera):Bool
  {
    if (object == null) return false;

    #if FLX_TOUCH
    for (touch in FlxG.touches.list)
    {
      if (touch.overlaps(object, camera ?? object.camera)) return true;
    }
    #end

    return false;
  }

  /**
   * Checks if the specified object overlaps with any active touch using precise point checks.
   *
   * @param object The FlxObject to check for overlap.
   * @param camera Optional camera for the overlap check. Defaults to all cameras of the object.
   *
   * @return `true` if there is a precise overlap with any touch; `false` otherwise.
   */
  public static function overlapsComplex(object:FlxObject, ?camera:FlxCamera):Bool
  {
    if (object == null) return false;

    #if FLX_TOUCH
    if (camera == null)
    {
      for (camera in object.cameras)
      {
        for (touch in FlxG.touches.list)
        {
          @:privateAccess
          if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera)) return true;
        }
      }
    }
    else
    {
      @:privateAccess
      if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera)) return true;
    }
    #end

    return false;
  }

  /**
   * Checks if the specified object overlaps with a specific point using precise point checks.
   *
   * @param object The FlxObject to check for overlap.
   * @param point The FlxPoint to check against the object.
   * @param inScreenSpace Whether to take scroll factors into account when checking for overlap.
   * @param camera Optional camera for the overlap check. Defaults to all cameras of the object.
   *
   * @return `true` if there is a precise overlap with the specified point; `false` otherwise.
   */
  public static function overlapsComplexPoint(object:FlxObject, point:FlxPoint, ?inScreenSpace:Bool = false, ?camera:FlxCamera):Bool
  {
    if (object == null || point == null) return false;

    #if FLX_TOUCH
    if (camera == null)
    {
      for (camera in object.cameras)
      {
        @:privateAccess
        if (object.overlapsPoint(point, inScreenSpace, camera))
        {
          point.putWeak();

          return true;
        }
      }
    }
    else
    {
      @:privateAccess
      if (object.overlapsPoint(point, inScreenSpace, camera))
      {
        point.putWeak();

        return true;
      }
    }
    #end

    point.putWeak();

    return false;
  }

  @:noCompletion
  private static function get_pressed():Bool
  {
    #if FLX_TOUCH
    for (touch in FlxG.touches.list)
    {
      if (touch.pressed) return true;
    }
    #end

    return false;
  }

  @:noCompletion
  private static function get_justPressed():Bool
  {
    #if FLX_TOUCH
    for (touch in FlxG.touches.list)
    {
      if (touch.justPressed) return true;
    }
    #end

    return false;
  }

  @:noCompletion
  private static function get_justReleased():Bool
  {
    #if FLX_TOUCH
    for (touch in FlxG.touches.list)
    {
      if (touch.justReleased) return true;
    }
    #end

    return false;
  }

  @:noCompletion
  private static function get_touch():FlxTouch
  {
    #if FLX_TOUCH
    for (touch in FlxG.touches.list)
    {
      if (touch != null) return touch;
    }

    return FlxG.touches.getFirst();
    // what?
    #else
    return null;
    #end
  }
}
