package com.lightstreamer.internal;

using Lambda;

private class AssocPair<T> {
  public final key: Int;
  public final value: T;

  public function new(key: Int, val: T) {
    this.key = key;
    this.value = val;
  }
}

// like an Array (and unlike Map), AssocArray returns its elements in the order they were originally inserted
@:forward(length)
abstract AssocArray<T>(MyList<AssocPair<T>>) {

  public function new() {
    this = new MyList();
  }

  @:op([]) 
  public function arrayRead(key: Int): Null<T> {
    var pair = this.find(p -> p.key == key);
    return pair == null ? null : pair.value;
  }

  @:op([]) 
  public function arrayWrite(key: Int, value: T): T {
    // NB not checking if the key already exists
    this.push(new AssocPair(key, value));
    return value;
  }

  public function remove(key: Int) {
    this.removeIf(p -> p.key == key);
  }

  public function keyValueIterator() {
    // since AssocPair has fields key and value,
    // it is compatible with KeyValueIterator interface
    return this.iterator();
  }

  public function containsValue(val: T) {
    return this.exists(p -> p.value == val);
  }
}