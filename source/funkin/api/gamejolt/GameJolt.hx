package funkin.api.gamejolt;

#if systools
// GameJolt things
import tentools.api.FlxGameJolt as GJApi;
// Login things
import flixel.FlxSprite;
import psych.ui.PsychUIInputText;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import lime.system.System;
// Toast things
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

using StringTools;

class GameJoltAPI // Connects to tentools.api.FlxGameJolt
{
  /**
   * Inline variable to see if the user has logged in.
   * True for logged in, false for not logged in. (Read Only!)
   */
  public static var userLogin(default, null):Bool = false; // For User Login Achievement (Like IC)

  /**
   * Inline variable to see if the user wants to submit scores.
   */
  public static var leaderboardToggle:Bool;

  /**
   * Grabs the username of the actual logged in user and returns it
   */
  public static function getUser():String
    return GJApi.username;

  /**
   * Grabs the game token of the actual logged in user and returns it
   */
  public static function getToken():String
    return GJApi.usertoken;

  /**
   * Sets the game API key from GJKeys.api
   */
  public static function connect()
  {
    trace("Grabbing API keys...");

    GJApi.init(Std.int(GJKeys.id), Std.string(GJKeys.key), function(data:Bool) {
      #if debug
      var daDesc:String = "If you are a developer, check GJKeys.hx\nMake sure the id and key are formatted correctly!";
      Main.gjToastManager.createToast(GameJoltInfo.imagePath, 'Game${!data ? " not" : ""} authenticated!', !data ? daDesc : "Success!");
      #end
    });
  }

  /**
   * Inline function to auth the user. Shouldn't be used outside of GameJoltAPI things.
   * @param in1 username
   * @param in2 token
   * @param loginArg Used in only GameJoltLogin
   */
  public static function authDaUser(in1:String, in2:String, ?loginArg:Bool = false)
  {
    if (!userLogin && in1 != "" && in2 != "")
    {
      GJApi.authUser(in1, in2, function(v:Bool) {
        trace("User: " + in1);
        trace("Token: " + in2);

        if (v)
        {
          Main.gjToastManager.createToast(GameJoltInfo.imagePath, 'SIGNED IN: ${in1.toUpperCase()}', "CONNECTED TO GAMEJOLT!");
          trace("User authenticated!");
          Save.instance.gjUser = in1;
          Save.instance.gjToken = in2;
          Save.instance.flush();
          userLogin = true;
          startSession();
        }
        else
        {
          Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Not signed in!\nSign in to save your GameJolt trophies!", "");
          trace("User login failure!");
          // FlxG.switchState(new GameJoltLogin());
        }

        if (loginArg) FlxG.switchState(() -> new GameJoltLogin());
      });
    }
  }

  /**
   * Inline function to deauth the user, shouldn't be used out of GameJoltLogin state!
   * @return  Logs the user out and closes the game
   */
  public static function deAuthDaUser()
  {
    closeSession();
    userLogin = false;
    trace('User: ${Save.instance.gjUser} | Token: ${Save.instance.gjToken}');
    Save.instance.gjUser = "";
    Save.instance.gjToken = "";
    Save.instance.flush();
    trace("Logged out!");
    System.exit(0);
  }

  /**
   * Awards a trophy to the user!
   * @param id Trophy ID. Check your game's API settings for trophy IDs.
   */
  public static function getTrophy(id:Int)
  {
    if (userLogin) GJApi.addTrophy(id,
      (data:Map<String, String>) -> trace(!data.exists("message") ? data : 'Could not add Trophy [$id] : ${data.get("message")}'));
  }

  /**
   * Checks a trophy to see if it was collected
   * @param id Trophy ID
   * @return Bool (True for achieved, false for unachieved)
   */
  public static function checkTrophy(id:Int):Bool
  {
    var value:Bool = false;
    var trophy:Null<Map<String, String>> = pullTrophy(id);

    if (trophy != null)
    {
      value = trophy.get("achieved") == "true";
      trace('Trophy state [$id]: ${value ? "achieved" : "unachieved"}');
    }

    return value;
  }

  /**
   * Pulls a trophy info by passing its ID
   * @param id Trophy ID
   * @return Map<String,String> or null if the process failed
   */
  public static function pullTrophy(id:Int):Null<Map<String, String>>
  {
    var returnable:Map<String, String> = [];

    GJApi.fetchTrophy(id, (data:Map<String, String>) -> returnable = data);
    if (returnable.exists("message"))
    {
      trace('Failed to pull trophy [$id] : ${returnable.get("message")}');
      return null;
    }
    return returnable;
  }

