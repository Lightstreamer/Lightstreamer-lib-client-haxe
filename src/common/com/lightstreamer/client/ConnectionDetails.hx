package com.lightstreamer.client;

import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.Types;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

#if (js || python) @:expose @:native("ConnectionDetails") #end
#if (java || cs || python) @:nativeGen #end
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
@:access(com.lightstreamer.client.LightstreamerClient)
class ConnectionDetails {
  // TODO fire property listeners
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
    this.serverAddress = newValue;
    client.eventDispatcher.onPropertyChange("serverAddress");
    // TODO forward event to client
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

  public function getServerInstanceAddress(): Null<String> {
    return serverInstanceAddress;
  }

  public function getServerSocketName(): Null<String> {
    return serverSocketName;
  }
  
  public function getClientIp(): Null<String> {
    return clientIp;
  }
}