package poco.net;

import cpp.UInt16;
import com.lightstreamer.cpp.CppString;

@:structAccess
@:include("Poco/Net/HTTPClientSession.h")
@:native("Poco::Net::HTTPClientSession::ProxyConfig")
extern class ProxyConfig {
  var host: CppString;
  var port: UInt16;
  var username: CppString;
  var password: CppString;
  
  function new();
  
  inline function setHost(host: String) {
    this.host = CppString.of(host);
  }
  inline function setPort(port: UInt16) {
    this.port = port;
  }
  inline function setUsername(user: String) {
    this.username = CppString.of(user);
  }
  inline function setPassword(password: String) {
    this.password = CppString.of(password);
  }
}