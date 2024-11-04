package funkin.ui.debug.char.pages;

import haxe.ui.containers.Box;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.menus.MenuCheckBox;
import haxe.ui.components.DropDown;
import haxe.ui.components.Label;
import haxe.ui.components.VerticalRule;
import funkin.data.stage.StageData;
import funkin.play.stage.Bopper;
import funkin.data.stage.StageData.StageDataCharacter;
import funkin.play.character.BaseCharacter.CharacterType;
import funkin.play.stage.StageProp;
import funkin.data.stage.StageRegistry;
import funkin.ui.debug.char.components.dialogs.*;
import flixel.util.FlxColor;

using StringTools;

class CharCreatorGameplayPage extends CharCreatorDefaultPage
{
  // stage
  public var curStage(default, set):String;
  public var stageProps:Array<StageProp> = [];
  public var charStageDatas:Map<CharacterType, StageDataCharacter> = [];
  public var stageZoom:Float = 1.0;

  // char
  public var currentCharacter:CharCreatorCharacter;

  // dialogs
  public var dialogMap:Map<CharDialogType, DefaultPageDialog> = [];

  // onion skin/ghost
  public var ghostCharacter:CharCreatorCharacter;

  override public function new(daState:CharCreatorState, wizardParams:WizardGenerateParams)
  {
    super(daState);
    curStage = "mainStage";

    Conductor.instance.onBeatHit.add(stageBeatHit);

    currentCharacter = new CharCreatorCharacter(wizardParams);
    add(currentCharacter);

    ghostCharacter = new CharCreatorCharacter(wizardParams);
    add(ghostCharacter);

    updateCharPerStageData();

    dialogMap.set(Animation, new AddAnimDialog(this, currentCharacter));
    dialogMap.set(Ghost, new GhostSettingsDialog(this));
  }

  override public function onDialogUpdate(dialog:DefaultPageDialog)
  {
    if (dialog == dialogMap[Animation])
    {
      var animDialog = cast(dialogMap[Animation], AddAnimDialog);
      var ghostDialog = cast(dialogMap[Ghost], GhostSettingsDialog);

      labelAnimName.text = animDialog.charAnimDropdown.selectedItem.text;
      labelAnimOffsetX.text = "" + currentCharacter.getAnimationData(labelAnimName.text).offsets[0];
      labelAnimOffsetY.text = "" + currentCharacter.getAnimationData(labelAnimName.text).offsets[1];

      GhostUtil.copyFromCharacter(ghostCharacter, currentCharacter);
      ghostDialog.ghostAnimDropdown.dataSource = animDialog.charAnimDropdown.dataSource;
    }
  }

  public function stageBeatHit()
  {
    for (spr in stageProps)
    {
      if (Std.isOfType(spr, Bopper))
      {
        var bop = cast(spr, Bopper);

        if (Conductor.instance.currentBeatTime % bop.danceEvery == 0) bop.dance();
      }
    }
  }

  var labelAnimName:Label;
  var labelAnimOffsetX:Label;
  var labelAnimOffsetY:Label;
  var labelCharType:Label;

