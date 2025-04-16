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

@:build(com.lightstreamer.internal.Macros.buildPythonImport("com_lightstreamer_net", "HttpClientPy"))
extern class HttpClientPy {
  function new();
  function sendAsync(url: String, body: String, headers: Null<python.Dict<String, String>>, proxy: Null<TypesPy.Proxy>, sslContext: Null<SSLContext>): Void;
  function dispose(): Void;
  function isDisposed(): Bool;
  function on_text(client: HttpClientPy, line: String): Void;
  function on_error(client: HttpClientPy, error: python.Exceptions.BaseException): Void;
  function on_done(client: HttpClientPy): Void;
}