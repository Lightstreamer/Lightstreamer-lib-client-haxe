
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