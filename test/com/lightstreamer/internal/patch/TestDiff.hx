package com.lightstreamer.internal.patch;

import com.lightstreamer.internal.patch.Diff.DiffDecoder.apply;

class TestDiff extends utest.Test {
  function testDecode() {
    equals("", apply("", ""));
    equals("foo", apply("foo", "d")); // copy(3)
    equals("foo", apply("foobar", "d")); // copy(3)
    equals("fzap", apply("foobar", "bdzap")); // copy(1)add(3,zap)
    equals("fzapbar", apply("foobar", "bdzapcd")); // copy(1)add(3,zap)del(2)copy(3)
    equals("zapfoo", apply("foobar", "adzapad")); // copy(0)add(3,zap)del(0)copy(3)
    equals("foo", apply("foobar", "aaad")); // copy(0)add(0)del(0)copy(3)
    equals("1", apply("abcdefghijklmnopqrstuvwxyz1", "aaBab")); // copy(0)add(0)del(26)copy(1)
  }
}