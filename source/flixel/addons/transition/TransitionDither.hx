package flixel.addons.transition;

import openfl.display.Bitmap;
import funkin.graphics.shaders.DumbShaders.DitherEffect;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;

// taken from vs dave lol
class TransitionDither extends TransitionEffect
{
  var ditherShader:DitherEffect = new DitherEffect();

  public function new(data:TransitionData)
  {
    super(data);

    var bitmap:BitmapData = new BitmapData(FlxG.width * 2, FlxG.width * 2, false, FlxColor.BLACK);
    var graphic = FlxGraphic.fromBitmapData(bitmap);

    var ugh:FlxSprite = new FlxSprite().loadGraphic(graphic);
    ugh.screenCenter();
    // ugh.shader = ditherShader.shader;
    add(ugh);
  }
}
