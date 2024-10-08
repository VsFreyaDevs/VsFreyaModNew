package funkin.ui.options;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;
import funkin.ui.AtlasText.AtlasFont;
import funkin.ui.options.OptionsState.Page;
import funkin.graphics.FunkinCamera;
import funkin.ui.TextMenuList.TextMenuItem;
import funkin.audio.FunkinSound;
import funkin.ui.options.MenuItemEnums;
import funkin.ui.options.items.CheckboxPreferenceItem;
import funkin.ui.options.items.NumberPreferenceItem;
import funkin.ui.options.items.EnumPreferenceItem;
import funkin.graphics.FunkinSprite;
import funkin.mobile.ui.FunkinBackspace;
#if mobile
import funkin.mobile.util.TouchUtil;
import funkin.mobile.util.SwipeUtil;
#end

class PreferencesMenu extends Page
{
  inline static final DESC_BG_OFFSET_X = 15.0;
  inline static final DESC_BG_OFFSET_Y = 15.0;
  static var DESC_TEXT_WIDTH:Null<Float>;

  var items:TextMenuList;
  var preferenceItems:FlxTypedSpriteGroup<FlxSprite>;

  var preferenceDesc:Array<String> = [];

  var menuCamera:FlxCamera;
  var camDesc:FlxCamera;
  var camWhat:FlxCamera;
  var camFollow:FlxObject;

  var boyFriend:FlxSprite;

  var descText:FlxText;
  var descTextBG:FlxSprite;

  public function new()
  {
    super();

    if (DESC_TEXT_WIDTH == null) DESC_TEXT_WIDTH = FlxG.width * 0.8;

    menuCamera = new FunkinCamera('prefMenu');
    FlxG.cameras.add(menuCamera, false);
    menuCamera.bgColor = 0x0;
    camera = menuCamera;
    camWhat = new FlxCamera();
    camWhat.bgColor.alpha = 0;
    FlxG.cameras.add(camWhat, false);
    camDesc = new FlxCamera();
    camDesc.bgColor.alpha = 0;
    FlxG.cameras.add(camDesc, false);

    add(items = new TextMenuList());
    add(preferenceItems = new FlxTypedSpriteGroup<FlxSprite>());

    descTextBG = new FlxSprite().makeGraphic(1, 1, 0x80000000);
    descTextBG.scrollFactor.set();
    descTextBG.antialiasing = false;
    descTextBG.active = false;
    descText = new FlxText(0, 0, 0, "what the fuck", 26);
    descText.scrollFactor.set();
    descText.font = Paths.font("vcr.ttf");
    descText.alignment = CENTER;
    descText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
    descTextBG.x = descText.x - DESC_BG_OFFSET_X;
    descTextBG.scale.x = descText.width + DESC_BG_OFFSET_X * 2;
    descTextBG.updateHitbox();

    descText.cameras = [camDesc];
    descTextBG.cameras = [camDesc];

    try
    {
      boyFriend = new FlxSprite(0, 0);
      boyFriend.frames = Paths.getSparrowAtlas('cheerFriend');
      boyFriend.animation.addByIndices('off', 'yayy0', [0, 1], '', 24, true);
      boyFriend.animation.addByPrefix('on', 'yayy0', 24, false);
      boyFriend.animation.addByPrefix('onLoop', 'yayy loop', 24, true);
      boyFriend.animation.play('off', true);
      boyFriend.screenCenter();
      boyFriend.x += 750;
      boyFriend.cameras = [camWhat];
      boyFriend.antialiasing = Preferences.antialiasing;
    }
    catch (e:Any)
      trace("BOYFRIEND GOT KILLED IN A SPREE, SORRY!!!!");

    descText.cameras = [camDesc];
    descTextBG.cameras = [camDesc];

    try
    {
      add(boyFriend);
    }
    catch (e:Any)
      trace("I WILL REVIVE HIM BACK DW ABOUT IT!!!!!");

    createPrefItems();

    add(descTextBG);
    add(descText);

    camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
    if (items != null) camFollow.y = items.selectedItem.y;

    menuCamera.follow(camFollow, null, 0.06);
    var margin = 100;
    menuCamera.deadzone.set(0, margin, menuCamera.width, menuCamera.height - margin * 2);
    // menuCamera.minScrollY = 0;

    var prevIndex = 0;
    var prevItem = items.selectedItem;

    items.onChange.add((selected) -> {
      camFollow.y = selected.y;

      prevItem.x = 120;
      selected.x = 150;

      final newDesc = preferenceDesc[items.selectedIndex];
      final showDesc = (newDesc != null && newDesc.length != 0);

      descText.visible = descTextBG.visible = showDesc;

      if (showDesc)
      {
        descText.text = newDesc;
        descText.fieldWidth = descText.width > DESC_TEXT_WIDTH ? DESC_TEXT_WIDTH : 0;
        descText.screenCenter(X).y = FlxG.height * 0.85 - descText.height * 0.5;
        descTextBG.x = descText.x - DESC_BG_OFFSET_X;
        descTextBG.y = descText.y - DESC_BG_OFFSET_Y;
        descTextBG.scale.set(descText.width + DESC_BG_OFFSET_X * 2, descText.height + DESC_BG_OFFSET_Y * 2);
        descTextBG.updateHitbox();
      }

      prevIndex = items.selectedIndex;
      prevItem = selected;
    });

    #if mobile
    backButton = new FunkinBackspace(FlxG.width * 0.77, FlxG.height * 0.85, flixel.util.FlxColor.BLACK);
    add(backButton);
    #end
  }

