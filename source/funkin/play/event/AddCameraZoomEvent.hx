package funkin.play.event;

import flixel.FlxCamera;
// Data from the chart
import funkin.data.song.SongData;
import funkin.data.song.SongData.SongEventData;
// Data from the event schema
import funkin.play.event.SongEvent;
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;

class AddCameraZoomEvent extends SongEvent
{
  public function new()
  {
    super('AddCameraZoom');
  }

  public override function getTitle():String
  {
    return 'Add Zoom to Camera';
  }

  public override function handleEvent(data:SongEventData):Void
  {
    if (PlayState.instance == null) return;
    var toGame:Null<Float> = data.getFloat('gameZoom');
    if (toGame == null) toGame = Constants.DEFAULT_BOP_INTENSITY;
    var toHUD:Null<Float> = data.getFloat('hudZoom');
    if (toHUD == null) toHUD = PlayState.instance.hudCameraZoomIntensity;
    // toGame *= PlayState.instance.cameraBopIntensity; //nah
    // toHUD *= PlayState.instance.hudCameraZoomIntensity; //nah
    PlayState.instance.cameraBopMultiplier += toGame;
    PlayState.instance.camHUD.zoom += toHUD;
  }

  public override function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([
      {
        name: 'gameZoom',
        title: 'Add to Game',
        defaultValue: 0.015,
        step: 0.001,
        type: SongEventFieldType.FLOAT,
        units: 'zoom'
      },
      {
        name: 'hudZoom',
        title: 'Add to HUD',
        defaultValue: 0.030,
        step: 0.001,
        type: SongEventFieldType.FLOAT,
        units: 'zoom'
      }
    ]);
  }
}
