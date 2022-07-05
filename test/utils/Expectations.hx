package utils;

import haxe.Exception;

private enum Slot {
  Await(expected: String);
  AwaitGroup(expected: Array<String>);
  Block(block: ()->Void);
}

@:access(utest.Test)
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Expectations {
  final expectations: Array<Slot> = [];
  final test: utest.Test;

  public function new(test: utest.Test) {
    this.test = test;
  }

  public function verify() {
    runBlocks();
  }

  public function await(expected: ...String): Expectations {
    if (expected.length == 0) {
      throw new haxe.Exception("Expected not empty value");
    } else if (expected.length == 1) {
      expectations.push(Await(expected[0]));
    } else {
      expectations.push(AwaitGroup(expected));
    }
    return this;
  }

  public function then(block: ()->Void): Expectations {
    expectations.push(Block(block));
    return this;
  }

  public function signal(actual: String) {
    consumeSignal(actual);
    runBlocks();
  }

  function consumeSignal(actual: String) {
    if (expectations.length == 0) {
      return;
    }
    var slot = expectations.shift();
    switch slot {
    case Await(expected):
      test.equals(expected, actual);
    case AwaitGroup(expected):
      var found = expected.remove(actual);
      if (!found) {
        test.fail('"$actual" not found');
      }
      if (expected.length > 0) {
        expectations.unshift(slot);
      }
    case _:
      throw new Exception('Expected $actual but found a block');
    }
  }

  function runBlocks() {
    var slot = expectations[0];
    while (expectations.length > 0) {
      switch slot {
      case Block(block):
        test.delay(block, 0);
      case Await(_) | AwaitGroup(_):
        break;
      }
      expectations.shift();
      slot = expectations[0];
    }
  }
}