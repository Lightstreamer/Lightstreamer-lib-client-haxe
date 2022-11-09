package com.lightstreamer.client;

extern interface ClientListener {
  public function onListenEnd(): Void;
  public function onListenStart(): Void;
  public function onServerError(errorCode: Int, errorMessage: String): Void;
  public function onStatusChange(status: String): Void;
  public function onPropertyChange(property: String): Void;
}