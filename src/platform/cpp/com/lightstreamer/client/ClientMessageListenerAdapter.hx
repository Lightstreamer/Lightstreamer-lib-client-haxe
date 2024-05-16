package com.lightstreamer.client;

import cpp.Pointer;

class ClientMessageListenerAdapter implements ClientMessageListener {
  final _listener: Pointer<NativeClientMessageListener>;

  public function new(listener: Pointer<NativeClientMessageListener>) {
		this._listener = listener;
	}

	public function onAbort(originalMessage: String, sentOnNetwork: Bool) {
    _listener.ref.onAbort(originalMessage, sentOnNetwork);
  }

	public function onDeny(originalMessage: String, code: Int, error: String) {
    _listener.ref.onDeny(originalMessage, code, error);
  }

	public function onDiscarded(originalMessage: String) {
    _listener.ref.onDiscarded(originalMessage);
  }

	public function onError(originalMessage: String) {
    _listener.ref.onError(originalMessage);
  }

	public function onProcessed(originalMessage: String, response: String) {
    _listener.ref.onProcessed(originalMessage, response);
  }
}