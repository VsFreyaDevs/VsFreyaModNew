package funkin.ui.title;

import flixel.FlxSprite;
import funkin.graphics.shaders.BlendModesShader;
import openfl.display.BitmapData;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import haxe.io.Path;

using StringTools;

class GFDancer extends FlxSprite
{
  public var animOffsets:Map<String, Array<Dynamic>>;

  var blendShader:BlendModesShader;
  var dipshitBitmap:BitmapData;
  var temp:FlxSprite;

  public function new(x:Float, y:Float)
  {
    super(x, y);

    animOffsets = new Map<String, Array<Dynamic>>();
    antialiasing = Preferences.antialiasing;

    temp = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
    blendShader = new BlendModesShader();
    dipshitBitmap = new BitmapData(2180, 1720, true, 0xFFCC00CC);
  }

  public function quickAnimAdd(name:String, prefix:String)
    animation.addByPrefix(name, prefix, 24, false);

  override function update(elapsed:Float)
  {
    super.update(elapsed);
  }

  public function loadOffsetFile(pathThing:String)
  {
    var daFile:Array<String> = funkin.util.MiscUtil.coolTextFile(Paths.file(pathThing));

    for (i in daFile)
    {
      var splitWords:Array<String> = i.split(" ");
      addOffset(splitWords[0], Std.parseInt(splitWords[1]), Std.parseInt(splitWords[2]));
    }
  }

  public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
  {
    animation.play(AnimName, Force, Reversed, Frame);

    var daOffset = animOffsets.get(AnimName);
    if (animOffsets.exists(AnimName)) offset.set(daOffset[0], daOffset[1]);
    else
      offset.set(0, 0);
  }

  public function addOffset(name:String, x:Float = 0, y:Float = 0)
    animOffsets[name] = [x, y];

  override function drawComplex(camera:FlxCamera):Void
  {
    _frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
    _matrix.translate(-origin.x, -origin.y);
    _matrix.scale(scale.x, scale.y);

    if (bakedRotationAngle <= 0)
    {
      updateTrig();
      if (angle != 0) _matrix.rotateWithTrig(_cosAngle, _sinAngle);
    }

    getScreenPosition(_point, camera).subtractPoint(offset);

    _point.add(origin.x, origin.y);
    _matrix.translate(_point.x, _point.y);

    if (isPixelPerfectRender(camera))
    {
      _matrix.tx = Math.floor(_matrix.tx);
      _matrix.ty = Math.floor(_matrix.ty);
    }

    var sprRect = getScreenBounds();

    // dipshitBitmap.draw(camera.canvas, camera.canvas.transform.matrix);
    // blendShader.setCamera(dipshitBitmap);

    // FlxG.bitmapLog.add(dipshitBitmap);

    camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
  }

  function copyToFlash(rect):openfl.geom.Rectangle
  {
    var flashRect = new openfl.geom.Rectangle();

    flashRect.x = rect.x;
    flashRect.y = rect.y;
    flashRect.width = rect.width;
    flashRect.height = rect.height;

    return flashRect;
  }

  override public function isSimpleRender(?camera:FlxCamera):Bool
  {
    if (FlxG.renderBlit) return super.isSimpleRender(camera);
    else
      return false;
  }
}
