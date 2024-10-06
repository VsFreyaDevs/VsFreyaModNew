package funkin.ui.credits;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.audio.FunkinSound;
import funkin.ui.credits.FreyaCreditsState;
import funkin.ui.mainmenu.MainMenuState;

/**
 * A state for handling which credits menu you wanna go to.
 */
class MainCreditsState extends MusicBeatState
{
  var optionShit:Array<String> = ['Credits List (WIP)', 'Credits Roll'];
  var formattedOptions:Array<String> = ['funkin', 'freya'];

  var bg:FlxSprite;
  var grpOptions:FlxTypedGroup<FlxText>;

  var curSelected:Int = 0;

  var unfinished:FlxText;
  var unfinishedBG:FlxSprite;

  public function new()
  {
    super();
  }

  override function create():Void
  {
    super.create();

    FunkinSound.playMusic('freeplayRandom',
      {
        startingVolume: 0.0,
        overrideExisting: true,
        restartTrack: true,
        loop: true,
        persist: true
      });
    FlxG.sound.music.fadeIn(6, 0, 0.8);

    bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
    add(bg);

    grpOptions = new FlxTypedGroup<FlxText>();
    add(grpOptions);

    var pos:Int = 0;
    for (option in optionShit)
    {
      pos++;
      var pos2:Int = 0;
      if (pos == 2) pos2 = 1;

      var text:FlxText = new FlxText(50, 150 * pos2, FlxG.width - 50, option, 30);
      text.setFormat(Paths.font('arial.ttf'), 50, 0xFFFF0000, CENTER, OUTLINE, 0xFF000000);
      grpOptions.add(text);
    }

    changeSelection();

    unfinishedBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    unfinishedBG.alpha = 0;

    unfinished = new FlxText(0, 0, 0, "(BTW THIS MENU IS A WIP!!)", 30);
    unfinished.setFormat(Paths.font('vcr.ttf'), 50, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
    unfinished.alpha = 0;

    add(unfinishedBG);
    add(unfinished);

    #if mobile
    addBackButton(FlxG.width * 0.77, FlxG.height * 0.85, FlxColor.WHITE, () -> {
      FunkinSound.playOnce(Paths.sound('cancelMenu'));
      FlxG.switchState(() -> new MainMenuState());
    });
    #end
  }

  var textTween:FlxTween;
  var bgTween:FlxTween;

  override function update(elapsed:Float):Void
  {
    final upP:Bool = (controls.UI_UP_P #if mobile || SwipeUtil.swipeUp #end);
    final downP:Bool = (controls.UI_DOWN_P #if mobile || SwipeUtil.swipeDown #end);

    if (controls.UI_LEFT_P || upP) changeSelection(-1);
    if (controls.UI_RIGHT_P || downP) changeSelection(1);

    if (controls.ACCEPT #if mobile || TouchUtil.pressed && !TouchUtil.overlaps(backButton) #end)
    {
      switch (formattedOptions[curSelected])
      {
        case 'funkin':
          FlxG.switchState(() -> new CreditsState());
        case 'freya':
          FlxG.switchState(() -> new FreyaCreditsState());
      }
    }

    if (controls.BACK)
    {
      FunkinSound.playOnce(Paths.sound('cancelMenu'));
      FlxG.switchState(() -> new MainMenuState());
    }
  }

  function changeSelection(change:Int = 0):Void
  {
    curSelected += change;

    if (curSelected >= optionShit.length) curSelected = 0;
    if (curSelected < 0) curSelected = optionShit.length - 1;

    FunkinSound.playOnce(Paths.sound('scrollMenu'));

    for (i in 0...optionShit.length)
    {
      if (i == curSelected) grpOptions.members[i].color = 0xFFDE4B;
      else
        grpOptions.members[i].color = 0xFFFFFF;
    }
  }

  public override function destroy():Void
  {
    super.destroy();
  }
}