  /**
   * Add a score to a table!
   * @param score Score of the song. **Can only be an int value!**
   * @param tableID ID of the table you want to add the score to!
   * @param extraData (Optional) You could put accuracy or any other details here!
   */
  public static function addScore(score:Int, tableID:Int, ?extraData:String)
  {
    var retFormat:String = 'Score: $score';
    if (GameJoltAPI.leaderboardToggle)
    {
      trace("Trying to add a score");
      var formData:Null<String> = extraData != null ? extraData.split(" ").join("%20") : null;

      if (formData != null) retFormat += '\nExtra Data: $formData';

      GJApi.addScore(score + "%20Points", score, tableID, false, null, formData, function(data:Map<String, String>) {
        trace("Score submitted with a result of: " + data.get("success"));
        Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score submitted!", retFormat, true);
      });
    }
    else
    {
      if (extraData != null) retFormat += '\nExtra Data: $extraData';

      retFormat += "\nScore was not submitted due to score submitting being disabled!";
      Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score not submitted!", retFormat, true);
    }
  }

  /**
   * Return the highest score from a table!
   *
   * Usable by pulling the data from the map by [function].get();
   *
   * Values returned in the map: score, sort, user_id, user, extra_data, stored, guest, success
   *
   * @param id The table you want to pull from
   * @return Map<String,String> or null if not available
   */
  public static function pullHighScore(id:Int):Null<Map<String, String>>
  {
    var returnable:Null<Map<String, String>>;
    GJApi.fetchScore(id, 1, function(data:Map<String, String>) {
      if (!data.exists('message'))
      {
        trace('Could not pull High Score from Table [$id] :' + data.get('message'));
        returnable = null;
      }
      else
      {
        trace(data);
        returnable = data;
      }
    });
    return returnable;
  }

  /**
   * Inline function to start the session. Shouldn't be used out of GameJoltAPI
   * Starts the session
   */
  public static function startSession()
  {
    GJApi.openSession(function() {
      trace("Session started!");
      new FlxTimer().start(20, tmr -> pingSession(), 0);
    });
  }

  /**
   * Tells GameJolt that you are still active!
   * Called every 20 seconds by a loop in startSession().
   */
  public static function pingSession()
    GJApi.pingSession(true, () -> trace("Ping!"));

  /**
   * Closes the session, used for signing out
   */
  public static function closeSession()
    GJApi.closeSession(() -> trace('Closed out the session'));
}

class GameJoltInfo
{
  /**
   * Inline variable to change the font for the GameJolt API elements. **Example: `Paths.font("vcr.ttf");`**
   * @param font You can change the font by doing **Paths.font([Name of your font file])** or by listing your file path.
   * If *null*, will default to the normal font.
   */
  public static var font:String = null;

  /**
   * Inline variable to change the font for the notifications made by Firubii.
   *
   * Don't make it a NULL variable. Worst mistake of my life.
   */
  public static var fontPath:String = "assets/fonts/vcr.ttf";

  /**
   * Image to show for notifications. Leave NULL for no image, it's all good :)
   *
   * Example: `Paths.getLibraryPath("images/stepmania-icon.png");`
   */
  public static var imagePath:String = null;

  /* Other things that shouldn't be messed with are below this line! */
  /**
   * GameJolt + FNF version.
   */
  public static var version:String = "1.1";

  /**
   * Random quotes I got from other people. Nothing more, nothing less. Just for funny.
   */
}

class GameJoltLogin extends MusicBeatState
{
  var bgImage:FlxGraphic = Paths.image('menuDesat');
  var usernameText:FlxText;
  var tokenText:FlxText;
  var usernameBox:PsychUIInputText;
  var tokenBox:PsychUIInputText;
  var signInBox:FlxButton;
  var helpBox:FlxButton;
  var leaderBox:FlxButton;
  var logOutBox:FlxButton;
  var cancelBox:FlxButton;
  var username1:FlxText;
  var username2:FlxText;
  var baseX:Int = -275;

  public static var charBop:FlxSprite;

