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
package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.Types;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

private enum abstract State_m(Int) {
  var s1 = 1; var s2 = 2; var s3 = 3; var s4 = 4; var s5 = 5;
}

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ItemDistinct extends ItemBase {
  var s_m: State_m;

  override public function new(itemIdx: Pos, sub: Subscription, client: ClientMachine, subId: Int) {
    super(itemIdx, sub, client, subId);
    this.s_m = sub.hasSnapshot() ? s3 : s1;
  }

  override public function evtUpdate(values: Map<Pos, FieldValue>) {
    traceEvent("update");
    switch s_m {
    case s1:
      doFirstUpdate(values);
      goto(s2);
    case s2:
      doUpdate0(values);
      goto(s2);
    case s3:
      doFirstSnapshot(values);
      goto(s4);
    case s4:
      doSnapshot(values);
      goto(s4);
    default:
      // ignore
    }
  }

  override public function evtOnEOS() {
    traceEvent("onEOS");
    switch s_m {
    case s3:
      goto(s1);
    case s4:
      goto(s2);
    default:
      // ignore
    }
  }

  override public function evtOnCS() {
    // nothing to do
  }

  override public function evtDispose(strategy: ModeStrategy) {
    traceEvent("dispose");
    switch s_m {
    case s1, s2, s3, s4:
      finalize();
      goto(s5);
      strategy.unrelate(itemIdx);
    default:
      // ignore
    }
  }

  function goto(to: State_m) {
    s_m = to;
    internalLogger.logTrace('sub#itm#goto($m_subId:$itemIdx) $s_m');
  }

  function traceEvent(evt: String) {
    internalLogger.logTrace('sub#itm#$evt($m_subId:$itemIdx) in $s_m');
  }
}