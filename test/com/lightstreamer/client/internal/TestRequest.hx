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
package com.lightstreamer.client.internal;

class TestRequest extends utest.Test {

  function testAdd() {
    var req = new Request();
    req.addSubRequest("foo");
    equals("foo", req.getBody());
    req.addSubRequest("bar");
    equals("foo\r\nbar", req.getBody());
  }

  function testConditionalAdd() {
    var req = new Request();
    equals(true, req.addSubRequestOnlyIfBodyIsLessThan("foo", 5));
    equals(false, req.addSubRequestOnlyIfBodyIsLessThan("bar", 5));
    equals("foo", req.getBody());
  }

  function testSurrogatePairs() {
    var req = new Request();
    equals(true, req.addSubRequestOnlyIfBodyIsLessThan("🌉", 10));
    equals(true, req.addSubRequestOnlyIfBodyIsLessThan("🌐", 10));
    equals(false, req.addSubRequestOnlyIfBodyIsLessThan("a", 10));
    equals(10, req.getByteSize());
    equals("🌉\r\n🌐", req.getBody());
  }
}