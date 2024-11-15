package funkin.api.windows;

import funkin.util.WindowUtil;

/**
 * taken from grafex lol
 *
 * this is also here to let the game access the cpp/windows api stuff without making hxcpp fucking cry lol
 */
#if windows
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
    <lib name="shell32.lib" if="windows" />
    <lib name="gdi32.lib" if="windows" />
    <lib name="ole32.lib" if="windows" />
    <lib name="uxtheme.lib" if="windows" />
</target>
')
// majority is taken from microsofts doc
@:cppFileCode('
#include "mmdeviceapi.h"
#include "combaseapi.h"
#include <iostream>
#include <Windows.h>
#include <cstdio>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
#include <Shlobj.h>
#include <wingdi.h>
#include <shellapi.h>
#include <uxtheme.h>
')
class WinAPI
{
  // i have now learned the power of the windows api, FEAR ME!!!
  #if windows
  @:functionCode('
        int darkMode = enable ? 1 : 0;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
    ')
  #end
  public static function setDarkMode(enable:Bool) {}

  #if windows
  @:functionCode('
    HWND window = GetActiveWindow();
    HICON smallIcon = (HICON) LoadImage(NULL, path, IMAGE_ICON, 16, 16, LR_LOADFROMFILE);
    HICON icon = (HICON) LoadImage(NULL, path, IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTSIZE);
    SendMessage(window, WM_SETICON, ICON_SMALL, (LPARAM)smallIcon);
    SendMessage(window, WM_SETICON, ICON_BIG, (LPARAM)icon);
    ')
  #end
  public static function setWindowIcon(path:String) {}

  #if windows
  @:functionCode("
		// simple but effective code
		unsigned long long allocatedRAM = 0;
		GetPhysicallyInstalledSystemMemory(&allocatedRAM);
		return (allocatedRAM / 1024);
	")
  #end
  public static function getTotalRam():Float
  {
    return 0;
  }

  #if windows
  @:functionCode('
		SetProcessDPIAware();
	')
  #end
  public static function registerAsDPICompatible() {}

  #if windows
  @:functionCode('
		HANDLE console = GetStdHandle(STD_OUTPUT_HANDLE);
		SetConsoleTextAttribute(console, color);
	')
  #end
  public static function setConsoleColors(color:Int) {}

  #if windows
  @:functionCode('
        HWND window = GetActiveWindow();

        // make window layered
        alpha = SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) ^ WS_EX_LAYERED);
        SetLayeredWindowAttributes(window, RGB(red, green, blue), 0, LWA_COLORKEY);
    ')
  #end
  public static function setTransColor(red:Int, green:Int, blue:Int, alpha:Int = 0)
  {
    return alpha;
  }

  #if windows
  @:functionCode('
		return GetFileAttributes(path);
	')
  #end
  public static function getFileAttribute(path:String):WindowUtil.FileAttribute
  {
    return NORMAL;
  }

  #if windows
  @:functionCode('
		return SetFileAttributes(path, attrib);
	')
  #end
  public static function setFileAttribute(path:String, attrib:WindowUtil.FileAttribute):Int
  {
    return 0;
  }

  // kudos to bing chatgpt thing i hate C++
  #if windows
  @:functionCode('
        HWND hwnd = GetActiveWindow();
        HMENU hmenu = GetSystemMenu(hwnd, FALSE);
        if (enable) {
            EnableMenuItem(hmenu, SC_CLOSE, MF_BYCOMMAND | MF_ENABLED);
        } else {
            EnableMenuItem(hmenu, SC_CLOSE, MF_BYCOMMAND | MF_GRAYED);
        }
    ')
  #end
  public static function setCloseButtonEnabled(enable:Bool)
  {
    return enable;
  }

  #if windows
  @:functionCode('
        system("CLS");
        std::cout<< "" <<std::flush;
    ')
  #end
  public static function clearScreen() {}

  #if windows
  @:functionCode('
	// https://stackoverflow.com/questions/15543571/allocconsole-not-displaying-cout
	if (!AllocConsole())
		return;
	freopen("CONIN$", "r", stdin);
	freopen("CONOUT$", "w", stdout);
	freopen("CONOUT$", "w", stderr);
	')
  #end
  public static function allocConsole() {}

  #if windows
  @:functionCode('
        return MessageBox(GetActiveWindow(), text, title, icon | MB_SETFOREGROUND);
    ')
  #end
  public static function showMessagePopup(title:String, text:String, icon:MessageBoxIcon):Int
  {
    lime.app.Application.current.window.alert(title, text);
    return 0;
  }

  #if windows
  @:functionCode('
        // https://stackoverflow.com/questions/4308503/how-to-enable-visual-styles-without-a-manifest
        // dumbass windows
        TCHAR dir[MAX_PATH];
        ULONG_PTR ulpActivationCookie = FALSE;
        ACTCTX actCtx =
        {
            sizeof(actCtx),
            ACTCTX_FLAG_RESOURCE_NAME_VALID
                | ACTCTX_FLAG_SET_PROCESS_DEFAULT
                | ACTCTX_FLAG_ASSEMBLY_DIRECTORY_VALID,
            TEXT("shell32.dll"), 0, 0, dir, (LPCTSTR)124
        };
        UINT cch = GetSystemDirectory(dir, sizeof(dir) / sizeof(*dir));
        if (cch >= sizeof(dir) / sizeof(*dir)) { return FALSE; /*shouldn\'t happen*/ }
        dir[cch] = TEXT(\'\\0\');
        ActivateActCtx(CreateActCtx(&actCtx), &ulpActivationCookie);
        return ulpActivationCookie;
    ')
  #end
  public static function enableVisualStyles()
  {
    return false;
  }
}

enum abstract MessageBoxIcon(Int)
{
  var MSG_ERROR = 0x00000010;
  var MSG_QUESTION = 0x00000020;
  var MSG_WARNING = 0x00000030;
  var MSG_INFORMATION = 0x00000040;
}
#end
