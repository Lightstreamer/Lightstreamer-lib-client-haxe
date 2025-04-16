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
@:pythonImport("lightstreamer.client", "ConnectionDetails")
#end
#if js @:native("ConnectionDetails") #end
#if LS_NODE @:jsRequire("lightstreamer-client-node", "ConnectionDetails") #end
extern class ConnectionDetails {
  #if !cs
  public function getAdapterSet(): Null<String>;
  public function setAdapterSet(adapterSet: Null<String>): Void;
  public function getServerAddress(): Null<String>;
  public function setServerAddress(serverAddress: Null<String>): Void;
  public function getUser(): Null<String>;
  public function setUser(user: Null<String>): Void;
  public function setPassword(password: Null<String>): Void;
  public function getSessionId(): Null<String>;
  public function getServerInstanceAddress(): Null<String>;
  public function getServerSocketName(): Null<String>;
  public function getClientIp(): Null<String>;
  #else
  public var AdapterSet(default, default): Null<String>;
  public var ServerAddress(default, default): Null<String>;
  public var User(default, default): Null<String>;
  public var Password(never, default): Null<String>;
  public var SessionId(default, never): Null<String>;
  public var ServerInstanceAddress(default, never): Null<String>;
  public var ServerSocketName(default, never): Null<String>;
  public var ClientIp(default, never): Null<String>;
  #end
}