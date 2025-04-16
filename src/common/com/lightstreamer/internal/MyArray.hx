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

/**
 An array implementation that supports appending and removing elements while iterating.

 **NB** To enable removing items while iterating, the elements are not actually removed from the array. They are only marked as deleted. This means that the space they occupy is not freed up, and the array operations can become inefficient. Therefore, you need to call the `compact` method occasionally to reclaim the space and optimize the array.
 */
@:allow(com.lightstreamer.internal.MyArrayIterator)
class MyArray<T> {
  var nRemoved = 0;
  var values = new Array<Pair<T>>();

  inline public function new() {}

  public var length(get, never): Int;

  inline function get_length() {
    return values.length - nRemoved;
  }

  public function compact() {
    if (nRemoved > values.length / 2) {
      nRemoved = 0;
      values = copy().values;
    }
  }

  inline public function push(e: T) {
    values.push(new Pair(e));
  }

  public function remove(e: T) {
    for (i in 0...values.length) {
      if (values[i].item == e && values[i].isValid) {
        nRemoved++;
        values[i].isValid = false;
        break;
      }
    }
  }

  public function filter(pred: T->Bool): MyArray<T> {
    var res = new MyArray();
    for (e in this) {
      if (pred(e)) {
        res.push(e);
      }
    }
    return res;
  }

  public function map<R>(f: T->R): MyArray<R> {
    var res = new MyArray();
    for (e in this) {
      res.push(f(e));
    }
    return res;
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

  inline public function iterator() {
    return new MyArrayIterator(this);
  }

  public function copy(): MyArray<T> {
    var arr = new MyArray();
    for (e in this) {
      arr.push(e);
    }
    return arr;
  }

  public function toString() {
    var i = 0, len = this.length;
    var str = "[";
    for (k in this) {
      str += k + (i != len - 1 ? ", " : "");
      i++;
    }
    return str + "]";
  }
}

private class Pair<T> {
  public final item: T;
  public var isValid: Bool = true;

  public function new(item: T) {
    this.item = item;
  }
}

private class MyArrayIterator<T> {
  var index: Int;
  final a: MyArray<T>;

  // Invariant: the range [0...index) has already been iterated over

  public function new(a: MyArray<T>) {
    this.a = a;
    this.index = 0;
  }

  public function hasNext(): Bool {
    for (j in index...a.values.length) {
      if (a.values[j].isValid) {
        return true;
      }
    }
    return false;
  }

  public function next(): T {
    for (j in index...a.values.length) {
      if (a.values[j].isValid) {
        index = j + 1;
        return a.values[j].item;
      }
    }
    throw new haxe.Exception("No such element");
  }
}