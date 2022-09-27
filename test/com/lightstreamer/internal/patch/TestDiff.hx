package com.lightstreamer.internal.patch;

import com.lightstreamer.internal.patch.Diff;

class TestDiff extends utest.Test {
  function testDiff() {
    equals("", applyDiff("", []));
    equals("foo", applyDiff("foo", [DiffCopy(3)]));
    equals("foo", applyDiff("foobar", [DiffCopy(3)]));
    equals("fzap", applyDiff("foobar", [DiffCopy(1), DiffAdd(3, "zap")]));
    equals("fzapbar", applyDiff("foobar", [DiffCopy(1), DiffAdd(3, "zap"), DiffDel(2), DiffCopy(3)]));
    equals("zapfoo", applyDiff("foobar", [DiffCopy(0), DiffAdd(3, "zap"), DiffDel(0), DiffCopy(3)]));
    equals("foo", applyDiff("foobar", [DiffCopy(0), DiffAdd(0, "zap"), DiffDel(0), DiffCopy(3)])); 
  }
}