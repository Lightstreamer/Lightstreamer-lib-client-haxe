package com.lightstreamer.client;

#if python
@:pythonImport("lightstreamer.client", "ConnectionDetails")
#end
#if js @:native("ConnectionDetails") #end
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