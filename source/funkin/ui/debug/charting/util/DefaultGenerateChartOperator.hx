package funkin.ui.debug.charting.util;

import funkin.data.song.SongData;

class DefaultGenerateChartOperator extends GenerateChartOperator
{
  public function new()
  {
    super('defaultOperator', 'Default Algorithm');
  }

  /**
   * Creates the chart
   * @param data The note data
   * @return The notes to generate
   */
  override public function execute(data:Array<NoteMidiData>):Array<SongNoteData>
  {
    var notes:Array<SongNoteData> = [];
    for (d in data)
    {
      notes.push(new SongNoteData(d.time, d.note % 4 + (d.isPlayerNote ? 0 : 4), d.length));
    }
    return notes;
  }
}
