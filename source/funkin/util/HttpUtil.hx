package funkin.util;

import haxe.Http;

class HttpUtil
{
  public static var userAgent:String = "request";

  public static function requestText(url:String)
  {
    var r = null;
    var h = new Http(url);
    h.setHeader("User-Agent", userAgent);
    h.onStatus = (s) -> if (isRedirect(s)) r = requestText(h.responseHeaders.get("Location"));
    h.onData = (d) -> if (r == null) r = d;
    h.onError = (e) -> throw e;
    h.request(false);
    return r;
  }

  public static function requestBytes(url:String)
  {
    var r = null;
    var h = new Http(url);
    h.setHeader("User-Agent", userAgent);
    h.onStatus = (s) -> if (isRedirect(s)) r = requestBytes(h.responseHeaders.get("Location"));
    h.onBytes = (e) -> if (r == null) r = d;
    h.onError = (e) -> throw e;
    h.request(false);
    return r;
  }

  private static function isRedirect(status:Int):Bool
  {
    switch (status)
    {
      // 301: Moved Permanently, 302: Found (Moved Temporarily), 307: Temporary Redirect, 308: Permanent Redirect  - Nex
      case 301 | 302 | 307 | 308:
        trace('[HTTP STATUS] Redirected with status code: $status');
        return true;
    }
    return false;
  }
}
