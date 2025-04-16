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