  /**
   * Create the menu items for each of the preferences.
   */
  function createPrefItems():Void
  {
    createPrefHeader('Gameplay');
    createPrefItemCheckbox('Downscroll', 'Enable to make notes move downwards', function(value:Bool):Void {
      Preferences.downscroll = value;
      yeahBf(value);
    }, Preferences.downscroll);
    createPrefItemCheckbox('Middlescroll', 'Enable to move the player strums to the center', function(value:Bool):Void {
      Preferences.middlescroll = value;
      yeahBf(value);
    }, Preferences.middlescroll);
    #if FEATURE_GHOST_TAPPING
    createPrefItemCheckbox('Ghost Tapping', 'Disable to get miss penalties on key presses\nThis is the thing people have been begging for forever lolol',
      function(value:Bool):Void {
        Preferences.ghostTapping = value;
        yeahBf(value);
      }, Preferences.ghostTapping);
    #end
    createPrefItemCheckbox('Bad/Shits as Combo Breaks',
      'Enable to break combo whenever you get a Bad or Shit rating\n(The result screen may still count it though)', function(value:Bool):Void {
        Preferences.badsShitsCauseMiss = value;
        yeahBf(value);
    }, Preferences.badsShitsCauseMiss);
    createPrefHeader('Visuals and Graphics');
    createPrefItemCheckbox('Note Splashes', 'Disable to remove splash animations when hitting notes', function(value:Bool):Void {
      Preferences.noteSplash = value;
      yeahBf(value);
    }, Preferences.noteSplash);
    createPrefItemCheckbox('Flashing Lights', 'Disable to dampen some flashing effects', function(value:Bool):Void {
      Preferences.flashingLights = value;
      yeahBf(value);
    }, Preferences.flashingLights);
    createPrefItemCheckbox('Antialiasing', 'Disable to increase performance at the cost of sharper visuals.', function(value:Bool):Void {
      Preferences.antialiasing = value;
      boyFriend.antialiasing = value;
      yeahBf(value);
    }, Preferences.antialiasing);
    createPrefItemCheckbox('Colored Health Bar', 'Enable to make the health bar use icon-based colors', function(value:Bool):Void {
      Preferences.coloredHealthBar = value;
      yeahBf(value);
    }, Preferences.coloredHealthBar);
    createPrefItemCheckbox('Show Timings', 'Enable to show your input timings in ms\nwhenever you hit a note', function(value:Bool):Void {
      Preferences.showTimings = value;
      yeahBf(value);
    }, Preferences.showTimings);
    createPrefItemNumber('Lane Underlay', 'Set the transparency of the lane underlay\nbehind the player\'s strums', function(value:Float) {
      Preferences.laneAlpha = Std.int(value);
      yeahBf(false);
    }, null, Preferences.laneAlpha, 0, 100, 1, 0);
    createPrefItemCheckbox('Combo Break Display', 'Enable to show your combo breaks during gameplay', function(value:Bool):Void {
      Preferences.comboBreakText = value;
      yeahBf(value);
    }, Preferences.comboBreakText);
    createPrefItemNumber('Strum Transparency', 'Set the transparency of both the CPU & player\'s strums', function(value:Float) {
      Preferences.strumAlpha = Std.int(value);
      yeahBf(false);
    }, null, Preferences.strumAlpha, 0, 100, 1, 0);
    createPrefItemCheckbox('Camera Zooming on Beat', 'Disable to stop the camera from bouncing to the song', function(value:Bool):Void {
      Preferences.zoomCamera = value;
      yeahBf(value);
    }, Preferences.zoomCamera);
    #if web
    createPrefItemCheckbox('Unlocked Framerate', 'Enable to unlock the framerate', function(value:Bool):Void {
      Preferences.unlockedFramerate = value;
      yeahBf(value);
    }, Preferences.unlockedFramerate);
    #else
    createPrefItemNumber('FPS Cap', 'Set the maximum framerate that the game targets', function(value:Float) {
      Preferences.framerate = Std.int(value);
      yeahBf(false);
    }, null, Preferences.framerate, #if mobile 60 #else 24 #end, 640, 1, 0);
    #end
    createPrefHeader('Miscellaneous');
    createPrefItemCheckbox('Naughtiness', 'Enable so your mom won\'t scream at ya, right now it doesn\'nt do much', function(value:Bool):Void {
      Preferences.naughtyness = value;
      yeahBf(value);
    }, Preferences.naughtyness);
    createPrefItemCheckbox('Stats Counter', 'Enable to show FPS and other debug stats', function(value:Bool):Void {
      Preferences.debugDisplay = value;
      yeahBf(value);
    }, Preferences.debugDisplay);
    createPrefItemCheckbox('Auto Pause', 'Enable so it automatically pauses the game when it loses focus', function(value:Bool):Void {
      Preferences.autoPause = value;
      yeahBf(value);
    }, Preferences.autoPause);
    #if mobile
    createPrefItemCheckbox('Allow Screen Timeout', "Enable to let the device sleep on its own while\nin the game", function(value:Bool):Void {
      Preferences.screenTimeout = value;
      yeahBf(value);
    }, Preferences.screenTimeout);
    createPrefItemCheckbox('Vibration', 'Enable to let the device vibrate in certain situations\nduring gameplay', function(value:Bool):Void {
      Preferences.vibration = value;
      yeahBf(value);
    }, Preferences.vibration);
    #end
  }

  function yeahBf(help:Bool):Void
  {
    if (boyFriend != null)
    {
      if (help) boyFriend.animation.play('on', true);
      else
        boyFriend.animation.play('off', true);
    }
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    // Indent the selected item.
    items.forEach(function(daItem:TextMenuItem) {
      var thyOffset:Int = 0;

      // Initializing thy text width (if thou text present)
      var thyTextWidth:Int = 0;
      if (Std.isOfType(daItem, EnumPreferenceItem)) thyTextWidth = cast(daItem, EnumPreferenceItem).lefthandText.getWidth();
      else if (Std.isOfType(daItem, NumberPreferenceItem)) thyTextWidth = cast(daItem, NumberPreferenceItem).lefthandText.getWidth();

      if (thyTextWidth != 0)
      {
        // Magic number because of the weird offset thats being added by default
        thyOffset += thyTextWidth - 75;
      }

      if (items.selectedItem == daItem) thyOffset += 150;
      else
        thyOffset += 120;

      daItem.x = thyOffset;
    });

    if (boyFriend != null) if (boyFriend.animation.curAnim != null) if (boyFriend.animation.curAnim.finished
      && boyFriend.animation.curAnim.name == 'on') boyFriend.animation.play('onLoop', true);

    #if mobile
    if (items.enabled
      && !items.busy
      && TouchUtil.justReleased
      && !SwipeUtil.swipeAny
      && (TouchUtil.touch != null
        && TouchUtil.overlapsComplexPoint(items.selectedItem,
          FlxPoint.weak(TouchUtil.touch.x, TouchUtil.touch.y + camFollow.y - ((items.selectedIndex == 0) ? 20 : 130)), false, menuCamera)))
    {
      items.accept();
    }
    #end
  }

  // - Preference item creation methods -
  // Should be moved into a separate PreferenceItems class but you can't access PreferencesMenu.items and PreferencesMenu.preferenceItems from outside.

  /**
   * Creates a non-interacted pref item, pretty good for when you wanna do some categorizing here.
   */
  function createPrefHeader(header:String):Void
  {
    var blank:FlxSprite = new FlxSprite(-100000000, (items.length - 1 + 1)).makeGraphic(10, 10, 0x00000000);
    items.createItem(0, (120 * items.length) + 30, header, AtlasFont.BOLD, () ->
      {
        // swag
      }, true);
    preferenceItems.add(blank);
    preferenceDesc.push("CATEGORY HEADER!!!!");
  }

  /**
   * Creates a pref item that works with booleans
   * @param onChange Gets called every time the player changes the value; use this to apply the value
   * @param defaultValue The value that is loaded in when the pref item is created (usually your Preferences.settingVariable)
   */
  function createPrefItemCheckbox(prefName:String, prefDesc:String, onChange:Bool->Void, defaultValue:Bool):Void
  {
    var checkbox:CheckboxPreferenceItem = new CheckboxPreferenceItem(0, 120 * (items.length - 1 + 1), defaultValue);

    items.createItem(0, (120 * items.length) + 30, prefName, AtlasFont.BOLD, function() {
      var value = !checkbox.currentValue;
      onChange(value);
      checkbox.currentValue = value;
    }, true);

    preferenceItems.add(checkbox);
    preferenceDesc.push(prefDesc);
  }

  /**
   * Creates a pref item that works with general numbers
   * @param onChange Gets called every time the player changes the value; use this to apply the value
   * @param valueFormatter Will get called every time the game needs to display the float value; use this to change how the displayed value looks
   * @param defaultValue The value that is loaded in when the pref item is created (usually your Preferences.settingVariable)
   * @param min Minimum value (example: 0)
   * @param max Maximum value (example: 10)
   * @param step The value to increment/decrement by (default = 0.1)
   * @param precision Rounds decimals up to a `precision` amount of digits (ex: 4 -> 0.1234, 2 -> 0.12)
   */
  function createPrefItemNumber(prefName:String, prefDesc:String, onChange:Float->Void, ?valueFormatter:Float->String, defaultValue:Int, min:Int, max:Int,
      step:Float = 0.1, precision:Int):Void
  {
    var item = new NumberPreferenceItem(0, (120 * items.length) + 30, prefName, defaultValue, min, max, step, precision, onChange, valueFormatter);
    items.addItem(prefName, item);

    preferenceItems.add(item.lefthandText);
    preferenceDesc.push(prefDesc);
  }

  /**
   * Creates a pref item that works with number percentages
   * @param onChange Gets called every time the player changes the value; use this to apply the value
   * @param defaultValue The value that is loaded in when the pref item is created (usually your Preferences.settingVariable)
   * @param min Minimum value (default = 0)
   * @param max Maximum value (default = 100)
   */
  function createPrefItemPercentage(prefName:String, prefDesc:String, onChange:Int->Void, defaultValue:Int, min:Int = 0, max:Int = 100):Void
  {
    var newCallback = function(value:Float) {
      onChange(Std.int(value));
    };
    var formatter = function(value:Float) {
      return '${value}%';
    };
    var item = new NumberPreferenceItem(0, (120 * items.length) + 30, prefName, defaultValue, min, max, 10, 0, newCallback, formatter);
    items.addItem(prefName, item);

    preferenceItems.add(item.lefthandText);
    preferenceDesc.push(prefDesc);
  }

  /**
   * Creates a pref item that works with enums
   * @param values Maps enum values to display strings _(ex: `NoteHitSoundType.PingPong => "Ping pong"`)_
   * @param onChange Gets called every time the player changes the value; use this to apply the value
   * @param defaultValue The value that is loaded in when the pref item is created (usually your Preferences.settingVariable)
   */
  function createPrefItemEnum(prefName:String, prefDesc:String, values:Map<String, String>, onChange:String->Void, defaultValue:String):Void
  {
    var item = new EnumPreferenceItem(0, (120 * items.length) + 30, prefName, values, defaultValue, onChange);
    items.addItem(prefName, item);

    preferenceItems.add(item.lefthandText);
    preferenceDesc.push(prefDesc);
  }
}
