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

import hx.concurrent.executor.Executor.TaskFuture;
import hx.concurrent.executor.Executor as HxExecutor;

class Executor {
  final exec: HxExecutor;

  inline public function new() {
    this.exec = HxExecutor.create(1);
  }

  inline public function submit(callback: ()->Void): Void {
    exec.submit(callback);
  }

  public function schedule(callback: ()->Void, delay: Types.Millis): TaskHandle {
    return exec.submit(callback, Schedule.ONCE(delay.toInt()));
  }

  public function stop() {
    exec.stop();
  }
}

abstract TaskHandle(TaskFuture<Void>) from TaskFuture<Void> {

  inline public function cancel(): Void {
    this.cancel();
  }

  inline public function isCanceled(): Bool {
    return this.isStopped;
  }
}