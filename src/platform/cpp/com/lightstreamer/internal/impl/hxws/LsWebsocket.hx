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
package com.lightstreamer.internal.impl.hxws;

import hx.ws.WebSocket;

class LsWebsocket extends WebSocket {
  public function new(url: String, protocol: String, headers: Null<Map<String, String>>) {
    super(url, false);
    additionalHeaders.set("Sec-WebSocket-Protocol", protocol);
    if (headers != null) {
      for (k => v in headers) {
        additionalHeaders.set(k, v);
      }
    }
  }
}