package com.lightstreamer.client;

import cpp.Pointer;
import com.lightstreamer.client.ClientListener;

class ClientListenerAdapter implements ClientListener {
  final _listener: Pointer<NativeClientListener>;

  public function new(listener: Pointer<NativeClientListener>) {
    _listener = listener;
  }

  public function onListenEnd(): Void {
    _listener.ref.onListenEnd();
  }
  public function onListenStart(): Void {
    _listener.ref.onListenStart();
  }
  public function onServerError(errorCode: Int, errorMessage: String): Void {
    _listener.ref.onServerError(errorCode, errorMessage);
  }
  public function onStatusChange(status: String): Void {
    _listener.ref.onStatusChange(status);
  }
  public function onPropertyChange(property: String): Void {
    _listener.ref.onPropertyChange(property);
  }
}