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
    return new TimerStamp(Timer.stamp());
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
