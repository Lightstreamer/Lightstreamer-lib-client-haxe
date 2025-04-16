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
package com.lightstreamer.client.internal;

import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.MacroTools;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ModeStrategyCommand extends ModeStrategy {
  
  override public function evtOnSUB(nItems: Int, nFields: Int, cmdIdx: Null<Pos>, keyIdx: Null<Pos>, currentFreq: Null<RequestedMaxFrequency>) {
    traceEvent("onSUB");
    if (s_m == s1) {
      doSUBCMD(nItems, nFields, cmdIdx, keyIdx);
      goto(s2);
    }
  }

  override public function getCommandValue(itemPos: Pos, key: String, fieldPos: Pos): Null<String> {
    var item = items[itemPos];
    if (item != null) {
      return item.getCommandValue(key, fieldPos);
    } else {
      return null;
    }
  }

  @:nullSafety(Off)
  function doSUBCMD(nItems: Int, nFields: Int, cmdIdx: Null<Pos>, keyIdx: Null<Pos>) {
    var items = subscription.fetchItems();
    var fields = subscription.fetchFields();
    assert(items != null ? nItems == items.length : true);
    assert(fields != null ? nFields == fields.length : true);
    assert(fields != null ? cmdIdx - 1 == fields.indexOf("command") : true);
    assert(fields != null ? keyIdx - 1 == fields.indexOf("key") : true);
  }
}