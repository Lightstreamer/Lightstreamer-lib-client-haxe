package com.lightstreamer.client;

import com.lightstreamer.internal.NativeTypes.IllegalArgumentException;

enum abstract ProxyType(String) to String {
  var HTTP;
  var SOCKS4;
  var SOCKS5;

  public static function fromString(s: String): ProxyType {
    return switch s {
      case "HTTP": HTTP;
      case "SOCKS4": SOCKS4;
      case "SOCKS5": SOCKS5;
      case _:  
        throw new IllegalArgumentException("The given type is not valid. Use one of: HTTP, SOCKS4 or SOCKS5");
    }
  }
}

#if (java || cs || python) @:nativeGen #end
class Proxy {
  public final type: ProxyType;
  public final host: String;
  public final port: Int;
  public final user: Null<String>;
  public final password: Null<String>;

  overload public function new(type: String, host: String, port: Int) {
    this.type = ProxyType.fromString(type);
    this.host = host;
    this.port = port;
    this.user = null;
    this.password = null;
  }

  overload public function new(type: String, host: String, port: Int, user: String) {
    this.type = ProxyType.fromString(type);
    this.host = host;
    this.port = port;
    this.user = user;
    this.password = null;
  }

  overload public function new(type: String, host: String, port: Int, user: String, password: String) {
    this.type = ProxyType.fromString(type);
    this.host = host;
    this.port = port;
    this.user = user;
    this.password = password;
  }

  public function equals(proxy2: Proxy) {
    return type == proxy2.type && host == proxy2.host && port == proxy2.port && user == proxy2.user && password == proxy2.password;
  }

  public function toString() {
    return '$type ${user != null ? user + "@" : ""}$host:$port';
  }
}