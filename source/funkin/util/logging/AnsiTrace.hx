package funkin.util.logging;

#if (sys && target.threaded)
import sys.thread.Mutex;
#end

class AnsiTrace
{
  public static var allTraces:Array<String> = [];

  #if (sys && target.threaded && !TREMOVE)
  static final _mutex:Mutex = new Mutex();
  #end

  // mostly a copy of haxe.Log.trace()
  // but adds nice cute ANSI things
  public static function trace(v:Dynamic, ?info:haxe.PosInfos)
  {
    #if NO_FEATURE_LOG_TRACE
    return;
    #end
    var str = formatOutput(v, info);
    allTraces.push(str);
    #if js
    if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null) (untyped console).log(str);
    #elseif lua
    untyped __define_feature__("use._hx_print", _hx_print(str));
    #elseif sys
    #if target.threaded
    _mutex.acquire();
    Sys.println(str);
    _mutex.release();
    #else
    Sys.println(str);
    #end
    #else
    throw new haxe.exceptions.NotImplementedException()
    #end
  }

  public static var colorSupported:Bool = #if sys (Sys.getEnv("TERM") == "xterm" || Sys.getEnv("ANSICON") != null) #else false #end;

  // ansi stuff
  public static inline var RED = "\x1b[31m";
  public static inline var YELLOW = "\x1b[33m";
  public static inline var WHITE = "\x1b[37m";
  public static inline var NORMAL = "\x1b[0m";
  public static inline var BOLD = "\x1b[1m";
  public static inline var ITALIC = "\x1b[3m";

  // where the real mf magic happens with ansi stuff!
  public static function formatOutput(v:Dynamic, infos:haxe.PosInfos):String
  {
    var str = Std.string(v);
    if (infos == null) return str;

    if (colorSupported)
    {
      var dirs:Array<String> = infos.fileName.split("/");
      dirs[dirs.length - 1] = ansiWrap(dirs[dirs.length - 1], BOLD);

      // rejoin the dirs
      infos.fileName = dirs.join("/");
    }

    var pstr = infos.fileName + ":" + ansiWrap(infos.lineNumber, BOLD);
    if (infos.customParams != null) for (v in infos.customParams)
      str += ", " + Std.string(v);
    return pstr + ": " + str;
  }

  public static function traceBF()
  {
    #if (sys)
    if (colorSupported)
    {
      for (line in ansiBF)
        Sys.stdout().writeString(line + "\n");
      Sys.stdout().flush();
    }
    #end
  }

  public static function ansiWrap(str:Dynamic, ansiCol:String)
  {
    return ansify(ansiCol) + str + ansify(NORMAL);
  }

  public static function ansify(ansiCol:String)
  {
    return (colorSupported ? ansiCol : "");
  }

  // generated using https://dom111.github.io/image-to-ansi/
  public static var ansiBF:Array<String> = [
    "\x1b[39m\x1b[49m                                  \x1b[48;2;154;23;70m            \x1b[49m                                                \x1b[m",
    "\x1b[39m\x1b[49m                              \x1b[48;2;154;23;70m    \x1b[48;2;184;46;83m  \x1b[48;2;246;87;102m        \x1b[48;2;239;83;100m  \x1b[48;2;154;23;70m          \x1b[48;2;154;23;69m  \x1b[49m                                    \x1b[m",
    "\x1b[39m\x1b[49m                            \x1b[48;2;154;23;70m  \x1b[48;2;191;52;87m  \x1b[48;2;246;87;102m                        \x1b[48;2;241;84;100m  \x1b[48;2;191;52;87m        \x1b[48;2;153;23;69m  \x1b[49m                          \x1b[m",
    "\x1b[39m\x1b[49m                          \x1b[48;2;154;23;70m  \x1b[48;2;246;87;102m                                  \x1b[48;2;154;23;70m      \x1b[49m                          \x1b[m",
    "\x1b[39m\x1b[49m                          \x1b[48;2;154;23;70m  \x1b[48;2;246;87;102m                \x1b[48;2;234;94;114m  \x1b[48;2;160;97;151m  \x1b[48;2;246;87;102m            \x1b[48;2;154;23;70m    \x1b[48;2;205;63;93m    \x1b[48;2;36;35;46m  \x1b[49m                        \x1b[m",
    "\x1b[39m\x1b[49m                          \x1b[48;2;47;49;144m        \x1b[48;2;246;87;102m          \x1b[48;2;80;121;206m  \x1b[48;2;193;167;177m  \x1b[48;2;246;87;102m          \x1b[48;2;184;46;83m  \x1b[48;2;205;63;93m          \x1b[48;2;20;19;31m  \x1b[49m                      \x1b[m",
    "\x1b[39m\x1b[49m                          \x1b[48;2;47;49;144m  \x1b[48;2;110;187;236m      \x1b[48;2;109;66;125m  \x1b[48;2;246;87;102m      \x1b[48;2;74;107;200m  \x1b[48;2;141;248;252m  \x1b[48;2;107;177;226m  \x1b[48;2;234;94;114m  \x1b[48;2;246;87;102m      \x1b[48;2;237;81;99m  \x1b[48;2;205;63;93m              \x1b[48;2;20;19;31m  \x1b[49m                    \x1b[m",
    "\x1b[39m\x1b[49m                    \x1b[48;2;74;106;196m  \x1b[48;2;87;133;210m  \x1b[48;2;64;105;174m  \x1b[48;2;141;248;252m        \x1b[48;2;126;219;244m  \x1b[48;2;57;65;148m  \x1b[48;2;47;49;144m  \x1b[48;2;141;248;252m    \x1b[48;2;129;225;245m  \x1b[48;2;157;94;147m  \x1b[48;2;246;87;102m        \x1b[48;2;159;27;72m  \x1b[48;2;205;63;93m              \x1b[48;2;55;27;43m  \x1b[48;2;21;21;31m  \x1b[49m                  \x1b[m",
    "\x1b[39m\x1b[49m                  \x1b[48;2;74;107;200m  \x1b[48;2;125;216;244m  \x1b[48;2;141;248;252m              \x1b[48;2;126;219;244m  \x1b[48;2;60;97;187m  \x1b[48;2;141;248;252m  \x1b[48;2;126;219;244m  \x1b[48;2;104;173;229m  \x1b[48;2;146;68;123m  \x1b[48;2;246;87;102m      \x1b[48;2;180;44;82m  \x1b[48;2;205;63;93m                  \x1b[48;2;20;19;31m  \x1b[49m                  \x1b[m",
    "\x1b[39m\x1b[49m                \x1b[48;2;74;107;200m  \x1b[48;2;141;248;252m        \x1b[48;2;110;187;236m        \x1b[48;2;141;248;252m        \x1b[48;2;110;187;236m  \x1b[48;2;104;173;229m  \x1b[48;2;146;68;123m  \x1b[48;2;246;87;102m      \x1b[48;2;154;23;70m  \x1b[48;2;205;63;93m                  \x1b[48;2;20;19;31m  \x1b[49m                  \x1b[m",
    "\x1b[39m\x1b[49m              \x1b[48;2;73;106;199m  \x1b[48;2;132;230;247m  \x1b[48;2;141;248;252m    \x1b[48;2;110;187;236m                \x1b[48;2;141;248;252m    \x1b[48;2;110;187;236m    \x1b[48;2;78;118;190m  \x1b[48;2;239;83;100m  \x1b[48;2;246;87;102m    \x1b[48;2;205;63;93m                    \x1b[48;2;20;19;31m  \x1b[49m                  \x1b[m",
    "\x1b[39m\x1b[49m              \x1b[48;2;73;106;199m  \x1b[48;2;132;230;247m  \x1b[48;2;141;248;252m  \x1b[48;2;110;187;236m        \x1b[48;2;20;19;31m  \x1b[48;2;110;187;236m          \x1b[48;2;141;248;252m  \x1b[48;2;110;187;236m    \x1b[48;2;78;118;190m  \x1b[48;2;239;83;100m  \x1b[48;2;246;87;102m  \x1b[48;2;154;23;70m  \x1b[48;2;205;63;93m                    \x1b[48;2;20;19;31m  \x1b[49m                  \x1b[m",
    "\x1b[39m\x1b[49m              \x1b[48;2;73;106;199m  \x1b[48;2;132;230;247m  \x1b[48;2;110;187;236m          \x1b[48;2;20;19;31m  \x1b[48;2;110;187;236m                  \x1b[48;2;51;72;160m  \x1b[48;2;246;87;102m  \x1b[48;2;154;23;70m  \x1b[48;2;205;63;93m                    \x1b[48;2;20;19;31m  \x1b[49m                  \x1b[m",
    "\x1b[39m\x1b[49m                \x1b[48;2;74;107;200m      \x1b[48;2;141;248;252m    \x1b[48;2;110;187;236m  \x1b[48;2;117;138;166m  \x1b[48;2;20;19;31m  \x1b[48;2;110;187;236m  \x1b[48;2;55;134;228m      \x1b[48;2;110;187;236m      \x1b[48;2;139;244;251m    \x1b[48;2;205;63;93m    \x1b[48;2;123;4;53m  \x1b[48;2;125;6;54m  \x1b[48;2;146;23;68m  \x1b[48;2;205;63;93m            \x1b[48;2;123;4;53m  \x1b[48;2;20;19;31m  \x1b[49m                  \x1b[m",
    "\x1b[39m\x1b[49m                  \x1b[48;2;74;107;200m  \x1b[48;2;141;248;252m    \x1b[48;2;110;187;236m      \x1b[48;2;20;19;31m    \x1b[48;2;103;130;185m  \x1b[48;2;240;174;162m    \x1b[48;2;74;107;200m  \x1b[48;2;110;187;236m  \x1b[48;2;141;248;252m  \x1b[48;2;107;177;226m  \x1b[48;2;74;107;200m  \x1b[48;2;20;19;31m      \x1b[48;2;205;63;93m              \x1b[48;2;20;19;31m    \x1b[48;2;153;78;112m    \x1b[49m                \x1b[m",
    "\x1b[39m\x1b[49m                \x1b[48;2;74;107;200m  \x1b[48;2;110;187;236m  \x1b[48;2;141;248;252m  \x1b[48;2;110;187;236m    \x1b[48;2;58;123;219m  \x1b[48;2;74;107;200m    \x1b[48;2;20;19;31m  \x1b[48;2;240;174;162m        \x1b[48;2;141;248;252m  \x1b[48;2;135;237;249m  \x1b[48;2;157;140;181m  \x1b[48;2;44;30;46m  \x1b[48;2;20;19;31m            \x1b[48;2;205;63;93m      \x1b[48;2;36;35;46m  \x1b[48;2;153;78;112m  \x1b[48;2;249;225;202m  \x1b[48;2;240;174;162m  \x1b[48;2;153;78;112m  \x1b[49m                \x1b[m",
    "\x1b[39m\x1b[49m                \x1b[48;2;74;107;200m  \x1b[48;2;141;248;252m  \x1b[48;2;110;187;236m    \x1b[48;2;74;107;200m    \x1b[48;2;20;19;31m  \x1b[48;2;240;174;162m    \x1b[48;2;93;37;66m  \x1b[48;2;240;174;162m    \x1b[48;2;74;107;200m    \x1b[48;2;240;174;162m  \x1b[48;2;130;96;96m  \x1b[48;2;20;19;31m  \x1b[48;2;240;174;162m    \x1b[48;2;74;107;200m  \x1b[48;2;141;248;252m  \x1b[48;2;110;187;236m    \x1b[48;2;20;19;31m  \x1b[48;2;205;63;93m  \x1b[48;2;170;35;77m  \x1b[48;2;196;126;137m  \x1b[48;2;249;225;202m      \x1b[48;2;132;70;100m  \x1b[48;2;20;19;31m    \x1b[49m            \x1b[m",
    "\x1b[39m\x1b[49m              \x1b[48;2;73;106;199m  \x1b[48;2;132;230;247m  \x1b[48;2;138;242;250m  \x1b[48;2;74;107;200m    \x1b[49m    \x1b[48;2;20;19;31m  \x1b[48;2;240;174;162m    \x1b[48;2;20;19;31m  \x1b[48;2;175;111;124m  \x1b[48;2;235;169;159m  \x1b[48;2;240;174;162m    \x1b[48;2;227;160;155m  \x1b[48;2;20;19;31m  \x1b[48;2;232;165;158m  \x1b[48;2;240;174;162m    \x1b[48;2;85;109;196m  \x1b[48;2;138;242;250m  \x1b[48;2;112;191;237m  \x1b[48;2;104;181;235m  \x1b[48;2;110;187;236m  \x1b[48;2;23;22;43m  \x1b[48;2;26;23;37m  \x1b[48;2;249;225;202m  \x1b[48;2;248;220;198m    \x1b[48;2;249;225;202m  \x1b[48;2;137;90;124m  \x1b[48;2;51;112;205m  \x1b[48;2;53;128;224m  \x1b[48;2;23;25;44m      \x1b[48;2;18;18;28m  \x1b[49m    \x1b[m",
    "\x1b[39m\x1b[49m              \x1b[48;2;73;106;199m  \x1b[48;2;109;182;229m  \x1b[48;2;74;107;200m  \x1b[49m    \x1b[48;2;151;78;111m  \x1b[48;2;194;126;136m  \x1b[48;2;110;100;98m  \x1b[48;2;244;194;178m    \x1b[48;2;72;42;63m  \x1b[48;2;103;76;81m  \x1b[48;2;191;136;147m  \x1b[48;2;240;174;162m  \x1b[48;2;206;136;142m  \x1b[48;2;20;19;31m    \x1b[48;2;232;165;158m  \x1b[48;2;240;174;162m      \x1b[48;2;65;128;218m  \x1b[48;2;141;248;252m  \x1b[48;2;74;107;200m  \x1b[48;2;85;133;200m  \x1b[48;2;88;139;214m  \x1b[48;2;84;69;150m  \x1b[48;2;211;167;166m  \x1b[48;2;187;116;132m  \x1b[48;2;213;145;147m  \x1b[48;2;245;205;186m  \x1b[48;2;135;83;115m  \x1b[48;2;43;66;124m  \x1b[48;2;47;87;174m  \x1b[48;2;51;130;227m      \x1b[48;2;28;40;76m  \x1b[49m    \x1b[m",
    "\x1b[39m\x1b[49m              \x1b[48;2;71;103;199m  \x1b[48;2;73;105;197m  \x1b[49m    \x1b[48;2;153;78;112m  \x1b[48;2;196;126;137m  \x1b[48;2;246;209;189m  \x1b[48;2;249;225;202m      \x1b[48;2;226;159;154m  \x1b[48;2;244;215;196m  \x1b[48;2;249;225;202m  \x1b[48;2;240;174;162m  \x1b[48;2;226;159;154m  \x1b[48;2;142;54;93m    \x1b[48;2;245;213;193m  \x1b[48;2;249;225;202m      \x1b[48;2;213;185;192m  \x1b[48;2;85;132;211m  \x1b[48;2;222;158;164m  \x1b[48;2;183;111;129m  \x1b[48;2;110;187;236m  \x1b[48;2;171;158;211m  \x1b[48;2;153;78;112m  \x1b[48;2;196;126;137m  \x1b[48;2;240;174;162m  \x1b[48;2;166;93;120m  \x1b[48;2;130;70;98m  \x1b[48;2;19;19;31m  \x1b[48;2;29;34;56m  \x1b[48;2;55;93;183m      \x1b[48;2;68;101;193m  \x1b[49m    \x1b[m",
    "\x1b[39m\x1b[49m                      \x1b[48;2;153;78;112m  \x1b[48;2;249;225;202m                    \x1b[48;2;196;126;137m  \x1b[48;2;218;150;149m  \x1b[48;2;249;225;202m          \x1b[48;2;240;174;162m    \x1b[48;2;196;126;137m  \x1b[48;2;47;49;144m  \x1b[48;2;196;126;137m    \x1b[48;2;153;78;112m    \x1b[49m        \x1b[48;2;20;19;31m      \x1b[48;2;41;43;121m  \x1b[49m    \x1b[m",
    "\x1b[39m\x1b[49m                      \x1b[48;2;153;78;112m  \x1b[48;2;249;225;202m            \x1b[48;2;244;215;196m  \x1b[48;2;249;225;202m            \x1b[48;2;145;49;90m  \x1b[48;2;249;225;202m      \x1b[48;2;240;174;162m    \x1b[48;2;153;78;112m        \x1b[49m                        \x1b[m",
    "\x1b[39m\x1b[49m                      \x1b[48;2;153;78;112m  \x1b[48;2;196;126;137m  \x1b[48;2;249;225;202m          \x1b[48;2;200;131;139m  \x1b[48;2;249;225;202m          \x1b[48;2;154;63;98m  \x1b[48;2;145;49;90m  \x1b[48;2;240;174;162m  \x1b[48;2;249;225;202m    \x1b[48;2;240;174;162m  \x1b[48;2;153;78;112m  \x1b[48;2;255;224;255m  \x1b[48;2;153;78;112m  \x1b[49m                            \x1b[m",
    "\x1b[39m\x1b[49m                        \x1b[48;2;153;78;112m  \x1b[48;2;210;141;145m  \x1b[48;2;241;181;168m  \x1b[48;2;249;225;202m        \x1b[48;2;196;126;137m      \x1b[48;2;195;125;136m  \x1b[48;2;170;94;119m  \x1b[48;2;237;73;115m  \x1b[48;2;244;75;120m  \x1b[48;2;145;49;90m  \x1b[48;2;249;225;202m  \x1b[48;2;241;181;167m  \x1b[48;2;181;121;161m  \x1b[48;2;255;224;255m      \x1b[48;2;178;117;159m  \x1b[49m                          \x1b[m",
    "\x1b[39m\x1b[49m                              \x1b[48;2;136;72;102m        \x1b[48;2;190;119;133m        \x1b[48;2;171;99;123m  \x1b[48;2;152;74;109m  \x1b[48;2;244;75;120m  \x1b[48;2;145;49;90m  \x1b[48;2;190;119;133m  \x1b[48;2;185;128;172m  \x1b[48;2;180;121;164m  \x1b[48;2;255;224;255m        \x1b[48;2;153;78;112m  \x1b[49m                        \x1b[m",
    "\x1b[39m\x1b[49m            \x1b[48;2;147;80;107m  \x1b[48;2;153;78;112m      \x1b[49m      \x1b[48;2;36;35;46m    \x1b[48;2;98;121;155m  \x1b[48;2;50;68;111m    \x1b[48;2;55;73;115m  \x1b[48;2;36;35;46m    \x1b[48;2;251;117;129m  \x1b[48;2;205;63;93m  \x1b[48;2;230;143;174m  \x1b[48;2;255;224;255m  \x1b[48;2;145;49;90m  \x1b[48;2;153;78;112m  \x1b[48;2;255;224;255m  \x1b[48;2;251;219;252m  \x1b[48;2;105;60;85m  \x1b[48;2;36;35;46m  \x1b[48;2;212;170;223m  \x1b[48;2;255;224;255m    \x1b[48;2;153;78;112m  \x1b[49m                        \x1b[m",
    "\x1b[39m\x1b[49m          \x1b[48;2;153;78;112m  \x1b[48;2;156;82;114m  \x1b[48;2;240;174;162m    \x1b[48;2;153;78;112m    \x1b[49m    \x1b[48;2;65;84;125m  \x1b[48;2;98;121;155m  \x1b[48;2;124;146;175m  \x1b[48;2;194;215;238m    \x1b[48;2;50;68;111m  \x1b[48;2;124;146;175m  \x1b[48;2;98;121;155m  \x1b[48;2;36;35;46m  \x1b[48;2;254;224;245m  \x1b[48;2;231;143;176m  \x1b[48;2;255;224;255m  \x1b[48;2;145;49;90m    \x1b[48;2;255;224;255m    \x1b[48;2;72;85;110m  \x1b[48;2;240;174;162m  \x1b[48;2;196;126;137m  \x1b[48;2;153;78;112m      \x1b[49m                        \x1b[m",
    "\x1b[39m\x1b[49m        \x1b[48;2;153;78;112m  \x1b[48;2;196;126;137m  \x1b[48;2;250;227;206m        \x1b[48;2;50;68;111m      \x1b[48;2;65;84;125m  \x1b[48;2;50;68;111m    \x1b[48;2;124;146;175m  \x1b[48;2;78;99;137m  \x1b[48;2;194;215;238m  \x1b[48;2;124;146;175m  \x1b[48;2;36;35;46m    \x1b[48;2;254;224;245m  \x1b[48;2;253;170;192m  \x1b[48;2;255;224;255m    \x1b[48;2;251;117;129m  \x1b[48;2;255;224;255m    \x1b[48;2;170;105;144m  \x1b[48;2;240;174;162m      \x1b[48;2;196;126;137m  \x1b[49m                          \x1b[m",
    "\x1b[39m\x1b[49m  \x1b[48;2;153;76;111m  \x1b[48;2;165;91;118m  \x1b[48;2;180;108;128m    \x1b[48;2;250;227;206m          \x1b[48;2;116;138;169m  \x1b[48;2;124;146;175m  \x1b[48;2;36;35;46m  \x1b[48;2;116;138;169m  \x1b[48;2;172;193;218m  \x1b[48;2;168;206;237m  \x1b[48;2;49;62;121m  \x1b[48;2;73;92;131m  \x1b[48;2;115;137;168m  \x1b[48;2;116;138;169m  \x1b[48;2;124;146;175m  \x1b[48;2;50;40;54m  \x1b[48;2;57;43;58m  \x1b[48;2;251;170;183m  \x1b[48;2;255;206;227m  \x1b[48;2;251;117;129m  \x1b[48;2;252;132;140m  \x1b[48;2;255;224;255m      \x1b[48;2;153;78;112m  \x1b[48;2;243;190;174m    \x1b[48;2;249;226;203m  \x1b[48;2;196;126;137m  \x1b[48;2;44;70;156m  \x1b[48;2;47;86;175m  \x1b[49m                    \x1b[m",
    "\x1b[39m\x1b[49m  \x1b[48;2;153;78;112m  \x1b[48;2;239;198;185m  \x1b[48;2;250;227;206m      \x1b[48;2;244;195;179m  \x1b[48;2;250;227;206m      \x1b[48;2;50;68;111m  \x1b[48;2;166;188;213m  \x1b[48;2;36;35;46m  \x1b[48;2;46;58;91m  \x1b[48;2;79;100;138m  \x1b[48;2;71;79;97m  \x1b[48;2;60;69;89m  \x1b[48;2;136;158;188m  \x1b[48;2;117;140;170m  \x1b[48;2;36;35;46m  \x1b[48;2;71;79;97m  \x1b[48;2;79;100;138m  \x1b[48;2;62;51;68m  \x1b[48;2;246;192;224m  \x1b[48;2;253;182;205m    \x1b[48;2;255;224;255m      \x1b[48;2;144;140;167m  \x1b[48;2;82;52;72m  \x1b[48;2;120;110;108m  \x1b[48;2;250;227;206m    \x1b[48;2;229;187;179m  \x1b[48;2;169;166;186m  \x1b[48;2;47;64;156m  \x1b[48;2;46;87;175m  \x1b[49m                  \x1b[m",
    "\x1b[39m\x1b[49m  \x1b[48;2;153;78;112m  \x1b[48;2;250;227;206m        \x1b[48;2;240;174;162m  \x1b[48;2;220;168;164m  \x1b[48;2;250;227;206m    \x1b[48;2;50;68;111m  \x1b[48;2;194;215;238m  \x1b[48;2;36;35;46m  \x1b[48;2;50;68;111m  \x1b[48;2;98;121;155m  \x1b[48;2;36;35;46m  \x1b[48;2;50;68;111m  \x1b[48;2;98;121;155m  \x1b[48;2;95;115;147m  \x1b[48;2;93;115;150m  \x1b[48;2;50;68;111m    \x1b[48;2;37;37;48m  \x1b[48;2;51;44;59m            \x1b[48;2;66;116;206m  \x1b[48;2;47;83;172m    \x1b[48;2;68;134;227m  \x1b[48;2;250;227;206m    \x1b[48;2;61;91;174m  \x1b[48;2;47;85;173m  \x1b[48;2;47;87;175m  \x1b[48;2;47;86;175m  \x1b[49m                \x1b[m",
    "\x1b[48;2;153;78;112m  \x1b[48;2;250;227;206m          \x1b[48;2;240;174;162m  \x1b[48;2;217;165;163m  \x1b[48;2;250;227;206m  \x1b[48;2;240;174;162m  \x1b[48;2;82;52;72m  \x1b[48;2;194;215;238m  \x1b[48;2;36;35;46m  \x1b[48;2;50;68;111m      \x1b[48;2;98;121;155m    \x1b[48;2;36;35;46m  \x1b[48;2;98;121;155m    \x1b[48;2;50;68;111m  \x1b[48;2;38;41;58m  \x1b[48;2;47;87;175m          \x1b[48;2;51;130;227m      \x1b[48;2;47;87;175m    \x1b[48;2;51;130;227m  \x1b[48;2;47;49;144m    \x1b[48;2;47;87;175m      \x1b[48;2;45;85;174m  \x1b[49m              \x1b[m",
    "\x1b[48;2;153;78;112m  \x1b[48;2;250;227;206m  \x1b[48;2;242;185;171m  \x1b[48;2;250;227;206m      \x1b[48;2;240;174;162m  \x1b[48;2;217;165;163m  \x1b[48;2;250;227;206m  \x1b[48;2;240;174;162m  \x1b[48;2;36;35;46m  \x1b[48;2;124;146;175m  \x1b[48;2;36;35;46m    \x1b[48;2;50;68;111m    \x1b[48;2;98;121;155m  \x1b[48;2;50;68;111m    \x1b[48;2;36;35;46m  \x1b[48;2;98;121;155m  \x1b[48;2;36;35;46m  \x1b[48;2;38;41;58m  \x1b[48;2;47;68;159m  \x1b[48;2;47;87;175m      \x1b[48;2;51;130;227m          \x1b[48;2;47;87;175m    \x1b[48;2;51;130;227m      \x1b[48;2;47;87;175m    \x1b[48;2;45;85;174m  \x1b[49m              \x1b[m",
    "\x1b[48;2;153;78;112m  \x1b[48;2;250;227;206m  \x1b[48;2;242;185;171m  \x1b[48;2;196;126;137m  \x1b[48;2;250;227;206m    \x1b[48;2;240;174;162m  \x1b[48;2;206;136;142m  \x1b[48;2;227;160;155m  \x1b[48;2;240;174;162m    \x1b[48;2;82;52;72m  \x1b[48;2;50;68;111m  \x1b[48;2;36;35;46m  \x1b[48;2;50;68;111m              \x1b[48;2;36;35;46m  \x1b[48;2;47;87;175m          \x1b[48;2;51;130;227m    \x1b[48;2;153;55;95m  \x1b[48;2;47;87;175m  \x1b[48;2;51;130;227m            \x1b[48;2;47;87;175m    \x1b[48;2;45;85;174m  \x1b[49m              \x1b[m",
    "\x1b[39m\x1b[49m  \x1b[48;2;152;77;112m  \x1b[48;2;228;161;155m  \x1b[48;2;237;171;160m  \x1b[48;2;196;126;137m  \x1b[48;2;193;123;135m    \x1b[48;2;177;105;126m  \x1b[48;2;193;123;135m        \x1b[48;2;37;37;50m  \x1b[48;2;155;69;105m  \x1b[48;2;36;35;46m    \x1b[48;2;49;66;107m      \x1b[48;2;36;35;46m      \x1b[48;2;159;83;115m  \x1b[48;2;155;67;103m  \x1b[48;2;47;69;142m  \x1b[48;2;47;87;175m  \x1b[48;2;46;73;157m  \x1b[48;2;47;85;173m  \x1b[48;2;63;77;159m  \x1b[48;2;247;97;126m  \x1b[48;2;254;165;165m  \x1b[48;2;253;160;161m  \x1b[48;2;159;79;111m  \x1b[48;2;72;106;198m      \x1b[48;2;50;67;149m  \x1b[48;2;53;69;151m  \x1b[48;2;157;77;111m  \x1b[48;2;151;22;68m  \x1b[49m              \x1b[m",
    "\x1b[39m\x1b[49m    \x1b[48;2;153;78;112m        \x1b[48;2;147;80;107m  \x1b[48;2;176;104;125m  \x1b[48;2;240;174;162m    \x1b[48;2;66;46;63m    \x1b[48;2;36;35;46m  \x1b[48;2;170;35;77m  \x1b[48;2;212;170;223m  \x1b[48;2;255;224;255m    \x1b[48;2;201;153;202m  \x1b[48;2;246;87;102m      \x1b[48;2;245;171;163m  \x1b[48;2;253;156;159m  \x1b[48;2;205;63;93m  \x1b[48;2;154;23;70m  \x1b[48;2;47;87;175m      \x1b[48;2;154;23;70m  \x1b[48;2;246;170;163m  \x1b[48;2;254;165;165m  \x1b[48;2;246;87;102m    \x1b[48;2;245;79;114m      \x1b[48;2;118;0;50m  \x1b[48;2;246;87;102m  \x1b[48;2;219;68;93m  \x1b[48;2;118;0;50m  \x1b[49m              \x1b[m",
    "\x1b[39m\x1b[49m            \x1b[48;2;147;80;107m  \x1b[48;2;187;116;132m  \x1b[48;2;240;174;162m  \x1b[48;2;153;78;112m      \x1b[48;2;212;170;223m  \x1b[48;2;255;224;255m    \x1b[48;2;212;170;223m  \x1b[48;2;182;124;167m  \x1b[48;2;255;224;255m  \x1b[48;2;251;127;141m  \x1b[48;2;246;87;102m  \x1b[48;2;154;23;70m  \x1b[48;2;205;63;93m  \x1b[48;2;246;87;102m  \x1b[48;2;225;75;97m  \x1b[48;2;154;23;70m        \x1b[48;2;159;27;72m  \x1b[48;2;246;87;102m              \x1b[48;2;154;23;70m  \x1b[48;2;246;87;102m  \x1b[48;2;118;0;50m  \x1b[49m                \x1b[m",
    "\x1b[39m\x1b[49m              \x1b[48;2;151;78;111m  \x1b[48;2;153;78;112m    \x1b[48;2;255;224;255m      \x1b[48;2;212;170;223m  \x1b[48;2;255;224;255m    \x1b[48;2;212;170;223m  \x1b[48;2;200;151;200m  \x1b[48;2;216;175;226m  \x1b[48;2;154;23;70m    \x1b[48;2;205;63;93m  \x1b[48;2;246;85;105m  \x1b[48;2;205;63;93m    \x1b[48;2;118;0;50m  \x1b[48;2;246;87;102m    \x1b[48;2;159;27;72m  \x1b[48;2;205;63;93m  \x1b[48;2;246;87;102m  \x1b[48;2;212;170;223m  \x1b[48;2;255;224;255m          \x1b[48;2;212;170;223m  \x1b[48;2;144;16;64m  \x1b[48;2;118;0;50m  \x1b[49m              \x1b[m",
    "\x1b[39m\x1b[49m                \x1b[48;2;154;23;70m  \x1b[48;2;246;87;102m    \x1b[48;2;182;124;167m    \x1b[48;2;255;224;255m  \x1b[48;2;153;78;112m  \x1b[48;2;182;124;167m  \x1b[48;2;255;224;255m  \x1b[48;2;205;63;93m  \x1b[48;2;159;27;72m  \x1b[48;2;154;23;70m  \x1b[48;2;205;63;93m          \x1b[48;2;118;0;50m    \x1b[48;2;246;87;102m    \x1b[48;2;205;63;93m    \x1b[48;2;212;170;223m  \x1b[48;2;255;224;255m  \x1b[48;2;212;170;223m      \x1b[48;2;182;124;167m    \x1b[48;2;168;74;106m  \x1b[48;2;174;39;79m  \x1b[48;2;153;78;112m  \x1b[49m            \x1b[m",
    "\x1b[39m\x1b[49m                \x1b[48;2;154;23;70m  \x1b[48;2;246;87;102m        \x1b[48;2;211;70;106m  \x1b[48;2;233;196;238m  \x1b[48;2;255;224;255m  \x1b[48;2;178;42;81m  \x1b[48;2;205;157;200m  \x1b[48;2;154;23;70m  \x1b[48;2;205;63;93m  \x1b[48;2;178;42;81m          \x1b[48;2;154;23;70m  \x1b[48;2;153;52;92m  \x1b[48;2;136;40;82m  \x1b[48;2;144;17;63m  \x1b[48;2;225;75;97m    \x1b[48;2;234;198;240m  \x1b[48;2;255;224;255m  \x1b[48;2;234;198;240m  \x1b[48;2;233;196;238m        \x1b[48;2;239;204;243m  \x1b[48;2;212;165;204m  \x1b[48;2;245;87;103m  \x1b[48;2;180;44;82m  \x1b[48;2;180;70;102m  \x1b[48;2;152;77;112m  \x1b[48;2;151;76;110m  \x1b[49m    \x1b[m",
    "\x1b[39m\x1b[49m                \x1b[48;2;153;68;104m  \x1b[48;2;213;67;95m  \x1b[48;2;246;87;102m      \x1b[48;2;213;67;95m  \x1b[48;2;195;66;97m  \x1b[48;2;173;61;105m  \x1b[48;2;154;23;70m  \x1b[48;2;195;55;89m    \x1b[48;2;205;63;93m  \x1b[48;2;125;4;54m  \x1b[48;2;170;101;145m  \x1b[48;2;171;102;146m  \x1b[48;2;201;153;202m      \x1b[48;2;182;124;167m  \x1b[48;2;158;87;122m  \x1b[48;2;138;36;79m  \x1b[48;2;205;63;93m    \x1b[48;2;196;143;183m  \x1b[48;2;255;224;255m    \x1b[48;2;234;94;114m  \x1b[48;2;229;85;104m      \x1b[48;2;236;96;117m  \x1b[48;2;248;113;131m  \x1b[48;2;246;88;103m  \x1b[48;2;246;87;102m    \x1b[48;2;195;66;97m  \x1b[48;2;172;109;148m  \x1b[49m    \x1b[m",
    "\x1b[39m\x1b[49m                \x1b[48;2;153;78;112m    \x1b[48;2;205;63;93m      \x1b[48;2;246;87;102m  \x1b[48;2;205;63;93m            \x1b[48;2;154;23;70m    \x1b[48;2;182;124;167m  \x1b[48;2;197;147;195m  \x1b[48;2;212;170;223m  \x1b[48;2;182;124;167m  \x1b[48;2;212;170;223m  \x1b[48;2;153;78;112m  \x1b[48;2;142;44;86m  \x1b[48;2;154;23;70m  \x1b[48;2;205;63;93m    \x1b[48;2;255;224;255m  \x1b[48;2;225;187;233m  \x1b[48;2;246;87;102m  \x1b[48;2;205;63;93m          \x1b[48;2;246;87;102m    \x1b[48;2;205;63;93m  \x1b[48;2;154;23;70m  \x1b[48;2;200;151;200m  \x1b[49m    \x1b[m",
    "\x1b[39m\x1b[49m                  \x1b[48;2;153;78;112m  \x1b[48;2;255;224;255m  \x1b[48;2;212;170;223m  \x1b[48;2;205;63;93m  \x1b[48;2;154;23;70m              \x1b[48;2;182;124;167m    \x1b[48;2;147;64;101m  \x1b[48;2;36;35;46m      \x1b[48;2;153;78;112m  \x1b[49m  \x1b[48;2;66;78;122m  \x1b[48;2;200;100;119m  \x1b[48;2;205;63;93m  \x1b[48;2;246;87;102m      \x1b[48;2;205;63;93m                \x1b[48;2;154;23;70m    \x1b[48;2;200;151;200m  \x1b[49m    \x1b[m",
    "\x1b[39m\x1b[49m                  \x1b[48;2;153;78;112m  \x1b[48;2;255;224;255m                \x1b[48;2;212;170;223m    \x1b[48;2;182;124;167m  \x1b[48;2;36;35;46m    \x1b[49m          \x1b[48;2;66;78;122m  \x1b[48;2;153;55;95m  \x1b[48;2;205;63;93m  \x1b[48;2;246;87;102m      \x1b[48;2;205;63;93m              \x1b[48;2;154;23;70m    \x1b[48;2;255;224;255m  \x1b[48;2;176;115;156m  \x1b[49m    \x1b[m",
    "\x1b[39m\x1b[49m                    \x1b[48;2;153;78;112m    \x1b[48;2;255;224;255m      \x1b[48;2;212;170;223m  \x1b[48;2;255;224;255m    \x1b[48;2;185;128;172m  \x1b[48;2;153;78;112m  \x1b[48;2;36;35;46m  \x1b[49m              \x1b[48;2;66;78;122m  \x1b[48;2;153;55;95m  \x1b[48;2;154;23;70m  \x1b[48;2;246;87;102m      \x1b[48;2;205;63;93m            \x1b[48;2;154;23;70m    \x1b[48;2;255;224;255m  \x1b[48;2;212;170;223m  \x1b[48;2;176;115;156m  \x1b[49m    \x1b[m",
    "\x1b[39m\x1b[49m                        \x1b[48;2;153;78;112m                \x1b[49m                \x1b[48;2;87;54;75m  \x1b[48;2;207;163;214m  \x1b[48;2;190;136;182m      \x1b[48;2;202;151;191m  \x1b[48;2;244;187;187m            \x1b[48;2;241;206;245m  \x1b[48;2;243;209;246m  \x1b[48;2;212;170;223m    \x1b[48;2;153;78;112m  \x1b[49m    \x1b[m",
    "\x1b[39m\x1b[49m                                                          \x1b[48;2;56;42;57m    \x1b[48;2;212;170;223m    \x1b[48;2;255;224;255m      \x1b[48;2;212;170;223m  \x1b[48;2;255;224;255m  \x1b[48;2;243;208;246m  \x1b[48;2;238;203;242m  \x1b[48;2;255;224;255m  \x1b[48;2;212;170;223m    \x1b[48;2;153;78;112m  \x1b[48;2;153;77;111m  \x1b[49m    \x1b[m",
    "\x1b[39m\x1b[49m                                                              \x1b[48;2;153;78;112m                        \x1b[49m        \x1b[m"
  ];
}