  override function create()
  {
    trace("gj api real? - " + Std.string(GJApi.initialized));
    FlxG.mouse.visible = true;

    var bg:FlxSprite = new FlxSprite().loadGraphic(bgImage);
    bg.setGraphicSize(FlxG.width, FlxG.height);
    bg.updateHitbox();
    bg.screenCenter();
    bg.scrollFactor.set();
    bg.antialiasing = true;
    bg.alpha = 0.25;
    add(bg);

    if (!GameJoltAPI.userLogin)
    {
      usernameText = new FlxText(0, 125, 300, "Username:", 14);
      tokenText = new FlxText(0, 225, 300, "Token:", 14);

      usernameBox = new PsychUIInputText(0, 175, 100, null, 8);
      tokenBox = new PsychUIInputText(0, 275, 200, null, 8);
      tokenBox.passwordMode = true;

      signInBox = new FlxButton(0, 475, "Sign In", function() {
        trace(usernameBox.text + " " + tokenBox.text);
        GameJoltAPI.authDaUser(usernameBox.text, tokenBox.text, true);
      });

      helpBox = new FlxButton(0, 550, "How do I get my GameJolt token?", () -> openLink('https://www.youtube.com/watch?v=T5-x7kAGGnE'));
      helpBox.color = FlxColor.fromRGB(84, 155, 149);

      add(usernameText);
      add(usernameBox);
      add(tokenText);
      add(tokenBox);
      add(signInBox);
      add(helpBox);
    }
    else
    {
      username1 = new FlxText(0, 95, 0, "You're signed in to GameJolt as:", 32);
      username1.alignment = CENTER;
      username1.screenCenter(X);
      username1.x += baseX;

      username2 = new FlxText(0, 145, 0, "" + GameJoltAPI.getUser() + "", 40);
      username2.alignment = CENTER;
      username2.screenCenter(X);
      username2.x += baseX;

      logOutBox = new FlxButton(0, 550, "Logout & Close", () -> GameJoltAPI.deAuthDaUser());
      logOutBox.color = FlxColor.RED; // FlxColor.fromRGB(255, 134, 61);

      add(username1);
      add(username2);
      add(logOutBox);
    }

    cancelBox = new FlxButton(0, 625, "Back", exit);
    add(cancelBox);

    forEachOfType(FlxText, item -> setTextData(item));
    forEachOfType(PsychUIInputText, item -> setTextData(item));
    forEachOfType(FlxButton, function(item:FlxButton) {
      item.screenCenter(X);
      item.setGraphicSize(Std.int(item.width) * 3);
      item.x += baseX;
    });

    super.create();
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    if (FlxG.keys.justPressed.ESCAPE) exit();
  }

  override function beatHit()
  {
    super.beatHit();
  }

  function setTextData(text:FlxText)
  {
    text.screenCenter(X);
    text.x += baseX;
    text.alignment = CENTER;

    if (GameJoltInfo.font != null) text.font = GameJoltInfo.font;
  }

  function exit()
  {
    Save.instance.flush();
    FlxG.mouse.visible = false;
    FlxG.switchState(() -> new funkin.ui.options.OptionsState());
  }

  function openLink(url:String)
  {
    #if linux
    Sys.command('/usr/bin/xdg-open', [url, "&"]);
    #else
    FlxG.openURL(url);
    #end
  }
}

/*
 * The toast things, pulled from Hololive Funkin
 * Thank you Firubii for the code for this!
 * https://twitter.com/firubiii
 * https://github.com/firubii
 * ILYSM
 */
class GJToastManager extends Sprite
{
  public static var ENTER_TIME:Float = 0.5;
  public static var DISPLAY_TIME:Float = 3.0;
  public static var LEAVE_TIME:Float = 0.5;
  public static var TOTAL_TIME:Float = ENTER_TIME + DISPLAY_TIME + LEAVE_TIME;

  var playTime:FlxTimer = new FlxTimer();

  public function new()
  {
    super();
    FlxG.signals.postStateSwitch.add(onStateSwitch);
    FlxG.signals.gameResized.add(onWindowResized);
  }

  /**
   * Create a toast!
   *
   * Usage: **Main.gjToastManager.createToast(iconPath, title, description);**
   * @param iconPath Path for the image **Paths.getLibraryPath("image/example.png")** (Set to null if you won't add an image, it's all OK)
   * @param title Title for the toast
   * @param description Description for the toast
   * @param sound Want to have an alert sound? Set this to **true**! Defaults to **false**.
   */
  public function createToast(iconPath:Null<String>, title:String, description:String, sound:Bool = false, color:String = '#3848CC'):Void
  {
    if (sound) FlxG.sound.play(Paths.sound('confirmMenu'));

    var toast = new Toast(iconPath, title, description, color);
    addChild(toast);

    playTime.start(TOTAL_TIME);
    playToasts();
  }

