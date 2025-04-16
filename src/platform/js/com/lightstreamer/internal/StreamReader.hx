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