package com.lightstreamer.internal;

class Set<T> {
  final values: Array<T> = [];

  public function new(?it: Iterator<T>) {
    if (it != null) {
      for (x in it) {
        insert(x);
      }
    }
  }

  public function count() {
    return values.length;
  }

  public function insert(x: T): Void {
    if (!values.contains(x)) {
      values.push(x);
    }
  }

  public function contains(x: T): Bool {
    return values.contains(x);
  }

  public function remove(x: T) {
    values.remove(x);
  }

  public function removeAll() {
    values.splice(0, values.length);
  }

  public function copy(): Set<T> {
    return new Set(iterator());
  }

  public function union(other: Array<T>): Set<T> {
    var res = new Set();
    for (v in values) {
      res.insert(v);
    }
    for (v in other) {
      res.insert(v);
    }
    return res;
  }

  public function subtracting(other: Array<T>): Set<T> {
    var res = new Set();
    for (v in values) {
      if (!other.contains(v)) {
        res.insert(v);
      }
    }
    return res;
  }

  public function iterator() {
    return values.iterator();
  }

  public function toArray() {
    return values;
  }
}