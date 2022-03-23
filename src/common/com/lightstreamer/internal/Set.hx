package com.lightstreamer.internal;

class Set<T> {
  final values: Array<T> = [];

  inline public function new() {}

  public function insert(x: T) {
    if (!values.contains(x)) {
      values.push(x);
    }
  }
}