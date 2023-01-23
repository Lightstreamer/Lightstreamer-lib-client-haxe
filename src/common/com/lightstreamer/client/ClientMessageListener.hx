package com.lightstreamer.client;

@:jsRequire("./ls_web_client_api", "ClientMessageListener")
@:build(com.lightstreamer.internal.Macros.buildPythonImport("ls_python_client_api", "ClientMessageListener"))
extern interface ClientMessageListener {
  public function onAbort(originalMessage: String, sentOnNetwork: Bool): Void;
  public function onDeny(originalMessage: String, code: Int, error: String): Void;
  public function onDiscarded(originalMessage: String): Void;
  public function onError(originalMessage: String): Void;
  public function onProcessed(originalMessage: String): Void;
}