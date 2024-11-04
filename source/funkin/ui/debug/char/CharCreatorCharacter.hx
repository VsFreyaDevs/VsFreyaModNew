package funkin.ui.debug.char;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import funkin.data.animation.AnimationData;
import funkin.play.character.BaseCharacter.CharacterType;
import funkin.play.character.CharacterData.CharacterDataParser;
import funkin.ui.debug.char.animate.CharSelectAtlasSprite;
import funkin.play.stage.Bopper;
import flixel.math.FlxPoint;
import flixel.math.FlxPoint.FlxCallbackPoint; // honestly these are kind of awesome
import flixel.FlxSprite;

// literally just basecharacter but less functionality
// like the removal of note event functions
// also easy way to store in files used for generation!
// also ALSO these have ALL the character types integrated, LOL
class CharCreatorCharacter extends Bopper
{
  public var generatedParams:WizardGenerateParams;
  public var characterId(get, never):String;
  public var renderType(get, never):String;

  public var characterName:String;
  public var characterType:CharacterType = BF;

  public var holdTimer:Float = 0;
  public var characterCameraOffsets:Array<Float> = [0.0, 0.0];
  public var animations:Array<AnimationData> = [];

  public var characterFlipX:Bool = false;
  public var characterScale:Float = 1.0; // character scale to be used in the data, ghosts need one

  public var characterOrigin(get, never):FlxPoint;
  public var feetPosition(get, never):FlxPoint;
  public var totalScale(default, set):Float; // total character scale, included with the stage scale

  public var atlasCharacter:CharSelectAtlasSprite = null;
  public var currentAtlasAnimation:Null<String> = null;

  override public function new(wizardParams:WizardGenerateParams)
  {
    super(CharacterDataParser.DEFAULT_DANCEEVERY);
    ignoreExclusionPref = ["sing"];
    shouldBop = false;

    generatedParams = wizardParams;

    switch (generatedParams.renderType)
    {
      case "sparrow" | "multisparrow":
        if (generatedParams.files.length < 2) return; // img and data

        var combinedFrames = null;
        for (i in 0...Math.floor(generatedParams.files.length / 2))
        {
          var img = BitmapData.fromBytes(generatedParams.files[i * 2].bytes);
          var data = generatedParams.files[i * 2 + 1].bytes.toString();
          var sparrow = FlxAtlasFrames.fromSparrow(img, data);
          if (combinedFrames == null) combinedFrames = sparrow;
          else
            combinedFrames.addAtlas(sparrow);
        }
        this.frames = combinedFrames;

      case "packer":
        if (generatedParams.files.length != 2) return; // img and data

        var img = BitmapData.fromBytes(generatedParams.files[0].bytes);
        var data = generatedParams.files[1].bytes.toString();
        this.frames = FlxAtlasFrames.fromSpriteSheetPacker(img, data);

      case "atlas": // todo
        if (generatedParams.files.length != 1) return; // zip file with all the data
        atlasCharacter = new CharSelectAtlasSprite(0, 0, generatedParams.files[0].bytes);

        atlasCharacter.alpha = 0.0001;
        atlasCharacter.draw();
        atlasCharacter.alpha = 1.0;

        atlasCharacter.x = this.x;
        atlasCharacter.y = this.y;
        atlasCharacter.alpha *= alpha;
        atlasCharacter.flipX = flipX;
        atlasCharacter.flipY = flipY;
        atlasCharacter.scrollFactor.copyFrom(scrollFactor);
        atlasCharacter.cameras = _cameras; // _cameras instead of cameras because get_cameras() will not return null

      default: // nothing, what the fuck are you even doing
    }
  }

  override public function update(elapsed:Float)
  {
    super.update(elapsed);

    if (atlasCharacter != null) // easier than transform LOL
    {
      atlasCharacter.x = this.x;
      atlasCharacter.y = this.y;
      atlasCharacter.flipX = this.flipX;
      atlasCharacter.flipY = this.flipY;
      atlasCharacter.moves = this.moves;
      atlasCharacter.color = this.color;
      atlasCharacter.blend = this.blend;
      atlasCharacter.immovable = this.immovable;
      atlasCharacter.visible = this.visible;
      atlasCharacter.active = this.active;
      atlasCharacter.solid = this.solid; // cwc reference
      atlasCharacter.alive = this.alive;
      atlasCharacter.exists = this.exists;
      atlasCharacter.camera = this.camera;
      atlasCharacter.cameras = this.cameras;
      atlasCharacter.offset.copyFrom(this.offset);
      atlasCharacter.origin.copyFrom(this.origin);
      atlasCharacter.scale.copyFrom(this.scale);
      atlasCharacter.scrollFactor.copyFrom(this.scrollFactor);
      atlasCharacter.antialiasing = this.antialiasing;
      atlasCharacter.pixelPerfectRender = this.pixelPerfectRender;
      atlasCharacter.pixelPerfectPosition = this.pixelPerfectPosition;
    }
  }

