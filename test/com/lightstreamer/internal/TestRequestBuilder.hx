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

@:access(com.lightstreamer.internal.RequestBuilder)
class TestRequestBuilder extends utest.Test {
  function testEncoding() {
    var req = new RequestBuilder();
    req.addParam("a", "f&=o");
    req.addParam("b", "b +r");
    req.addParam("c", 123);
    req.addParam("d", 456.7);
    req.addParam("e", true);
    equals("a=f%26%3Do&b=b%20%2Br&c=123&d=456.7&e=true", req.getEncodedString());
  }

  function testListEncoding() {
    var req = new RequestBuilder();
    req.LS_item(["a b", "x&y", "%20"]);
    req.LS_field(["f=1", "+"]);
    req.LS_data_adapter("a&b");
    equals("LS_item=a%20b&x%26y&%2520&LS_field=f%3D1&%2B&LS_data_adapter=a%26b", req.getEncodedString());
  }

  function testListOrderAndDuplicates() {
    var req = new RequestBuilder();
    req.LS_item(["second", "first", "second"]);
    req.LS_field(["only"]);
    equals("LS_item=second&first&second&LS_field=only", req.getEncodedString());
  }

  function testUnicodeAndControlNames() {
    var unicode = haxe.io.Bytes.ofHex("c3a9e4b8adf09f9880").toString();
    var req = new RequestBuilder();
    req.LS_item([unicode, "\u0000\t\r\n"]);
    req.LS_field([" ?#/", unicode]);
    equals("LS_item=%C3%A9%E4%B8%AD%F0%9F%98%80&%00%09%0D%0A&LS_field=%20%3F%23%2F&%C3%A9%E4%B8%AD%F0%9F%98%80", req.getEncodedString());
  }

  function testNamesCannotInjectParameters() {
    var req = new RequestBuilder();
    req.LS_item(["LS_group=x", "a&LS_schema=y"]);
    req.LS_field(["LS_field=z"]);
    equals("LS_item=LS_group%3Dx&a%26LS_schema%3Dy&LS_field=LS_field%3Dz", req.getEncodedString());
  }

  function testListSnapshot() {
    var names = ["original"];
    var req = new RequestBuilder();
    req.LS_item(names);
    names[0] = "changed";
    names.push("another");
    equals("LS_item=original", req.getEncodedString());
  }
}