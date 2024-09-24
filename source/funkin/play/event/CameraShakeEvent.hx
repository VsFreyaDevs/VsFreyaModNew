package funkin.play.event;

import flixel.FlxCamera;
// Data from the chart
import funkin.data.song.SongData;
import funkin.data.song.SongData.SongEventData;
// Data from the event schema
import funkin.play.event.SongEvent;
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;

class CameraShakeEvent extends SongEvent
{
  public function new()
  {
    super('CameraShake');
  }

  static final DEFAULT_TARGET:String = 'camHUD';
  static final DEFAULT_INTENSITY:Float = 0.05;
  static final DEFAULT_DURATION:Float = 4.0;
  static final DEFAULT_FORCED:Bool = false;

  public override function handleEvent(data:SongEventData):Void
  {
    if (PlayState.instance == null || PlayState.instance.currentStage == null) return;
    var targetName:String = data.getString('target') ?? DEFAULT_TARGET;
    var intensity:Float = data.getFloat('intensity') ?? DEFAULT_INTENSITY;
    var duration:Float = data.getFloat('duration') ?? DEFAULT_DURATION;
    var durSeconds:Float = Conductor.instance.stepLengthMs * duration / 1000;
    var force:Bool = data.getBool('force') ?? DEFAULT_FORCED;
    var camera:FlxCamera = targetName == 'camHUD' ? PlayState.instance.camHUD : PlayState.instance.camGame;
    camera.shake(intensity, durSeconds, null, force);
  }

  public override function getTitle():String
  {
    return 'Camera Shake';
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
        name: 'intensity',
        title: 'Intensity',
        defaultValue: 0.05,
        step: 0.01,
        type: SongEventFieldType.FLOAT
      },
      {
        name: 'force',
        title: 'Force',
        defaultValue: false,
        type: SongEventFieldType.BOOL
      }
    ]);
  }
}
