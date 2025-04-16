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

#if js @:native("ClientListener") #end
#if python @:build(com.lightstreamer.internal.Macros.buildPythonImport("ls_python_client_api", "ClientListener")) #end
#if cpp interface #else extern interface #end ClientListener {
  // NB onListenStart and onListenEnd have the hidden parameter `client` for the sake of the legacy web widgets
  public function onListenEnd(#if js client: LightstreamerClient #end): Void;
  public function onListenStart(#if js client: LightstreamerClient #end): Void;
  public function onServerError(errorCode: Int, errorMessage: String): Void;
  public function onStatusChange(status: String): Void;
  public function onPropertyChange(property: String): Void;
  #if LS_WEB
  public function onServerKeepalive(): Void;
  #end
}