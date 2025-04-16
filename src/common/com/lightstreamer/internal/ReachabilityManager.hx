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

import com.lightstreamer.internal.PlatformApi.ReachabilityStatus;
import com.lightstreamer.internal.PlatformApi.IReachability;

#if LS_WEB
class ReachabilityManager implements IReachability {
  public function new() {}

  public function startListening(onUpdate:ReachabilityStatus -> Void) {
    if (js.Browser.supported) {
      js.Browser.window.ononline = () -> onUpdate(RSReachable);
      js.Browser.window.onoffline = () -> onUpdate(RSNotReachable);
    }
  }

  @:nullSafety(Off)
  public function stopListening() {
    if (js.Browser.supported) {
      js.Browser.window.ononline = null;
      js.Browser.window.onoffline = null;
    }
  }
}
#else
// dummy implementation
class ReachabilityManager implements IReachability {
  public function new() {}
  public function startListening(onUpdate:ReachabilityStatus -> Void) {}
  public function stopListening() {}
}
#end