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

import com.lightstreamer.internal.NativeTypes.Long;
import com.lightstreamer.internal.Types;

abstract TimerMillis(Float) {
  public inline function new(millis: Float) {
    this = millis;
  }

  @:op(-A)
  public static function uminus(a: TimerMillis): TimerMillis;

  @:op(A - B)
  public static function minus(a: TimerMillis, b: TimerMillis): TimerMillis;

  @:op(A + B)
  public static function plus(a: TimerMillis, b: TimerMillis): TimerMillis;

  @:op(A * B)
  public static function mult(a: TimerMillis, b: Float): TimerMillis;

  @:op(A > B)
  public static function gt(a: TimerMillis, b: TimerMillis): Bool;

  @:op(A < B)
  public static function lt(a: TimerMillis, b: TimerMillis): Bool;

  @:to
  public function toMillis(): Millis {
    return new Millis(cast this);
  }

  public inline function toLong(): Long {
    return cast this;
  }
}

abstract TimerStamp(Float) {

  public inline function new(seconds: Float) {
    this = seconds;
  }

  public static inline function now() {
    return new TimerStamp(haxe.Timer.stamp());
  }

  @:op(A + B)
  public function plus(rhs: Millis): TimerMillis {
    return new TimerMillis((this * 1000) + rhs.toInt());
  }

  @:op(A - B)
  public function minus(rhs: TimerStamp): TimerMillis {
    return new TimerMillis((this - rhs.toFloat()) * 1000);
  }

  inline function toFloat(): Float {
    return this;
  }
}

typedef Timer = TimerImpl;
