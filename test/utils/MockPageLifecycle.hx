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
package utils;

import com.lightstreamer.internal.PlatformApi;

#if LS_WEB
import js.Browser;
import com.lightstreamer.log.LoggerTools.pageLogger;

class MockPageLifecycle implements IPageLifecycle {
  public var onEvent(default, null): PageState -> Void;
  public var frozen(default, default): Bool = false;

  public function create(onEvent: PageState->Void) {
    this.onEvent = onEvent;
    return this;
  }
  public function new() {}
  public function startListening() {}
  public function stopListening() {}
  public function freeze() {
    Browser.window.setTimeout(() -> {
      pageLogger.warn('Frozen event detected');
      frozen = true;
      onEvent(Frozen);
    });
  }
  public function resume() {
    Browser.window.setTimeout(() -> {
      pageLogger.warn('Resumed event detected');
      frozen = false;
      onEvent(Resumed);
    });
  }
}
#else
class MockPageLifecycle implements IPageLifecycle {
  public function create(onEvent: PageState->Void) return this;
  public var frozen(default, default): Bool = false;
  public function new() {}
  public function startListening() {}
  public function stopListening() {}
}
#end