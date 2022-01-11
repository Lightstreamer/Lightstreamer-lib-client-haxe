package com.lightstreamer.client;

@:nativeGen
class ConnectionDetails {
  var serverAddress: String;
  var adapterSet: String;
  var user: String;
  var password: String;
  var sessionId: String;
  var serverInstanceAddress: String;
  var serverSocketName: String;
  var clientIp: String;

  public function new() {}

  public function getServerAddress(): String {
    return serverAddress;
  }
  public function setServerAddress(serverAddress: String): Void {
    this.serverAddress = serverAddress;
  }
  public function getAdapterSet(): String {
    return adapterSet;
  }
  public function setAdapterSet(adapterSet: String): Void {
    this.adapterSet = adapterSet;
  }
  public function getUser(): String {
    return user;
  }
  public function setUser(user: String): Void {
    this.user = user;
  }
  public function setPassword(password: String): Void {
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