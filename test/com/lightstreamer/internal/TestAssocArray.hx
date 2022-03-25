package com.lightstreamer.internal;

class TestAssocArray extends utest.Test {
  var a: AssocArray<String>;

  function setup() {
    a = new AssocArray();
    a[1] = "one";
    a[4] = "four";
    a[6] = "six";
  }

  function testLength() {
    equals(3, a.length);
  }

  function testRead() {
    equals(null, a[0]);
    equals("one", a[1]);
    equals("four", a[4]);
    equals("six", a[6]);
    equals(null, a[9]);
  }

  function testIterator() {
    same(
      [1 => "one", 4 => "four", 6 => "six"], 
      [for (k => v in a) k => v]);
  }
}