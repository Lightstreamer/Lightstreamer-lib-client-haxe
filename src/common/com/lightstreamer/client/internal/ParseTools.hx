package com.lightstreamer.client.internal;

import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.Types;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;
using com.lightstreamer.internal.NullTools;
using StringTools;
using com.lightstreamer.client.internal.ParseTools;

function parseInt(s: String) {
  return Std.parseInt(s).sure();
}

function parseFloat(s: String) {
  return Std.parseFloat(s).sure();
}

class UpdateInfo {
  public final subId: Int;
  public final itemIdx: Pos;
  public final values: Map<Pos, FieldValue>;

  public function new(subId: Int, itemIdx: Pos, values: Map<Pos, FieldValue>) {
    this.subId = subId;
    this.itemIdx = itemIdx;
    this.values = values;
  }
}

function parseUpdate(message: String): UpdateInfo {
  // message is either U,<table>,<item>,<filed_1>|...|<field_N>
  // or U,<table>,<item>,<field_1>|^<number of unchanged fields>|...|<field_N>

  /* parse table and item */
  var tableIndex = message.checkedIndexOf(",") + 1;
  var itemIndex = message.checkedIndexOf(",", tableIndex) + 1;
  var fieldsIndex = message.checkedIndexOf(",", itemIndex) + 1;
  var table = parseInt(message.substring(tableIndex, itemIndex - 1));
  var item = parseInt(message.substring(itemIndex, fieldsIndex - 1));
  
  /* parse fields */
  var values = new Map<Pos, FieldValue>();
  var fieldStart = fieldsIndex - 1; // index of the separator introducing the next field
  var nextFieldIndex = 1;
  while (fieldStart < message.length) {
    var fieldEnd = message.indexOf("|", fieldStart + 1);
    if (fieldEnd == -1) {
      fieldEnd = message.length;
    }
    /*
      Decoding algorithm:
        1) Set a pointer to the first field of the schema.
        2) Look for the next pipe “|” from left to right and take the substring to it, or to the end of the line if no pipe is there.
        3) Evaluate the substring:
           A) If its value is empty, the pointed field should be left unchanged and the pointer moved to the next field.
           B) Otherwise, if its value corresponds to a single “#” (UTF-8 code 0x23), the pointed field should be set to a null value and the pointer moved to the next field.
           C) Otherwise, If its value corresponds to a single “$” (UTF-8 code 0x24), the pointed field should be set to an empty value (“”) and the pointer moved to the next field.
           D) Otherwise, if its value begins with a caret “^” (UTF-8 code 0x5E):
               - take the substring following the caret and convert it to an integer number;
               - for the corresponding count, leave the fields unchanged and move the pointer forward;
               - e.g. if the value is “^3”, leave unchanged the pointed field and the following two fields, and move the pointer 3 fields forward;
           E) Otherwise, the value is an actual content: decode any percent-encoding and set the pointed field to the decoded value, then move the pointer to the next field.
            Note: “#”, “$” and “^” characters are percent-encoded if occurring at the beginning of an actual content.
        4) Return to the second step, unless there are no more fields in the schema.
     */
    var value = message.substring(fieldStart + 1, fieldEnd);
    if (value == "") { // step A
      values[nextFieldIndex] = unchanged;
      nextFieldIndex += 1;
    } else if (value == "#") { // step B
      values[nextFieldIndex] = changed(null);
      nextFieldIndex += 1;
    } else if (value == "$") { // step C
      values[nextFieldIndex] = changed("");
      nextFieldIndex += 1;
    } else if (value.charAt(0) == "^") { // step D
      if (value.charAt(1) == "P") {
        #if LS_JSON_PATCH
        var unquoted = value.substring(2).urlDecode();
        try {
          var patch = new com.lightstreamer.internal.patch.Json.JsonPatch(unquoted);
          values[nextFieldIndex] = jsonPatch(patch);
          nextFieldIndex += 1;
        } catch(e) {
          sessionLogger.logErrorEx(e.message, e);
          throw new IllegalStateException('The JSON Patch for the field $nextFieldIndex is not well-formed');
        }
        #else
        throw new IllegalStateException("JSONPatch compression is not supported by the client");
        #end
      } else {
        var count = parseInt(value.substring(1));
        for (_ in 0...count) {
          values[nextFieldIndex] = unchanged;
          nextFieldIndex += 1;
        }
      }
    } else { // step E
      values[nextFieldIndex] = changed(value.urlDecode());
      nextFieldIndex += 1;
    }
    fieldStart = fieldEnd;
  }
  return new UpdateInfo(table, item, values);
}

private function checkedIndexOf(s: String, needle: String, ?startIndex:Int): Int {
  var i = s.indexOf(needle, startIndex);
  if (i == -1) {
    throw new IllegalStateException("string not found");
  }
  return i;
}