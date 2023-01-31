package com.lightstreamer.client;

#if python
@:pythonImport("lightstreamer.client", "ClientListener")
#end
#if js @:native("ClientListener") #end
#if LS_NODE @:jsRequire("lightstreamer-client-node", "ClientListener") #end
extern interface ClientListener {
  public function onStatusChange(status:String): Void;
  public function onServerError(code:Int, message:String): Void;
  public function onPropertyChange(property:String): Void;
  public function onListenEnd(): Void;
  public function onListenStart(): Void;
  #if LS_WEB
  public function onServerKeepalive(): Void;
  #end
}