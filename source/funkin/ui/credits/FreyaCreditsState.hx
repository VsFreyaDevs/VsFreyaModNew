package funkin.ui.credits;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.ui.credits.MainCreditsState;
import funkin.graphics.FunkinSprite;
import funkin.audio.FunkinSound;
import funkin.data.JsonFile;
import funkin.mobile.util.SwipeUtil;
import funkin.mobile.util.TouchUtil;

/**
 * The `credits.json` file, used to store the credits data.
 */
typedef CreditsFile =
{
  var comment:Null<String>;
  var creditsListData:Array<Array<String>>;
}

/**
 * This just looks like Psych Engine's credits menu, but whatever, my Psych spirit's still in me for some reason...
 */
class FreyaCreditsState extends MusicBeatState
{
  var creditsList:Array<Array<String>> = [];

  var bg:FlxSprite;

  var curSelected:Int = 0;

  /**
   * Whether an entry has a link assosciated with it or not.
   */
  var isSelectable:Array<Bool>;

  var grpCredits:FlxTypedGroup<FlxText>;
  var grpIcons:FlxTypedGroup<FunkinSprite>;

  /**
   * Whether an entry has a description or not.
   */
  var hasDesc:Array<Bool>;

  var camCredits:FlxCamera;
  var camDesc:FlxCamera;

  var camFollow:FlxObject;

  var descBox:FlxSprite;
  var descText:FlxText;

  /**
   * If a header exists, this will prevent items from overlapping after enough headers are loaded.
   */
  public var nextOffset:Int = 0;

