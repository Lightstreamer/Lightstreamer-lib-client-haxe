package com.lightstreamer.client;

#if (js || python) @:expose @:native("ClientMessageListener") #end
#if (java || cs || python) @:nativeGen #end
extern interface ClientMessageListener {
  public function onAbort(originalMessage: String, sentOnNetwork: Bool): Void;
  public function onDeny(originalMessage: String, code: Int, error: String): Void;
  public function onDiscarded(originalMessage: String): Void;
  public function onError(originalMessage: String): Void;
  public function onProcessed(originalMessage: String): Void;
}