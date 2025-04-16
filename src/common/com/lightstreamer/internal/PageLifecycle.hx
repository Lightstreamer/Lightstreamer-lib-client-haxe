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
package com.lightstreamer.internal;

import com.lightstreamer.internal.PlatformApi;
import com.lightstreamer.client.internal.ClientMachine;
import com.lightstreamer.log.LoggerTools.pageLogger;

// dummy implementation
class PageLifecycle implements IPageLifecycle {
  static public function newLoggingInstance() return new PageLifecycle(_ -> null);
  public var frozen(default, null): Bool = false;
  inline public function new(onEvent: PageState->Void) {}
  inline public function startListening() {}
  inline public function stopListening() {}
}