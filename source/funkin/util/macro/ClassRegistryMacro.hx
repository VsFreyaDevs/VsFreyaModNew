package funkin.util.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;

class ClassRegistryMacro
{
  public static macro function build():Array<Field>
  {
    var fields = Context.getBuildFields();

    var cls = Context.getLocalClass().get();
    var entryCls = getEntryClass(cls);
    var scriptedEntryCls = getScriptedEntryClass(entryCls);

    fields = fields.concat(buildInstanceField(cls));

    fields.push(buildEntryTraceNameField(entryCls));

    fields.push(buildIgnoreBuiltInEntryField(entryCls, scriptedEntryCls));

    fields.push(buildListScriptedClassesField(scriptedEntryCls));

    fields.push(buildGetBuildInEntriesField(entryCls));

    fields.push(buildCreateScriptedEntryField(entryCls, scriptedEntryCls));

    return fields;
  }

  #if macro
  static function getEntryClass(cls:ClassType):ClassType
  {
    switch (cls.superClass.t.get().kind)
    {
      case KGenericInstance(_, params):
        switch (params[0])
        {
          case TInst(t, _):
            return t.get();
          default:
            throw 'Not a class';
        }
      default:
        throw 'Not in the correct format';
    }
  }

  static function getScriptedEntryClass(entryCls:ClassType):ClassType
  {
    var scriptedEntryClsName = entryCls.pack.join('.') + '.Scripted' + entryCls.name;
    switch (Context.getType(scriptedEntryClsName))
    {
      case Type.TInst(t, _):
        return t.get();
      default:
        throw 'Not A Class (${scriptedEntryClsName})';
    };
  }

  static function buildInstanceField(cls:ClassType):Array<Field>
  {
    var fields = [];

    fields.push(
      {
        name: '_instance',
        access: [Access.APrivate, Access.AStatic],
        kind: FieldType.FVar(ComplexType.TPath(
          {
            pack: [],
            name: 'Null',
            params: [
              TypeParam.TPType(ComplexType.TPath(
                {
                  pack: cls.pack,
                  name: cls.name,
                  params: []
                }))
            ]
          })),
        pos: Context.currentPos()
      });

    fields.push(
      {
        name: 'instance',
        access: [Access.APublic, Access.AStatic],
        kind: FieldType.FProp("get", "never", ComplexType.TPath(
          {
            pack: cls.pack,
            name: cls.name,
            params: []
          })),
        pos: Context.currentPos()
      });

    var newStrExpr = 'new ${cls.pack.join('.')}.${cls.name}()';
    var newExpr = Context.parse(newStrExpr, Context.currentPos());

    fields.push(
      {
        name: 'get_instance',
        access: [Access.APrivate, Access.AStatic],
        kind: FFun(
          {
            args: [],
            expr: macro
            {
              if (_instance == null)
              {
                _instance = ${newExpr};
              }
              return _instance;
            },
            params: [],
            ret: ComplexType.TPath(
              {
                pack: cls.pack,
                name: cls.name,
                params: []
              })
          }),
        pos: Context.currentPos()
      });

    return fields;
  }

  static function buildEntryTraceNameField(entryCls:ClassType):Field
  {
    return {
      name: 'entryTraceName',
      access: [Access.APrivate],
      kind: FieldType.FFun(
        {
          args: [],
          expr: macro
          {
            var traceName:String = '';
            for (i in 0...$v{entryCls.name.length})
            {
              var c = $v{entryCls.name}.charAt(i);
              if ('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.contains(c))
              {
                traceName += ' ';
              }
              traceName += c.toLowerCase();
            }
            return traceName;
          },
          params: [],
          ret: (macro :String)
        }),
      pos: Context.currentPos()
    };
  }

  static function buildIgnoreBuiltInEntryField(entryCls:ClassType, scriptedEntryCls:ClassType):Field
  {
    var entryClsName = '${entryCls.pack.join('.')}.${entryCls.name}';
    var scriptedEntryClsName = '${scriptedEntryCls.pack.join('.')}.${scriptedEntryCls.name}';

    return {
      name: 'ignoreBuiltInEntry',
      access: [Access.APrivate],
      kind: FieldType.FFun(
        {
          args: [
            {
              name: 'builtInEntryName',
              type: (macro :String)
            }
          ],
          expr: macro
          {
            return builtInEntryName == $v{entryClsName} || builtInEntryName == $v{scriptedEntryClsName};
          },
          params: [],
          ret: (macro :Bool)
        }),
      pos: Context.currentPos()
    };
  }

  static function buildListScriptedClassesField(scriptedEntryCls:ClassType):Field
  {
    var scriptedEntryExpr = Context.parse('${scriptedEntryCls.pack.join('.')}.${scriptedEntryCls.name}', Context.currentPos());

    return {
      name: 'listScriptedClasses',
      access: [Access.APrivate],
      kind: FieldType.FFun(
        {
          args: [],
          expr: macro
          {
            return ${scriptedEntryExpr}.listScriptClasses();
          },
          params: [],
          ret: (macro :Array<String>)
        }),
      pos: Context.currentPos()
    };
  }

  static function buildGetBuildInEntriesField(entryCls:ClassType):Field
  {
    var entryExpr = Context.parse('${entryCls.pack.join('.')}.${entryCls.name}', Context.currentPos());

    return {
      name: 'getBuiltInEntries',
      access: [Access.APrivate],
      kind: FieldType.FFun(
        {
          args: [],
          expr: macro
          {
            return funkin.util.macro.ClassMacro.listSubclassesOf($entryExpr);
          },
          params: [],
          ret: ComplexType.TPath(
            {
              pack: [],
              name: 'List',
              params: [
                TypeParam.TPType(ComplexType.TPath(
                  {
                    pack: [],
                    name: 'Class',
                    params: [
                      TypeParam.TPType(ComplexType.TPath(
                        {
                          pack: entryCls.pack,
                          name: entryCls.name
                        }))
                    ]
                  }))
              ]
            })
        }),
      pos: Context.currentPos()
    };
  }

  static function buildCreateScriptedEntryField(entryCls:ClassType, scriptedEntryCls:ClassType):Field
  {
    var scriptedStrExpr = '${scriptedEntryCls.pack.join('.')}.${scriptedEntryCls.name}.init(clsName, ${buildNullArgs(entryCls.constructor.get())})';
    var scriptedInitExpr = Context.parse(scriptedStrExpr, Context.currentPos());

    return {
      name: 'createScriptedEntry',
      access: [Access.APrivate],
      kind: FieldType.FFun(
        {
          args: [
            {
              name: 'clsName',
              type: (macro :String)
            }
          ],
          expr: macro
          {
            return ${scriptedInitExpr};
          },
          params: [],
          ret: ComplexType.TPath(
            {
              pack: [],
              name: 'Null',
              params: [
                TypeParam.TPType(ComplexType.TPath(
                  {
                    pack: entryCls.pack,
                    name: entryCls.name
                  }))
              ]
            })
        }),
      pos: Context.currentPos()
    };
  }

  static function buildNullArgs(fun:ClassField):String
  {
    var amount:Int = 0;
    switch (fun.type)
    {
      case Type.TFun(args, _):
        amount = args.length;
      case Type.TLazy(f):
        switch (f())
        {
          case Type.TFun(args, _):
            amount = args.length;
          default:
            throw 'Not a function';
        }
      default:
        throw 'Not a function';
    }

    var args = [];
    for (i in 0...amount)
    {
      args.push('null');
    }
    return args.join(', ');
  }
  #end
}
