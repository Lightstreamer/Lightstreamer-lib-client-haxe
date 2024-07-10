package com.lightstreamer.client;

#if LS_HAS_PROXY
import com.lightstreamer.cpp.CppString;
import com.lightstreamer.client.Proxy.LSProxy;

@:forward
abstract NativeProxy(_NativeProxy) {
  @:to
  @:unreflective
  inline function to(): LSProxy {
    return new LSProxy(
      this.type, 
      this.host, 
      this.port, 
      this.user.isEmpty() ? null : this.user, 
      this.password.isEmpty() ? null : this.password);
  }
}

@:structAccess
@:native("Lightstreamer::Proxy")
@:include("Lightstreamer/Proxy.h")
private extern class _NativeProxy {
  var type: CppString;
  var host: CppString;
  var port: Int;
  var user: CppString;
  var password: CppString;
}
#end