package com.lightstreamer.client;

import com.lightstreamer.client.internal.SubscriptionManager.SubscriptionManagerLiving;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.EventDispatcher;
import com.lightstreamer.internal.Types;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

private enum SubscriptionState {
  Inactive; Active; Subscribed;
}

private class SubscriptionEventDispatcher extends EventDispatcher<SubscriptionListener> {}

/**
 * Subscription class
 **/
#if (js || python) @:expose @:native("Subscription") #end
#if (java || cs || python) @:nativeGen #end
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Subscription {
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

  // TODO implement overloaded constructors
  public function new(mode: String, items: NativeArray<String>, fields: NativeArray<String>) {
    this.mode = SubscriptionMode.fromString(mode);
    this.snapshot = this.mode == Raw ? null : SnpYes;
    this.items = Items.fromArray(items.toHaxe());
    this.fields = Fields.fromArray(fields.toHaxe());
    if (this.mode == Command && @:nullSafety(Off) !this.fields.hasKeyField()) {
      throw new IllegalArgumentException("Field 'key' is missing");
    }
    if (this.mode == Command && @:nullSafety(Off) !this.fields.hasCommandField()) {
      throw new IllegalArgumentException("Field 'command' is missing");
    }
  }

  public function addListener(listener: SubscriptionListener): Void {
    eventDispatcher.addListenerAndFireOnListenStart(listener, this);
  }
  public function removeListener(listener: SubscriptionListener): Void {
    eventDispatcher.removeListenerAndFireOnListenEnd(listener, this);
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
  public function setRequestedMaxFrequency(freq: Null<String>): Void {
    var newValue = RequestedMaxFrequencyTools.fromString(freq);
    switch (mode) {
      case Merge|Distinct|Command:
      case _:
        throw new IllegalArgumentException("The operation in only available on MERGE, DISTINCT and COMMAND Subscripitons");
    }
    if (isActive() && (newValue == null || newValue == FreqUnfiltered || this.requestedMaxFrequency == FreqUnfiltered)) {
      throw new IllegalArgumentException("Cannot change the frequency from/to 'unfiltered' or to null while the Subscription is active");
    }
    this.requestedMaxFrequency = newValue;
    // TODO forward to manager
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

  public function getValue(itemName: String, fieldName: String): String {
    return "";
  }
  // TODO overload
  // public function getValue(itemPos: Int, fieldPos: Int): String {}
  // public function getValue(itemName: String, fieldPos: Int): String {}
  // public function getValue(itemPos: Int, fieldName: String): String {}

  public function getCommandValue(itemName: String, keyValue: String, fieldName: String): String {
    return "";
  }
  // TODO overload
  // public function getCommandValue(itemPos: Int, keyValue: String, fieldPos: Int): String {}
  // public function getCommandValue(itemPos: Int, keyValue: String, fieldName: String): String {}
  // public function getCommandValue(itemName: String, keyValue: String, fieldPos: Int): String {}

  // --------------- private methods ---------------

  function checkActive() {
    if (isActive()) {
      throw new IllegalStateException("Cannot modify an active Subscription. Please unsubscribe before applying any change");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fetchMode(): SubscriptionMode {
    return mode;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fetchRequestedBufferSize(): Null<RequestedBufferSize> {
    return bufferSize;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fetchRequestedSnapshot(): Null<RequestedSnapshot> {
    return snapshot;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fetchRequestedMaxFrequency(): Null<RequestedMaxFrequency> {
    return requestedMaxFrequency;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.SubscriptionManager)
  function fetch_nItems(): Null<Int> {
    return nItems;
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
  function get_nFields(): Null<Int> {
    return nFields;
  }

  @:synchronized
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
}