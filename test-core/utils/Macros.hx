/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package utils;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using Lambda;
using StringTools;
using haxe.macro.TypeTools;

/**
 * Searches the methods having the name starting with '_test' and for each combination of methods and
 * parameters generates a test method which sets the field `_param` to the value of the parameter and
 * then calls the method.
 */
macro function parameterize(...params: String): Array<Field> {
  var fields = Context.getBuildFields();
  // add field `param`
  fields.push({
    name: "_param",
    kind: FVar(macro :String, macro null),
    pos: Context.currentPos()
  });
  // generate a test method for each parameter value
  var testFields = fields.filter(f -> f.name.startsWith("_test") && f.kind.match(FFun(_)));
  for (param in params) {
    for (field in testFields) {
      var fieldFunc = switch field.kind {
        case FFun(f): f;
        case _: null;
      };
      var newField = {
        name: getName(field.name, param),
        kind: FFun({
          args: fieldFunc.args,
          expr: macro {
            this._param = $v{param};
            $i{field.name}(async);
          }
        }),
        pos: Context.currentPos()
      };
      fields.push(newField);
    }
  }
  return fields;
}

/**
 * Removes the leading _ from `name`, replaces all non-word characters in `param` with _
 * and concatenates the two strings.
 */
private function getName(name: String, param: String) {
  return name.substring(1) + "_"  + ~/[^\w]/g.replace(param, "_");
}

function synchronizeClass(): Array<Field> {
  var fields = Context.getBuildFields();
  var hasLock = false;
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
  if (!hasLock) {
    fields.push({
      name:  "lock",
      access: [Access.AFinal],
      kind: FieldType.FVar(macro: hx.concurrent.lock.RLock, macro new hx.concurrent.lock.RLock()), 
      pos: Context.currentPos(),
    });
  }
  // synchronize (1) public, non-static methods and (2) private, non-static, @:synchronized methods
  // by wrapping the bodies in lock.execute
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
      macro @:pos(field.pos) this.lock.execute(() -> ${func.expr})
    else 
      macro @:pos(field.pos) return this.lock.execute(() -> ${func.expr});
  }
  return fields;
}