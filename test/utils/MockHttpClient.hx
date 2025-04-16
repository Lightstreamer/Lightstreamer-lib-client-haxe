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

import com.lightstreamer.internal.PlatformApi.IHttpClient;

class MockHttpClient implements IHttpClient {
  final test: utest.Test;
  final prefix: String;

  public function new(test: utest.Test, prefix: String = "http") {
    this.test = test;
    this.prefix = prefix;
  }

  public function create(url: String, body: String, headers: Null<Map<String, String>>, onText: (IHttpClient, String)->Void, onError: (IHttpClient, String)->Void, onDone: IHttpClient->Void) {
    this.onText = onText.bind(this);
    this.onError = onError.bind(this, prefix + ".error");
    this.onDone = onDone.bind(this);
    test.exps.signal(prefix + ".send " + url + "\r\n" + body);
    return this;
  }

  public function dispose() test.exps.signal(prefix + ".dispose");
  public function isDisposed() return false;

  dynamic public function onText(s: String) {}
  dynamic public function onError() {}
  dynamic public function onDone() {}
}