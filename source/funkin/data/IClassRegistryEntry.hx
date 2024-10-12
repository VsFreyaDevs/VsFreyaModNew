package funkin.data;

interface IClassRegistryEntry
{
  public var id:String;

  public function destroy():Void;
  public function toString():String;
}
