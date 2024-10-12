package funkin.ui.debug.charting.handlers;

import funkin.ui.debug.charting.commands.GenerateNotesCommand;
import funkin.ui.debug.charting.ChartEditorState;
import funkin.ui.debug.charting.util.GenerateChartOperator;
import funkin.ui.debug.charting.util.GenerateDifficultyOperator;
import funkin.data.song.SongData;
import funkin.util.SortUtil;
import funkin.util.FileUtil;
import grig.midi.file.event.MidiFileEventType;
import grig.midi.MessageType;
import grig.midi.MidiFile;
import flixel.util.FlxSort;

/**
 * Helper class for generating charts
 */
@:access(funkin.ui.debug.charting.ChartEditorState)
class ChartEditorChartGeneratorHandler
{
  /**
   * Generate Hints (and Notes)
   * @param state The Chart Editor State
   * @param params The Params
   */
  public static function generateChartFromMidi(state:ChartEditorState, params:ChartGeneratorParams):Void
  {
    var data:Array<NoteMidiData> = [];

    var bpm:Float = 0;
    for (track in params.midi.tracks)
    {
      var channelIndex:Int = -1;
      switch (track.midiEvents[0].type) // get track name
      {
        case Text(event):
          channelIndex = getChannelIndex(event.bytes.getString(0, event.bytes.length), params.channels);
          if (channelIndex == -1)
          {
            continue;
          }
        default:
          // do nothing
      }

      var channel:ChartGeneratorChannel = params.channels[channelIndex];

      for (event in track.midiEvents)
      {
        switch (event.type)
        {
          case TempoChange(e):
            // bpm = e.tempo; // e.tempo returns a wrong value
            // it happens because of the use of Std.int
            // for now we'll just do it ourselves
            // maybe we should create a fork, which fixes that issue
            bpm = 60000000.0 / e.microsecondsPerQuarterNote;
          case MidiMessage(e):
            if (e.midiMessage.messageType == MessageType.NoteOn)
            {
              var time:Float = translateToMS(event.absoluteTime, bpm, params.midi.timeDivision);
              data.push(
                {
                  note: e.midiMessage.byte2,
                  time: time,
                  length: 0,
                  isPlayerNote: channel.isPlayerTrack
                });
            }
            else if (e.midiMessage.messageType == MessageType.NoteOff)
            {
              if (data.length == 0)
              {
                continue;
              }

              var curData:NoteMidiData = data[data.length - 1];
              var threshold:Float = (60.0 / bpm) * 1000.0 * 0.25;
              var sustainLength:Float = translateToMS(event.absoluteTime, bpm, params.midi.timeDivision);
              sustainLength -= curData.time;
              sustainLength -= threshold;
              if (sustainLength > 0.001)
              {
                curData.length = sustainLength;
              }
            }
          default:
            // do nothing
        }
      }
    }

    data.sort((a, b) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
    var notes:Array<SongNoteData> = params.algorithm.execute(data);

    state.performCommand(new GenerateNotesCommand(params.onlyHints ? null : notes, notes, null));
  }

  /**
   * Generate an easier version of a given chart
   * @param state The Chart Editor State
   * @param params The Params
   */
  public static function generateChartDifficulty(state:ChartEditorState, params:ChartGeneratorDifficultyParams):Void
  {
    var refNotes:Array<SongNoteData> = state.currentSongChartData.notes.get(state.selectedDifficulty) ?? [];

    if (refNotes.length == 0)
    {
      trace('Skipping Note Generation for \'${params.difficultyId.toTitleCase()}\', since \'${state.selectedDifficulty.toTitleCase()}\' doesn\'t contain  any notes.');
      return;
    }

    // deepClone: just to be safe
    var notes:Array<SongNoteData> = params.algorithm.execute(refNotes.deepClone());

    state.performCommand(new GenerateNotesCommand(params.onlyHints ? null : notes, notes, params.difficultyId));
  }

  /**
   * Create a list of ZIP file entries from the current loaded vocal tracks in the chart eidtor.
   * @param state The chart editor state.
   * @return `haxe.zip.Entry`
   */
  public static function makeZIPEntryFromMidi(state:ChartEditorState):haxe.zip.Entry
  {
    return FileUtil.makeZIPEntryFromBytes(state.midiFile ?? 'hintMidi.mid', state.midiData);
  }

  static function getChannelIndex(name:String, channels:Array<ChartGeneratorChannel>):Int
  {
    for (i in 0...channels.length)
    {
      if (channels[i].name == name)
      {
        return i;
      }
    }

    return -1;
  }

  static function translateToMS(time:Float, bpm:Float, timeDivision:Float):Float
  {
    return (time / timeDivision) * (60.0 / bpm) * 1000.0;
  }
}

typedef NoteMidiData =
{
  var note:Int;
  var time:Float;
  var length:Float;
  var isPlayerNote:Bool;
}

typedef ChartGeneratorParams =
{
  var algorithm:GenerateChartOperator;
  var midi:MidiFile;
  var channels:Array<ChartGeneratorChannel>;
  var onlyHints:Bool;
}

typedef ChartGeneratorChannel =
{
  var name:String;
  var isPlayerTrack:Bool;
}

typedef ChartGeneratorDifficultyParams =
{
  var algorithm:GenerateDifficultyOperator;
  var difficultyId:String;
  var onlyHints:Bool;
}

enum ChartGeneratorDifficultyAlgorithm
{
  RemoveNthTooClose(n:Int);
}
