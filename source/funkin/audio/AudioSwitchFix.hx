package funkin.audio;

import lime.media.AudioManager;
import flixel.sound.FlxSound;
import flixel.FlxState;

/**
 * if youre stealing this keep this comment at least please lol
 * hi gray itsa me yoshicrafter29 i fixed it hehe
 *
 *
 *
 * ok --- @charlescatyt
 * @see https://github.com/FNF-CNE-Devs/CodenameEngine/blob/main/source/funkin/backend/system/modules/AudioSwitchFix.hx
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
#define SAFE_RELEASE(punk)  \\
			  if ((punk) != NULL)  \\
				{ (punk)->Release(); (punk) = NULL; }
static long lastDefId = 0;
class AudioFixClient : public IMMNotificationClient {
	LONG _cRef;
	IMMDeviceEnumerator *_pEnumerator;
	public:
	AudioFixClient() :
		_cRef(1),
		_pEnumerator(NULL)
	{
		HRESULT result = CoCreateInstance(__uuidof(MMDeviceEnumerator),
							  NULL, CLSCTX_INPROC_SERVER,
							  __uuidof(IMMDeviceEnumerator),
							  (void**)&_pEnumerator);
		if (result == S_OK) {
			_pEnumerator->RegisterEndpointNotificationCallback(this);
		}
	}
	~AudioFixClient()
	{
		SAFE_RELEASE(_pEnumerator);
	}
	ULONG STDMETHODCALLTYPE AddRef()
	{
		return InterlockedIncrement(&_cRef);
	}
	ULONG STDMETHODCALLTYPE Release()
	{
		ULONG ulRef = InterlockedDecrement(&_cRef);
		if (0 == ulRef)
		{
			delete this;
		}
		return ulRef;
	}
	HRESULT STDMETHODCALLTYPE QueryInterface(
								REFIID riid, VOID **ppvInterface)
	{
		return S_OK;
	}
	HRESULT STDMETHODCALLTYPE OnDeviceAdded(LPCWSTR pwstrDeviceId)
	{
		::Main_obj::audioDisconnected = true;
		return S_OK;
	};
	HRESULT STDMETHODCALLTYPE OnDeviceRemoved(LPCWSTR pwstrDeviceId)
	{
		return S_OK;
	}
	HRESULT STDMETHODCALLTYPE OnDeviceStateChanged(
								LPCWSTR pwstrDeviceId,
								DWORD dwNewState)
	{
		return S_OK;
	}
	HRESULT STDMETHODCALLTYPE OnPropertyValueChanged(
								LPCWSTR pwstrDeviceId,
								const PROPERTYKEY key)
	{
		return S_OK;
	}
	HRESULT STDMETHODCALLTYPE OnDefaultDeviceChanged(
		EDataFlow flow, ERole role,
		LPCWSTR pwstrDeviceId)
	{
		::Main_obj::audioDisconnected = true;
		return S_OK;
	};
};
AudioFixClient *curAudioFix;
')
#end
@:dox(hide)
class AudioSwitchFix
{
  // Reload audio device and replay all audio
  public static function reloadAudioDevice():Void
  {
    #if windows
    var playingList:Array<PlayingSound> = [];
    for (e in FlxG.sound.list)
    {
      if (e.playing)
      {
        playingList.push(
          {
            sound: e,
            time: e.time
          });
        e.stop();
      }
    }
    if (FlxG.sound.music != null) FlxG.sound.music.stop();
    AudioManager.suspend();
    #if !lime_doc_gen
    if (AudioManager.context.type == OPENAL)
    {
      var alc = AudioManager.context.openal;
      var buffer = alc.BUFFER;
      var buffersProcessed = alc.BUFFERS_PROCESSED;
      var buffersQueued = alc.BUFFERS_QUEUED;
      var byteOffset = alc.BYTE_OFFSET;
      var device = alc.openDevice();
      var ctx = alc.createContext(device);
      alc.makeContextCurrent(ctx);
      alc.processContext(ctx);
      alc.BUFFER = buffer;
      alc.BUFFERS_PROCESSED = buffersProcessed;
      alc.BUFFERS_QUEUED = buffersQueued;
      alc.BYTE_OFFSET = byteOffset;
    }
    #end
    AudioManager.resume();
    Main.audioDisconnected = false;
    for (e in playingList)
    {
      e.sound.play(true, e.time);
    }
    #end
  }

  // Initialize the listener for audio device changes
  #if windows @:functionCode('if (!curAudioFix) curAudioFix = new AudioFixClient();') #end
  public static function init():Void {}
}

// Helper for storing sound while fixing audio
typedef PlayingSound =
{
  var sound:FlxSound;
  var time:Float;
}
