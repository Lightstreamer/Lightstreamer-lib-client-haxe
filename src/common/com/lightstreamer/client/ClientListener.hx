package com.lightstreamer.client;

interface ClientListener {
  public function onListenEnd(client: LightstreamerClient): Void;
  public function onListenStart(client: LightstreamerClient): Void;
  public function onServerError(errorCode: Int, errorMessage: String): Void;
  public function onStatusChange(status: String): Void;
  public function onPropertyChange(property: String): Void;
}