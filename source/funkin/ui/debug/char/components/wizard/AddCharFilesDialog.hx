package funkin.ui.debug.char.components.wizard;

import haxe.io.Path;
import haxe.ui.containers.HBox;
import haxe.ui.containers.dialogs.Dialogs.FileDialogExtensionInfo;
import haxe.ui.components.Button;
import haxe.ui.components.TextField;
import funkin.ui.debug.char.handlers.CharCreatorStartupWizard;
import funkin.util.FileUtil;
import flxanimate.data.AnimationData.AnimAtlas;
import flxanimate.data.SpriteMapData.AnimateAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.net.FileFilter;

using StringTools;

@:build(haxe.ui.macros.ComponentMacros.build("assets/exclude/data/ui/char-creator/wizard/add-assets.xml"))
class AddCharFilesDialog extends DefaultWizardDialog
{
  override public function new()
  {
    super(UPLOAD_ASSETS);
  }

  var stupidFuckingRenderCheck:String = "";

  override public function showDialog(modal:Bool = true):Void
  {
    super.showDialog(modal);

    addAssetsBox.disabled = !params.generateCharacter;
    if (stupidFuckingRenderCheck == params.renderType) return;

    while (addAssetsBox.childComponents.length > 0)
      addAssetsBox.removeComponent(addAssetsBox.childComponents[0]);

    switch (params.renderType)
    {
      case "sparrow" | "multisparrow":
        if (params.renderType == "multisparrow") recursiveAssetsBox();
        else
          addAssetsBox.addComponent(new UploadAssetsBox("Put the path to the Spritesheet Image here.", FileUtil.FILE_EXTENSION_INFO_PNG));

      case "packer":
        addAssetsBox.addComponent(new UploadAssetsBox("Put the path to the Spritesheet Image here.", FileUtil.FILE_EXTENSION_INFO_PNG));

      case "atlas":
        addAssetsBox.addComponent(new UploadAssetsBox("Put the path to the Atlas .zip Data Here", FileUtil.FILE_EXTENSION_INFO_ZIP));
    }

    stupidFuckingRenderCheck = params.renderType;
  }

  override public function isNextStepAvailable():Bool
  {
    // we skippin if we aint even doin these
    if (addAssetsBox.disabled) return true;

    var uploadBoxes:Array<UploadAssetsBox> = [];
    for (i => box in addAssetsBox.childComponents)
    {
      if (stupidFuckingRenderCheck == "multisparrow" && i == addAssetsBox.childComponents.length - 1)
      {
        continue;
      }
      if (Std.isOfType(box, UploadAssetsBox)) uploadBoxes.push(cast box);
    }

    // check if the files even exist
    for (thingy in uploadBoxes)
    {
      if (!FileUtil.doesFileExist(thingy.daField.text)) return false;
    }

    // we do a little trollin
    return typeCheck(uploadBoxes);
  }

