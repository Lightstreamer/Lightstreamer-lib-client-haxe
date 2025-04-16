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
package com.lightstreamer.client.hxcbridge;

import cpp.Star;
import cpp.Pointer;
import haxe.Constraints.Constructible;

/**
 * A list of native listeners and their haxe adapters.
 */
@:generic
@:unreflective
class ListenerArray<L, A: Constructible<(Pointer<L>)->Void>> {
  final _listeners = new Array<Pair<Pointer<L>, A>>();

  public function new() {}
  
  /**
   * Adds the given native listener and its haxe adapter, provided that the listener is not already present. 
   * If the listener is added, the callback `ifAdded` is invoked with the haxe adapter as argument.
   */
  public function add(nativeListener: Star<L>, ifAdded: A->Void) {
    var p = Pointer.fromStar(nativeListener);
    for (l in _listeners) {
      if (l._1 == p) {
        return;
      }
    }
    var adapter = new A(p);
    _listeners.push({ _1: p, _2: adapter });
    ifAdded(adapter);
  }

  /**
   * Removes the given native listener and its haxe adapter, provided that the listener is present.
   * If the listener is removed, the callback `ifRemoved` is invoked with the haxe adapter as argument. 
   */
  public function remove(nativeListener: Star<L>, ifRemoved: A->Void) {
    var p = Pointer.fromStar(nativeListener);
    var j = -1;
    for (i => l in _listeners) {
      if (l._1 == p) {
        j = i;
        break;
      }
    }
    if (j != -1) {
      var adapter = _listeners[j]._2;
      _listeners.splice(j, 1);
      ifRemoved(adapter);
    }
  }

  public function iterator(): Iterator<Pair<Pointer<L>, A>> {
    return _listeners.iterator();
  }
}

@:structInit
@:publicFields
private class Pair<P, Q> {
  final _1: P;
  final _2: Q;

  function new(_1: P, _2: Q) {
    this._1 = _1;
    this._2 = _2;
  }
}