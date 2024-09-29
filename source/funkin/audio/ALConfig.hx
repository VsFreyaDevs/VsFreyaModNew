package funkin.audio;

import haxe.io.Path;

class ALConfig
{
  #if desktop
  static function __init__():Void
  {
    var configPath:String = Path.directory(Path.withoutExtension(Sys.programPath()));

    #if windows
    configPath += "/plugins/alsoft.ini";
    #elseif mac
    configPath = Path.directory(configPath) + "/Resources/plugins/alsoft.conf";
    #else
    configPath += "/plugins/alsoft.conf";
    #end

    Sys.putEnv("ALSOFT_CONF", configPath);
  }
  #end
}
