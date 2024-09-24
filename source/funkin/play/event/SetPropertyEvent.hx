package funkin.play.event;

import flixel.FlxCamera;
// Data from the chart
import funkin.data.song.SongData;
import funkin.data.song.SongData.SongEventData;
// Data from the event schema
import funkin.play.event.SongEvent;
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;

class SetPropertyEvent extends SongEvent
{
  public function new()
  {
    super('SetProperty');
  }

  public override function getTitle():String
  {
    return "Set Property";
  }

  public override function handleEvent(data:SongEventData)
  {
    if (PlayState.instance == null) return;

    var target = data.getString('target');
    var value = data.getString('value');
    try
    {
      var split:Array<String> = target.split('.');
      if (split.length > 1)
      {
        setVarInArray(getPropertyLoop(split), split[split.length - 1], value);
      }
      else
      {
        setVarInArray(PlayState.instance, target, value);
      }
    }
    catch (e:Dynamic)
    {
      var len:Int = e.message.indexOf('\n') + 1;
      if (len <= 0) len = e.message.length;
      FlxG.log.warn('ERROR ("Set Property" Event) - ' + e.message.substr(0, len));
    }
  }

  public override function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([
      {
        name: 'target',
        title: 'Field',
        type: SongEventFieldType.STRING,
        defaultValue: '',
      },
      {
        name: 'value',
        title: 'Property',
        type: SongEventFieldType.STRING,
        defaultValue: '',
      }
    ]);
  }

  ////////  ////////  ////////  ////////  ////////  ////////  ////////  ////////
  public static function setVarInArray(instance:Dynamic, variable:String, value:Dynamic):Any
  {
    var splitProps:Array<String> = variable.split('[');
    if (value == "true" || value == "false") value = (value == "true" ? true : false);
    if (splitProps.length > 1)
    {
      var target:Dynamic = Reflect.getProperty(instance, splitProps[0]);
      for (i in 1...splitProps.length)
      {
        var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
        if (i >= splitProps.length - 1) // Last array
          target[j] = value;
        else // Anything else
          target = target[j];
      }
      return target;
    }
    Reflect.setProperty(instance, variable, value);
    return value;
  }

  public static function getVarInArray(instance:Dynamic, variable:String):Any
  {
    var splitProps:Array<String> = variable.split('[');
    if (splitProps.length > 1)
    {
      var target:Dynamic = Reflect.getProperty(instance, splitProps[0]);
      for (i in 1...splitProps.length)
      {
        var j:Dynamic = splitProps[i].substr(0, splitProps[i].length - 1);
        target = target[j];
      }
      return target;
    }

    return Reflect.getProperty(instance, variable);
  }

  public static function getPropertyLoop(split:Array<String>):Dynamic
  {
    var obj:Dynamic = getObjectDirectly(split[0]);
    var end = split.length;
    end = split.length - 1;
    for (i in 1...end)
      obj = getVarInArray(obj, split[i]);
    return obj;
  }

  public static function getObjectDirectly(objectName:String):Dynamic
  {
    switch (objectName)
    {
      case 'this' | 'instance' | 'game':
        return PlayState.instance;

      default:
        return getVarInArray(PlayState.instance, objectName);
    }
  }
}
