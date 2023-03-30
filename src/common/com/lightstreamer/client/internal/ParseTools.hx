package com.lightstreamer.client.internal;

import haxe.io.Encoding;
import haxe.io.Bytes;
import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.NativeTypes.Long;
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

function parseLong(s: String): Long {
  #if (js || python)
  return parseInt(s);
  #else
  return haxe.Int64.parseString(s);
  #end
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
           D.1) Otherwise, if its value begins with a caret “^” (UTF-8 code 0x5E) and is followed by a digit:
               - take the substring following the caret and convert it to an integer number;
               - for the corresponding count, leave the fields unchanged and move the pointer forward;
               - e.g. if the value is “^3”, leave unchanged the pointed field and the following two fields, and move the pointer 3 fields forward;
           D.2) if its value begins with a caret “^” and is followed by "P", the value is a JSON patch
           D.3) if its value begins with a caret “^” and is followed by "T", the value is a TLCP-diff
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
        var unquoted = value.substring(2).unquote();
        try {
          var patch = new com.lightstreamer.internal.patch.Json.JsonPatch(unquoted);
          values[nextFieldIndex] = jsonPatch(patch);
          nextFieldIndex += 1;
        } catch(e) {
          sessionLogger.logErrorEx('Invalid JSON patch $unquoted: ${e.message}', e);
          throw new IllegalStateException('The JSON Patch for the field $nextFieldIndex is not well-formed');
        }
        #else
        throw new IllegalStateException("JSONPatch compression is not supported by the client");
        #end
      } else if (value.charAt(1) == "T") {
        #if LS_TLCP_DIFF
        var unquoted = value.substring(2).unquote();
        var patch = new com.lightstreamer.internal.patch.Diff.DiffPatch(unquoted);
        values[nextFieldIndex] = diffPatch(patch);
        nextFieldIndex += 1;
        #else
        throw new IllegalStateException("TLCP-diff compression is not supported by the client");
        #end
      } else {
        var count = parseInt(value.substring(1));
        for (_ in 0...count) {
          values[nextFieldIndex] = unchanged;
          nextFieldIndex += 1;
        }
      }
    } else { // step E
      values[nextFieldIndex] = changed(value.unquote());
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

/**
 * Converts a string containing sequences as {@code %<hex digit><hex digit>} into a new string 
 * where such sequences are transformed in UTF-8 encoded characters. <br> 
 * For example the string "a%C3%A8" is converted to "aè" because the sequence 'C3 A8' is 
 * the UTF-8 encoding of the character 'è'.
 */
function unquote(s: String): String {
  // to save space and time the input byte sequence is also used to store the converted byte sequence.
  // this is possible because the length of the converted sequence is equal to or shorter than the original one.
  var bb = Bytes.ofString(s, Encoding.UTF8);
  var i = 0, j = 0;
  while (i < bb.length) {
    // assert i >= j;
    if (bb.get(i) == "%".code) {
      var firstHexDigit  = hexToNum(bb.get(i + 1));
      var secondHexDigit = hexToNum(bb.get(i + 2));
      bb.set(j++, (firstHexDigit << 4) + secondHexDigit); // i.e (firstHexDigit * 16) + secondHexDigit
      i += 3;
    } else {
      bb.set(j++, bb.get(i++));
    }
  }
  // j contains the length of the converted string
  var ss = bb.getString(0, j, Encoding.UTF8);
  return ss;
}

/**
 * Converts an ASCII-encoded hex digit in its numeric value.
 */
private function hexToNum(ascii: Int): Int {
  var hex = 0;
  // NB ascii characters '0', 'A', 'a' have codes 30, 41 and 61
  if ((hex = ascii - "a".code + 10) > 9) {
    // NB (ascii - 'a' + 10 > 9) <=> (ascii >= 'a')
    // and thus ascii is in the range 'a'..'f' because
    // '0' and 'A' have codes smaller than 'a'
    // assert 'a' <= ascii && ascii <= 'f';
    // assert 10 <= hex && hex <= 15;
  } else if ((hex = ascii - "A".code + 10) > 9) {
    // NB (ascii - 'A' + 10 > 9) <=> (ascii >= 'A')
    // and thus ascii is in the range 'A'..'F' because
    // '0' has a code smaller than 'A' 
    // and the range 'a'..'f' is excluded
    // assert 'A' <= ascii && ascii <= 'F';
    // assert 10 <= hex && hex <= 15;
  } else {
    // NB ascii is in the range '0'..'9'
    // because the ranges 'a'..'f' and 'A'..'F' are excluded
    hex =  ascii - "0".code;
    // assert '0' <= ascii && ascii <= '9';
    // assert 0 <= hex && hex <= 9;
  }
  // assert 0 <= hex && hex <= 15;
  return hex;
}