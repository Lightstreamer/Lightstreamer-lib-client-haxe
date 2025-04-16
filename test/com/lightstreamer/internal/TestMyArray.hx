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

class TestMyArray extends utest.Test {
  var l: MyArray<Int>;

  function setup() {
    l = new MyArray();
    l.push(0);
    l.push(1);
    l.push(2);
  }

  @:access(com.lightstreamer.internal.MyArray)
  function testCompact() {
    l.remove(0);
    l.remove(2);
    equals(1, l.length);
    equals(3, l.values.length);
    l.compact();
    equals(1, l.values.length);
  }

  function testLength() {
    equals(3, l.length);
  }

  function testRemove() {
    l.remove(1);
    equals("[0, 2]", l.toString());
    l.remove(5);
    equals("[0, 2]", l.toString());
    l.remove(2);
    equals("[0]", l.toString());
    l.remove(0);
    equals("[]", l.toString());
  }

  function removeWhileIteratingHelper(x: Int) {
    l = new MyArray();
    l.push(0);
    l.push(1);
    l.push(2);
    var visited = [];
    for (e in l) {
      visited.push(e);
      if (e == x) {
        l.remove(x);
      }
    }
    return visited;
  }

  function testRemoveWhileIterating() {
    var v = removeWhileIteratingHelper(0);
    equals([0, 1, 2], v);
    equals("[1, 2]", l.toString());
    v = removeWhileIteratingHelper(1);
    equals([0, 1, 2], v);
    equals("[0, 2]", l.toString());
    v = removeWhileIteratingHelper(2);
    equals([0, 1, 2], v);
    equals("[0, 1]", l.toString());
  }

  // function testRemoveIf() {
  //   l.removeIf(e -> e == 1);
  //   equals("[0, 2]", l.toString());
  //   l.removeIf(e -> e == 5);
  //   equals("[0, 2]", l.toString());
  // }

  function testFilter() {
    equals("[0, 2]", l.filter(e -> e % 2 == 0).toString());
  }

  function testMap() {
    equals("[3, 4, 5]", l.map(e -> e + 3).toString());
  }

  function testIterator() {
    equals([0, 1, 2], [for (e in l) e]);
  }

  function testPush() {
    l.push(3);
    equals("[0, 1, 2, 3]", l.toString());
  }

  function testExists() {
    isTrue(l.exists(e -> e == 1));
    isFalse(l.exists(e -> e == 5));
  }

  function testContains() {
    isTrue(l.contains(1));
    isFalse(l.contains(5));
  }

  function testFind() {
    equals(1, l.find(e -> e == 1));
    isNull(l.find(e -> e == 5));
  }
}