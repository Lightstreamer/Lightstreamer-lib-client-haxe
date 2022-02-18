package com.lightstreamer.internal;

#if macro
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
using haxe.macro.TypeTools;

function synchronizeClass(): Array<Field> {
  // don't synchronize single-threaded languages
  if (Context.defined("js") || Context.defined("php"))
    return null;
  var fields = Context.getBuildFields();
  if (!fields.map(f -> f.name).contains("lock")) {
    fields.push({
      name:  "lock",
      access: [Access.AFinal],
      kind: FieldType.FVar(macro: com.lightstreamer.internal.RLock, macro new com.lightstreamer.internal.RLock()), 
      pos: Context.currentPos(),
    });
  }
  // synchronize public, non-static methods by wrapping the bodies in lock.execute
  for (field in fields) {
    if (field.name == "new")
      continue;
    if (!(field.access != null && field.access.contains(APublic) && !field.access.contains(AStatic)))
      continue;
    if (field.meta != null && field.meta.map(m -> m.name).contains(":unsynchronized"))
      continue;
    var func: Function;
    switch field.kind {
    case FFun(f) if (f.expr != null):
      func = f;
    case _:
      continue;
    }
    func.expr = if (func.ret == null || switch func.ret {
      case TPath({name: "Void"}): true;
      case _: false;
    }) 
      macro this.lock.execute(() -> ${func.expr})
    else 
      macro return this.lock.execute(() -> ${func.expr});
  }
  return fields;
}

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
              dispatchToOne(listener, l -> if (l.onListenStart != null) l.onListenStart( $a{eventArgs} ));
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
              dispatchToOne(listener, l -> if (l.onListenEnd != null) l.onListenEnd( $a{eventArgs} ));
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
            dispatchToAll(listener -> if (listener.$eventName != null) listener.$eventName( $a{eventArgs} ));
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