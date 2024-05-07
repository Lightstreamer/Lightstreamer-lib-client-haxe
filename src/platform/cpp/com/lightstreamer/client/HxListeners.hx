package com.lightstreamer.client;

import cpp.Star;
import cpp.Pointer;
import haxe.Constraints.Constructible;

/**
 * A list of native listeners and their haxe adapters.
 */
@:generic
@:unreflective
class HxListeners<L, A: Constructible<(Pointer<L>)->Void>> {
  final _listeners = new Array<Pair<Pointer<L>, A>>();

  public function new() {}
  
  /**
   * Adds the native listener `l` and its haxe adapter, provided that `l` is not already present. 
   * If `l` is added, the callback `ifAdded` is invoked with the haxe adapter as argument.
   */
  public function add(l: Star<L>, ifAdded: A->Void) {
    var p = Pointer.fromStar(l);
    for (l in _listeners) {
      if (l._1 == p) {
        return;
      }
    }
    var la = new A(p);
    _listeners.push({ _1: p, _2: la });
    ifAdded(la);
  }

  /**
   * Removes the native listener `l` and its haxe adapter, provided that `l` is present.
   * If `l` is removed, the callback `ifRemoved` is invoked with the haxe adapter as argument. 
   */
  public function remove(l: Star<L>, ifRemoved: A->Void) {
    var p = Pointer.fromStar(l);
    var j = -1;
    for (i => l in _listeners) {
      if (l._1 == p) {
        j = i;
        break;
      }
    }
    if (j != -1) {
      var la = _listeners[j]._2;
      _listeners.splice(j, 1);
      ifRemoved(la);
    }
  }

  public function iterator(): Iterator<Pair<Pointer<L>, A>> {
    return _listeners.iterator();
  }
}