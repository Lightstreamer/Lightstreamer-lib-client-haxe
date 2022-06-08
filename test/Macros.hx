import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;
using StringTools;

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