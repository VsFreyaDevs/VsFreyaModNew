package funkin.util;

import flixel.util.FlxSignal.FlxTypedSignal;

using StringTools;

/**
 * Utilities for operating on the current window, such as changing the title.
 */
#if (cpp && windows)
@:cppFileCode('
#include <iostream>
#include <windows.h>
#include <psapi.h>
')
#end
@:keep class WindowUtil
{
  /**
   * Runs platform-specific code to open a URL in a web browser.
   * @param targetUrl The URL to open.
   */
  public static function openURL(targetUrl:String):Void
  {
    #if FEATURE_OPEN_URL
    #if linux
    Sys.command('/usr/bin/xdg-open $targetUrl &');
    #else
    // This should work on Windows and HTML5.
    FlxG.openURL(targetUrl);
    #end
    #else
    throw 'Cannot open URLs on this platform.';
    #end
  }

  /**
   * Runs platform-specific code to open a path in the file explorer.
   * @param targetPath The path to open.
   */
  public static function openFolder(targetPath:String):Void
  {
    #if FEATURE_OPEN_URL
    #if windows
    Sys.command('explorer', [targetPath.replace('/', '\\')]);
    #elseif mac
    Sys.command('open', [targetPath]);
    #elseif linux
    Sys.command('xdg-open $targetPath &');
    #end
    #else
    throw 'Cannot open URLs on this platform.';
    #end
  }

  /**
   * Runs platform-specific code to open a file explorer and select a specific file.
   * @param targetPath The path of the file to select.
   */
  public static function openSelectFile(targetPath:String):Void
  {
    #if FEATURE_OPEN_URL
    #if windows
    Sys.command('explorer', ['/select,' + targetPath.replace('/', '\\')]);
    #elseif mac
    Sys.command('open', ['-R', targetPath]);
    #elseif linux
    // TODO: unsure of the linux equivalent to opening a folder and then "selecting" a file.
    // Sys.command('open', [targetPath]);

    // TODO: Is this consistent across distros?
    Sys.command('dbus-send', [
      '--session',
      '--print-reply',
      '--dest=org.freedesktop.FileManager1',
      '--type=method_call /org/freedesktop/FileManager1',
      'org.freedesktop.FileManager1.ShowItems array:string:"file://$targetPath"',
      'string:""'
    ]);
    #end
    #else
    throw 'Cannot open URLs on this platform.';
    #end
  }

  /**
   * Dispatched when the game window is closed.
   */
  public static final windowExit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

  /**
   * Wires up FlxSignals that happen based on window activity.
   * For example, we can run a callback when the window is closed.
   */
  public static function initWindowEvents():Void
  {
    // onUpdate is called every frame just before rendering.

    // onExit is called when the game window is closed.
    openfl.Lib.current.stage.application.onExit.add((exitCode:Int) -> windowExit.dispatch(exitCode));

    #if !mobile
    openfl.Lib.current.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e:openfl.events.KeyboardEvent) -> {
      for (key in PlayerSettings.player1.controls.getKeysForAction(WINDOW_FULLSCREEN))
      {
        // FlxG.stage.focus is set to null by the debug console stuff,
        // so when that's in focus, we don't want to toggle fullscreen using F
        // (annoying when tying "FlxG" in console... lol)
        #if FLX_DEBUG
        @:privateAccess
        if (FlxG.game.debugger.visible) return;
        #end

        if (e.keyCode == key) openfl.Lib.application.window.fullscreen = !openfl.Lib.application.window.fullscreen;
      }
    });
    #end
  }

  /**
   * Turns off that annoying "Report to Microsoft" dialog that pops up when the game crashes.
   */
  public static function disableCrashHandler():Void
  {
    #if (cpp && windows)
    untyped __cpp__('SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOGPFAULTERRORBOX);');
    #else
    // Do nothing.
    #end
  }

  /**
   * Runs ShellExecute from shell32.
   */
  public static function shellExecute(?operation:String, ?file:String, ?parameters:String, ?directory:String):Void
  {
    #if (cpp && windows)
    untyped __cpp__('static HMODULE hShell32 = LoadLibraryW(L"shell32.dll");');
    untyped __cpp__('static const auto pShellExecuteW = (decltype(ShellExecuteW)*)GetProcAddress(hShell32, "ShellExecuteW");');
    untyped __cpp__('pShellExecuteW(NULL, operation.__WCStr(), file.__WCStr(), parameters.__WCStr(), directory.__WCStr(), SW_SHOWDEFAULT);');
    #else
    // Do nothing.
    #end
  }

  /**
   * Sets the title of the application window.
   * @param value The title to use.
   */
  public static function setWindowTitle(value:String):Void
  {
    lime.app.Application.current.window.title = value;
  }

  /**
   * Shows a message box if supported and logs message to the console
   */
  public static function showMessageBox(message:Null<String>, title:Null<String>):Void
  {
    trace('[$title] $message');

    lime.app.Application.current.window.alert(message, title);
  }

  public static function setDarkMode(enable:Bool)
  {
    #if windows
    funkin.api.windows.WinAPI.setDarkMode(enable);
    #else
    trace("wait wtf this aint windows... eh whatever");
    #end
  }
}
