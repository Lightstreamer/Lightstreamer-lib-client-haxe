package com.lightstreamer.client;

@:jsRequire("./ls_web_client_api", "ClientListener")
@:build(com.lightstreamer.internal.Macros.buildPythonImport("ls_python_client_api", "ClientListener"))
extern interface ClientListener {
  public function onListenEnd(): Void;
  public function onListenStart(): Void;
  public function onServerError(errorCode: Int, errorMessage: String): Void;
  public function onStatusChange(status: String): Void;
  public function onPropertyChange(property: String): Void;
}