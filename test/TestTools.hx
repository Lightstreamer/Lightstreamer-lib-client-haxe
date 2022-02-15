
function strictSame<T>(expected: T, actual: T) {
  utest.Assert.same(expected, actual);
}

function raisesEx(method:() -> Void, type: Class<Dynamic>, exMsg: String) {
  try {
    method();
    utest.Assert.fail();
  } catch (e) {
    utest.Assert.equals(exMsg, e.message);
  }
}

function jsonEquals(expected: String, actual: String) {
  utest.Assert.same(haxe.Json.parse(expected), haxe.Json.parse(actual));
}

class AsyncTools {
  inline public static function completed(async: utest.Async) {
    sys.thread.Thread.runWithEventLoop(() -> async.done());
  }
}