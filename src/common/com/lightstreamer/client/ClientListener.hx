package com.lightstreamer.client;

#if python
#if LS_TEST
@:pythonImport("ls_python_client_api", "ClientListener")
#else
@:pythonImport(".ls_python_client_api", "ClientListener")
#end
#end
extern interface ClientListener {
  public function onListenEnd(): Void;
  public function onListenStart(): Void;
  public function onServerError(errorCode: Int, errorMessage: String): Void;
  public function onStatusChange(status: String): Void;
  public function onPropertyChange(property: String): Void;
}