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

import com.lightstreamer.internal.InfoMap;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.Types;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

private var DEFAULT_SERVER = #if LS_WEB
!js.Browser.supported || (js.Browser.location?.protocol != "http:" && js.Browser.location?.protocol != "https:") ? null : 
  ServerAddress.fromString(
    js.Browser.location.protocol + "//" + js.Browser.location.hostname + (js.Browser.location.port != "" ? ":" + js.Browser.location.port : "") + "/");
#else
null;
#end

#if (js || python) @:expose @:native("LSConnectionDetails") #end
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
@:access(com.lightstreamer.client)
class LSConnectionDetails {
  var serverAddress: Null<ServerAddress> = DEFAULT_SERVER;
  var adapterSet: Null<String>;
  var user: Null<String>;
  var password: Null<String>;
  var sessionId: Null<String>;
  var serverInstanceAddress: Null<String>;
  var serverSocketName: Null<String>;
  var clientIp: Null<String>;
  final client: LightstreamerClient;
  final lock: com.lightstreamer.internal.RLock;

  public function new(client: LightstreamerClient) {
    this.client = client;
    this.lock = client.lock;
  }

  public function getServerAddress(): Null<String> {
    return serverAddress;
  }
  public function setServerAddress(serverAddress: Null<String>): Void {
    var newValue = ServerAddress.fromString(serverAddress);
    if (newValue == this.serverAddress) {
      return;
    }
    actionLogger.logInfo('serverAddress changed: $newValue');
    var oldValue = this.serverAddress;
    this.serverAddress = newValue;
    client.eventDispatcher.onPropertyChange("serverAddress");
    if (oldValue != newValue) {
      client.machine.evtServerAddressChanged();
    }
  }

  public function getAdapterSet(): Null<String> {
    return adapterSet;
  }
  public function setAdapterSet(adapterSet: Null<String>): Void {
    if (adapterSet == this.adapterSet) {
      return;
    }
    actionLogger.logInfo('adapterSet changed: $adapterSet');
    this.adapterSet = adapterSet;
    client.eventDispatcher.onPropertyChange("adapterSet");
  }

  public function getUser(): Null<String> {
    return user;
  }
  public function setUser(user: Null<String>): Void {
    if (user == this.user) {
      return;
    }
    actionLogger.logInfo('user changed: $user');
    this.user = user;
    client.eventDispatcher.onPropertyChange("user");
  }

  public function setPassword(password: Null<String>): Void {
    if (password == this.password) {
      return;
    }
    actionLogger.logInfo("password changed");
    this.password = password;
    client.eventDispatcher.onPropertyChange("password");
  }

  public function getSessionId(): Null<String> {
    return sessionId;
  }

  function setSessionId(sessionId: Null<String>) {
    if (sessionId == this.sessionId) {
      return;
    }
    this.sessionId = sessionId;
    client.eventDispatcher.onPropertyChange("sessionId");
  }

  public function getServerInstanceAddress(): Null<String> {
    return serverInstanceAddress;
  }

  function setServerInstanceAddress(serverInstanceAddress: Null<String>) {
    if (serverInstanceAddress == this.serverInstanceAddress) {
      return;
    }
    this.serverInstanceAddress = serverInstanceAddress;
    client.eventDispatcher.onPropertyChange("serverInstanceAddress");
  }

  public function getServerSocketName(): Null<String> {
    return serverSocketName;
  }

  function setServerSocketName(serverSocketName: Null<String>) {
    if (serverSocketName == this.serverSocketName) {
      return;
    }
    this.serverSocketName = serverSocketName;
    client.eventDispatcher.onPropertyChange("serverSocketName");
  }
  
  public function getClientIp(): Null<String> {
    return clientIp;
  }

  function setClientIp(clientIp: Null<String>) {
    if (clientIp == this.clientIp) {
      return;
    }
    this.clientIp = clientIp;
    client.eventDispatcher.onPropertyChange("clientIp");
  }

  public function toString(): String {
    var map = new InfoMap();
    map["serverAddress"] = serverAddress;
    map["adapterSet"] = adapterSet;
    map["user"] = user;
    map["sessionId"] = sessionId;
    map["serverInstanceAddress"] = serverInstanceAddress;
    map["serverSocketName"] = serverSocketName;
    map["clientIp"] = clientIp;
    map["libVersion"] = LightstreamerClient.LIB_NAME + " " + LightstreamerClient.LIB_VERSION;
    return map.toString();
  }
}