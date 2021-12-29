package com.lightstreamer.client;

@:nativeGen
class ConnectionDetails {
  @:internal
  var adapterSet: String;
  @:internal
  var serverAddress: String;

  public function new() {}

  public function getAdapterSet(): String {
    return adapterSet;
  }
  public function setAdapterSet(adapterSet: String): Void {
    this.adapterSet = adapterSet;
  }
  public function getServerAddress(): String {
    return serverAddress;
  }
  public function setServerAddress(serverAddress: String): Void {
    this.serverAddress = serverAddress;
  }
  public function getUser(): String {
    return null;
  }
  public function setUser(user: String): Void {}
  public function getServerInstanceAddress(): String {
    return null;
  }
  public function getServerSocketName(): String {
    return null;
  }
  public function getClientIp(): String {
    return null;
  }
  public function getSessionId(): String {
    return null;
  }
  public function setPassword(password: String): Void {}
}