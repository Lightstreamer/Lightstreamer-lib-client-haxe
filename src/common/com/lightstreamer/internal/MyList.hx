package com.lightstreamer.internal;

import haxe.ds.List;

/**
 * A List where it is safe to remove the current element while iterating.
 */
@:forward(remove, filter, map, iterator, keyValueIterator, length, toString)
abstract MyList<T>(List<T>) {

  public function new() {
    this = new List();
  }

  inline public function push(e: T) {
    this.add(e);
  }

  inline public function exists(f: T->Bool) {
    return Lambda.exists(this, f);
  }

  inline public function find(f: T->Bool) {
    return Lambda.find(this, f);
  }

  inline public function contains(x: T) {
    return Lambda.has(this, x);
  }

  // adapted from https://github.com/HaxeFoundation/haxe/blob/4.2.5/std/haxe/ds/List.hx
  @:access(haxe.ds.List)
  public function removeIf(pred: T->Bool): Bool {
    var prev:Dynamic = null;
    var l = this.h;
    while (l != null) {
      if (pred(l.item)) {
        if (prev == null)
          this.h = l.next;
        else
          prev.next = l.next;
        if (this.q == l)
          this.q = prev;
        this.length--;
        return true;
      }
      prev = l;
      l = l.next;
    }
    return false;
  }
}
