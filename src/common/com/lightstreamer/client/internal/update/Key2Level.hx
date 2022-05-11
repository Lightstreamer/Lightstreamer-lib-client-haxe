package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.Set;
import com.lightstreamer.client.internal.update.UpdateUtils;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.RLock;
import com.lightstreamer.internal.MacroTools;
using com.lightstreamer.internal.NullTools;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;
using Lambda;

private enum abstract State_m(Int) {
  var s1 = 1; var s2 = 2; var s3 = 3; var s4 = 4; var s5 = 5;
  var s10 = 10; var s11 = 11; var s12 = 12;
}

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Key2Level implements ItemKey {
  final keyName: String;
  final item: ItemCommand2Level;
  var currKeyValues: Null<Map<Pos, Null<String>>>;
  var currKey2Values: Null<Map<Pos, Null<String>>>;
  var listener2Level: Null<Sub2LevelDelegate>;
  var subscription2Level: Null<Subscription>;
  var s_m: State_m = s1;
  public final lock: RLock;
  public var realMaxFrequency: Null<RealMaxFrequency>;

  public function new(keyName: String, item: ItemCommand2Level) {
    this.keyName = keyName;
    this.item = item;
    this.lock = item.lock;
  }

  function finalize() {
    currKeyValues = null;
    currKey2Values = null;
    item.unrelate(keyName);
  }

  public function evtUpdate(keyValues: Map<Pos, Null<String>>, snapshot: Bool) {
    traceEvent("update");
    switch s_m {
    case s1:
      if (!isDelete(keyValues)) {
        var sub = create2LevelSubscription();
        if (sub != null) {
          doFirstUpdate(keyValues, snapshot);
          subscription2Level = sub;
          goto(s4);
          // TODO item.strategy.client.subscribeExt(sub, true);
        } else {
          doFirstUpdate(keyValues, snapshot);
          notify2LevelIllegalArgument();
          goto(s3);
        }
      } else {
        doLightDelete(keyValues, snapshot);
        finalize();
        goto(s11);
        genOnRealMaxFrequency2LevelRemoved();
      }
    case s3:
      if (!isDelete(keyValues)) {
        doUpdate(keyValues, snapshot);
        goto(s3);
      } else {
        doDelete1LevelOnly(keyValues, snapshot);
        finalize();
        goto(s11);
        genOnRealMaxFrequency2LevelRemoved();
      }
    case s4:
      if (!isDelete(keyValues)) {
        doUpdate(keyValues, snapshot);
        goto(s4);
      } else {
        doDelete(keyValues, snapshot);
        finalize();
        goto(s11);
        genOnRealMaxFrequency2LevelRemoved();
      }
    case s5:
      if (!isDelete(keyValues)) {
        doUpdate1Level(keyValues, snapshot);
        goto(s5);
      } else {
        doDeleteExt(keyValues, snapshot);
        finalize();
        goto(s11);
        genOnRealMaxFrequency2LevelRemoved();
      }
    default:
      // ignore
    }
  }

  public function evtDispose() {
    traceEvent("dispose");
    switch s_m {
    case s1, s2, s3:
      finalize();
      goto(s10);
    case s4, s5:
      doUnsubscribe();
      finalize();
      goto(s12);
    default:
      // ignore
    }
  }

  public function evtOnSubscriptionError2Level(code: Int, msg: String) {
    traceEvent("onSubscriptionError2Level");
    if (s_m == s4) {
      notify2LevelSubscriptionError(code, msg);
      goto(s3);
    }
  }

  public function evtUpdate2Level(update: ItemUpdate) {
    traceEvent("update2Level");
    switch s_m {
    case s4:
      doUpdate2Level(update);
      goto(s5);
    case s5:
      doUpdate2Level(update);
      goto(s5);
    default:
      // ignore
    }
  }

  public function evtOnUnsubscription2Level() {
    traceEvent("onUnsubscription2Level");
    switch s_m {
    case s4, s5:
      doUnsetRealMaxFrequency();
      goto(s_m);
      genOnRealMaxFrequency2LevelRemoved();
    default:
      // ignore
    }
  }

  public function evtOnItemLostUpdates2Level(lostUpdates: Int) {
    traceEvent("onItemLostUpdates2Level");
    switch s_m {
    case s4, s5:
      goto(s_m);
      notify2LevelLostUpdates(lostUpdates);
    default:
      // ignore
    }
  }

  public function evtOnRealMaxFrequency2Level(maxFrequency: Null<RealMaxFrequency>) {
    traceEvent("onRealMaxFrequency2Level");
    switch s_m {
    case s4, s5:
      doSetRealMaxFrequency(maxFrequency);
      goto(s_m);
      genOnRealMaxFrequency2LevelAdded();
    default:
      // ignore
    }
  }

  public function evtSetRequestedMaxFrequency() {
    traceEvent("setRequestedMaxFrequency");
    switch s_m {
    case s4, s5:
      doChangeRequestedMaxFrequency();
      goto(s_m);
    default:
      // ignore
    }
  }

  public function getCommandValue(fieldIdx: Pos): Null<String> {
    var values = currKeyValues; 
    if (values != null && values[fieldIdx] != null) {
      return values[fieldIdx];
    } else {
      var values = currKey2Values;
      var nFields = item.subscription.get_nFields();
      if (values != null && nFields != null) {
        return values[fieldIdx - nFields];
      } else {
        return null;
      }
    }
  }

  function doFirstUpdate(keyValues: Map<Pos, Null<String>>, snapshot: Bool) {
    var cmdIdx = item.subscription.getCommandPosition().sure();
    currKeyValues = keyValues;
    currKeyValues[cmdIdx] = "ADD";
    var changedFields = findChangedFields(null, currKeyValues);
    var update = new ItemUpdate2Level(item.itemIdx, item.subscription, currKeyValues, changedFields, snapshot);
    
    fireOnItemUpdate(update);
  }

  function doUpdate(keyValues: Map<Pos, Null<String>>, snapshot: Bool) {
    var cmdIdx = item.subscription.getCommandPosition().sure();
    var prevKeyValues = currKeyValues;
    currKeyValues = keyValues;
    currKeyValues[cmdIdx] = "UPDATE";
    var changedFields = findChangedFields(prevKeyValues, currKeyValues);
    var update = new ItemUpdate2Level(item.itemIdx, item.subscription, currKeyValues, changedFields, snapshot);
    
    fireOnItemUpdate(update);
  }

  function doUpdate2Level(update: ItemUpdate) {
    var cmdIdx = item.subscription.getCommandPosition().sure();
    var nFields = item.subscription.get_nFields().sure();
    var prevKeyValues = currKeyValues.sure();
    @:nullSafety(Off)
    currKeyValues[cmdIdx] = "UPDATE";
    currKey2Values = getFieldsByPosition(update);
    var extKeyValues = currKeyValues.sure();
    for (f => v in currKey2Values) {
      extKeyValues[f + nFields] = v;
    }
    var changedFields = new Set<Pos>();
    @:nullSafety(Off)
    if (prevKeyValues[cmdIdx] != currKeyValues[cmdIdx]) {
      changedFields.insert(cmdIdx);
    }
    for (f => _ in getChangedFieldsByPosition(update)) {
      changedFields.insert(f + nFields);
    }
    var snapshot = update.isSnapshot();
    var extUpdate = new ItemUpdate2Level(item.itemIdx, item.subscription, extKeyValues, changedFields, snapshot);
    
    fireOnItemUpdate(extUpdate);
  }

  function doUpdate1Level(keyValues: Map<Pos, Null<String>>, snapshot: Bool) {
    var cmdIdx = item.subscription.getCommandPosition().sure();
    var nFields = item.subscription.get_nFields().sure();
    var prevKeyValues = currKeyValues.sure();
    currKeyValues =  keyValues;
    currKeyValues[cmdIdx] = "UPDATE";
    var extKeyValues = currKeyValues.sure();
    for (f => v in currKey2Values.sure()) {
      extKeyValues[f + nFields] = v;
    }
    var changedFields = new Set<Pos>();
    for (f in 1...nFields + 1) {
      if (prevKeyValues[f] != extKeyValues[f]) {
        changedFields.insert(f);
      }
    }
    var extUpdate = new ItemUpdate2Level(item.itemIdx, item.subscription, extKeyValues, changedFields, snapshot);
    
    fireOnItemUpdate(extUpdate);
  }

  function doDelete(keyValues: Map<Pos, Null<String>>, snapshot: Bool) {
    var n = item.subscription.get_nFields().sure();
    var keyIdx = item.subscription.getKeyPosition().sure();
    var cmdIdx = item.subscription.getCommandPosition().sure();
    currKeyValues = null;
    var changedFields = new Set(1...n+1).subtracting([keyIdx]);
    var extKeyValues = new Map<Pos, Null<String>>();
    for (f in 1...n+1) {
      extKeyValues[f] = null;
    }
    extKeyValues[keyIdx] = keyName;
    extKeyValues[cmdIdx] = "DELETE";
    var update = new ItemUpdate2Level(item.itemIdx, item.subscription, extKeyValues, changedFields, snapshot);
    
    item.unrelate(keyName);
    
    var sub = subscription2Level.sure();
    sub.removeListener(listener2Level.sure());
    listener2Level.sure().disable();
    subscription2Level = null;
    listener2Level = null;
    
    // TODO item.strategy.client.unsubscribe(sub);
    fireOnItemUpdate(update);
  }

  function doDeleteExt(keyValues: Map<Pos, Null<String>>, snapshot: Bool) {
    var nFields = item.subscription.get_nFields().sure();
    var keyIdx = item.subscription.getKeyPosition().sure();
    var cmdIdx = item.subscription.getCommandPosition().sure();
    var n = nFields + currKey2Values.sure().count();
    currKeyValues = null;
    currKey2Values = null;
    var changedFields = new Set(1...n+1).subtracting([keyIdx]);
    var extKeyValues = new Map<Pos, Null<String>>();
    for (f in 1...n+1) {
      extKeyValues[f] = null;
    }
    extKeyValues[keyIdx] = keyName;
    extKeyValues[cmdIdx] = "DELETE";
    var update = new ItemUpdate2Level(item.itemIdx, item.subscription, extKeyValues, changedFields, snapshot);
    
    item.unrelate(keyName);
    
    var sub = subscription2Level.sure();
    sub.removeListener(listener2Level.sure());
    listener2Level.sure().disable();
    subscription2Level = null;
    listener2Level = null;
    
    // TODO item.strategy.client.unsubscribe(sub);
    fireOnItemUpdate(update);
  }

  function doLightDelete(keyValues: Map<Pos, Null<String>>, snapshot: Bool) {
    var nFields = item.subscription.get_nFields().sure();
    var keyIdx = item.subscription.getKeyPosition().sure();
    var cmdIdx = item.subscription.getCommandPosition().sure();
    currKeyValues = null;
    var changedFields = new Set(1...nFields+1);
    var values = new Map<Pos, Null<String>>();
    for (f in 1...nFields+1) {
      values[f] = null;
    }
    values[keyIdx] = keyValues[keyIdx];
    values[cmdIdx] = keyValues[cmdIdx];
    var update = new ItemUpdate2Level(item.itemIdx, item.subscription, values, changedFields, snapshot);
    
    fireOnItemUpdate(update);
  }

  function doDelete1LevelOnly(keyValues: Map<Pos, Null<String>>, snapshot: Bool) {
    var nFields = item.subscription.get_nFields().sure();
    var keyIdx = item.subscription.getKeyPosition().sure();
    var cmdIdx = item.subscription.getCommandPosition().sure();
    currKeyValues = null;
    var changedFields = new Set(1...nFields+1).subtracting([keyIdx]);
    var values = new Map<Pos, Null<String>>();
    for (f in 1...nFields+1) {
      values[f] = null;
    }
    values[keyIdx] = keyValues[keyIdx];
    values[cmdIdx] = keyValues[cmdIdx];
    var update = new ItemUpdate2Level(item.itemIdx, item.subscription, values, changedFields, snapshot);
    
    fireOnItemUpdate(update);
  }

  function doChangeRequestedMaxFrequency() {
    subscription2Level.sure().setRequestedMaxFrequency(item.strategy.requestedMaxFrequency.toString());
  }
  
  function doSetRealMaxFrequency(maxFrequency: Null<RealMaxFrequency>) {
    realMaxFrequency = maxFrequency;
  }
  
  function doUnsetRealMaxFrequency() {
    realMaxFrequency = null;
  }
  
  function genOnRealMaxFrequency2LevelAdded() {
    item.strategy.evtOnRealMaxFrequency2LevelAdded(realMaxFrequency);
  }
  
  function genOnRealMaxFrequency2LevelRemoved() {
    item.strategy.evtOnRealMaxFrequency2LevelRemoved();
  }

  function doUnsubscribe() {
    assert(subscription2Level != null);
    assert(listener2Level != null);
    var sub = subscription2Level;
    sub.removeListener(listener2Level);
    listener2Level.disable();
    subscription2Level = null;
    listener2Level = null;
    
    // TODO item.strategy.client.unsubscribe(sub);
  }

  function notify2LevelIllegalArgument() {
    listener2Level = null;
    subscription2Level = null;
    
    item.subscription.fireOnSubscriptionError2Level(keyName, 14, "The received key value is not a valid name for an Item", item.m_subId, item.itemIdx);
  }

  function notify2LevelSubscriptionError(code: Int, msg: String) {
    listener2Level = null;
    subscription2Level = null;
    
    item.subscription.fireOnSubscriptionError2Level(keyName, code, msg, item.m_subId, item.itemIdx);
  }

  function notify2LevelLostUpdates(lostUpdates: Int) {
    item.subscription.fireOnLostUpdates2Level(keyName, lostUpdates, item.m_subId, item.itemIdx);
  }

  function fireOnItemUpdate(update: ItemUpdate) {
    item.subscription.fireOnItemUpdate(update, item.m_subId);
  }

  function create2LevelSubscription(): Null<Subscription> {
    listener2Level = new Sub2LevelDelegate(this);
    var sub = item.subscription;
    @:nullSafety(Off)
    var sub2 = new Subscription(Merge, null, null);
    var items = [keyName];
    // TODO
    // guard allValidItems(items) else {
    //   return null;
    // }
    sub2.setItems(items);
    var fields2 = sub.getCommandSecondLevelFields();
    if (fields2 != null) {
      sub2.setFields(fields2);
    } else {
      sub2.setFieldSchema(sub.getCommandSecondLevelFieldSchema());
    }
    sub2.setDataAdapter(sub.getCommandSecondLevelDataAdapter());
    sub2.setRequestedSnapshot(SnpYes.toString());
    sub2.setRequestedMaxFrequency(item.strategy.requestedMaxFrequency.toString());
    sub2.addListener(listener2Level.sure());
    sub2.setInternal();
    return sub2;
  }

  function isDelete(keyValues: Map<Pos, Null<String>>): Bool {
    return keyValues[item.subscription.getCommandPosition().sure()] == "DELETE";
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

private class Sub2LevelDelegate implements SubscriptionListener {
  final key: Key2Level;
  var m_disabled = false;

  public function new(key: Key2Level) {
    this.key = key;
  }

  public function disable() {
    key.lock.synchronized(() -> {
      m_disabled = true;
    });
  }

  function synchronized(block: () -> Void) {
    key.lock.synchronized(() -> {
      if (!m_disabled) {
        block();
      }
    });
  }

  public function onSubscriptionError(code: Int, message: String) {
    synchronized(() -> {
      key.evtOnSubscriptionError2Level(code, message);
    });
  }
  
  public function onItemUpdate(itemUpdate: ItemUpdate) {
    synchronized(() -> {
      key.evtUpdate2Level(itemUpdate);
    });
  }

  public function onItemLostUpdates(itemName: Null<String>, itemPos: Pos, lostUpdates: Int) {
    synchronized(() -> {
      key.evtOnItemLostUpdates2Level(lostUpdates);
    });
  }

  public function onRealMaxFrequency(frequency: Null<String>) {
    synchronized(() -> {
      key.evtOnRealMaxFrequency2Level(frequency == null ? null : switch frequency {
        case "unlimited": RFreqUnlimited;
        case Std.parseFloat(_) => max if (!Math.isNaN(max)): RFreqLimited(max);
        case _: null;
      });
    });
  }

  public function onUnsubscription() {
    synchronized(() -> {
      key.evtOnUnsubscription2Level();
    });
  }

  public function onClearSnapshot(itemName:Null<String>, itemPos:Int) {}
  public function onCommandSecondLevelItemLostUpdates(lostUpdates:Int, key:String) {}
  public function onCommandSecondLevelSubscriptionError(code:Int, message:String, key:String) {}
  public function onEndOfSnapshot(itemName:Null<String>, itemPos:Int) {}
  public function onListenEnd(subscription:Subscription) {}
  public function onListenStart(subscription:Subscription) {}
  public function onSubscription() {}
}