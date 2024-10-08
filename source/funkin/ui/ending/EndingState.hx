package funkin.ui.ending;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.audio.FunkinSound;
import funkin.ui.MusicBeatState;

/**
 * I DO NOT LOOK LIKE A BBPANZU
 * G O D D A M N ! ! ! ! !
 */
class EndingState extends MusicBeatState
{
  var _ending:String;
  var _song:String;

  public function new(?ending:String = "goodEnding", ?song:String = "uzil")
  {
    super();

    _ending = ending;
    _song = song;
  }

  override public function create():Void
  {
    super.create();

    var end:FlxSprite = new FlxSprite(0, 0);
    end.loadGraphic(Paths.image("endings/" + _ending));
    add(end);

    FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.pressed.ENTER) endIt();
  }

  public function endIt()
  {
    FlxG.switchState(() -> new StoryMenuState());

    FunkinSound.playMusic('freakyMenu',
      {
        overrideExisting: true,
        restartTrack: false,
        // Continue playing this music between states, until a different music track gets played.
        persist: true
      });
  }
}
