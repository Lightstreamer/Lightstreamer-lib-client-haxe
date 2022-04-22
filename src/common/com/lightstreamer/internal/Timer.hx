package com.lightstreamer.internal;

import com.lightstreamer.internal.NativeTypes.Long;
import hx.concurrent.executor.Executor;
import com.lightstreamer.internal.PlatformApi;

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

  @:op(A - B)
  public function minus(rhs: TimerStamp): TimerMillis {
    return new TimerMillis((this - rhs.toFloat()) * 1000);
  }

  inline function toFloat(): Float {
    return this;
  }
}

class Timer implements ITimer {
  static final executor = Executor.create();
  final task: TaskFuture<Void>;

  public function new(id: String, delay: Types.Millis, callback: ITimer->Void) {
    task = executor.submit(() -> callback(this), Schedule.ONCE(delay.toInt()));
  }

  inline public function cancel(): Void {
    task.cancel();
  }

  inline public function isCanceled(): Bool {
    return task.isStopped;
  }

  inline static public function stamp(): Float {
    return haxe.Timer.stamp();
  }
}