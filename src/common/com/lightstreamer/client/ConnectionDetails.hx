package com.lightstreamer.client;

import com.lightstreamer.client.Types;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

#if (js || python) @:expose @:native("ConnectionDetails") #end
#if (java || cs || python) @:nativeGen #end
class ConnectionDetails {
  // TODO synchronize methods
  // TODO fire property listeners
  @:internal var serverAddress: Null<ServerAddress>;
  @:internal var adapterSet: Null<String>;
  @:internal var user: Null<String>;
  @:internal var password: Null<String>;
  @:internal var sessionId: Null<String>;
  @:internal var serverInstanceAddress: Null<String>;
  @:internal var serverSocketName: Null<String>;
  @:internal var clientIp: Null<String>;

  @:internal public function new() {}

  public function getServerAddress(): Null<String> {
    return serverAddress;
  }
  public function setServerAddress(serverAddress: String): Void {
    var newValue = ServerAddress.fromString(serverAddress);
    actionLogger.logInfo('serverAddress changed: $newValue');
    this.serverAddress = newValue;
    // TODO forward event to client
  }
  public function getAdapterSet(): Null<String> {
    return adapterSet;
  }
  public function setAdapterSet(adapterSet: String): Void {
    actionLogger.logInfo('adapterSet changed: $adapterSet');
    this.adapterSet = adapterSet;
  }
  public function getUser(): Null<String> {
    return user;
  }
  public function setUser(user: String): Void {
    actionLogger.logInfo('user changed: $user');
    this.user = user;
  }
  public function setPassword(password: String): Void {
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