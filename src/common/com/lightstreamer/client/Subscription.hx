package com.lightstreamer.client;

import com.lightstreamer.client.NativeTypes;
import com.lightstreamer.client.Types;

enum SubscriptionState {
  Inactive; Active; Subscribed;
}

/**
 * Subscription class
 **/
#if (js || python) @:expose @:native("Subscription") #end
#if (java || cs || python) @:nativeGen #end
class Subscription {
  // TODO synchronize methods
  // TODO implement listeners
  final mode: SubscriptionMode;
  var items: Null<Items>;
  var fields: Null<Fields>;
  var group: Null<Name>;
  var schema: Null<Name>;
  // let multicastDelegate = MulticastDelegate<SubscriptionDelegate>()
  // let callbackQueue = defaultQueue
  var dataAdapter: Null<Name>;
  var bufferSize: Null<RequestedBufferSize>;
  var snapshot: Null<RequestedSnapshot>;
  var requestedMaxFrequency: Null<RequestedMaxFrequency>;
  var selector: Null<Name>;
  var dataAdapter2: Null<Name>;
  var fields2: Null<Fields>;
  var schema2: Null<Name>;
  // /* other variables */
  // let lock = NSRecursiveLock()
  var state: SubscriptionState = Inactive;
  // var m_subId: Int?
  var cmdIdx: Null<FieldPosition>;
  var keyIdx: Null<FieldPosition>;
  // var m_nItems: Int?
  // var m_nFields: Int?
  // var m_internal: Bool = false // special flag used to mark 2-level subscriptions

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

  public function addListener(listener: SubscriptionListener): Void {}
  public function removeListener(listener: SubscriptionListener): Void {}
  public function getListeners(): NativeList<SubscriptionListener> {
    return new NativeList([]);
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

  function checkActive() {
    if (isActive()) {
      throw new IllegalStateException("Cannot modify an active Subscription. Please unsubscribe before applying any change");
    }
  }
}