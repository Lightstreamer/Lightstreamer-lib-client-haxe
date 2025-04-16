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

import com.lightstreamer.internal.OrderedIntMap;

class TestOrderedIntMap extends utest.Test {
  var a: OrderedIntMap<String>;

  function setup() {
    a = new OrderedIntMap();
    a[1] = "one";
    a[4] = "four";
    a[6] = "six";
  }

  function testLength() {
    equals(3, a.length);
  }

  function testRead() {
    equals(null, a[0]);
    equals("one", a[1]);
    equals("four", a[4]);
    equals("six", a[6]);
    equals(null, a[9]);
  }

  function testIterator() {
    same(
      ["one", "four", "six"], 
      [for (k in a) k]);
  }

  function testKVIterator() {
    same(
      ["1one", "4four", "6six"], 
      [for (k => v in a) k + v]);
  }

  function testRemove() {
    a.remove(4);
    equals("[1 => one, 6 => six]", a.toString());
    equals(2, a.length);
    a.remove(5);
    equals("[1 => one, 6 => six]", a.toString());
    equals(2, a.length);
    a.remove(6);
    equals("[1 => one]", a.toString());
    equals(1, a.length);
    a.remove(1);
    equals("[]", a.toString());
    equals(0, a.length);
  }

  function testContainsValue() {
    isTrue(a.containsValue("four"));
    isFalse(a.containsValue("seven"));
  }

  function removeWhileIteratingHelper(x: Int, y: Int) {
    a = new OrderedIntMap();
    a[0] = "zero";
    a[1] = "one";
    a[2] = "two";
    var visited = [];
    for (k => v in a) {
      notNull(v);
      visited.push(k);
      if (k == x) {
        a.remove(y);
      }
    }
    return visited;
  }

  function testRemoveWhileIterating() {
    var v = removeWhileIteratingHelper(0, 0);
    equals([0, 1, 2], v);
    equals("[1 => one, 2 => two]", a.toString());

    v = removeWhileIteratingHelper(0, 1);
    equals([0, 2], v);
    equals("[0 => zero, 2 => two]", a.toString());

    v = removeWhileIteratingHelper(0, 2);
    equals([0, 1], v);
    equals("[0 => zero, 1 => one]", a.toString());

    v = removeWhileIteratingHelper(1, 0);
    equals([0, 1, 2], v);
    equals("[1 => one, 2 => two]", a.toString());

    v = removeWhileIteratingHelper(1, 1);
    equals([0, 1, 2], v);
    equals("[0 => zero, 2 => two]", a.toString());

    v = removeWhileIteratingHelper(1, 2);
    equals([0, 1], v);
    equals("[0 => zero, 1 => one]", a.toString());

    v = removeWhileIteratingHelper(2, 0);
    equals([0, 1, 2], v);
    equals("[1 => one, 2 => two]", a.toString());

    v = removeWhileIteratingHelper(2, 1);
    equals([0, 1, 2], v);
    equals("[0 => zero, 2 => two]", a.toString());

    v = removeWhileIteratingHelper(2, 2);
    equals([0, 1, 2], v);
    equals("[0 => zero, 1 => one]", a.toString());
  }

  function addWhileIteratingHelper(x: Int) {
    a = new OrderedIntMap();
    a[0] = "zero";
    a[1] = "one";
    a[2] = "two";
    var visited = [];
    for (k => v in a) {
      notNull(v);
      visited.push(k);
      if (k == x) {
        a[3] = "three";
      }
    }
    return visited;
  }

  function testAddWhileIterating() {
    var v = addWhileIteratingHelper(0);
    equals([0, 1, 2, 3], v);
    equals("[0 => zero, 1 => one, 2 => two, 3 => three]", a.toString());

    v = addWhileIteratingHelper(1);
    equals([0, 1, 2, 3], v);
    equals("[0 => zero, 1 => one, 2 => two, 3 => three]", a.toString());

    v = addWhileIteratingHelper(2);
    equals([0, 1, 2, 3], v);
    equals("[0 => zero, 1 => one, 2 => two, 3 => three]", a.toString());
  }
}