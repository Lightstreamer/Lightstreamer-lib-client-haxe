/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.lightstreamer.client.hxcbridge;

import cpp.Pointer;

class ClientMessageListenerAdapter implements ClientMessageListener extends cpp.Finalizable {
  final _listener: Pointer<NativeClientMessageListener>;

  public function new(listener: Pointer<NativeClientMessageListener>) {
    super();
		this._listener = listener;
	}

  override function finalize() {
    _listener.destroy();
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