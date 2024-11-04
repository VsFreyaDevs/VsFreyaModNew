package funkin.ui.debug.char.util;

import funkin.ui.debug.char.animate.CharSelectAtlasSprite;
import funkin.ui.debug.char.pages.CharCreatorGameplayPage;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;

// utilities for the onion skin/ghost character
class GhostUtil
{
  public static function copyFromCharacter(ghost:CharCreatorCharacter, player:CharCreatorCharacter)
  {
    ghost.generatedParams = player.generatedParams;
    ghost.atlasCharacter = null;

    switch (player.renderType)
    {
      case "sparrow" | "multisparrow":
        if (ghost.generatedParams.files.length != 2) return; // img and data

        var img = BitmapData.fromBytes(ghost.generatedParams.files[0].bytes);
        var data = ghost.generatedParams.files[1].bytes.toString();
        ghost.frames = FlxAtlasFrames.fromSparrow(img, data);

      case "packer":
        if (ghost.generatedParams.files.length != 2) return; // img and data

        var img = BitmapData.fromBytes(ghost.generatedParams.files[0].bytes);
        var data = ghost.generatedParams.files[1].bytes.toString();
        ghost.frames = FlxAtlasFrames.fromSpriteSheetPacker(img, data);

      case "atlas": // todo
        if (ghost.generatedParams.files.length != 1) return; // zip file with all the data
        ghost.atlasCharacter = new CharSelectAtlasSprite(0, 0, ghost.generatedParams.files[0].bytes);

        ghost.atlasCharacter.alpha = 0.0001;
        ghost.atlasCharacter.draw();
        ghost.atlasCharacter.alpha = 1.0;

        ghost.atlasCharacter.x = ghost.x;
        ghost.atlasCharacter.y = ghost.y;
        ghost.atlasCharacter.alpha *= ghost.alpha;
        ghost.atlasCharacter.flipX = ghost.flipX;
        ghost.atlasCharacter.flipY = ghost.flipY;
        ghost.atlasCharacter.scrollFactor.copyFrom(ghost.scrollFactor);
        @:privateAccess ghost.atlasCharacter.cameras = ghost._cameras; // _cameras instead of cameras because get_cameras() will not return null

      default: // nothing, what the fuck are you even doing
    }

    ghost.globalOffsets = player.globalOffsets.copy();

    for (anim in player.animations)
    {
      ghost.addAnimation(anim.name, anim.prefix, anim.offsets, anim.frameIndices, anim.assetPath, anim.frameRate, anim.looped, anim.flipX, anim.flipY);
      ghost.setAnimationOffsets(anim.name, anim.offsets[0], anim.offsets[1]);
    }
  }
}
