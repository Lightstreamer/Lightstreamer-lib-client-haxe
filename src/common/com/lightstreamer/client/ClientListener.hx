package com.lightstreamer.client;

#if js @:native("ClientListener") #end
#if python @:build(com.lightstreamer.internal.Macros.buildPythonImport("ls_python_client_api", "ClientListener")) #end
#if cpp interface #else extern interface #end ClientListener {
  // NB onListenStart and onListenEnd have the hidden parameter `client` for the sake of the legacy web widgets
  public function onListenEnd(#if js client: LightstreamerClient #end): Void;
  public function onListenStart(#if js client: LightstreamerClient #end): Void;
  public function onServerError(errorCode: Int, errorMessage: String): Void;
  public function onStatusChange(status: String): Void;
  public function onPropertyChange(property: String): Void;
  #if LS_WEB
  public function onServerKeepalive(): Void;
  #end
}