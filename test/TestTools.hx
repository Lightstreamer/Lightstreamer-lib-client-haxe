
function strictSame<T>(clazz: Class<utest.Assert>, expected: T, actual: T) {
  utest.Assert.same(expected, actual);
}

function raisesEx(clazz: Class<utest.Assert>, method:() -> Void, type: Class<Dynamic>, exMsg: String) {
  try {
    method();
    utest.Assert.fail();
  } catch (e) {
    utest.Assert.equals(exMsg, e.message);
  }
}