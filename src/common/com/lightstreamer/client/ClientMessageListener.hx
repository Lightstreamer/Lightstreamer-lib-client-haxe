package com.lightstreamer.client;

#if python
#if LS_TEST
@:pythonImport("ls_python_client_api", "ClientMessageListener")
#else
@:pythonImport(".ls_python_client_api", "ClientMessageListener")
#end
#end
extern interface ClientMessageListener {
  public function onAbort(originalMessage: String, sentOnNetwork: Bool): Void;
  public function onDeny(originalMessage: String, code: Int, error: String): Void;
  public function onDiscarded(originalMessage: String): Void;
  public function onError(originalMessage: String): Void;
  public function onProcessed(originalMessage: String): Void;
}