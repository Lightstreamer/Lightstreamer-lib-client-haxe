package utils;

import haxe.Exception;
import com.lightstreamer.internal.PlatformApi.ITimer;
import com.lightstreamer.internal.Types.Millis;
import com.lightstreamer.internal.Threads;

@:access(utils.MockScheduler)
class MockTimer implements ITimer {
  final scheduler: MockScheduler;
  final id: String;
  final delay: Millis;
  final callback: ITimer->Void;

  public function new(factory: MockScheduler, id: String, delay: Millis, callback: ITimer->Void) {
    this.scheduler = factory;
    this.id = id;
    this.delay = delay;
    this.callback = callback;
  }

  public function perform() {
    callback(this);
  }

  public function cancel() {
    scheduler.timeouts.remove(id);
  }

  public function isCanceled() return false;
}

class MockScheduler {
  final test: utest.Test;
  final timeouts: Map<String, MockTimer> = [];

  public function new(test: utest.Test) this.test = test;

  public function create(id: String, delay: Millis, callback: ITimer->Void) {
    var timer = new MockTimer(this, id, delay, callback);
    if (timeouts[id] != null) {
      throw new Exception('Timer $id already running');
    }
    timeouts[id] = timer;
    return timer;
  }

  public function fireRetryTimeout() {
    sessionThread.submit(() -> timeouts["retry.timeout"].perform());
  }

  public function fireTransportTimeout() {
    sessionThread.submit(() -> timeouts["transport.timeout"].perform());
  }

  public function fireRecoveryTimeout() {
    sessionThread.submit(() -> timeouts["recovery.timeout"].perform());
  }

  public function fireIdleTimeout() {
    sessionThread.submit(() -> timeouts["idle.timeout"].perform());
  }

  public function firePollingTimeout() {
    sessionThread.submit(() -> timeouts["polling.timeout"].perform());
  }

  public function fireCtrlTimeout() {
    sessionThread.submit(() -> timeouts["ctrl.timeout"].perform());
  }

  public function fireKeepaliveTimeout() {
    sessionThread.submit(() -> timeouts["keepalive.timeout"].perform());
  }

  public function fireStalledTimeout() {
    sessionThread.submit(() -> timeouts["stalled.timeout"].perform());
  }

  public function fireReconnectTimeout() {
    sessionThread.submit(() -> timeouts["reconnect.timeout"].perform());
  }

  public function fireRhbTimeout() {
    sessionThread.submit(() -> timeouts["rhb.timeout"].perform());
  }
}