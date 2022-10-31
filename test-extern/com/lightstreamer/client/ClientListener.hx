package com.lightstreamer.client;

#if python
@:pythonImport("lightstreamer.client", "ClientListener")
#end
#if js @:native("ClientListener") #end
extern interface ClientListener {
  public function onStatusChange(status:String): Void;
  public function onServerError(code:Int, message:String): Void;
  public function onPropertyChange(property:String): Void;
  public function onListenEnd(client:LightstreamerClient): Void;
  public function onListenStart(client:LightstreamerClient): Void;
}