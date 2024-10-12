package funkin.ui.debug.charting.util;

import funkin.data.song.SongData.SongNoteData;
import funkin.data.IClassRegistryEntry;
import haxe.ui.containers.VBox;
import haxe.ui.components.Label;

/**
 * Scriptable difficulty generation operator
 */
class GenerateDifficultyOperator implements IClassRegistryEntry
{
  /**
   * Internal ID
   */
  public var id:String;

  /**
   * Displayed Name in Chart Editor dropdown
   */
  public var name:String;

  public function new(id:String, name:String)
  {
    this.id = id;
    this.name = name;
  }

  /**
   * Creates the chart
   * @param data Copy of the note data
   * @return The notes to generate
   */
  public function execute(data:Array<SongNoteData>):Array<SongNoteData>
  {
    return data;
  }

  /**
   * Builds the haxe ui
   * @param root The root to add the components to
   */
  public function buildUI(root:VBox):Void
  {
    var label:Label = new Label();
    label.value = "None";
    root.addComponent(label);
  }

  public function destroy():Void {}

  public function toString():String
  {
    return 'GenerateDifficultyOperator ($name)';
  }

  public function createNote(time:Float, data:Int, length:Float, ?kind:String):SongNoteData
  {
    return new SongNoteData(time, data, length, kind);
  }
}
