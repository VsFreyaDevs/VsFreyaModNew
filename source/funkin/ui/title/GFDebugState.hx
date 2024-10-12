package funkin.ui.title;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using StringTools;

/**
 * Heavily based off on the old AnimationDebug state, because I'm just fucking lazy lol.
 *
 * @see https://github.com/FunkinCrew/Funkin/blob/legacy/0.2.x/source/AnimationDebug.hx
 */
class GFDebugState extends MusicBeatState
{
  var gfDance:GFDancer;

  var textAnim:FlxText;
  var dumbTexts:FlxTypedGroup<FlxText>;

  var animList:Array<String> = [];
  var curAnim:Int = 0;

  var camFollow:FlxObject;

  public function new()
  {
    super();
  }

  override function create():Void
  {
    FlxG.sound.music?.stop();

    var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
    gridBG.scrollFactor.set(0.5, 0.5);
    add(gridBG);

    gfDance = new GFDancer(512, 42);
    gfDance.frames = Paths.getSparrowAtlas('freyaDanceTitle');
    gfDance.animation.addByPrefix('danceLeft', 'freya rockstar dance left instance 1', 24, false);
    gfDance.animation.addByPrefix('danceRight', 'freya rockstar dance right instance 1', 24, false);
    gfDance.scale.set(0.5, 0.5);
    gfDance.screenCenter(Y);

    add(gfDance);

    if (gfDance != null && gfDance.animation != null) gfDance.animation.play('danceRight');

    dumbTexts = new FlxTypedGroup<FlxText>();
    add(dumbTexts);

    textAnim = new FlxText(300, 16);
    textAnim.size = 26;
    textAnim.scrollFactor.set();
    add(textAnim);

    genBoyOffsets();

    camFollow = new FlxObject(0, 0, 2, 2);
    camFollow.screenCenter();
    add(camFollow);

    FlxG.camera.follow(camFollow);

    FlxG.mouse.visible = true;

    super.create();
  }

  function genBoyOffsets(pushList:Bool = true):Void
  {
    var daLoop:Int = 0;

    for (anim => offsets in gfDance.animOffsets)
    {
      var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
      text.scrollFactor.set();
      text.setFormat(Paths.font('roboto/roboto.ttf'), 15, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
      dumbTexts.add(text);

      if (pushList) animList.push(anim);

      daLoop++;
    }
  }

  function updateTexts():Void
  {
    dumbTexts.forEach((text:FlxText) -> {
      text.kill();
      dumbTexts.remove(text, true);
    });
  }

  override function update(elapsed:Float)
  {
    try
    {
      textAnim.text = gfDance.animation.curAnim.name;
    }
    catch (e:Any) {}

    if (FlxG.keys.justPressed.F4)
    {
      funkin.ui.title.TitleState.initialized = false;
      FlxG.switchState(() -> new TitleState());
    }

    if (FlxG.keys.justPressed.E) FlxG.camera.zoom += 0.25;
    if (FlxG.keys.justPressed.Q) FlxG.camera.zoom -= 0.25;

    if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
    {
      if (FlxG.keys.pressed.I) camFollow.velocity.y = -90;
      else if (FlxG.keys.pressed.K) camFollow.velocity.y = 90;
      else
        camFollow.velocity.y = 0;

      if (FlxG.keys.pressed.J) camFollow.velocity.x = -90;
      else if (FlxG.keys.pressed.L) camFollow.velocity.x = 90;
      else
        camFollow.velocity.x = 0;
    }
    else
      camFollow.velocity.set();

    if (FlxG.keys.justPressed.W) curAnim -= 1;
    if (FlxG.keys.justPressed.S) curAnim += 1;

    if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
    {
      gfDance.playAnim(animList[curAnim]);

      updateTexts();
      genBoyOffsets(false);
    }

    var upP = FlxG.keys.anyJustPressed([UP]);
    var rightP = FlxG.keys.anyJustPressed([RIGHT]);
    var downP = FlxG.keys.anyJustPressed([DOWN]);
    var leftP = FlxG.keys.anyJustPressed([LEFT]);

    var holdShift = FlxG.keys.pressed.SHIFT;
    var holdControl = FlxG.keys.pressed.CONTROL;
    var multiplier = 1;
    if (holdShift) multiplier = 10;
    if (holdControl) multiplier = 5;

    if (upP || rightP || downP || leftP)
    {
      updateTexts();
      if (upP) gfDance.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
      if (downP) gfDance.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
      if (leftP) gfDance.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
      if (rightP) gfDance.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

      updateTexts();
      genBoyOffsets(false);
      gfDance.playAnim(animList[curAnim]);
    }

    if (FlxG.keys.justPressed.ESCAPE)
    {
      var outputString:String = "";

      for (swagAnim in animList)
        outputString += swagAnim + " " + gfDance.animOffsets.get(swagAnim)[0] + " " + gfDance.animOffsets.get(swagAnim)[1] + "\n";

      outputString.trim();

      saveOffsets(outputString);
    }

    super.update(elapsed);
  }

  var _file:FileReference;

  private function saveOffsets(saveString:String)
  {
    if ((saveString != null) && (saveString.length > 0))
    {
      _file = new FileReference();
      _file.addEventListener(Event.COMPLETE, onSaveComplete);
      _file.addEventListener(Event.CANCEL, onSaveCancel);
      _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
      _file.save(saveString, "gfDanceOffsets.txt");
    }
  }

  function onSaveComplete(_):Void
  {
    _file.removeEventListener(Event.COMPLETE, onSaveComplete);
    _file.removeEventListener(Event.CANCEL, onSaveCancel);
    _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
    _file = null;
    FlxG.log.notice("Successfully saved LEVEL DATA.");
  }

  /**
   * Called when the save file dialog is cancelled.
   */
  function onSaveCancel(_):Void
  {
    _file.removeEventListener(Event.COMPLETE, onSaveComplete);
    _file.removeEventListener(Event.CANCEL, onSaveCancel);
    _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
    _file = null;
  }

  /**
   * Called if there is an error while saving the gameplay recording.
   */
  function onSaveError(_):Void
  {
    _file.removeEventListener(Event.COMPLETE, onSaveComplete);
    _file.removeEventListener(Event.CANCEL, onSaveCancel);
    _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
    _file = null;
    FlxG.log.error("Problem saving Level data");
  }
}
