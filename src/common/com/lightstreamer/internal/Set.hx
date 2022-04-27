package com.lightstreamer.internal;

class Set<T> {
  final values: Array<T> = [];

  public function new() {}

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

  public function toArray() {
    return values;
  }
}