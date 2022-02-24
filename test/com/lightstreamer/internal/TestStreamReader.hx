package com.lightstreamer.internal;

import com.lightstreamer.internal.HttpClient.StreamReader;

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