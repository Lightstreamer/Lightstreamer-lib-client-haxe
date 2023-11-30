package utest;

import hx.concurrent.executor.Executor as HxExecutor;
import hx.concurrent.executor.Executor.TaskFuture as HxTaskFuture;

abstract Executor(HxExecutor) {
  
  inline public function new() {
    this = HxExecutor.create();
  }

  inline public function schedule(task: ()->Void, ms: Int): TaskHandle {
    return this.submit(task, Schedule.ONCE(ms));
  }
}

@:forward(cancel)
abstract TaskHandle(HxTaskFuture<Void>) from HxTaskFuture<Void> {}