/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.lightstreamer.internal;

private interface IEvtListener {
  function onListenStart(s: String): Void;
  function onListenEnd(s: String): Void;
  function evt1(s: String): Void;
  function evt2(i: Int): Void;
}

private class EvtListener implements IEvtListener {
  public var output = new Array<Any>();
  public function new() {}
  public function onListenStart(s: String) output.push(s);
  public function onListenEnd(s: String) output.push(s);
  public function evt1(s: String) output.push(s);
  public function evt2(i: Int) output.push(i);
}

private class EvtDispatcher extends EventDispatcher<IEvtListener> {}

class TestEventDispatcher extends utest.Test {
  var dispatcher: EvtDispatcher;
  var listener: EvtListener;
  static final DELAY = 200;

  public function setup() {
    dispatcher = new EvtDispatcher();
    listener = new EvtListener();
  }

  function testAddListener(async: utest.Async) {
    equals(true, dispatcher.addListener(listener));
    equals(false, dispatcher.addListener(listener));
    dispatcher.evt1("evt1");

    delay(() -> {
      same(["evt1"], listener.output);
      async.done();
    }, DELAY);
  }

  function testRemoveListener(async: utest.Async) {
    equals(true, dispatcher.addListener(listener));
    equals(true, dispatcher.removeListener(listener));
    equals(false, dispatcher.removeListener(listener));
    dispatcher.evt1("evt1");

    delay(() -> {
      same([], listener.output);
      async.done();
    }, DELAY);
  }

  function testGetListeners() {
    equals(0, dispatcher.getListeners().length);
    dispatcher.addListener(listener);
    equals(1, dispatcher.getListeners().length);
    equals(listener, dispatcher.getListeners()[0]);
    dispatcher.removeListener(listener);
    equals(0, dispatcher.getListeners().length);
  }

  function testAddListenerAndFireOnListenStart(async: utest.Async) {
    dispatcher.addListenerAndFireOnListenStart(listener, "onListenStart");
    dispatcher.addListenerAndFireOnListenStart(listener, "onListenStart");

    delay(() -> {
      same(["onListenStart"], listener.output);
      async.done();
    }, DELAY);
  }

  function testRemoveListenerAndFireOnListenEnd(async: utest.Async) {
    dispatcher.addListenerAndFireOnListenStart(listener, "onListenStart");
    dispatcher.removeListenerAndFireOnListenEnd(listener, "onListenEnd");
    dispatcher.removeListenerAndFireOnListenEnd(listener, "onListenEnd");

    delay(() -> {
      same(["onListenStart", "onListenEnd"], listener.output);
      async.done();
    }, DELAY);
  }
}