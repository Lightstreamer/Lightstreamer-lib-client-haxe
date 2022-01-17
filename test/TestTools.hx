
function strictSame<T>(clazz: Class<utest.Assert>, expected: T, actual: T) {
  utest.Assert.same(expected, actual);
}