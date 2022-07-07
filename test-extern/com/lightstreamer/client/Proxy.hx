package com.lightstreamer.client;

#if (java || cs || python)
#if python
@:pythonImport("lightstreamer_client", "Proxy")
#end
extern class Proxy {
  #if (java || cs)
  overload public function new(type: String, host: String, port: Int): Void;
  overload public function new(type: String, host: String, port: Int, user: String): Void;
  overload public function new(type: String, host: String, port: Int, user: String, password: String): Void;
  #end

  #if python
  public function new(type: String, host: String, port: Int, user: Null<String>, password: Null<String>): Void;
  #end
}
#end