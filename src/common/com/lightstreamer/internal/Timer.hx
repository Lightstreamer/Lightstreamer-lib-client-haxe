package com.lightstreamer.internal;

import hx.concurrent.executor.Executor;
import com.lightstreamer.internal.PlatformApi;

abstract TimerMillis(Float) {
  public inline function new(millis: Float) {
    this = millis;
  }

  @:op(-A)
  public inline function uminus() {
    return new TimerMillis(-this);
  }

  @:op(A - B)
  public inline function minus(rhs: TimerMillis) {
    return new TimerMillis(this - rhs.toFloat());
  }

  @:op(A + B)
  public inline function plus(rhs: TimerMillis) {
    return new TimerMillis(this + rhs.toFloat());
  }

  @:op(A * B)
  public inline function mult(rhs: Float) {
    return new TimerMillis(this * rhs);
  }

  @:op(A > B)
  public inline function gt(rhs: TimerMillis) {
    return this > rhs.toFloat();
  }

  @:op(A < B)
  public inline function lt(rhs: TimerMillis) {
    return this < rhs.toFloat();
  }

  inline function toFloat(): Float {
    return this;
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