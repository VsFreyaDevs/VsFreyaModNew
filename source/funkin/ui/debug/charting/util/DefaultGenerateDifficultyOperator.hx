package funkin.ui.debug.charting.util;

import funkin.data.song.SongData;
import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.components.NumberStepper;
import haxe.ui.components.Label;

class DefaultGenerateDifficultyOperator extends GenerateDifficultyOperator
{
  var n:Int = 2;

  public function new()
  {
    super('defaultOperator', 'Default Algorithm');
  }

  /**
   * Creates the chart
   * @param data Copy of the note data
   * @return The notes to generate
   */
  override public function execute(data:Array<SongNoteData>):Array<SongNoteData>
  {
    var notes:Array<SongNoteData> = data;

    var threshold:Float = Conductor.instance.stepLengthMs * 1.5;
    var notesToRemove:Array<SongNoteData> = [];
    var curNPlayer:Int = 0;
    var curNOpponent:Int = 0;
    for (i in 0...(notes.length - 1))
    {
      var noteI:SongNoteData = notes[i];
      if (noteI == null || notesToRemove.contains(noteI))
      {
        continue;
      }

      for (j in (i + 1)...notes.length)
      {
        var noteJ:SongNoteData = notes[j];
        if (noteJ == null
          || noteJ.length != 0 // dont remove hold notes
          || (noteJ.kind != null && noteJ.kind != '') // dont remove special notes
          || noteJ.getStrumlineIndex() != noteI.getStrumlineIndex()
          || notesToRemove.contains(noteJ))
        {
          continue;
        }

        var curN:Float = noteJ.getStrumlineIndex() == 0 ? curNPlayer : curNOpponent;

        if (Math.abs(noteJ.time - noteI.time) <= threshold)
        {
          if (curN % n == 0)
          {
            notesToRemove.push(noteJ);
          }

          if (noteJ.getStrumlineIndex() == 0)
          {
            curNPlayer++;
          }
          else
          {
            curNOpponent++;
          }
        }
      }
    }

    for (note in notesToRemove)
    {
      notes.remove(note);
    }

    return notes;
  }

  override public function buildUI(root:VBox):Void
  {
    var hbox:HBox = new HBox();
    hbox.percentWidth = 100;
    root.addComponent(hbox);

    var label:Label = new Label();
    label.value = 'Remove Every Nth Note';
    label.verticalAlign = 'center';
    hbox.addComponent(label);

    var numberStepper:NumberStepper = new NumberStepper();
    numberStepper.step = 1;
    numberStepper.min = 1;
    numberStepper.max = 5;
    numberStepper.value = 2;
    numberStepper.verticalAlign = 'center';
    numberStepper.onChange = function(_) {
      n = numberStepper.value;
    }
    n = numberStepper.value;
    hbox.addComponent(numberStepper);
  }
}
