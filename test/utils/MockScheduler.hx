package utils;

import haxe.Exception;
import com.lightstreamer.internal.PlatformApi.ITimer;
import com.lightstreamer.internal.Types.Millis;

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
    timeouts["retry.timeout"].perform();
  }

  public function fireTransportTimeout() {
    timeouts["transport.timeout"].perform();
  }

  public function fireRecoveryTimeout() {
    timeouts["recovery.timeout"].perform();
  }

  public function fireIdleTimeout() {
    timeouts["idle.timeout"].perform();
  }

  public function firePollingTimeout() {
    timeouts["polling.timeout"].perform();
  }

  public function fireCtrlTimeout() {
    timeouts["ctrl.timeout"].perform();
  }

  public function fireKeepaliveTimeout() {
    timeouts["keepalive.timeout"].perform();
  }

  public function fireStalledTimeout() {
    timeouts["stalled.timeout"].perform();
  }

  public function fireReconnectTimeout() {
    timeouts["reconnect.timeout"].perform();
  }

  public function fireRhbTimeout() {
    timeouts["rhb.timeout"].perform();
  }
}