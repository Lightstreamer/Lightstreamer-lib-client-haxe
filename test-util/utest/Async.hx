package utest;

import hx.concurrent.lock.Semaphore;

class Async extends Semaphore {
  public var isCompleted(default, null) = false;

  public function new() {
    super(0);
  }

  public function completed() {
    isCompleted = true;
    release();
  }

  inline public function done() {
    completed();
  }
}