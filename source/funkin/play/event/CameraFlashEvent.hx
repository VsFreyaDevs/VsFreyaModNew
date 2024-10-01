package funkin.play.event;

import flixel.util.FlxColor;
import flixel.FlxCamera;
// Data from the chart
import funkin.data.song.SongData;
import funkin.data.song.SongData.SongEventData;
// Data from the event schema
import funkin.play.event.SongEvent;
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;

class CameraFlashEvent extends SongEvent
{
  public function new()
  {
    super('CameraFlash');
  }

  static final DEFAULT_TARGET:String = 'camHUD';
  static final DEFAULT_COLOR:String = '#FF0000';
  static final DEFAULT_DURATION:Float = 4.0;
  static final DEFAULT_REVERSED:Bool = false;

  public override function handleEvent(data:SongEventData):Void
  {
    if (PlayState.instance == null || PlayState.instance.currentStage == null) return;
    var targetName:String = data.getString('target') ?? DEFAULT_TARGET;
    var color:String = data.getString('color') ?? DEFAULT_COLOR;
    var duration:Float = data.getFloat('duration') ?? DEFAULT_DURATION;
    var durSeconds:Float = Conductor.instance.stepLengthMs * duration / 1000;
    var reversed:Bool = data.getBool('reversed') ?? DEFAULT_REVERSED;
    var camera:FlxCamera = targetName == 'camHUD' ? PlayState.instance.camHUD : PlayState.instance.camGame;
    if (reversed)
    {
      camera.fade(FlxColor.fromString(color), durSeconds, false, () -> {
        camera.stopFX();
      }, true);
    }
    else
      camera.flash(FlxColor.fromString(color), durSeconds, null, true);
  }

  public override function getTitle():String
  {
    return 'Camera Flash';
  }

  public override function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([
      {
        name: 'target',
        title: 'Target',
        defaultValue: 'camHUD',
        type: SongEventFieldType.ENUM,
        keys: ['HUD Camera' => 'camHUD', 'Game Camera' => 'camGame']
      },
      {
        name: 'duration',
        title: 'Duration',
        defaultValue: 4.0,
        step: 0.5,
        type: SongEventFieldType.FLOAT,
        units: 'steps'
      },
      {
        name: 'color',
        title: 'Color',
        type: SongEventFieldType.STRING
      },
      {
        name: 'reversed',
        title: 'Reversed',
        defaultValue: false,
        type: SongEventFieldType.BOOL
      }
    ]);
  }
}