  override function create():Void
  {
    camDesc = new FlxCamera();
    camCredits = new FlxCamera();

    FlxG.cameras.add(camCredits, false);
    FlxG.cameras.add(camDesc, false);

    camera = camCredits;
    camCredits.bgColor = 0x00000000;
    camDesc.bgColor = 0x00000000;

    camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
    add(camFollow);

    camCredits.follow(camFollow, null, 0.5);

    bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
    bg.scrollFactor.set(0, 0);
    bg.color = 0x68B87C;
    add(bg);

    grpCredits = new FlxTypedGroup<FlxText>();
    grpIcons = new FlxTypedGroup<FunkinSprite>();

    add(grpCredits);
    add(grpIcons);

    hasDesc = [];
    isSelectable = []; // So it gets reset every time this state loads up.

    bringUpCredits();

    descBox = new FlxSprite().makeGraphic(FlxG.width - 24, 200, 0x99000000);
    descBox.y = FlxG.height - (descBox.height + 5);
    descBox.x = 12;
    descBox.cameras = [camDesc];
    descBox.visible = false;
    add(descBox);

    descText = new FlxText(0, descBox.getGraphicMidpoint().y, descBox.width, "wiener", 30);
    descText.setFormat(Paths.font("arial.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    descText.screenCenter(X);
    descText.visible = false;
    descText.cameras = [camDesc];
    add(descText);

    changeSelection();

    #if mobile
    addBackButton(FlxG.width * 0.77, FlxG.height * 0.85, FlxColor.WHITE, () -> {
      FunkinSound.playOnce(Paths.sound('cancelMenu'));
      FlxG.switchState(() -> new MainCreditsState());
    });
    #end
  }

  override function update(elapsed:Float):Void
  {
    if (curSelected == 0 && creditsList[curSelected][1] == "header" && controls.UI_LEFT) changeSelection(-1, true);
    if (curSelected == 0 && creditsList[curSelected][1] == "header" && controls.UI_UP) changeSelection(-1, true);
    if (curSelected == 0 && creditsList[curSelected][1] == "header") changeSelection(1, true);

    final upP:Bool = (controls.UI_UP_P #if mobile || SwipeUtil.swipeUp #end);
    final downP:Bool = (controls.UI_DOWN_P #if mobile || SwipeUtil.swipeDown #end);

    if (controls.UI_LEFT_P || upP) changeSelection(-1);
    if (controls.UI_RIGHT_P || downP) changeSelection(1);

    if (controls.ACCEPT #if mobile || TouchUtil.pressed && !TouchUtil.overlaps(backButton) #end)
    {
      if (isSelectable[curSelected]) browserLoad(creditsList[curSelected][2]);
    }

    if (controls.BACK)
    {
      FunkinSound.playOnce(Paths.sound('cancelMenu'));
      FlxG.switchState(() -> new MainCreditsState());
    }
  }

  function bringUpCredits():Void
  {
    for (i in 0...creditsList.length)
    {
      var array:Array<String> = creditsList[i];

      var tooShort:Bool = false;
      if (array.length < 1) tooShort = true;

      var size:Int = 30;
      var yPos:Int = (150 * i) + nextOffset;

      if (array.length == 1)
      {
        size = 50;
        yPos += 150;
        nextOffset += 150;
      }

      var textString:String = !tooShort ? creditsList[i][0] : '"creditsList[$i]" was empty!\nidk why';

      var text:FlxText = new FlxText(0, yPos, 0, textString, size);
      text.setFormat(Paths.font('impact.otf'), size, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
      text.screenCenter(X);

      if (text.text == '' || text.text == null)
      {
        trace('Error while setting text!');

        text.text = 'Got an error trying to get the name!';
      }

      grpCredits.add(text);

      hasDesc.push(creditsList[i].length >= 2);
      isSelectable.push(creditsList[i].length >= 3);

      if (creditsList[i].length == 4)
      {
        var icon:FunkinSprite = FunkinSprite.create(0, 0, 'credits/' + creditsList[i][3]);

        grpIcons.add(icon);

        icon.x = text.x + text.width + 30;
        icon.y = text.y - 75;

        try
        {
          icon.graphic.assetsKey == null; // so that it still trys to attach itself, but doesn't trace each time
        }
        catch (e:Any)
        {
          try
          {
            icon.visible = false;
          }
          catch (e:Any)
            trace('CREDITS ERROR WHATTT "$e"');
        }
      }
    }
  }

  function changeSelection(change:Int = 0, ?muted:Bool = false):Void
  {
    curSelected += change;

    if (curSelected < 0) curSelected = creditsList.length - 1;
    if (curSelected >= creditsList.length) curSelected = 0;
    if (curSelected > 0 && creditsList[curSelected][1] == "header")
    {
      changeSelection(change);
      return;
    }

    if (!muted) FunkinSound.playOnce(Paths.sound('scrollMenu')); // So you don't get 2x the scroll sound lmao.

    camFollow.y = grpCredits.members[curSelected].y;

    for (wtf in 0...grpCredits.members.length)
    {
      if (wtf == curSelected) grpCredits.members[wtf].color = 0xFF0000;
      else
        grpCredits.members[wtf].color = 0xFFFFFF;
    }

    var imJustLazyShit:Int = curSelected;

    if (hasDesc[imJustLazyShit])
    {
      descBox.visible = true;
      descText.visible = true;

      descText.text = creditsList[curSelected][1];
    }
    else if (!hasDesc[imJustLazyShit])
    {
      descBox.visible = false;
      descText.visible = false;

      descText.text = "";
    }
  }

  function browserLoad(site:String):Void
  {
    #if linux Sys.command('/usr/bin/xdg-open', [site]); #else FlxG.openURL(site); #end
  }

  static final CREDITS_DATA_PATH:String = 'assets/data/freyaCredits.json';

  /**
   * dsfgjdkjukjsadufgfiudwrfutfd
   */
  public static var CREDITS_DATA(get, default):Null<CreditsFile> = null;

  static function get_CREDITS_DATA():CreditsFile
  {
    if (CREDITS_DATA == null) CREDITS_DATA = parseCreditsData(fetchCreditsData());

    return CREDITS_DATA;
  }

  static function parseCreditsData(file:JsonFile):Null<CreditsFile>
  {
    #if !macro
    if (file.contents == null) return null;

    var parser = new json2object.JsonParser<CreditsFile>();
    parser.ignoreUnknownVariables = false;

    trace('[CREDITS] Parsing credits data from ${CREDITS_DATA_PATH}');

    parser.fromJson(file.contents, file.fileName);

    if (parser.errors.length > 0)
    {
      printErrors(parser.errors, file.fileName);
      return null;
    }

    return parser.value;
    #else
    return null;
    #end
  }

  static function fetchCreditsData():funkin.data.JsonFile
  {
    #if !macro
    var rawJson:String;
    try
    {
      rawJson = openfl.Assets.getText(CREDITS_DATA_PATH).trim();
    }
    catch (e:Any)
    {
      trace('HELP AN ERROR $e');

      return {
        fileName: CREDITS_DATA_PATH,
        contents: null
      };
    }
    return {
      fileName: CREDITS_DATA_PATH,
      contents: rawJson
    };
    #else
    return {
      fileName: CREDITS_DATA_PATH,
      contents: null
    };
    #end
  }

  function doCreditsMerge():Void
  {
    for (array in CREDITS_DATA.creditsListData)
      if (!creditsList.contains(array)) creditsList.push(array);
  }

  static function printErrors(errors:Array<json2object.Error>, id:String = ''):Void
  {
    trace('[CREDITS] Failed to parse credits data: ${id}');

    for (error in errors)
      funkin.data.DataError.printError(error);
  }
}
