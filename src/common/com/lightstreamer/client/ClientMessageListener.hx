package com.lightstreamer.client;

#if js @:native("ClientMessageListener") #end
#if python @:build(com.lightstreamer.internal.Macros.buildPythonImport("ls_python_client_api", "ClientMessageListener")) #end
#if cpp interface #else extern interface #end ClientMessageListener {
  public function onAbort(originalMessage: String, sentOnNetwork: Bool): Void;
  public function onDeny(originalMessage: String, code: Int, error: String): Void;
  public function onDiscarded(originalMessage: String): Void;
  public function onError(originalMessage: String): Void;
  public function onProcessed(originalMessage: String, response: String): Void;
}