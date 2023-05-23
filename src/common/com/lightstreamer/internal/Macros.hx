package com.lightstreamer.internal;

#if macro
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
using haxe.macro.TypeTools;
using Lambda;

/**
 * Patches the method `haxe.Timer.delay` by internally using `setTimeout` instead of `setInterval` in order to fix an issue of the latter when executed in a React Native environment (see `https://github.com/facebook/react-native/issues/37464`).
 * 
 * @see `com.lightstreamer.internal.JsTimer`
 * @see `https://community.haxe.org/t/solved-how-to-make-math-random-deterministic` for a hint about how to patch Haxe standard library
 */
 macro function patchHaxeTimer(): Array<Field> {
  var fields = Context.getBuildFields();
  for (field in fields) {
    if (field.name == "delay") {
      switch field.kind {
      case FFun(fun):
        var args = fun.args;
        var f = macro $i{args[0].name};
        var time_ms = macro $i{args[1].name};
        fun.expr = macro {
          var t = new com.lightstreamer.internal.JsTimer($time_ms);
          t.run = $f;
          return cast t;
        }
      default:
        Context.fatalError("haxe.Timer.delay not found", Context.currentPos());
      }
    }
  }
  return fields;
}

/**
 * Synchronizes a class by adding a lock field and by wrapping the bodies of the methods in the expression `lock.synchronized`.
 * 
 * The synchronization is only applied to methods that are:
 * 1) non-static and public, or
 * 2) non-static and private but annotated with @:synchronized.
 * 
 * Annotating a method with @:unsynchronized prevents the synchronization.
 */
function synchronizeClass(): Array<Field> {
  var fields = Context.getBuildFields();
  var hasLock = false;
  // search a field named `lock` in the class and its super classes
  if (fields.exists(f -> f.name == "lock" && f.kind.match(FVar(_,_)))) {
    hasLock = true;
  } else {
    var clazz: ClassType = Context.getLocalClass().get();
    while (clazz != null) {
      var fields = clazz.fields.get();
      if (fields.exists(f -> f.name == "lock" && f.kind.match(FVar(_,_)))) {
        hasLock = true;
        break;
      }
      var superDesc = clazz.superClass;
      clazz = superDesc != null ? superDesc.t.get() : null;
    }
  }
  // add a lock if it doesn't exist yet
  if (!hasLock) {
    fields.push({
      name:  "lock",
      access: [Access.AFinal],
      kind: FieldType.FVar(macro: com.lightstreamer.internal.RLock, macro new com.lightstreamer.internal.RLock()), 
      pos: Context.currentPos(),
    });
  }
  // single-thread targets don't need synchronization
  if (!Context.defined("target.threaded")) {
    return fields;
  }
  // wrap the eligible methods in `lock.synchronized`
  for (field in fields) {
    if (field.name == "new")
      continue;
    if (!(field.access != null && !field.access.contains(AStatic) && (field.access.contains(APublic) || field.meta != null && field.meta.map(m -> m.name).contains(":synchronized"))))
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
      macro @:pos(field.pos) this.lock.synchronized(() -> ${func.expr})
    else 
      macro @:pos(field.pos) return this.lock.synchronized(() -> ${func.expr});
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

function buildPythonImport(typeModule: String, typeName: String): Array<Field> {
  var isPython = Context.defined("python");
  if (isPython) {
    var pos = Context.currentPos();
    var localClass: ClassType = Context.getLocalClass().get();
    var isTest = Context.defined("LS_TEST");
    if (!isTest) {
      typeModule = "." + typeModule;
    }
    localClass.meta.add(":pythonImport", [macro $v{typeModule}, macro $v{typeName}], pos);
  }
  return null;
}
#end