package com.lightstreamer.client;

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