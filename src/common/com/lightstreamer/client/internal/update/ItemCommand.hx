package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.Types;
import com.lightstreamer.client.internal.update.UpdateUtils;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;
using com.lightstreamer.internal.NullTools;

private enum abstract State_m(Int) {
  var s1 = 1; var s2 = 2; var s3 = 3; var s4 = 4; var s5 = 5;
}

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ItemCommand extends ItemBase {
  public final keys = new Map<String, ItemKey>();
  var s_m: State_m;

  override public function new(itemIdx: Pos, sub: Subscription, client: ClientMachine, subId: Int) {
    super(itemIdx, sub, client, subId);
    s_m = sub.hasSnapshot() ? s3 : s1;
  }

  override function finalize() {
    // nothing to do
  }

  public function unrelate(keyName: String) {
    keys.remove(keyName);
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
    throw new IllegalStateException("Unsupported method");
  }

  override public function evtDispose(strategy: ModeStrategy) {
    traceEvent("dispose");
    switch s_m {
    case s1, s2, s3, s4:
      finalize();
      goto(s5);
      genDisposeKeys();
      strategy.unrelate(itemIdx);
    default:
      // ignore
    }
  }

  override public function getCommandValue(keyName: String, fieldIdx: Pos): Null<String> {
    var key = keys[keyName];
    if (key != null) {
      return key.getCommandValue(fieldIdx);
    } else {
      return null;
    }
  }

  function createKey(keyName: String): ItemKey {
    throw new IllegalStateException("Abstract method");
  }

  override function doUpdate(values: Map<Pos, FieldValue>, snapshot: Bool) {
    var prevValues = currValues;
    currValues = mapUpdateValues(prevValues, values);
    var key = selectKey();
    
    key.evtUpdate(currValues, snapshot);
  }

  function genDisposeKeys() {
    // make a copy of `keys` because evtDispose removes elements from it while iterating
    var _keys = keys.copy();
    for (_ => key in _keys) {
      key.evtDispose();
    }
  }

  function selectKey(): ItemKey {
    @:nullSafety(Off)
    var keyName: String = currValues[subscription.getKeyPosition()];
    var key = keys[keyName];
    if (key == null) {
      key = createKey(keyName);
      keys[keyName] = key;
    }
    return key;
  }

  function goto(to: State_m) {
    s_m = to;
    internalLogger.logTrace('sub#itm#goto($m_subId:$itemIdx) in $s_m');
  }

  function traceEvent(evt: String) {
    internalLogger.logTrace('sub#itm#$evt($m_subId:$itemIdx) in $s_m');
  }
}