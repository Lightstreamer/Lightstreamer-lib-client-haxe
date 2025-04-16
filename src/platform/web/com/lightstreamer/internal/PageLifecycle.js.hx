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

import js.Browser;
import com.lightstreamer.internal.PlatformApi;
import com.lightstreamer.log.LoggerTools.pageLogger;

class PageLifecycle implements IPageLifecycle {
  final onEvent: PageState->Void;
  public var frozen(default, null): Bool = false;

  static public function newLoggingInstance() {
    var glb = new PageLifecycle(e -> pageLogger.logWarn('$e event detected'));
    glb.startListening();
    return glb;
  }

  public function new(onEvent: PageState->Void) {
    this.onEvent = onEvent;
  }

  function handleFrozen() {
    frozen = true;
    onEvent(Frozen);
  }

  function handleResumed() {
    frozen = false;
    onEvent(Resumed);
  }

  public function startListening() {
    if (Browser.supported) {
      Browser.window.addEventListener("freeze", handleFrozen, {capture: true});
      Browser.window.addEventListener("resume", handleResumed, {capture: true});
    }
  }

  public function stopListening() {
    if (Browser.supported) {
      Browser.window.removeEventListener("freeze", handleFrozen, {capture: true});
      Browser.window.removeEventListener("resume", handleResumed, {capture: true});
    }
  }
}
