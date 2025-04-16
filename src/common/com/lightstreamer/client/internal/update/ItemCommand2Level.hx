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

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ItemCommand2Level extends ItemCommand {
  public final strategy: ModeStrategyCommand2Level;

  public function new(itemIdx: Pos, sub: Subscription, strategy: ModeStrategyCommand2Level, client: ClientMachine, subId: Int) {
    super(itemIdx, sub, client, subId);
    this.strategy = strategy;
  }

  override public function evtOnCS() {
    traceEvent("onCS");
    switch s_m {
    case s1, s2, s3, s4:
      goto(s_m);
      genDisposeKeys();
      genOnRealMaxFrequency2LevelRemoved();
    default:
      // ignore
    }
  }

  public function evtSetRequestedMaxFrequency() {
    traceEvent("setRequestedMaxFrequency");
    switch s_m {
    case s1, s2, s3, s4:
      goto(s_m);
      genSetRequestedMaxFrequency();
    default:
      // ignore
    }
  }

  override function createKey(keyName: String): ItemKey {
    return new Key2Level(keyName, this);
  }
  
  function genSetRequestedMaxFrequency() {
    for (_ => key in keys) {
      key.evtSetRequestedMaxFrequency();
    }
  }
  
  function genOnRealMaxFrequency2LevelRemoved() {
    strategy.evtOnRealMaxFrequency2LevelRemoved();
  }
}