package com.lightstreamer.client;

import com.lightstreamer.client.Types;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

#if (js || python) @:expose @:native("ConnectionDetails") #end
#if (java || cs || python) @:nativeGen #end
class ConnectionDetails {
  // TODO synchronize methods
  // TODO fire property listeners
  @:internal var serverAddress: ServerAddress;
  @:internal var adapterSet: String;
  @:internal var user: String;
  @:internal var password: String;
  @:internal var sessionId: String;
  @:internal var serverInstanceAddress: String;
  @:internal var serverSocketName: String;
  @:internal var clientIp: String;

  @:internal public function new() {}

  public function getServerAddress(): String {
    return serverAddress;
  }
  public function setServerAddress(serverAddress: String): Void {
    actionLogger.logInfo('serverAddress changed: $serverAddress');
    this.serverAddress = new ServerAddress(serverAddress);
    // TODO forward event to client
  }
  public function getAdapterSet(): String {
    return adapterSet;
  }
  public function setAdapterSet(adapterSet: String): Void {
    actionLogger.logInfo('adapterSet changed: $adapterSet');
    this.adapterSet = adapterSet;
  }
  public function getUser(): String {
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
  public function getSessionId(): String {
    return sessionId;
  }
  public function getServerInstanceAddress(): String {
    return serverInstanceAddress;
  }
  public function getServerSocketName(): String {
    return serverSocketName;
  }
  public function getClientIp(): String {
    return clientIp;
  }
}