  public function addAnimation(name:String, prefix:String, offsets:Array<Float>, indices:Array<Int>, animPath:String = "", frameRate:Int = 24,
      looped:Bool = false, flipX:Bool = false, flipY:Bool = false)
  {
    if (getAnimationData(name) != null) return true; // i mean i guess???

    if (renderType != "atlas")
    {
      if (indices.length > 0) animation.addByIndices(name, prefix, indices, "", frameRate, looped, flipX, flipY);
      else
        animation.addByPrefix(name, prefix, frameRate, looped, flipX, flipY);

      if (!animation.getNameList().contains(name)) return false;
    }

    animations.push(
      {
        name: name,
        prefix: prefix,
        frameIndices: indices,
        assetPath: animPath,
        frameRate: frameRate,
        flipX: flipX,
        flipY: flipY,
        looped: looped,
        offsets: offsets
      });

    return true;
  }

  public override function playAnimation(name:String, restart:Bool = false, ignoreOther:Bool = false, reverse:Bool = false):Void
  {
    if (atlasCharacter == null)
    {
      super.playAnimation(name, restart, ignoreOther, reverse);
      return;
    }

    if ((!canPlayOtherAnims && !ignoreOther)) return;

    var correctName = correctAnimationName(name);
    if (correctName == null)
    {
      trace('Could not find Atlas animation: ' + name);
      return;
    }

    var animData = getAnimationData(correctName);
    currentAtlasAnimation = correctName;
    var prefix:String = animData.prefix;
    if (prefix == null) prefix = correctName;
    var loop:Bool = animData.looped;

    atlasCharacter.playAnimation(prefix, restart, ignoreOther, loop);
  }

  public override function hasAnimation(name:String):Bool
  {
    return atlasCharacter == null ? super.hasAnimation(name) : getAnimationData(name) != null;
  }

  public override function isAnimationFinished():Bool
  {
    return atlasCharacter == null ? super.isAnimationFinished() : atlasCharacter.isAnimationFinished();
  }

  override function onAnimationFinished(prefix:String):Void
  {
    super.onAnimationFinished(prefix);
    if (atlasCharacter == null) return;

    if (getAnimationData() != null && getAnimationData().looped)
    {
      playAnimation(currentAtlasAnimation, true, false);
    }
    else
    {
      atlasCharacter.cleanupAnimation(prefix);
    }
  }

  public override function getCurrentAnimation():Null<String>
  {
    return atlasCharacter == null ? super.getCurrentAnimation() : currentAtlasAnimation;
  }

  public function getAnimationData(name:String = null)
  {
    if (name == null) name = getCurrentAnimation();

    for (anim in animations)
    {
      if (anim.name == name) return anim;
    }

    return null;
  }

  // getters and setters
  // git gut

  function get_characterId()
  {
    return generatedParams.characterID;
  }

  function get_renderType()
  {
    return generatedParams.renderType;
  }

  function get_characterOrigin():FlxPoint
  {
    var xPos = (width / 2); // Horizontal center
    var yPos = (height); // Vertical bottom
    return new FlxPoint(xPos, yPos);
  }

  function get_feetPosition():FlxPoint
  {
    return new FlxPoint(x + characterOrigin.x, y + characterOrigin.y);
  }

  function set_totalScale(value:Float)
  {
    if (totalScale == value) return totalScale;
    totalScale = value;

    var feetPos:FlxPoint = feetPosition;
    this.scale.x = totalScale;
    this.scale.y = totalScale;
    this.updateHitbox();
    // Reposition with newly scaled sprite.
    this.x = feetPos.x - characterOrigin.x + globalOffsets[0];
    this.y = feetPos.y - characterOrigin.y + globalOffsets[1];

    return totalScale;
  }

  override function set_isPixel(value:Bool)
  {
    pixelPerfectPosition = value;
    pixelPerfectRender = value;
    antialiasing = !value;
    return super.set_isPixel(value);
  }

  override function get_height():Float
  {
    if (atlasCharacter == null) return super.get_height();
    return atlasCharacter.height;
  }

  override function get_width():Float
  {
    if (atlasCharacter == null) return super.get_width();
    return atlasCharacter.width;
  }
}
