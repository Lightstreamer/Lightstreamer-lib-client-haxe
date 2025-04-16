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

class TestStreamReader extends utest.Test {

  function testStreamProgress() {
    var stream = new StreamReader();
    same([], 
      stream.streamProgress("lorem ipsum"));
    same(["lorem ipsum", ""], 
      stream.streamProgress("lorem ipsum\r\ndolor sit amet"));
    same(["dolor sit amet", ""], 
      stream.streamProgress("lorem ipsum\r\ndolor sit amet\r\n"));
    same(["consectetur", "adipiscing", ""], 
      stream.streamProgress("lorem ipsum\r\ndolor sit amet\r\nconsectetur\r\nadipiscing\r\nelit"));
  }

  function testStreamComplete() {
    var stream = new StreamReader();
    same(["lorem ipsum", "dolor sit amet", "consectetur", "adipiscing", "elit"], 
      stream.streamComplete("lorem ipsum\r\ndolor sit amet\r\nconsectetur\r\nadipiscing\r\nelit"));

    stream = new StreamReader();
    same(["lorem ipsum", "dolor sit amet", "consectetur", "adipiscing", "elit", ""], 
      stream.streamComplete("lorem ipsum\r\ndolor sit amet\r\nconsectetur\r\nadipiscing\r\nelit\r\n"));
  }
}