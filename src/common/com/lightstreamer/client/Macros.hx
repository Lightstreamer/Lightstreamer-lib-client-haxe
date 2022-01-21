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
  var eventType: Type = localClass.superClass.params[0];
  var eventClassType: ClassType;
  switch eventType {
    case TInst(_.get() => t, _):
      eventClassType = t;
    case _:
      throw false;
  }
  var eventFields: Array<ClassField> = eventClassType.fields.get();
  for (eventClassField in eventFields) {
    // event: ClassField
    var eventFieldType: Type = eventClassField.type;
    var eventArgs:Array<{name:String, opt:Bool, t:Type}>;
    switch eventFieldType {
      case TFun(args, _):
        eventArgs = args;
      case _:
        throw false;
    }
    var eventDispatcherArgs: Array<FunctionArg> = [ for (a in eventArgs) {name: a.name, type: a.t.toComplexType()} ];
    var eventActualArgs: Array<Expr> = [ for (a in eventArgs) macro $i{a.name} ];
    var eventFieldName: String = eventClassField.name;
    var eventField: Field = {
      name:  eventFieldName,
      access:  [Access.APublic],
      kind: FieldType.FFun({
        expr: macro {
          for (listener in listeners)
            listener.$eventFieldName( $a{eventActualArgs} );
        },
        ret: (macro:Void),
        args: eventDispatcherArgs
      }),
      pos: Context.currentPos()
    };
    fields.push(eventField);
  }
  return fields;
}
#end