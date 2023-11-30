package utest;

import java.util.concurrent.Callable;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.ScheduledFuture;
import java.lang.Runnable;

class Executor {
  final exec: ScheduledExecutorService;

  inline public function new() {
    this.exec = Executors.newSingleThreadScheduledExecutor();
  }

  public function schedule(callback: ()->Void, delay: Int): TaskHandle {
    // workaround for issue https://github.com/HaxeFoundation/haxe/issues/11236
    if (callback is Runnable) {
      return exec.schedule((cast callback: Runnable), delay, TimeUnit.MILLISECONDS);
    } else {
      return exec.schedule((cast callback: Callable<Dynamic>), delay, TimeUnit.MILLISECONDS);
    }
  }
}

abstract TaskHandle(ScheduledFuture) from ScheduledFuture {

  inline public function cancel(): Void {
    this.cancel(false);
  }
}