  public function playToasts():Void
  {
    for (i in 0...numChildren)
    {
      var child = getChildAt(i);
      FlxTween.cancelTweensOf(child);
      FlxTween.tween(child, {y: (numChildren - 1 - i) * child.height}, ENTER_TIME,
        {
          ease: FlxEase.quadOut,
          onComplete: function(tween:FlxTween) {
            FlxTween.cancelTweensOf(child);
            FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME,
              {
                ease: FlxEase.quadOut,
                startDelay: DISPLAY_TIME,
                onComplete: function(tween:FlxTween) {
                  cast(child, Toast).removeChildren();
                  removeChild(child);
                }
              });
          }
        });
    }
  }

  public function collapseToasts():Void
  {
    for (i in 0...numChildren)
    {
      var child = getChildAt(i);
      FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME,
        {
          ease: FlxEase.quadOut,
          onComplete: function(tween:FlxTween) {
            cast(child, Toast).removeChildren();
            removeChild(child);
          }
        });
    }
  }

  public function onStateSwitch():Void
  {
    if (!playTime.active) return;

    var elapsedSec = playTime.elapsedTime / 1000;
    if (elapsedSec < ENTER_TIME)
    {
      for (i in 0...numChildren)
      {
        var child = getChildAt(i);
        FlxTween.cancelTweensOf(child);
        FlxTween.tween(child, {y: (numChildren - 1 - i) * child.height}, ENTER_TIME - elapsedSec,
          {
            ease: FlxEase.quadOut,
            onComplete: function(tween:FlxTween) {
              FlxTween.cancelTweensOf(child);
              FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME,
                {
                  ease: FlxEase.quadOut,
                  startDelay: DISPLAY_TIME,
                  onComplete: function(tween:FlxTween) {
                    cast(child, Toast).removeChildren();
                    removeChild(child);
                  }
                });
            }
          });
      }
    }
    else if (elapsedSec < DISPLAY_TIME)
    {
      for (i in 0...numChildren)
      {
        var child = getChildAt(i);
        FlxTween.cancelTweensOf(child);
        FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME,
          {
            ease: FlxEase.quadOut,
            startDelay: DISPLAY_TIME - (elapsedSec - ENTER_TIME),
            onComplete: function(tween:FlxTween) {
              cast(child, Toast).removeChildren();
              removeChild(child);
            }
          });
      }
    }
    else if (elapsedSec < LEAVE_TIME)
    {
      for (i in 0...numChildren)
      {
        var child = getChildAt(i);
        FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME - (elapsedSec - ENTER_TIME - DISPLAY_TIME),
          {
            ease: FlxEase.quadOut,
            onComplete: function(tween:FlxTween) {
              cast(child, Toast).removeChildren();
              removeChild(child);
            }
          });
      }
    }
  }

  public function onWindowResized(x:Int, y:Int):Void
  {
    for (i in 0...numChildren)
    {
      var child = getChildAt(i);
      child.x = Lib.current.stage.stageWidth - child.width;
    }
  }
}

class Toast extends Sprite
{
  var back:Bitmap;
  var icon:Bitmap;
  var title:TextField;
  var desc:TextField;

  public function new(iconPath:Null<String>, titleText:String, description:String, color:String = '#3848CC')
  {
    super();
    back = new Bitmap(new BitmapData(500, 125, true, 0xFF000000));
    back.alpha = 0.9;
    back.x = back.y = 0;

    if (iconPath != null)
    {
      var iconBmp = FlxG.bitmap.add(Paths.image(iconPath));
      iconBmp.persist = true;
      icon = new Bitmap(iconBmp.bitmap);
      icon.width = 100;
      icon.height = 100;
      icon.x = 10;
      icon.y = 10;
    }

    title = new TextField();
    title.text = titleText.toUpperCase();
    title.setTextFormat(new TextFormat(openfl.utils.Assets.getFont(GameJoltInfo.fontPath).fontName, 30, FlxColor.fromString(color), true));
    title.wordWrap = true;
    title.width = 360;
    title.x = iconPath != null ? 120 : 5;
    title.y = 5;

    desc = new TextField();
    desc.text = description.toUpperCase();
    desc.setTextFormat(new TextFormat(openfl.utils.Assets.getFont(GameJoltInfo.fontPath).fontName, 24, FlxColor.WHITE));
    desc.wordWrap = true;
    desc.width = 360;
    desc.height = 95;
    desc.x = iconPath != null ? 120 : 5;
    desc.y = 35;

    if (titleText.length >= 25 || titleText.contains("\n"))
    {
      desc.y += 25;
      desc.height -= 25;
    }

    addChild(back);

    if (iconPath != null) addChild(icon);

    addChild(title);
    addChild(desc);

    width = back.width;
    height = back.height;
    x = Lib.current.stage.stageWidth - width;
    y = -height;
  }
}
#end
