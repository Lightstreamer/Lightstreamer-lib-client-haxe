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
package com.lightstreamer.client.internal;

import com.lightstreamer.internal.Types.Millis;
import com.lightstreamer.internal.NativeTypes.Long;

class RetryDelayCounter {
  var attempt: Int;
  var _currentRetryDelay: Long;
  public var currentRetryDelay(get, never): Millis;

  public function new() {
    attempt = 1;
    _currentRetryDelay = 0;
  }

  function get_currentRetryDelay() {
    return new Millis(_currentRetryDelay);
  }

  public function increase() {
    if (attempt > 10) {
      if (_currentRetryDelay < 60_000) {
        if (_currentRetryDelay * 2 < 60_000) {
          _currentRetryDelay *= 2;
        } else {
          _currentRetryDelay = 60_000;
        }
      }
    } else {
      attempt += 1;
    }
  }

  public function reset(retryDelay: Long) {
    attempt = 1;
    _currentRetryDelay = retryDelay;
  }
}