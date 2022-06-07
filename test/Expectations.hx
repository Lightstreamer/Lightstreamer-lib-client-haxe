import haxe.Exception;

private enum Slot {
  Await(expected: String);
  Block(block: ()->Void);
}

@:access(utest.Test)
class Expectations {
  final expectations: Array<Slot> = [];
  final test: utest.Test;

  public function new(test: utest.Test) {
    this.test = test;
  }

  public function verify() {
    runBlocks();
  }

  public function await(expected: String): Expectations {
    expectations.push(Await(expected));
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
    case _:
      throw new Exception("Expected a condition");
    }
  }

  function runBlocks() {
    var slot = expectations[0];
    while (expectations.length > 0) {
      switch slot {
      case Block(block):
        block();
      case Await(_):
        break;
      }
      expectations.shift();
      slot = expectations[0];
    }
  }
}