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