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
package com.lightstreamer.log;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Format;

using StringTools;

macro function logFatal(logger: ExprOf<Logger>, line: Expr) {
  line = extractLog(line);
  return macro if ($logger.isFatalEnabled()) {
    $logger.fatal($line);
  }
}

macro function logError(logger: ExprOf<Logger>, line: Expr) {
  line = extractLog(line);
  return macro if ($logger.isErrorEnabled()) {
    $logger.error($line);
  }
}

macro function logErrorEx(logger: ExprOf<Logger>, line: Expr, exception: Expr/*haxe.Exception*/) {
  line = extractLog(line);
  return macro if ($logger.isErrorEnabled()) {
    $logger.error($line + "\n" + $exception.details());
  }
}

macro function logWarn(logger: ExprOf<Logger>, line: Expr) {
  line = extractLog(line);
  return macro if ($logger.isWarnEnabled()) {
    $logger.warn($line);
  }
}

macro function logInfo(logger: ExprOf<Logger>, line: Expr) {
  line = extractLog(line);
  return macro if ($logger.isInfoEnabled()) {
    $logger.info($line);
  }
}

macro function logDebug(logger: ExprOf<Logger>, line: Expr) {
  line = extractLog(line);
  return macro if ($logger.isDebugEnabled()) {
    $logger.debug($line);
  }
}

macro function logDebugEx(logger: ExprOf<Logger>, line: Expr, exception: Expr/*haxe.Exception*/) {
  line = extractLog(line);
  return macro if ($logger.isDebugEnabled()) {
    $logger.debug($line + "\n" + $exception.details());
  }
}

macro function logDebugEx2(logger: ExprOf<Logger>, line: Expr, exception: Expr/*NativeException*/) {
  line = extractLog(line);
  return macro if ($logger.isDebugEnabled()) {
    $logger.debug($line, $exception);
  }
}

macro function logTrace(logger: ExprOf<Logger>, line: Expr) {
  line = extractLog(line);
  return macro if ($logger.isTraceEnabled()) {
    $logger.trace($line);
  }
}

#if macro
var logMessages = [];

/**
 * Parses a log message and separates the string literals from the expressions embedded in the message. For example the message 'foo ${x+y} bar' contains the string literal "foo $1 bar" (where `$1` represents the embedded expression) and the expression `x+y`.
 * 
 * The parser has some limitations, thus the only messages accepted must have patterns such as:
 * 
 * - "foo"
 * - "foo" + x
 * - "foo" + x + "bar"
 * - 'foo'
 * - 'foo $x'
 * - 'foo $x bar'
 * 
 * and so on.
 */
function extractLog(e: Expr) {
  #if !LS_STRIP_LOGS
  return e;
  #end

  var i = 1;
  var tokens: Array<String> = [];
  var expressions: Array<Expr> = [];

  function extract(e: Expr) {
    switch e.expr {
    case EConst(CString(s, DoubleQuotes|null)):
      tokens.push(s);
    case EConst(CString(s, SingleQuotes)):
      var e = Format.format(e);
      switch e.expr {
      case ECheckType(e1, TPath({name: "String"})):
        extract(e1);
      case e1:
        Context.fatalError('Invalid pattern: $e1', e.pos);
      }
    case EBinop(OpAdd, _.expr => EConst(CString(s, DoubleQuotes|null)), e2):
      tokens.push(s);
      tokens.push("$" + i++);
      expressions.push(e2);
    case EBinop(OpAdd, e1, _.expr => EConst(CString(s, DoubleQuotes|null))):
      extract(e1);
      tokens.push(s);
    case EBinop(OpAdd, e1, e2):
      extract(e1);
      tokens.push("$" + i++);
      expressions.push(e2);
    case e1:
      Context.fatalError('Invalid pattern: $e1', e.pos);
    }
  }
  extract(e);

  var stringLiteral = tokens.join("");
  var stringIndex = getLiteralIndex(stringLiteral);
  var msg = [macro $v{stringIndex}].concat(expressions);
  return macro Std.string(($a{msg}:Array<Dynamic>));
}

function getLiteralIndex(stringLiteral: String): Int {
  var stringIndex = logMessages.indexOf(stringLiteral);
  if (stringIndex == -1) {
    stringIndex = logMessages.length;
    logMessages.push(stringLiteral);

    // if length == 1 then getLiteralIndex is called for the first time
    if (logMessages.length == 1) {
      // save the content of logMessages when the compilation ends
      Context.onAfterGenerate(() -> {
        var file = Context.definedValue("LS_STRIP_LOGS");
        var content = haxe.Json.stringify(logMessages);
        sys.io.File.saveContent(file, content);
      });
    }
  }
  return stringIndex;
}
#end