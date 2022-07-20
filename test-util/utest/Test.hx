package utest;

import hx.concurrent.executor.Executor;
import haxe.Exception;
import deepequal.DeepEqual;
import utils.Expectations;

using Lambda;

private final executor = Executor.create();

@:rtti
class Test {
  var name: String = null;
  final errors: Array<Exception> = [];
  var _async: Async = null;
  var numAssertions = 0;
  public final exps: Expectations;

  public function new() {
    this.exps = new Expectations(this);
  }

  function fail(error: String) {
    numAssertions++;
    addError(error);
  }

  function pass() {
    numAssertions++;
  }

  function equals(expected: Any, actual: Any) {
    numAssertions++;
    if (expected is Int) {
      // fix for cs: DeepEqual.compare has problems when comparing different types of integers
      if (expected != actual) {
        addError('Expected $expected but found $actual');
      }
    } else {
      switch DeepEqual.compare(expected, actual) {
        case Success(_):
        case Failure(f):
          addError(f.message);
      }
    }
  }

  function strictEquals<T>(expected: T, actual: T) {
    equals(expected, actual);
  }

  function floatEquals(expected: Float, actual: Float, approx: Float) {
    numAssertions++;
    if (Math.abs(expected - actual) > approx) {
      addError('Expected $expected but found $actual');
    }
  }

  function same(expected: Any, actual: Any) {
    equals(expected, actual);
  }

  function strictSame<T>(expected: T, actual: T) {
    equals(expected, actual);
  }

  function contains<T>(value: T, array: Array<T>) {
    numAssertions++;
    if (!array.contains(value)) {
      addError('Expected $value in array but not found');
    }
  }
  
  function isTrue(cond: Bool) {
    equals(true, cond);
  }

  function isFalse(cond: Bool) {
    equals(false, cond);
  }

  function isNull(value: Any) {
    isTrue(value == null);
  }

  function notNull(value: Any) {
    isTrue(value != null);
  }
  
  function match(regex: EReg, actual: String) {
    numAssertions++;
    if (!regex.match(actual)) {
      addError('Expected $regex but found $actual');
    }
  }

  function raises(func: ()->Void, clazz: Class<Any>) {
    numAssertions++;
    try {
      func();
    } catch(e: Dynamic) {
      if (!Std.isOfType(e, clazz)) {
        addError('Expected class ${Type.getClassName(clazz)} but found ${Type.getClassName(Type.getClass(e))}');
      }
    }
  }

  function raisesEx(method:() -> Void, type: Class<Dynamic>, exMsg: String) {
    numAssertions++;
    try {
      method();
      fail('Expected exception $type');
    } catch (e) {
      equals(exMsg, e.message);
    }
  }

  function jsonEquals(expected: String, actual: String) {
    equals(haxe.Json.parse(expected), haxe.Json.parse(actual));
  }

  inline function addError(error: String) {
    errors.push(new Exception(error));
  }

  inline function addException(ex: Exception) {
    errors.push(ex);
  }

  function passed() {
    return errors.length == 0;
  }

  function delay(task: ()->Void, ms: Int) {
    return executor.submit(task, Schedule.ONCE(ms));
  }
}