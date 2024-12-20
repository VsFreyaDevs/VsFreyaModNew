package funkin.ui.debug.char.handlers;

import funkin.ui.debug.char.components.wizard.*;
import haxe.ui.containers.dialogs.Dialog;
import haxe.io.Bytes;

// wizard? like that one coder???
class CharCreatorStartupWizard
{
  public static var wizardProcessRunning:Bool = false;

  public static var onComplete:WizardGenerateParams->Void = null;
  public static var onQuit:Void->Void = null;

  public static var dialogArray:Array<DefaultWizardDialog> = [];
  public static var params:WizardGenerateParams =
    {
      characterID: "",
      generateCharacter: false,
      generatePlayerData: false,
      renderType: "sparrow",
      files: []
    }

  public static function startWizard(state:CharCreatorState, onComplete:WizardGenerateParams->Void = null, onQuit:Void->Void = null)
  {
    if (wizardProcessRunning) return;

    CharCreatorStartupWizard.onComplete = onComplete;
    CharCreatorStartupWizard.onQuit = onQuit;
    refreshDialogArray();

    dialogArray[0].showDialog();
    wizardProcessRunning = true;
  }

  static function refreshDialogArray()
  {
    if (wizardProcessRunning) return;

    while (dialogArray.length > 0)
    {
      var dialog = dialogArray.pop();
      dialog.destroy();
    }

    dialogArray = [];

    dialogArray.push(new StartWizardDialog());
    dialogArray.push(new RenderWizardDialog());
    dialogArray.push(new AddCharFilesDialog());
    dialogArray.push(new ConfirmDialog());
  }
}

typedef WizardGenerateParams =
{
  var characterID:String;
  var generateCharacter:Bool;
  var generatePlayerData:Bool;
  var renderType:String;
  var files:Array<WizardFile>;
}

typedef WizardFile =
{
  var name:String;
  var bytes:Bytes;
}

enum abstract WizardStep(Int) from Int to Int
{
  public var STARTUP = 0;
  public var SELECT_CHAR_TYPE = 1;
  public var UPLOAD_ASSETS = 2;
  public var UPLOAD_PLAYER_ASSETS = -1; // not implemented yet!
  public var CONFIRM = 3;
}
