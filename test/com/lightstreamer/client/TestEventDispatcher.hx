package com.lightstreamer.client;

private interface IEvtListener {
  function evt1(s: String): Void;
  function evt2(i: Int): Void;
}

private class EvtListener implements IEvtListener {
  public var output = new Array<Any>();
  public function new() {}
  public function evt1(s: String) output.push(s);
  public function evt2(i: Int) output.push(i);
}

private class EvtDispatcher extends EventDispatcher<IEvtListener> {}

class TestEventDispatcher extends utest.Test {
  var dispatcher = new EvtDispatcher();
  var listener = new EvtListener();

  function testAddListener(async: utest.Async) {
    equals(true, dispatcher.addListener(listener));
    equals(false, dispatcher.addListener(listener));
    dispatcher.evt1("evt1");

    delay(() -> {
      same(["evt1"], listener.output);
      async.done();
    }, 50);
  }

  function testRemoveListener(async: utest.Async) {
    equals(true, dispatcher.addListener(listener));
    equals(true, dispatcher.removeListener(listener));
    equals(false, dispatcher.removeListener(listener));
    dispatcher.evt1("evt1");

    delay(() -> {
      same([], listener.output);
      async.done();
    }, 50);
  }

  function testGetListeners() {
    equals(0, dispatcher.getListeners().length);
    dispatcher.addListener(listener);
    equals(1, dispatcher.getListeners().length);
    equals(listener, dispatcher.getListeners()[0]);
    dispatcher.removeListener(listener);
    equals(0, dispatcher.getListeners().length);
  }
}