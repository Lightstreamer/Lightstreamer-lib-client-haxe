package com.lightstreamer.client;

import com.lightstreamer.internal.InfoMap;
import com.lightstreamer.client.internal.SubscriptionManager;
import com.lightstreamer.client.internal.SubscriptionManager.SubscriptionManagerLiving;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.EventDispatcher;
import com.lightstreamer.internal.Types;
import haxe.extern.EitherType;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

private enum SubscriptionState {
  Inactive; Active; Subscribed;
}

private class SubscriptionEventDispatcher extends EventDispatcher<SubscriptionListener> {}

/**
 * Subscription class
 **/
 #if (js || python) @:expose @:native("LSSubscription") #end
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class LSSubscription {
  final eventDispatcher = new SubscriptionEventDispatcher();
  final mode: SubscriptionMode;
  var items: Null<Items>;
  var fields: Null<Fields>;
  var group: Null<Name>;
  var schema: Null<Name>;
  var dataAdapter: Null<Name>;
  var bufferSize: Null<RequestedBufferSize>;
  var snapshot: Null<RequestedSnapshot>;
  var requestedMaxFrequency: Null<RequestedMaxFrequency>;
  var selector: Null<Name>;
  var dataAdapter2: Null<Name>;
  var fields2: Null<Fields>;
  var schema2: Null<Name>;
  // /* other variables */
  var state: SubscriptionState = Inactive;
  var subId: Null<Int>;
  var cmdIdx: Null<Pos>;
  var keyIdx: Null<Pos>;
  var nItems: Null<Int>;
  var nFields: Null<Int>;
  var m_internal: Bool = false; // special flag used to mark 2-level subscriptions
  var manager: Null<SubscriptionManagerLiving>;
  public final wrapper: Null<Any>;

  #if js
  public function new(mode: String, items: NativeArray<String>, fields: NativeArray<String>, wrapper: Any = null) {
    this.wrapper = wrapper;
    this.mode = SubscriptionMode.fromString(mode);
    initSnapshot();
    initItemsAndFields(items is String ? [cast items] : items, fields);
  }
  #elseif (java || cs)
  overload public function new(mode: String, items: NativeArray<String>, fields: NativeArray<String>, wrapper: Any = null) {
    this.wrapper = wrapper;
    this.mode = SubscriptionMode.fromString(mode);
    initSnapshot();
    initItemsAndFields(items, fields);
  }

  overload public function new(mode: String, wrapper: Any = null) {
    this.wrapper = wrapper;
    this.mode = SubscriptionMode.fromString(mode);
    initSnapshot();
  }

  overload public function new(mode: String, item: String, fields: NativeArray<String>, wrapper: Any = null) {
    this.wrapper = wrapper;
    this.mode = SubscriptionMode.fromString(mode);
    initSnapshot();
    initItemsAndFields([item], fields);
  }
  #else
  public function new(mode: String, items: NativeArray<String>, fields: NativeArray<String>, wrapper: Any = null) {
    this.wrapper = wrapper;
    this.mode = SubscriptionMode.fromString(mode);
    initSnapshot();
    initItemsAndFields(items, fields);
  }
  #end

  function initSnapshot() {
    this.snapshot = this.mode == Raw ? null : SnpYes;
  }

  function initItemsAndFields(items: NativeArray<String>, fields: NativeArray<String>) {
    if (items != null) {
      if (fields == null) {
        throw new IllegalArgumentException("Please specify a valid field list");
      }
      this.items = Items.fromArray(items.toHaxe());
      this.fields = Fields.fromArray(fields.toHaxe());
      if (this.mode == Command && @:nullSafety(Off) !this.fields.hasKeyField()) {
        throw new IllegalArgumentException("Field 'key' is missing");
      }
      if (this.mode == Command && @:nullSafety(Off) !this.fields.hasCommandField()) {
        throw new IllegalArgumentException("Field 'command' is missing");
      }
    } else if (fields != null) {
      throw new IllegalArgumentException("Please specify a valid item or item list");
    }
  }

  public function addListener(listener: SubscriptionListener): Void {
    eventDispatcher.addListenerAndFireOnListenStart(listener);
  }
  public function removeListener(listener: SubscriptionListener): Void {
    eventDispatcher.removeListenerAndFireOnListenEnd(listener);
  }
  public function getListeners(): NativeList<SubscriptionListener> {
    return new NativeList(eventDispatcher.getListeners());
  }

  public function isActive(): Bool {
    return state != Inactive;
  }
  public function isSubscribed(): Bool {
    return state == Subscribed;
  }

  public function getDataAdapter(): Null<String> {
    return dataAdapter;
  }
  public function setDataAdapter(dataAdapter: Null<String>): Void {
    checkActive();
    this.dataAdapter = Name.fromString(dataAdapter);
  }

  public function getMode(): String {
    return mode;
  }

  public function getItems(): Null<NativeArray<String>> {
    return items == null ? null : new NativeArray(items);
  }
  public function setItems(items: Null<NativeArray<String>>): Void {
    checkActive();
    this.items = Items.fromArray(items == null ? null : items.toHaxe());
    this.group = null;
  }

  public function getItemGroup(): Null<String> {
    return group;
  }
  public function setItemGroup(group: Null<String>): Void {
    checkActive();
    this.group = Name.fromString(group);
    this.items = null;
  }

  public function getFields(): Null<NativeArray<String>> {
    return fields == null ? null : new NativeArray(fields);
  }
  public function setFields(fields: Null<NativeArray<String>>): Void {
    checkActive();
    var newValue = Fields.fromArray(fields == null ? null : fields.toHaxe());
    if (mode == Command && newValue != null) {
      if (!newValue.hasCommandField()) {
        throw new IllegalArgumentException("Field 'command' is missing");
      }
      if (!newValue.hasKeyField()) {
        throw new IllegalArgumentException("Field 'key' is missing");
      }
    }
    this.fields = newValue;
    this.schema = null;
  }

  public function getFieldSchema(): Null<String> {
    return schema;
  }
  public function setFieldSchema(schema: Null<String>): Void {
    checkActive();
    this.schema = Name.fromString(schema);
    this.fields = null;
  }

  public function getRequestedBufferSize(): Null<String> {
    return bufferSize.toString();
  }
  public function setRequestedBufferSize(size: Null<String>): Void {
    checkActive();
    this.bufferSize = RequestedBufferSizeTools.fromString(size);
  }

  public function getRequestedSnapshot(): Null<String> {
    return snapshot.toString();
  }
  public function setRequestedSnapshot(snapshot: Null<String>): Void {
    checkActive();
    var newValue = RequestedSnapshotTools.fromString(snapshot);
    switch mode {
      case Raw if (newValue != null):
        throw new IllegalArgumentException("Snapshot is not permitted if RAW was specified as mode");
      case Merge | Command if (newValue != null && newValue.match(SnpLength(_))):
        throw new IllegalArgumentException("Snapshot length is not permitted if MERGE or COMMAND was specified as mode");
      case _:
    }
    this.snapshot = newValue;
  }

  public function getRequestedMaxFrequency(): Null<String> {
    return requestedMaxFrequency.toString();
  }
  @:unsynchronized
  public function setRequestedMaxFrequency(freq: Null<String>): Void {
    var _manager;
    lock.synchronized(() -> {
      var newValue = RequestedMaxFrequencyTools.fromString(freq);
      switch (mode) {
        case Merge|Distinct|Command:
        case _:
          throw new IllegalArgumentException("The operation in only available on MERGE, DISTINCT and COMMAND Subscripitons");
      }
      if (isActive() && (newValue == null || newValue == FreqUnfiltered || this.requestedMaxFrequency == FreqUnfiltered)) {
        throw new IllegalArgumentException("Cannot change the frequency from/to 'unfiltered' or to null while the Subscription is active");
      }
      if (subId != null) {
        subscriptionLogger.logInfo('Subscription $subId requested max frequency changed: $freq');
      }
      this.requestedMaxFrequency = newValue;
      _manager = manager;
    });
    if (_manager != null) {
      _manager.evtExtConfigure();
    }
  }

  public function getSelector(): Null<String> {
    return selector;
  }
  public function setSelector(selector: Null<String>): Void {
    checkActive();
    this.selector = Name.fromString(selector);
  }

  public function getCommandPosition(): Null<Int> {
    return cmdIdx;
  }
  public function getKeyPosition(): Null<Int> {
    return keyIdx;
  }

  public function getCommandSecondLevelDataAdapter(): Null<String> {
    return dataAdapter2;
  }
  public function setCommandSecondLevelDataAdapter(dataAdapter: Null<String>): Void {
    checkActive();
    if (mode != Command) {
      throw new IllegalStateException("The operation is only available on COMMAND Subscriptions");
    }
    this.dataAdapter2 = Name.fromString(dataAdapter);
  }

  public function getCommandSecondLevelFields(): Null<NativeArray<String>> {
    return fields2 == null ? null : new NativeArray(fields2);
  }
  public function setCommandSecondLevelFields(fields: Null<NativeArray<String>>) {
    checkActive();
    var newValue = Fields.fromArray(fields == null ? null : fields.toHaxe());
    if (mode != Command) {
      throw new IllegalStateException("The operation is only available on COMMAND Subscriptions");
    }
    this.fields2 = newValue;
    this.schema2 = null;
  }

  public function getCommandSecondLevelFieldSchema(): Null<String> {
    return schema2;
  }
  public function setCommandSecondLevelFieldSchema(schema: String): Void {
    checkActive();
    if (mode != Command) {
      throw new IllegalStateException("The operation is only available on COMMAND Subscriptions");
    }
    this.schema2 = Name.fromString(schema);
    this.fields2 = null;
  }

  #if (java || cs)
  @:unsynchronized
  overload public function getValue(itemPos: Int, fieldPos: Int): Null<String> {
    if (itemPos < 1 || fieldPos < 1) {
      throw new IllegalArgumentException("The specified position is out of bounds");
    }
    var _manager;
    lock.synchronized(() -> {
      _manager = manager;
    });
    return _manager != null ? _manager.getValue(itemPos, fieldPos) : null;
  }

  @:unsynchronized
  overload public function getValue(itemPos: Int, fieldName: String): String {
    var fieldPos = lock.synchronized(() -> getFieldPos(fieldName));
    return getValue(itemPos, fieldPos);
  }

  @:unsynchronized
  overload public function getValue(itemName: String, fieldPos: Int): String {
    var itemPos = lock.synchronized(() -> getItemPos(itemName));
    return getValue(itemPos, fieldPos);
  }

  @:unsynchronized
  overload public function getValue(itemName: String, fieldName: String): String {
    var itemPos = lock.synchronized(() -> getItemPos(itemName));
    var fieldPos = lock.synchronized(() -> getFieldPos(fieldName));
    return getValue(itemPos, fieldPos);
  }

  @:unsynchronized
  overload public function getCommandValue(itemPos: Int, keyValue: String, fieldPos: Int): Null<String> {
    if (mode != Command) {
      throw new IllegalStateException("This method can only be used on COMMAND subscriptions");
    }
    if (itemPos < 1 || fieldPos < 1) {
      throw new IllegalArgumentException("The specified position is out of bounds");
    }
    var _manager;
    lock.synchronized(() -> {
      _manager = manager;
    });
    return _manager != null ? _manager.getCommandValue(itemPos, keyValue, fieldPos) : null;
  }

  @:unsynchronized
  overload public function getCommandValue(itemPos: Int, keyValue: String, fieldName: String): Null<String> {
    var fieldPos = lock.synchronized(() -> getFieldPos(fieldName));
    return getCommandValue(itemPos, keyValue, fieldPos);
  }

  @:unsynchronized
  overload public function getCommandValue(itemName: String, keyValue: String, fieldPos: Int): Null<String> {
    var itemPos = lock.synchronized(() -> getItemPos(itemName));
    return getCommandValue(itemPos, keyValue, fieldPos);
  }

  @:unsynchronized
  overload public function getCommandValue(itemName: String, keyValue: String, fieldName: String): Null<String> {
    var itemPos = lock.synchronized(() -> getItemPos(itemName));
    var fieldPos = lock.synchronized(() -> getFieldPos(fieldName));
    return getCommandValue(itemPos, keyValue, fieldPos);
  }
  #else
  @:unsynchronized
  public function getValue(itemNameOrPos: EitherType<Int, String>, fieldNameOrPos: EitherType<Int, String>): Null<String> {
    var isItemPos = itemNameOrPos is Int;
    var isItemName = itemNameOrPos is String;
    var isFieldPos = fieldNameOrPos is Int;
    var isFieldName = fieldNameOrPos is String;
    if (isItemPos && isFieldPos) {
      return getValuePosPos(itemNameOrPos, fieldNameOrPos);
    } else if (isItemPos && isFieldName) {
      return getValuePosName(itemNameOrPos, fieldNameOrPos);
    } else if (isItemName && isFieldPos) {
      return getValueNamePos(itemNameOrPos, fieldNameOrPos);
    } else if (isItemName && isFieldName) {
      return getValueNameName(itemNameOrPos, fieldNameOrPos);
    } else {
      throw new IllegalArgumentException("Invalid argument type");
    }
  }

  @:unsynchronized
  public function getCommandValue(itemNameOrPos: EitherType<Int, String>, keyValue: String, fieldNameOrPos: EitherType<Int, String>): Null<String> {
    var isItemPos = itemNameOrPos is Int;
    var isItemName = itemNameOrPos is String;
    var isFieldPos = fieldNameOrPos is Int;
    var isFieldName = fieldNameOrPos is String;
    if (isItemPos && isFieldPos) {
      return getCommandValuePosPos(itemNameOrPos, keyValue, fieldNameOrPos);
    } else if (isItemPos && isFieldName) {
      return getCommandValuePosName(itemNameOrPos, keyValue, fieldNameOrPos);
    } else if (isItemName && isFieldPos) {
      return getCommandValueNamePos(itemNameOrPos, keyValue, fieldNameOrPos);
    } else if (isItemName && isFieldName) {
      return getCommandValueNameName(itemNameOrPos, keyValue, fieldNameOrPos);
    } else {
      throw new IllegalArgumentException("Invalid argument type");
    }
  }

  function getValuePosPos(itemPos: Int, fieldPos: Int): Null<String> {
    if (itemPos < 1 || fieldPos < 1) {
      throw new IllegalArgumentException("The specified position is out of bounds");
    }
    var _manager;
    lock.synchronized(() -> {
      _manager = manager;
    });
    return _manager != null ? _manager.getValue(itemPos, fieldPos) : null;
  }

  function getValuePosName(itemPos: Int, fieldName: String): Null<String> {
    var fieldPos = lock.synchronized(() -> getFieldPos(fieldName));
    return getValuePosPos(itemPos, fieldPos);
  }

  function getValueNamePos(itemName: String, fieldPos: Int): Null<String> {
    var itemPos = lock.synchronized(() -> getItemPos(itemName));
    return getValuePosPos(itemPos, fieldPos);
  }

  function getValueNameName(itemName: String, fieldName: String): Null<String> {
    var itemPos = lock.synchronized(() -> getItemPos(itemName));
    var fieldPos = lock.synchronized(() -> getFieldPos(fieldName));
    return getValuePosPos(itemPos, fieldPos);
  }

  function getCommandValuePosPos(itemPos: Int, keyValue: String, fieldPos: Int): Null<String> {
    if (mode != Command) {
      throw new IllegalStateException("This method can only be used on COMMAND subscriptions");
    }
    if (itemPos < 1 || fieldPos < 1) {
      throw new IllegalArgumentException("The specified position is out of bounds");
    }
    var _manager;
    lock.synchronized(() -> {
      _manager = manager;
    });
    return _manager != null ? _manager.getCommandValue(itemPos, keyValue, fieldPos) : null;
  }

  function getCommandValuePosName(itemPos: Int, keyValue: String, fieldName: String): Null<String> {
    var fieldPos = lock.synchronized(() -> getFieldPos(fieldName));
    return getCommandValuePosPos(itemPos, keyValue, fieldPos);
  }

  function getCommandValueNamePos(itemName: String, keyValue: String, fieldPos: Int): Null<String> {
    var itemPos = lock.synchronized(() -> getItemPos(itemName));
    return getCommandValuePosPos(itemPos, keyValue, fieldPos);
  }

  function getCommandValueNameName(itemName: String, keyValue: String, fieldName: String): Null<String> {
    var itemPos = lock.synchronized(() -> getItemPos(itemName));
    var fieldPos = lock.synchronized(() -> getFieldPos(fieldName));
    return getCommandValuePosPos(itemPos, keyValue, fieldPos);
  }
  #end

  // --------------- private methods ---------------

  function getItemPos(itemName: String) {
    var itemPos: Int;
    if (items == null || (itemPos = items.getPos(itemName)) == -1) {
      throw new IllegalArgumentException("Unknown item name");
    }
    return itemPos;
  }

  function getFieldPos(fieldName: String) {
    var fieldPos: Int;
    if (fields == null || (fieldPos = fields.getPos(fieldName)) == -1) {
      throw new IllegalArgumentException("Unknown field name");
    }
    return fieldPos;
  }

  function checkActive() {
    if (isActive()) {
      throw new IllegalStateException("Cannot modify an active Subscription. Please unsubscribe before applying any change");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fetch_mode(): SubscriptionMode {
    return mode;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fetch_requestedBufferSize(): Null<RequestedBufferSize> {
    return bufferSize;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fetch_requestedSnapshot(): Null<RequestedSnapshot> {
    return snapshot;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fetch_requestedMaxFrequency(): Null<RequestedMaxFrequency> {
    return requestedMaxFrequency;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fetch_nItems(): Null<Int> {
    return nItems;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.ClientMachine)
  function fetch_subManager(): Null<SubscriptionManagerLiving> {
    return manager;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function setActive() {
    state = Active;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function setInactive() {
    state = Inactive;
    subId = null;
    cmdIdx = null;
    keyIdx = null;
    nItems = null;
    nFields = null;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function setSubscribed(subId: Int, nItems: Int, nFields: Int) {
    this.state = Subscribed;
    this.subId = subId;
    this.nItems = nItems;
    this.nFields = nFields;
  }
  
  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function setSubscribedCMD(subId: Int, nItems: Int, nFields: Int, cmdIdx: Pos, keyIdx: Pos) {
    this.state = Subscribed;
    this.subId = subId;
    this.cmdIdx = cmdIdx;
    this.keyIdx = keyIdx;
    this.nItems = nItems;
    this.nFields = nFields;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.update.Key1Level)
  @:allow(com.lightstreamer.client.internal.update.Key2Level)
  @:allow(com.lightstreamer.client.internal.update.ItemUpdateBase)
  @:allow(com.lightstreamer.client.internal.update.ItemUpdate2Level)
  function fetch_nFields(): Null<Int> {
    return nFields;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.ClientMachine)
  function isInternal(): Bool {
    return m_internal;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.update.Key2Level)
  function setInternal() {
    m_internal = true;
  }

  @:synchronized
  function getItemName(itemIdx: Pos): Null<String> {
    if (items != null) {
      return (items[itemIdx - 1] : Null<String>);
    }
    return (null : Null<String>);
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function relate(manager: SubscriptionManagerLiving) {
    this.manager = manager;
  }
  
  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function unrelate(manager: SubscriptionManagerLiving) {
    if (this.manager != manager) {
      return;
    }
    this.manager = null;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.update.ItemBase)
  function hasSnapshot(): Bool {
    return !(snapshot == null || snapshot == SnpNo);
  }

  function getItemNameOrPos(itemIdx: Pos): String {
    return items != null ? items[itemIdx - 1] : '$itemIdx';
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fireOnSubscription(subId: Int) {
    subscriptionLogger.logInfo('Subscription $subId added');
    eventDispatcher.onSubscription();
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fireOnUnsubscription(subId: Int) {
    subscriptionLogger.logInfo('Subscription $subId deleted');
    eventDispatcher.onUnsubscription();
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fireOnSubscriptionError(subId: Int, code: Int, msg: String) {
    subscriptionLogger.logWarn('Subscription $subId failed: $code - $msg');
    eventDispatcher.onSubscriptionError(code, msg);
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fireOnEndOfSnapshot(itemIdx: Pos, subId: Int) {
    subscriptionLogger.logDebug('Subscription $subId:${getItemNameOrPos(itemIdx)}: snapshot ended');
    eventDispatcher.onEndOfSnapshot(getItemName(itemIdx), itemIdx);
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fireOnClearSnapshot(itemIdx: Pos, subId: Int) {
    subscriptionLogger.logDebug('Subscription $subId:${getItemNameOrPos(itemIdx)}: snapshot cleared');
    eventDispatcher.onClearSnapshot(getItemName(itemIdx), itemIdx);
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fireOnLostUpdates(itemIdx: Pos, lostUpdates: Int, subId: Int) {
    subscriptionLogger.logDebug('Subscription $subId:${getItemNameOrPos(itemIdx)}: lost $lostUpdates updates');
    eventDispatcher.onItemLostUpdates(getItemName(itemIdx), itemIdx, lostUpdates);
  }
  
  @:synchronized
  @:allow(com.lightstreamer.client.internal.update.ItemBase)
  @:allow(com.lightstreamer.client.internal.update.Key1Level)
  @:allow(com.lightstreamer.client.internal.update.Key2Level)
  function fireOnItemUpdate(update: ItemUpdate, subId: Int) {
    subscriptionLogger.logDebug('Subscription $subId:${getItemNameOrPos(update.getItemPos())} update: $update');
    eventDispatcher.onItemUpdate(update);
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.ModeStrategy)
  function fireOnRealMaxFrequency(freq: Null<RealMaxFrequency>, subId: Int) {
    subscriptionLogger.logDebug('Subscription $subId real max frequency changed: $freq');
    eventDispatcher.onRealMaxFrequency(realFrequencyAsString(freq));
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.update.Key2Level)
  function fireOnSubscriptionError2Level(keyName: String, code: Int, msg: String, subId: Int, itemIdx: Pos) {
    subscriptionLogger.logWarn('Subscription $subId:${getItemNameOrPos(itemIdx)}:$keyName failed: $code - $msg');
    eventDispatcher.onCommandSecondLevelSubscriptionError(code, msg, keyName);
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.update.Key2Level)
  function fireOnLostUpdates2Level(keyName: String, lostUpdates: Int, subId: Int, itemIdx: Pos) {
    subscriptionLogger.logDebug('Subscription $subId:${getItemNameOrPos(itemIdx)}:$keyName: lost $lostUpdates updates');
    eventDispatcher.onCommandSecondLevelItemLostUpdates(lostUpdates, keyName);
  }

  public function toString(): String {
    var map = new InfoMap();
    map["mode"] = mode;
    map["items"] = items != null ? Std.string(items) : group;
    map["fields"] = fields != null ? Std.string(fields) : schema;
    map["dataAdapter"] = dataAdapter;
    map["requestedBufferSize"] = bufferSize;
    map["requestedSnapshot"] = snapshot;
    map["requestedMaxFrequency"] = requestedMaxFrequency;
    map["selector"] = selector;
    map["secondLevelFields"] = fields2 != null ? Std.string(fields2) : schema2;
    map["secondLevelDataAdapter"] = dataAdapter2;
    return map.toString();
  }
}