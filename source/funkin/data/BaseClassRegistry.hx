package funkin.data;

import haxe.Constraints.Constructible;
import flixel.FlxG;

using StringTools;

@:generic
abstract class BaseClassRegistry<T:(IClassRegistryEntry)>
{
  /**
   * This registry's id
   */
  public var registryId(default, null):String;

  final entries:Map<String, T>;
  final scriptedEntries:Map<String, String>;

  public function new(registryId:String)
  {
    this.registryId = registryId;
    this.entries = new Map<String, T>();
    this.scriptedEntries = new Map<String, String>();

    // Lazy initialization of singletons should let this get called,
    // but we have this check just in case.
    if (FlxG.game != null)
    {
      FlxG.console.registerObject('registry$registryId', this);
    }
  }

  /**
   * Loads all built-in and scripted classes
   */
  public function loadEntries():Void
  {
    this.entries.clear();
    this.scriptedEntries.clear();

    registerBuiltInClasses();
    registerScriptedClasses();
  }

  /**
   * Retrieve all registered Entries
   * @return Entries
   */
  public function fetchEntries():Array<T>
  {
    return entries.values();
  }

  /**
   * Retrieve all registered Entries' ids
   * @return Ids
   */
  public function fetchEntryIds():Array<String>
  {
    return entries.keys().array();
  }

  /**
   * Retrieve only registered scripted Entries
   * @return Scripted Entries
   */
  public function fetchScriptedEntries():Array<String>
  {
    return scriptedEntries.values();
  }

  /**
   * Retrieve only registered scripted Entries' ids
   * @return Scripted Ids
   */
  public function fetchScriptedEntryIds():Array<String>
  {
    return scriptedEntries.keys().array();
  }

  /**
   * Retrive entry by id
   * @param id The ID
   * @return Null<T>
   */
  public function fetchEntry(id:String):Null<T>
  {
    return entries.get(id);
  }

  /**
   * Creates an instance of an entry
   * @param id The id
   * @return Null<T>
   */
  public function createInstanceOf(id:String):Null<T>
  {
    var scriptedEntry = scriptedEntries.get(id);
    if (scriptedEntry != null)
    {
      return createScriptedEntry(scriptedEntry);
    }

    var entry = entries.get(id);
    if (entry == null)
    {
      return null;
    }
    return Type.createInstance(Type.getClass(entry), []);
  }

  function registerBuiltInClasses():Void
  {
    final baseEntryName:String = entryTraceName();

    trace('Instantiating ${getBuiltInEntries().length - 2} built-in${baseEntryName}s...');
    for (builtInEntryCls in getBuiltInEntries())
    {
      var builtInEntryClsName:String = Type.getClassName(builtInEntryCls);
      if (ignoreBuiltInEntry(builtInEntryClsName))
      {
        continue;
      }

      var builtInEntry:T = Type.createInstance(builtInEntryCls, []);

      if (builtInEntry != null)
      {
        trace('  Loaded built-in${baseEntryName}: ${builtInEntry.id}');
        entries.set(builtInEntry.id, builtInEntry);
      }
      else
      {
        trace('  Failed to load built-in${baseEntryName}: ${builtInEntryClsName}');
      }
    }
  }

  function registerScriptedClasses():Void
  {
    final baseEntryName:String = entryTraceName();

    var scriptedEntryClsNames:Array<String> = listScriptedClasses();
    trace('Instantiating ${scriptedEntryClsNames.length} scripted${baseEntryName}s...');
    if (scriptedEntryClsNames == null || scriptedEntryClsNames.length == 0) return;

    for (scriptedEntryCls in scriptedEntryClsNames)
    {
      var scriptedEntry:Null<T> = createScriptedEntry(scriptedEntryCls);

      if (scriptedEntry != null)
      {
        trace('  Loaded scripted${baseEntryName}: ${scriptedEntry.id}');
        entries.set(scriptedEntry.id, scriptedEntry);
        scriptedEntries.set(scriptedEntry.id, scriptedEntryCls);
      }
      else
      {
        trace('  Failed to instantiate scripted${baseEntryName} class: ${scriptedEntryCls}');
      }
    }
  }

  abstract function entryTraceName():String;

  abstract function listScriptedClasses():Array<String>;

  abstract function ignoreBuiltInEntry(builtInEntryName:String):Bool;

  abstract function getBuiltInEntries():List<Class<T>>;

  abstract function createScriptedEntry(id:String):Null<T>;
}
