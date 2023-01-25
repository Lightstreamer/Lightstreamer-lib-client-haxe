package com.lightstreamer.client;

#if python
@:pythonImport("lightstreamer.client", "ClientMessageListener")
#end
#if js @:native("ClientMessageListener") #end
#if LS_NODE @:jsRequire("lightstreamer-client-node", "ClientMessageListener") #end
extern interface ClientMessageListener {
  public function onProcessed(msg:String): Void;
  public function onDeny(msg:String, code:Int, error:String): Void;
  public function onAbort(msg:String, sentOnNetwork:Bool): Void;
  public function onDiscarded(msg:String): Void;
  public function onError(msg:String): Void;
}