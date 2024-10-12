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
    var clsName = cls.pack.join('.') + '.' + cls.name;

    // switch (cls.superClass.params[0])
    // {
    //   case Type.TInst(t, _params):
    //     entryCls = t.get();
    //   default:
    //     // do nothing
    // }

    // we have to retrieve the type parameter using the name of the super class
    var superCls = cls.superClass.t.get();
    var entryClsName = superCls.name.substring(superCls.name.indexOf('_') + 1, superCls.name.length).replace('_', '.');
    var entryExpr = Context.parse(entryClsName, Context.currentPos());

    var entryCls = switch (Context.getType(entryClsName))
    {
      case Type.TInst(t, _params):
        t.get();
      default:
        throw 'Not A Class (${entryClsName})';
    };

    var scriptedEntryClsName = entryCls.pack.join('.') + '.Scripted' + entryCls.name;
    var scriptedEntryExpr = Context.parse(scriptedEntryClsName, Context.currentPos());

    var scriptedEntryCls = switch (Context.getType(scriptedEntryClsName))
    {
      case Type.TInst(t, _params):
        t.get();
      default:
        throw 'Not A Class (${scriptedEntryClsName})';
    };

    var initArgs:Int = 0;
    switch (entryCls.constructor.get().type)
    {
      case Type.TFun(args, ret):
        initArgs = args.length;
      case Type.TLazy(f):
        switch (f())
        {
          case Type.TFun(args, ret):
            initArgs = args.length;
          default:
            throw 'No Constructor';
        }
      default:
        throw 'No Constructor';
    }

    var scriptedStrExpr = '${scriptedEntryClsName}.init(id';
    for (i in 0...initArgs)
    {
      scriptedStrExpr += ', null';
    }
    scriptedStrExpr += ')';
    var scriptedInitExpr = Context.parse(scriptedStrExpr, Context.currentPos());

    fields.push(
      {
        name: '_instance',
        access: [Access.APublic, Access.AStatic],
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
                _instance = Type.createInstance(Type.resolveClass($v{clsName}), []);
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

    fields.push(
      {
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
      });

    fields.push(
      {
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
      });

    fields.push(
      {
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
      });

    fields.push(
      {
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
      });

    fields.push(
      {
        name: 'createScriptedEntry',
        access: [Access.APrivate],
        kind: FieldType.FFun(
          {
            args: [
              {
                name: 'id',
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
      });

    return fields;
  }
}
