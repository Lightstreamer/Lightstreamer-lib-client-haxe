package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.Set;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.RLock;
import com.lightstreamer.log.LoggerTools;
import com.lightstreamer.client.internal.update.UpdateUtils;

using com.lightstreamer.log.LoggerTools;
using com.lightstreamer.internal.NullTools;
using com.lightstreamer.client.internal.update.UpdateUtils.CurrFieldValTools;

private  enum abstract State_m(Int) {
  var s1 = 1; var s2 = 2; var s3 = 3;
}

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Key1Level implements ItemKey {
  final keyName: String;
  final item: ItemCommand1Level;
  var currKeyValues: Null<Map<Pos, Null<CurrFieldVal>>>;
  var s_m: State_m = s1;
  final lock: RLock;
  
  public function new(keyName: String, item: ItemCommand1Level) {
    this.keyName = keyName;
    this.item = item;
    this.lock = item.lock;
  }

  function finalize() {
    currKeyValues = null;
    item.unrelate(keyName);
  }

  public function evtUpdate(keyValues: Map<Pos, Null<CurrFieldVal>>, snapshot: Bool) {
    traceEvent("update");
    switch s_m {
    case s1:
      if (!isDelete(keyValues)) {
        doFirstUpdate(keyValues, snapshot);
        goto(s2);
      } else {
        doLightDelete(keyValues, snapshot);
        finalize();
        goto(s3);
      }
    case s2:
      if (!isDelete(keyValues)) {
        doUpdate(keyValues, snapshot);
        goto(s2);
      } else {
        doDelete(keyValues, snapshot);
        finalize();
        goto(s3);
      }
    default:
      // ignore
    }
  }

  public function evtDispose() {
    traceEvent("dispose");
    switch s_m {
    case s1, s2:
      finalize();
      goto(s3);
    default:
      // ignore
    }
  }

  public function evtSetRequestedMaxFrequency() {
    // nothing to do
  }

  public function getCommandValue(fieldIdx: Pos): Null<String> {
    return currKeyValues != null ? currKeyValues[fieldIdx].toString() : null;
  }

  function doFirstUpdate(keyValues: Map<Pos, Null<CurrFieldVal>>, snapshot: Bool) {
    var nFields = item.subscription.fetch_nFields().sure();
    var cmdIdx = item.subscription.getCommandPosition();
    currKeyValues = keyValues;
    currKeyValues[cmdIdx] = StringVal("ADD");
    var changedFields = new Set(1...nFields + 1);
    var update = new ItemUpdateBase(item.itemIdx, item.subscription, currKeyValues, changedFields, snapshot#if LS_JSON_PATCH, []#end);
    
    fireOnItemUpdate(update);
  }

  function doUpdate(keyValues: Map<Pos, Null<CurrFieldVal>>, snapshot: Bool) {
    var cmdIdx = item.subscription.getCommandPosition();
    var prevKeyValues = currKeyValues;
    currKeyValues = keyValues;
    currKeyValues[cmdIdx] = StringVal("UPDATE");
    var changedFields = findChangedFields(prevKeyValues, currKeyValues);
    var update = new ItemUpdateBase(item.itemIdx, item.subscription, currKeyValues, changedFields, snapshot#if LS_JSON_PATCH, []#end);
    
    fireOnItemUpdate(update);
  }

  function doLightDelete(keyValues: Map<Pos, Null<CurrFieldVal>>, snapshot: Bool) {
    currKeyValues = null;
    var changedFields = new Set(keyValues.keys());
    var update = new ItemUpdateBase(item.itemIdx, item.subscription, nullify(keyValues), changedFields, snapshot#if LS_JSON_PATCH, []#end);
    item.unrelate(keyName);
    
    fireOnItemUpdate(update);
  }

  function doDelete(keyValues: Map<Pos, Null<CurrFieldVal>>, snapshot: Bool) {
    currKeyValues = null;
    var changedFields = new Set(keyValues.keys()).subtracting([item.subscription.getKeyPosition()]);
    var update = new ItemUpdateBase(item.itemIdx, item.subscription, nullify(keyValues), changedFields, snapshot#if LS_JSON_PATCH, []#end);
    item.unrelate(keyName);
    
    fireOnItemUpdate(update);
  }

  function nullify(keyValues: Map<Pos, Null<CurrFieldVal>>): Map<Pos, Null<CurrFieldVal>> {
    var values = new Map<Pos, Null<CurrFieldVal>>();
    for (p => val in keyValues) {
      var newVal = p == item.subscription.getCommandPosition() || p == item.subscription.getKeyPosition() ? val : null;
      values[p] = newVal;
    }
    return values;
  }

  function isDelete(keyValues: Map<Pos, Null<CurrFieldVal>>): Bool {
    return keyValues[item.subscription.getCommandPosition()].toString() == "DELETE";
  }

  function fireOnItemUpdate(update: ItemUpdate) {
    item.subscription.fireOnItemUpdate(update, item.m_subId);
  }

  function goto(to: State_m) {
    s_m = to;
    traceEvent("goto");
  }

  function traceEvent(evt: String) {
    if (internalLogger.isTraceEnabled()) {
      var subId = item.m_subId;
      var itemIdx = item.itemIdx;
      internalLogger.trace('sub#key#$evt($subId:$itemIdx:$keyName) in $s_m');
    }
  }
}