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
    var _items = subscription.getItems();
    var items = _items != null ? _items.toHaxe() : null;
    var _fields = subscription.getFields();
    var fields = _fields != null ? _fields.toHaxe() : null;
    assert(items != null ? nItems == items.length : true);
    assert(fields != null ? nFields == fields.length : true);
    assert(fields != null ? cmdIdx - 1 == fields.indexOf("command") : true);
    assert(fields != null ? keyIdx - 1 == fields.indexOf("key") : true);
  }
}