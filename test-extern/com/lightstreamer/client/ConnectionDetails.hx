package com.lightstreamer.client;

#if python
@:pythonImport("lightstreamer_client.client", "ConnectionDetails")
#end
extern class ConnectionDetails {
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
}