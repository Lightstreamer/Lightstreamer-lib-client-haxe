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

import com.lightstreamer.internal.Threads;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

@:autoBuild(com.lightstreamer.internal.Macros.buildEventDispatcher())
class EventDispatcher<T> {
  var listeners = new Array<T>();

  public function new() {}

  public function addListener(listener: T): Bool {
    if (!listeners.contains(listener)) {
      listeners.push(listener);
      return true;
    }
    return false;
  }

  public function removeListener(listener: T): Bool {
    return listeners.remove(listener);
  }

  public function getListeners(): Array<T> {
    return listeners;
  }

  function dispatchToAll(func: T->Void) {
    for (l in listeners) {
      dispatchToOne(l, func);
    }
  }

  function dispatchToOne(listener: T, func: T->Void) {
    userThread.submit(() -> {
      try {
        func(listener);
      } catch(e) {
        actionLogger.logErrorEx("Uncaught exception", e);
      }
    });
  }
}