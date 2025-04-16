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

import com.lightstreamer.internal.Threads;
import com.lightstreamer.internal.PlatformApi.ITimer;
import com.lightstreamer.internal.Executor.TaskHandle;

class TimerImpl implements ITimer {
  final task: TaskHandle;

  public function new(id: String, delay: Types.Millis, callback: ITimer->Void) {
    task = sessionThread.schedule(() -> callback(this), delay);
  }

  inline public function cancel(): Void {
    task.cancel();
  }

  inline public function isCanceled(): Bool {
    return task.isCanceled();
  }
}