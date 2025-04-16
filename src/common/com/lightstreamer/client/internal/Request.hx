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

class Request {
  static final EOL_LEN =  lengthOfBytes("\r\n");
  var body = "";

  public function new() {}

  public function getByteSize() {
    return lengthOfBytes(body);
  }

  public function getBody() {
    return body;
  }

  public function addSubRequest(req: String) {
    if (isEmpty(body))  {
      body = req;
    } else {
      body += "\r\n" + req;
    }
  }

  public function addSubRequestOnlyIfBodyIsLessThan(req: String, requestLimit: Int) {
    if (isEmpty(body) && lengthOfBytes(req) <= requestLimit) {
      body = req;
      return true;
    } else if (lengthOfBytes(body) + EOL_LEN + lengthOfBytes(req) <= requestLimit) {
      body += "\r\n" + req;
      return true;
    }
    return false;
  }

  static function isEmpty(s: String) {
    return s.length == 0;
  }

  static function lengthOfBytes(req: String) {
    return haxe.io.Bytes.ofString(req, haxe.io.Encoding.UTF8).length;
  }
}