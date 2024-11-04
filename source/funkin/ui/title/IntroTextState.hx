package funkin.ui.title;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.NextState;
import funkin.audio.visualize.SpectogramSprite;
import funkin.graphics.shaders.ColorSwap;
import funkin.graphics.shaders.LeftMaskShader;
import funkin.data.song.SongRegistry;
import funkin.graphics.FunkinSprite;
import funkin.ui.MusicBeatState;
import funkin.data.song.SongData.SongMusicData;
import funkin.graphics.shaders.TitleOutline;
import funkin.audio.FunkinSound;
import funkin.ui.freeplay.FreeplayState;
import funkin.ui.AtlasText;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.AsyncErrorEvent;
import funkin.ui.mainmenu.MainMenuState;
import funkin.ui.title.OutdatedSubState;
import openfl.events.MouseEvent;
import openfl.events.NetStatusEvent;
import funkin.ui.freeplay.FreeplayState;
import openfl.media.Video;
import openfl.net.NetStream;
import funkin.api.newgrounds.NGio;
import openfl.display.BlendMode;
import funkin.save.Save;
import haxe.Timer;
#if mobile
import funkin.mobile.util.TouchUtil;
import funkin.mobile.util.SwipeUtil;
#end

using StringTools;

/**
 * Basically `TitleState` but it's just the wacky intro text!
 */
class IntroTextState extends MusicBeatState
{
  var blackScreen:FlxSprite;
  var credGroup:FlxGroup;
  var textGroup:FlxGroup;

  var curWacky:Array<String> = [];
  var lastBeat:Int = 0;

  override public function create():Void
  {
    super.create();

    curWacky = FlxG.random.getObject(getIntroTextShit());

    try
    {
      startIntro();
    }
    catch (e)
    {
      trace(e);
    }
  }

  function startIntro():Void
  {
    if (FlxG.sound.music == null) playMenuMusic();

    persistentUpdate = true;

    var bg:FunkinSprite = new FunkinSprite(-1).makeSolidColor(FlxG.width + 2, FlxG.height, FlxColor.BLACK);
    bg.screenCenter();
    add(bg);

    credGroup = new FlxGroup();
    add(credGroup);

    textGroup = new FlxGroup();

    blackScreen = bg.clone();

    if (credGroup != null)
    {
      credGroup.add(blackScreen);
      credGroup.add(textGroup);
    }

    FlxG.mouse.visible = true;
  }

  function playMenuMusic():Void
  {
    // Load music. Includes logic to handle BPM changes.
    FunkinSound.playMusic('freakyMenu',
      {
        startingVolume: 0.0,
        overrideExisting: true,
        restartTrack: false,
        // Continue playing this music between states, until a different music track gets played.
        persist: true
      });
    var shouldFadeIn:Bool = (FlxG.sound.music != null);
    // Fade from 0.0 to 1 over 4 seconds.
    if (shouldFadeIn) FlxG.sound.music.fadeIn(4.0, 0.0, 1.0);
  }

  function getIntroTextShit():Array<Array<String>>
  {
    var fullText:String = Assets.getText(Paths.txt('introText'));

    // Split into lines and remove empty lines
    var firstArray:Array<String> = fullText.split('\n').filter((s:String) -> return s != '');
    var swagGoodArray:Array<Array<String>> = [];

    for (i in firstArray)
      swagGoodArray.push(i.split('--'));

    return swagGoodArray;
  }

  override function update(elapsed:Float):Void
  {
    #if HAS_PITCH
    if (FlxG.keys.pressed.UP) FlxG.sound.music.pitch += 0.5 * elapsed;

    if (FlxG.keys.pressed.DOWN) FlxG.sound.music.pitch -= 0.5 * elapsed;
    #end

    if (controls.BACK)
    {
      FunkinSound.playOnce(Paths.sound('cancelMenu'));
      FlxG.switchState(() -> new MainMenuState());
    }

    Conductor.instance.update();

    if (FlxG.sound.music != null) Conductor.instance.update(FlxG.sound.music.time);

    // do controls.PAUSE | controls.ACCEPT instead?
    var pressedEnter:Bool = controls.ACCEPT #if mobile || (TouchUtil.justReleased && !SwipeUtil.swipeAny) #end;

    var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

    if (gamepad != null)
    {
      if (gamepad.justPressed.START) pressedEnter = true;
    }

    if (pressedEnter) funni();

    super.update(elapsed);
  }

  override function draw()
  {
    super.draw();
  }

  public function createCoolText(textArray:Array<String>)
  {
    if (credGroup == null || textGroup == null) return;

    for (i in 0...textArray.length)
    {
      var money:AtlasText = new AtlasText(0, 0, textArray[i], AtlasFont.BOLD);
      money.screenCenter(X);
      money.y += (i * 60) + 200;
      // credGroup.add(money);
      textGroup.add(money);
    }
  }

  public function addMoreText(text:String)
  {
    if (credGroup == null || textGroup == null) return;

    var coolText:AtlasText = new AtlasText(0, 0, text.trim(), AtlasFont.BOLD);
    coolText.screenCenter(X);
    coolText.y += (textGroup.length * 60) + 200;
    textGroup.add(coolText);
  }

  public function deleteCoolText()
  {
    if (credGroup == null || textGroup == null) return;

    while (textGroup.members.length > 0)
    {
      // credGroup.remove(textGroup.members[0], true);
      textGroup.remove(textGroup.members[0], true);
    }
  }

  function funni():Void
  {
    curWacky = FlxG.random.getObject(getIntroTextShit());

    trace("randomized intro text 4 no fuckin reason lol");

    createCoolText([curWacky[0]]);
    addMoreText(curWacky[1]);
  }
}
