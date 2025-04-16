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

#if python
@:pythonImport("lightstreamer.client", "ClientMessageListener")
#end
#if js @:native("ClientMessageListener") #end
#if LS_NODE @:jsRequire("lightstreamer-client-node", "ClientMessageListener") #end
extern interface ClientMessageListener {
  public function onProcessed(msg:String, resp:String): Void;
  public function onDeny(msg:String, code:Int, error:String): Void;
  public function onAbort(msg:String, sentOnNetwork:Bool): Void;
  public function onDiscarded(msg:String): Void;
  public function onError(msg:String): Void;
}