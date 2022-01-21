package com.lightstreamer.client;

#if macro
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
using haxe.macro.TypeTools;

function buildEventDispatcher(): Array<Field> {
  var fields: Array<Field> = Context.getBuildFields();
  var localType: Type = Context.getLocalType();
  var localClass: ClassType;
  switch localType {
    case TInst(_.get() => t, _):
      localClass = t;
    case _:
      throw false;
  }
  var localSuperClassType: ClassType = localClass.superClass.t.get();
  var typeParamType: Type = localClass.superClass.params[0];
  var typeParamClassType: ClassType;
  switch typeParamType {
    case TInst(_.get() => t, _):
      typeParamClassType = t;
    case _:
      throw false;
  }
  var typeParamFields: Array<ClassField> = typeParamClassType.fields.get();
  for (typeParamField in typeParamFields) {
    // event: ClassField
    var typeParamFieldType: Type = typeParamField.type;
    var typeParamFieldArgs:Array<{name:String, opt:Bool, t:Type}>;
    switch typeParamFieldType {
      case TFun(args, _):
        typeParamFieldArgs = args;
      case _:
        throw false;
    }
    var eventName: String = typeParamField.name;
    var eventDispatcherArgs: Array<FunctionArg> = [ for (a in typeParamFieldArgs) {name: a.name, type: a.t.toComplexType()} ];
    var eventArgs: Array<Expr> = [ for (a in typeParamFieldArgs) macro $i{a.name} ];
    var eventField: Field;
    if (eventName == "onListenStart") {
      eventDispatcherArgs = [{name: "listener", type: typeParamType.toComplexType()}].concat(eventDispatcherArgs);
      eventField = {
        name: "addListenerAndFireOnListenStart",
        access:  [Access.APublic],
        kind: FieldType.FFun({
          expr: macro {
            if (addListener(listener))
              dispatchToOne(listener, l -> l.onListenStart( $a{eventArgs} ));
          },
          ret: (macro:Void),
          args: eventDispatcherArgs
        }),
        pos: Context.currentPos()
      };
    } else if (eventName == "onListenEnd") {
      eventDispatcherArgs = [{name: "listener", type: typeParamType.toComplexType()}].concat(eventDispatcherArgs);
      eventField = {
        name: "removeListenerAndFireOnListenEnd",
        access:  [Access.APublic],
        kind: FieldType.FFun({
          expr: macro {
            if (removeListener(listener))
              dispatchToOne(listener, l -> l.onListenEnd( $a{eventArgs} ));
          },
          ret: (macro:Void),
          args: eventDispatcherArgs
        }),
        pos: Context.currentPos()
      };
    } else {
      eventField = {
        name:  eventName,
        access:  [Access.APublic],
        kind: FieldType.FFun({
          expr: macro {
            dispatchToAll(listener -> listener.$eventName( $a{eventArgs} ));
          },
          ret: (macro:Void),
          args: eventDispatcherArgs
        }),
        pos: Context.currentPos()
      };
    }
    fields.push(eventField);
  }
  return fields;
}
#end