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
import com.lightstreamer.client.ClientListener;

class ClientListenerAdapter implements ClientListener extends cpp.Finalizable {
  final _listener: Pointer<NativeClientListener>;

  public function new(listener: Pointer<NativeClientListener>) {
    super();
    _listener = listener;
  }

  override function finalize() {
    _listener.destroy();
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