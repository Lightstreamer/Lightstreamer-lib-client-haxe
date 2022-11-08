package com.lightstreamer.client;

import com.lightstreamer.internal.InfoMap;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.Types;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

#if (js || python) @:expose @:native("ConnectionDetails") #end
#if (java || cs || python) @:nativeGen #end
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
@:access(com.lightstreamer.client.LightstreamerClient)
class LSConnectionDetails {
  var serverAddress: Null<ServerAddress>;
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
    actionLogger.logInfo('adapterSet changed: $adapterSet');
    this.adapterSet = adapterSet;
    client.eventDispatcher.onPropertyChange("adapterSet");
  }

  public function getUser(): Null<String> {
    return user;
  }
  public function setUser(user: Null<String>): Void {
    actionLogger.logInfo('user changed: $user');
    this.user = user;
    client.eventDispatcher.onPropertyChange("user");
  }

  public function setPassword(password: Null<String>): Void {
    actionLogger.logInfo("password changed");
    this.password = password;
    client.eventDispatcher.onPropertyChange("password");
  }

  public function getSessionId(): Null<String> {
    return sessionId;
  }

  function setSessionId(sessionId: String) {
    this.sessionId = sessionId;
    client.eventDispatcher.onPropertyChange("sessionId");
  }

  public function getServerInstanceAddress(): Null<String> {
    return serverInstanceAddress;
  }

  function setServerInstanceAddress(serverInstanceAddress: String) {
    this.serverInstanceAddress = serverInstanceAddress;
    client.eventDispatcher.onPropertyChange("serverInstanceAddress");
  }

  public function getServerSocketName(): Null<String> {
    return serverSocketName;
  }

  function setServerSocketName(serverSocketName: String) {
    this.serverSocketName = serverSocketName;
    client.eventDispatcher.onPropertyChange("serverSocketName");
  }
  
  public function getClientIp(): Null<String> {
    return clientIp;
  }

  function setClientIp(clientIp: String) {
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
    return map.toString();
  }
}