package com.lightstreamer.client;

#if python
@:pythonImport("lightstreamer_client", "ClientMessageListener")
#end
extern interface ClientMessageListener {
  public function onProcessed(msg:String): Void;
  public function onDeny(msg:String, code:Int, error:String): Void;
  public function onAbort(msg:String, sentOnNetwork:Bool): Void;
  public function onDiscarded(msg:String): Void;
  public function onError(msg:String): Void;
}