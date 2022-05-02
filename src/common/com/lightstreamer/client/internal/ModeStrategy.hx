package com.lightstreamer.client.internal;

import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.RLock;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.MacroTools;
import com.lightstreamer.client.internal.update.ItemBase;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

private enum abstract State_m(Int) {
  var s1 = 1; var s2 = 2; var s3 = 3;
}

@:access(com.lightstreamer.client.internal.ClientMachine)
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ModeStrategy {
  final subscription: Subscription;
  var realMaxFrequency: Null<RealMaxFrequency>;
  var s_m: State_m = s1;
  final items = new Map<Int, ItemBase>();
  final lock: RLock;
  final client: ClientMachine;
  final m_subId: Int;

  public function new(sub: Subscription, client: ClientMachine, subId: Int) {
    this.lock = client.lock;
    this.client = client;
    this.subscription = sub;
    this.m_subId = subId;
  }

  function finalize() {
    // nothing to do
  }

  public function evtAbort() {
    traceEvent("abort");
    if (s_m == s1) {
      doAbort();
      goto(s1);
    } else if (s_m == s2) {
      doAbort();
      goto(s1);
      genDisposeItems();
    }
  }

  public function evtOnSUB(nItems: Int, nFields: Int, cmdIdx: Null<Pos>, keyIdx: Null<Pos>, currentFreq: Null<RequestedMaxFrequency>) {
    traceEvent("onSUB");
    if (s_m == s1) {
      doSUB(nItems, nFields);
      goto(s2);
    }
  }

  public function evtOnCONF(freq: RealMaxFrequency) {
    traceEvent("onCONF");
    if (s_m == s2) {
      doCONF(freq);
      goto(s2);
    }
  }

  public function evtOnCS(itemIdx: Pos) {
    traceEvent("onCS");
    if (s_m == s2) {
      doCS(itemIdx);
      goto(s2);
    }
  }

  public function evtOnEOS(itemIdx: Pos) {
    traceEvent("onEOS");
    if (s_m == s2) {
      doEOS(itemIdx);
      goto(s2);
    }
  }

  public function evtUpdate(itemIdx: Pos, values: Map<Pos, FieldValue>) {
    traceEvent("update");
    if (s_m == s2) {
      doUpdate(itemIdx, values);
      goto(s2);
    }
  }

  public function evtUnsubscribe() {
    traceEvent("unsubscribe");
    if (s_m == s1) {
      finalize();
      goto(s3);
    } else if (s_m == s2) {
      finalize();
      goto(s3);
      genDisposeItems();
    }
  }

  public function evtOnUNSUB() {
    traceEvent("onUNSUB");
    if (s_m == s2) {
      finalize();
      goto(s3);
      genDisposeItems();
    }
  }

  public function evtDispose() {
    traceEvent("dispose");
    if (s_m == s1 || s_m == s2) {
      finalize();
      goto(s3);
      genDisposeItems();
    }
  }

  public function evtSetRequestedMaxFrequency(freq: Null<RequestedMaxFrequency>) {
    // ignore: only needed by 2-level COMMAND
  }

  public function getValue(itemPos: Pos, fieldPos: Pos): Null<String> {
    var item = items[itemPos];
    if (item != null) {
      return item.getValue(fieldPos);
    } else {
      return null;
    }
  }

  public function getCommandValue(itemPos: Pos, key: String, fieldPos: Pos): Null<String> {
    throw new IllegalStateException("Unsupported operation");
  }

  public function createItem(itemIdx: Pos): ItemBase {
    throw new IllegalStateException("Abstract method");
  }

  function doSUB(nItems: Int, nFields: Int) {
    var items = subscription.getItems();
    var fields = subscription.getFields();
    assert(items != null ? nItems == items.length : true);
    assert(fields != null ? nFields == fields.length : true);
  }

  function doUpdate(itemIdx: Pos, values: Map<Pos, FieldValue>) {
    var item = selectItem(itemIdx);
    item.evtUpdate(values);
  }

  function doEOS(itemIdx: Pos) {
    var item = selectItem(itemIdx);
    item.evtOnEOS();
  }

  function doCS(itemIdx: Pos) {
    var item = selectItem(itemIdx);
    item.evtOnCS();
  }

  function doCONF(freq: RealMaxFrequency) {
    realMaxFrequency = freq;
    subscription.fireOnRealMaxFrequency(freq, m_subId);
  }

  function doAbort() {
    realMaxFrequency = null;
  }

  function genDisposeItems() {
    for (_ => item in items) {
      item.evtDispose(this);
    }
  }

  function selectItem(itemIdx: Pos): ItemBase {
    var item = items[itemIdx];
    if (item == null) {
      item = createItem(itemIdx);
      items[itemIdx] = item;
    }
    return item;
  }

  public function unrelate(itemIdx: Pos) {
    items.remove(itemIdx);
  }

  function traceEvent(evt: String) {
    internalLogger.logTrace('sub#mod#$evt($m_subId) in $s_m');
  }

  function goto(to: State_m) {
    s_m = to;
    internalLogger.logTrace('sub#mod#goto($m_subId) $s_m');
  }
}