  public function typeCheck(uploadBoxes:Array<UploadAssetsBox>):Bool
  {
    switch (params.renderType)
    {
      case "sparrow" | "multisparrow":
        var files = [];
        for (uploadBox in uploadBoxes)
        {
          var imgPath = uploadBox.daField.text;
          var xmlPath = uploadBox.daField.text.replace(".png", ".xml");

          // checking if we even have the correct file types in the correct places
          if (Path.extension(imgPath) != "png" || Path.extension(xmlPath) != "xml") return false;

          // testing if we could actually use these
          var imgBytes = CharCreatorUtil.gimmeTheBytes(imgPath);
          var xmlBytes = CharCreatorUtil.gimmeTheBytes(xmlPath);

          var tempSprite = new FlxSprite();
          try
          {
            var bitmap = BitmapData.fromBytes(imgBytes);
            tempSprite.frames = FlxAtlasFrames.fromSparrow(bitmap, xmlBytes.toString());
          }
          catch (e)
          {
            tempSprite.destroy();
            return false;
          }

          tempSprite.destroy(); // fuck this guy i hate him
          files = files.concat([
            {
              name: imgPath,
              bytes: imgBytes
            },
            {
              name: xmlPath,
              bytes: xmlBytes
            }
          ]);
        }
        params.files = files;

        return true;

      case "packer": // essentially just sparrow...but different!
        var imgPath = uploadBoxes[0].daField.text;
        var txtPath = uploadBoxes[0].daField.text.replace(".png", ".txt");

        // checking if we even have the correct file types in the correct places
        if (Path.extension(imgPath) != "png" || Path.extension(txtPath) != "txt") return false;

        // testing if we could actually use these
        var imgBytes = CharCreatorUtil.gimmeTheBytes(imgPath);
        var txtBytes = CharCreatorUtil.gimmeTheBytes(txtPath);

        var tempSprite = new FlxSprite();
        try
        {
          var bitmap = BitmapData.fromBytes(imgBytes);
          tempSprite.frames = FlxAtlasFrames.fromSpriteSheetPacker(bitmap, txtBytes.toString());
        }
        catch (e)
        {
          tempSprite.destroy();
          return false;
        }
        tempSprite.destroy();

        params.files = [
          {name: imgPath, bytes: imgBytes}, {name: txtPath, bytes: txtBytes}];

        return true;

      case "atlas":
        var zipPath = uploadBoxes[0].daField.text;

        // checking if we even have the correct file types in the correct places
        if (Path.extension(zipPath) != "zip") return false;

        var zipBytes = CharCreatorUtil.gimmeTheBytes(zipPath);
        if (zipBytes == null) return false;

        var zipFiles = FileUtil.readZIPFromBytes(zipBytes);
        if (zipFiles.length == 0) return false;

        params.files = [];
        var hasAnimData:Bool = false;
        var hasSpritemapData:Bool = false;
        var hasImageData:Bool = false;

        for (entry in zipFiles)
        {
          if (entry.fileName.indexOf("/") != -1) entry.fileName = Path.withoutDirectory(entry.fileName);

          if (entry.fileName.endsWith("Animation.json"))
          {
            var fileData = entry.data.toString();
            var animData:AnimAtlas = haxe.Json.parse(CharCreatorUtil.normalizeJSONText(fileData));
            if (animData == null) return false;

            hasAnimData = true;
          }

          if (entry.fileName.startsWith("spritemap") && entry.fileName.endsWith(".json"))
          {
            var fileData = entry.data.toString();
            var spritemapData:AnimateAtlas = haxe.Json.parse(CharCreatorUtil.normalizeJSONText(fileData));
            if (spritemapData == null) return false;

            hasSpritemapData = true;
          }

          if (entry.fileName.startsWith("spritemap") && entry.fileName.endsWith(".png"))
          {
            if (BitmapData.fromBytes(entry.data) == null) return false;
            hasImageData = true;
          }
        }

        if (hasAnimData && hasSpritemapData && hasImageData) params.files.push({name: zipPath, bytes: zipBytes});
        return hasAnimData && hasSpritemapData && hasImageData;
    }

    return false;
  }

  function recursiveAssetsBox():Void
  {
    var uploadAssetsBox:UploadAssetsBox = new UploadAssetsBox("Put the path to the Spritesheet Image here.", FileUtil.FILE_EXTENSION_INFO_PNG);
    uploadAssetsBox.daField.onChange = (_) -> {
      uploadAssetsBox.daField.onChange = null;
      recursiveAssetsBox();
    };
    addAssetsBox.addComponent(uploadAssetsBox);
  }
}

class UploadAssetsBox extends HBox
{
  public var daField:TextField;

  override public function new(title:String = "", lookFor:FileDialogExtensionInfo = null)
  {
    super();

    styleString = "border:1px solid $normal-border-color";
    percentWidth = 100;
    height = 25;
    verticalAlign = "center";

    daField = new TextField();
    daField.placeholder = title;
    daField.height = this.height;
    daField.percentWidth = 75;
    addComponent(daField);

    var daButton = new Button();
    daButton.text = "Load File";
    daButton.height = this.height;
    daButton.percentWidth = 100 - daField.percentWidth;
    addComponent(daButton);

    daButton.onClick = function(_) {
      FileUtil.browseForBinaryFile("Load File", [lookFor], function(_) {
        if (_?.fullPath != null) daField.text = _.fullPath;
      });
    }
  }
}
