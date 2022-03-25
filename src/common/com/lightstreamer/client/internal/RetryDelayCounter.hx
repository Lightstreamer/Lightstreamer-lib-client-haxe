package com.lightstreamer.client.internal;

import com.lightstreamer.internal.Types.Millis;
import com.lightstreamer.internal.NativeTypes.Long;

class RetryDelayCounter {
  var attempt: Int;
  var currentRetryDelay: Long;

  public function new() {
    attempt = 1;
    currentRetryDelay = 0;
  }

  public function getCurrentRetryDelay() {
    return new Millis(currentRetryDelay);
  }

  public function increase() {
    if (attempt > 10) {
      if (currentRetryDelay < 60_000) {
        if (currentRetryDelay * 2 < 60_000) {
          currentRetryDelay *= 2;
        } else {
          currentRetryDelay = 60_000;
        }
      }
    } else {
      attempt += 1;
    }
  }

  public function reset(retryDelay: Long) {
    attempt = 1;
    currentRetryDelay = retryDelay;
  }
}