  override public function fillUpBottomBar(left:Box, middle:Box, right:Box)
  {
    // ==================left==================
    labelAnimName = new Label();
    labelAnimName.text = "None";
    labelAnimName.styleNames = "infoText";
    labelAnimName.verticalAlign = "center";
    labelAnimName.tooltip = "Left Click to play the Next Animation";
    left.addComponent(labelAnimName);

    var leftRule1 = new VerticalRule();
    leftRule1.percentHeight = 80;
    left.addComponent(leftRule1);

    labelAnimOffsetX = new Label();
    labelAnimOffsetX.text = "0";
    labelAnimOffsetX.styleNames = "infoText";
    labelAnimOffsetX.verticalAlign = "center";
    labelAnimOffsetX.tooltip = "Left/Right Click to Increase/Decrease the Horizontal Offset.";
    left.addComponent(labelAnimOffsetX);

    var leftRule2 = new VerticalRule();
    leftRule2.percentHeight = 80;
    left.addComponent(leftRule2);

    labelAnimOffsetY = new Label();
    labelAnimOffsetY.text = "0";
    labelAnimOffsetY.styleNames = "infoText";
    labelAnimOffsetY.verticalAlign = "center";
    labelAnimOffsetY.tooltip = "Left/Right Click to Increase/Decrease the Vertical Offset.";
    left.addComponent(labelAnimOffsetY);

    // ==================middle==================

    // ==================right==================
    var typesArray = [BF, GF, DAD];

    labelCharType = new Label();
    labelCharType.text = "BF";
    labelCharType.styleNames = "infoText";
    labelCharType.verticalAlign = "center";
    labelCharType.tooltip = "Left Click/Right Click to switch to the Next/Previous Character Mode.";
    right.addComponent(labelCharType);

    var rightRule = new VerticalRule();
    rightRule.percentHeight = 80;
    right.addComponent(rightRule);

    var dropdown = new DropDown();
    dropdown.text = "Select Stage";
    dropdown.dropdownVerticalPosition = "top";
    dropdown.width = 125;
    dropdown.selectedItem = curStage;
    right.addComponent(dropdown);

    var stages = StageRegistry.instance.listEntryIds();
    stages.sort(funkin.util.SortUtil.alphabetically);
    for (aught in stages)
      dropdown.dataSource.add({text: aught});

    // ==================callback bs==================

    labelAnimName.onClick = function(_) {
      var drop = cast(dialogMap[Animation], AddAnimDialog).charAnimDropdown;
      if (drop.selectedIndex == -1) return;

      var id = drop.selectedIndex + 1;
      if (id >= drop.dataSource.size) id = 0;
      drop.selectedIndex = id;
      currentCharacter.playAnimation(currentCharacter.animations[drop.selectedIndex].name);
    }

    labelAnimName.onRightClick = function(_) {
      var drop = cast(dialogMap[Animation], AddAnimDialog).charAnimDropdown;
      if (drop.selectedIndex == -1) return;

      var id = drop.selectedIndex - 1;
      if (id < 0) id = drop.dataSource.size - 1;
      drop.selectedIndex = id;
      currentCharacter.playAnimation(currentCharacter.animations[drop.selectedIndex].name);
    }

    labelAnimOffsetX.onClick = _ -> changeCharAnimOffset(5);
    labelAnimOffsetX.onRightClick = _ -> changeCharAnimOffset(-5);
    labelAnimOffsetY.onClick = _ -> changeCharAnimOffset(0, 5);
    labelAnimOffsetY.onRightClick = _ -> changeCharAnimOffset(0, -5);

    labelCharType.onClick = function(_) {
      var idx = typesArray.indexOf(currentCharacter.characterType);
      idx++;
      if (idx >= typesArray.length) idx = 0;
      updateCharPerStageData(typesArray[idx]);
      labelCharType.text = Std.string(currentCharacter.characterType);
    }
    labelCharType.onRightClick = function(_) {
      var idx = typesArray.indexOf(currentCharacter.characterType);
      idx--;
      if (idx < 0) idx = typesArray.length - 1;
      updateCharPerStageData(typesArray[idx]);
      labelCharType.text = Std.string(currentCharacter.characterType);
    }
    dropdown.onChange = function(_) {
      curStage = dropdown.selectedItem?.text ?? curStage;
      updateCharPerStageData(currentCharacter.characterType);
    }
  }

  function changeCharAnimOffset(changeX:Int = 0, changeY:Int = 0)
  {
    if (currentCharacter.animations.length == 0) return;

    // we get the anim idx from dropdown cuz its our way to store current animation
    var drop = cast(dialogMap[Animation], AddAnimDialog).charAnimDropdown;
    var animOffsets = currentCharacter.animations[drop.selectedIndex].offsets;
    var newOffsets = [animOffsets[0] + changeX, animOffsets[1] + changeY];

    currentCharacter.animations[drop.selectedIndex].offsets = newOffsets;
    currentCharacter.setAnimationOffsets(currentCharacter.animations[drop.selectedIndex].name, newOffsets[0], newOffsets[1]); // todo: probs merge there two lol
    currentCharacter.playAnimation(currentCharacter.animations[drop.selectedIndex].name);

    // GhostUtil.copyFromCharacter(ghostCharacter, currentCharacter); very costly for memory! we're just gonna update the offsets
    ghostCharacter.animations[drop.selectedIndex].offsets = newOffsets;
    ghostCharacter.setAnimationOffsets(ghostCharacter.animations[drop.selectedIndex].name, newOffsets[0], newOffsets[1]); // todo: probs merge there two lol

    // might as well update the text
    labelAnimOffsetX.text = "" + newOffsets[0];
    labelAnimOffsetY.text = "" + newOffsets[1];
  }

  override public function fillUpPageSettings(item:haxe.ui.containers.menus.Menu)
  {
    var checkAnim = new MenuCheckBox();
    checkAnim.text = "View Animations";
    checkAnim.onChange = function(_) {
      dialogMap[Animation].hidden = !checkAnim.selected;
    }
    item.addComponent(checkAnim);

    var checkGhost = new MenuCheckBox();
    checkGhost.text = "Ghost Settings";
    checkGhost.onChange = function(_) {
      dialogMap[Ghost].hidden = !checkGhost.selected;
    }
    item.addComponent(checkGhost);
  }

  override public function performCleanup()
  {
    Conductor.instance.onBeatHit.remove(stageBeatHit);
  }

  static inline final GHOST_SKIN_ALPHA:Float = 0.3;

