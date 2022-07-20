package utest;

import hx.concurrent.lock.Semaphore;

class Async {
  public var isCompleted(default, null) = false;
  final runner: Runner;
  final testIndex: Int;

  public function new(runner: Runner, testIndex: Int) {
    this.runner = runner;
    this.testIndex = testIndex;
  }

  public function completed() {
    //trace('async.completed testIndex=$testIndex');
    isCompleted = true;
    runner.evtCompleted(testIndex);
  }

  inline public function done() {
    completed();
  }
}