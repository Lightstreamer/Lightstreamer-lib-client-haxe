package com.lightstreamer.client;

class BaseClientListener implements ClientListener {
  public var statusChangeCb(null, default): String->Void;
  public var serverErrorCb(null, default): (Int, String)->Void;
  public function new() {}
  public function onListenEnd(client:LightstreamerClient) {}
  public function onListenStart(client:LightstreamerClient) {}
  public function onServerError(errorCode:Int, errorMessage:String) {
    serverErrorCb(errorCode, errorMessage);
  }
  public function onStatusChange(status:String) {
    statusChangeCb(status);
  }
  public function onPropertyChange(property:String) {}
}