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
package utils;

import com.lightstreamer.internal.PlatformApi.IWsClient;

class MockWsClient implements IWsClient {
  final test: utest.Test;

  public function new(test: utest.Test) this.test = test;
  
  public function create(url: String, headers: Null<Map<String, String>>, onOpen: IWsClient->Void, onText: (IWsClient, String)->Void, onError: (IWsClient, String)->Void) {
    this.onOpen = onOpen.bind(this);
    this.onText = onText.bind(this);
    this.onError = onError.bind(this, "ws.error");
    test.exps.signal("ws.init " + url);
    return this;
  }

  public function send(txt: String) test.exps.signal(txt);
  public function dispose() test.exps.signal("ws.dispose");
  public function isDisposed() return false;

  dynamic public function onOpen() {}
  dynamic public function onText(s: String) {}
  dynamic public function onError() {}
}