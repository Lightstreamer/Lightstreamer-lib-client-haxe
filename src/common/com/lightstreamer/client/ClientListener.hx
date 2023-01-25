package com.lightstreamer.client;

#if js @:native("ClientListener") #end
@:build(com.lightstreamer.internal.Macros.buildPythonImport("ls_python_client_api", "ClientListener"))
extern interface ClientListener {
  public function onListenEnd(): Void;
  public function onListenStart(): Void;
  public function onServerError(errorCode: Int, errorMessage: String): Void;
  public function onStatusChange(status: String): Void;
  public function onPropertyChange(property: String): Void;
}