  public function updateCharPerStageData(type:CharacterType = BF)
  {
    if (charStageDatas[type] == null) return;

    currentCharacter.zIndex = charStageDatas[type].zIndex;
    currentCharacter.x = charStageDatas[type].position[0] - currentCharacter.characterOrigin.x;
    currentCharacter.y = charStageDatas[type].position[1] - currentCharacter.characterOrigin.y;
    currentCharacter.totalScale = currentCharacter.characterScale * charStageDatas[type].scale;
    currentCharacter.flipX = (type == BF ? !currentCharacter.characterFlipX : currentCharacter.characterFlipX);

    ghostCharacter.characterType = currentCharacter.characterType = type;

    ghostCharacter.alpha = GHOST_SKIN_ALPHA;
    ghostCharacter.zIndex = currentCharacter.zIndex - 1; // should onion skin be behind or in front?
    ghostCharacter.x = charStageDatas[type].position[0] - ghostCharacter.characterOrigin.x;
    ghostCharacter.y = charStageDatas[type].position[1] - ghostCharacter.characterOrigin.y;
    ghostCharacter.totalScale = ghostCharacter.characterScale * charStageDatas[type].scale;
    ghostCharacter.flipX = (type == BF ? !ghostCharacter.characterFlipX : ghostCharacter.characterFlipX);

    sortAssets();
  }

  function sortAssets()
  {
    sort(funkin.util.SortUtil.byZIndex, flixel.util.FlxSort.ASCENDING);
  }

  function set_curStage(value:String)
  {
    this.curStage = value;

    // clear da assets
    while (stageProps.length > 0)
    {
      var memb = stageProps.pop();
      memb.kill();
      remove(memb, true);
      memb.destroy();
    }

    var data = StageRegistry.instance.parseEntryData(curStage);
    if (data == null) return curStage;

    Paths.setCurrentLevel(data.directory ?? "shared");
    openfl.utils.Assets.loadLibrary(data.directory ?? "shared").onComplete(_ -> generateStageFromData(data)); // loading shit may take a while cuz web!

    return curStage;
  }

  function generateStageFromData(data:StageData)
  {
    if (data == null) return;

    stageZoom = data.cameraZoom ?? 1.0;
    charStageDatas.set(BF, data.characters.bf);
    charStageDatas.set(GF, data.characters.gf);
    charStageDatas.set(DAD, data.characters.dad);

    for (prop in data.props)
    {
      var spr:StageProp = (prop.danceEvery ?? 0) == 0 ? new StageProp() : new Bopper(prop.danceEvery);

      if (prop.animations.length > 0)
      {
        switch (prop.animType)
        {
          case 'packer':
            spr.loadPacker(prop.assetPath);
          default:
            spr.loadSparrow(prop.assetPath);
        }
      }
      else if (prop.assetPath.startsWith("#"))
      {
        var width:Int = 1;
        var height:Int = 1;
        switch (prop.scale)
        {
          case Left(value):
            width = Std.int(value);
            height = Std.int(value);

          case Right(values):
            width = Std.int(values[0]);
            height = Std.int(values[1]);
        }
        spr.makeSolidColor(width, height, FlxColor.fromString(prop.assetPath));
      }
      else
      {
        spr.loadTexture(prop.assetPath);
        spr.active = false;
      }

      if (spr.frames == null || spr.frames.numFrames == 0)
      {
        @:privateAccess
        trace('    ERROR: Could not build texture for prop. Check the asset path (${Paths.currentLevel ?? 'default'}, ${prop.assetPath}).');
        continue;
      }

      if (!prop.assetPath.startsWith("#"))
      {
        switch (prop.scale)
        {
          case Left(value):
            spr.scale.set(value, value);

          case Right(values):
            spr.scale.set(values[0], values[1]);
        }
      }
      spr.updateHitbox();

      spr.setPosition(prop.position[0], prop.position[1]);
      spr.alpha = prop.alpha;
      spr.angle = prop.angle;
      spr.antialiasing = !prop.isPixel;
      spr.pixelPerfectPosition = spr.pixelPerfectRender = prop.isPixel;
      spr.scrollFactor.set(prop.scroll[0], prop.scroll[1]);
      spr.color = FlxColor.fromString(prop.color);
      @:privateAccess spr.blend = openfl.display.BlendMode.fromString(prop.blend);
      spr.zIndex = prop.zIndex;
      spr.flipX = prop.flipX;
      spr.flipY = prop.flipY;

      switch (prop.animType)
      {
        case 'packer':
          for (anim in prop.animations)
          {
            spr.animation.add(anim.name, anim.frameIndices, anim.frameRate, anim.looped, anim.flipX, anim.flipY);
            if (Std.isOfType(spr, Bopper)) cast(spr, Bopper).setAnimationOffsets(anim.name, anim.offsets[0], anim.offsets[1]);
          }
        default: // 'sparrow'
          funkin.util.assets.FlxAnimationUtil.addAtlasAnimations(spr, prop.animations);
          if (Std.isOfType(spr, Bopper))
          {
            for (anim in prop.animations)
              cast(spr, Bopper).setAnimationOffsets(anim.name, anim.offsets[0], anim.offsets[1]);
          }
      }

      add(spr);
      stageProps.push(spr);
    }

    sortAssets();
  }
}

enum CharDialogType
{
  Animation;
  Data;
  Ghost;
}
