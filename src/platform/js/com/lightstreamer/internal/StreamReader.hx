package com.lightstreamer.internal;

class StreamReader {
  var progress = 0;

  inline public function new() {}

  function extractNewData(stream: String, isComplete: Bool) {
    var endIndex;
    if (isComplete) {
      endIndex = stream.length;
    } else {
      endIndex = stream.lastIndexOf("\r\n");
      if (endIndex < 0) {
        return [];
      } else {
        endIndex += 2;
      }
    }
    if (endIndex <= progress) {
      return [];
    }
    var newData = stream.substring(progress, endIndex);
    progress = endIndex;
    return newData.split("\r\n");
  }

  inline public function streamProgress(stream: String) {
    return extractNewData(stream, false);
  }

  inline public function streamComplete(stream: String) {
    return extractNewData(stream, true);
  }
}