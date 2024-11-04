package funkin.ui.debug.char;

import haxe.ui.core.Screen;
import haxe.ui.backend.flixel.UIState;
import haxe.ui.containers.windows.WindowManager;
import funkin.audio.FunkinSound;
import funkin.input.Cursor;
import funkin.ui.debug.char.pages.*;
import funkin.util.MouseUtil;
import funkin.util.WindowUtil;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxG;

/**
 * also made by kolo
 * my second slightly more disappointing son
 */
@:build(haxe.ui.ComponentBuilder.build("assets/exclude/data/ui/char-creator/main-view.xml"))
class CharCreatorState extends UIState
{
  var bg:FlxSprite;

  var camHUD:FlxCamera;
  var camGame:FlxCamera;

  var selectedPage:CharCreatorDefaultPage = null;
  var pages:Map<CharCreatorPage, CharCreatorDefaultPage> = []; // collect my pages

  override public function create()
  {
    WindowManager.instance.reset();
    FlxG.sound.music?.stop();
    WindowUtil.setWindowTitle("Friday Night Funkin\' Character Creator");

    camGame = new FlxCamera();
    camHUD = new FlxCamera();
    camHUD.bgColor.alpha = 0;

    FlxG.cameras.reset(camGame);
    FlxG.cameras.add(camHUD, false);
    FlxG.cameras.setDefaultDrawTarget(camGame, true);

    persistentUpdate = false;

    bg = FlxGridOverlay.create(10, 10);
    bg.scrollFactor.set();
    add(bg);

    super.create(); // add hud
    setupUICallbacks();

    root.scrollFactor.set();
    root.cameras = [camHUD];
    root.width = FlxG.width;
    root.height = FlxG.height;

    WindowManager.instance.container = root;
    // Screen.instance.addComponent(root);

    Cursor.show();

    // I feel like there should be more editor themes
    // I don't dislike Artistic expression or anythin I had simply heard it a million times while making da editors and I'm getting a bit tired of it
    // plus it's called *chart*EditorLoop so CHECKMATE liberals hehe -Kolo
    FunkinSound.playMusic('chartEditorLoop',
      {
        overrideExisting: true,
        restartTrack: true
      });

    FlxG.sound.music.fadeIn(10, 0, 1);

    this.startWizard(wizardComplete, exitEditor);
  }

  override public function update(elapsed:Float)
  {
    super.update(elapsed);
    Conductor.instance.update();

    if (FlxG.mouse.justPressed || FlxG.mouse.justPressedRight) FunkinSound.playOnce(Paths.sound("chartingSounds/ClickDown"));
    if (FlxG.mouse.justReleased || FlxG.mouse.justReleasedRight) FunkinSound.playOnce(Paths.sound("chartingSounds/ClickUp"));

    if (!CharCreatorUtil.isCursorOverHaxeUI)
    {
      if (camGame.zoom > 0.11) MouseUtil.mouseWheelZoom();
      MouseUtil.mouseCamDrag();
    }

    bg.scale.set(1 / camGame.zoom, 1 / camGame.zoom);
  }

  function setupUICallbacks()
  {
    menubarOptionGameplay.onChange = function(_) switchToPage(Gameplay);
  }

  function wizardComplete(params:WizardGenerateParams)
  {
    // clear da pages sorry chat
    remove(selectedPage);
    selectedPage = null;

    var allPages = [for (k => p in pages) p];
    while (allPages.length > 0)
    {
      var page = allPages.pop();
      page.performCleanup();
      page.kill();
      page.destroy();
    }

    pages.clear();

    if (params.generateCharacter) pages.set(Gameplay, new CharCreatorGameplayPage(this, params));

    menubarOptionGameplay.disabled = !params.generateCharacter;
    menubarOptionCharSelect.disabled = menubarOptionFreeplay.disabled = menubarOptionResults.disabled = !params.generatePlayerData;

    menubarOptionGameplay.selected = menubarOptionCharSelect.selected = menubarOptionFreeplay.selected = menubarOptionResults.selected = false;
    (params.generateCharacter ? menubarOptionGameplay : menubarOptionCharSelect).selected = true;

    switchToPage(params.generateCharacter ? Gameplay : CharacterSelect);
  }

  function exitEditor()
  {
    Cursor.hide();
    FlxG.switchState(() -> new DebugMenuSubState());
    FlxG.sound.music.stop();
  }

  function switchToPage(page:CharCreatorPage)
  {
    if (selectedPage == pages[page]) return;

    for (box in [bottomBarLeftBox, bottomBarMiddleBox, bottomBarRightBox, menubarMenuSettings])
    {
      while (box.childComponents.length > 0)
        box.removeComponent(box.childComponents[0]);
    }

    remove(selectedPage);
    selectedPage = pages[page];
    add(selectedPage);

    selectedPage.fillUpBottomBar(bottomBarLeftBox, bottomBarMiddleBox, bottomBarRightBox);
    selectedPage.fillUpPageSettings(menubarMenuSettings);
  }
}

enum CharCreatorPage
{
  Gameplay;
  CharacterSelect;
  Freeplay;
  ResultScreen;
}
