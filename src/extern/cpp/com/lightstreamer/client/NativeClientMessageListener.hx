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
package com.lightstreamer.client;

import cpp.Reference;
import com.lightstreamer.cpp.CppString;

@:structAccess
@:native("Lightstreamer::ClientMessageListener")
@:include("Lightstreamer/ClientMessageListener.h")
extern class NativeClientMessageListener {
  function onAbort(originalMessage: Reference<CppString>, sentOnNetwork: Bool): Void;
  function onDeny(originalMessage: Reference<CppString>, code: Int, error: Reference<CppString>): Void;
  function onDiscarded(originalMessage: Reference<CppString>): Void;
  function onError(originalMessage: Reference<CppString>): Void;
  function onProcessed(originalMessage: Reference<CppString>, response: Reference<CppString>): Void;
}