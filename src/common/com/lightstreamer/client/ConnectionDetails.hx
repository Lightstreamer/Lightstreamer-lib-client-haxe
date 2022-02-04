package com.lightstreamer.client;

import com.lightstreamer.client.Types;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

#if (js || python) @:expose @:native("ConnectionDetails") #end
#if (java || cs || python) @:nativeGen #end
@:build(com.lightstreamer.client.Macros.synchronizeClass())
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

  public function new() {}

  public function getServerAddress(): Null<String> {
    return serverAddress;
  }
  public function setServerAddress(serverAddress: Null<String>): Void {
    var newValue = ServerAddress.fromString(serverAddress);
    actionLogger.logInfo('serverAddress changed: $newValue');
    this.serverAddress = newValue;
    // TODO forward event to client
  }

  public function getAdapterSet(): Null<String> {
    return adapterSet;
  }
  public function setAdapterSet(adapterSet: Null<String>): Void {
    actionLogger.logInfo('adapterSet changed: $adapterSet');
    this.adapterSet = adapterSet;
  }

  public function getUser(): Null<String> {
    return user;
  }
  public function setUser(user: Null<String>): Void {
    actionLogger.logInfo('user changed: $user');
    this.user = user;
  }

  public function setPassword(password: Null<String>): Void {
    actionLogger.logInfo("password changed");
    this.password = password;
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