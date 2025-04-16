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

class Globals {
  static public final instance = new Globals();

  public final hasWorkers = js.Lib.typeof(js.html.Worker) != "undefined";
  public final hasMicroTasks = js.Lib.typeof(js.Lib.global.queueMicrotask) != "undefined";

  function new() {}

  public function toString() {
    return '{ hasWorkers: $hasWorkers, hasMicroTasks: $hasMicroTasks }';
  }
}