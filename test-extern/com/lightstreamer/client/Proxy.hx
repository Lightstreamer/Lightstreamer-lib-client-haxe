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
package com.lightstreamer.client;

#if (java || cs || python)
#if python
@:pythonImport("lightstreamer.client", "Proxy")
#end
extern class Proxy {
  #if (java || cs)
  overload public function new(type: String, host: String, port: Int): Void;
  overload public function new(type: String, host: String, port: Int, user: String): Void;
  overload public function new(type: String, host: String, port: Int, user: String, password: String): Void;
  #end

  #if python
  public function new(type: String, host: String, port: Int, user: Null<String>, password: Null<String>): Void;
  #end
}
#end