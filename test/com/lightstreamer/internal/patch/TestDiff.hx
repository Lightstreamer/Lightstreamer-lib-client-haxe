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
package com.lightstreamer.internal.patch;

import com.lightstreamer.internal.patch.Diff.DiffDecoder.apply;

class TestDiff extends utest.Test {
  function testDecode() {
    equals("", apply("", ""));
    equals("foo", apply("foo", "d")); // copy(3)
    equals("foo", apply("foobar", "d")); // copy(3)
    equals("fzap", apply("foobar", "bdzap")); // copy(1)add(3,zap)
    equals("fzapbar", apply("foobar", "bdzapcd")); // copy(1)add(3,zap)del(2)copy(3)
    equals("zapfoo", apply("foobar", "adzapad")); // copy(0)add(3,zap)del(0)copy(3)
    equals("foo", apply("foobar", "aaad")); // copy(0)add(0)del(0)copy(3)
    equals("1", apply("abcdefghijklmnopqrstuvwxyz1", "aaBab")); // copy(0)add(0)del(26)copy(1)
  }
}