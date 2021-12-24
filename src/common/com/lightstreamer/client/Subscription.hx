package com.lightstreamer.client;

/**
 * Subscription class
 **/
@:expose("Subscription")
@:nativeGen
class Subscription {
  
  #if java
  public overload function new(subscriptionMode: String, items: java.NativeArray<String>, fields: java.NativeArray<String>) {
    trace("Sub.new");
  }

  public overload function new(subscriptionMode: String, item: String, fields: java.NativeArray<String>) {
    trace("Sub.new");
  }

  public overload function new(subscriptionMode: String) {
    trace("Sub.new");
  }
  #elseif js
  public function new(subscriptionMode: String, items: Dynamic, fields: Array<String>) {
    trace("Sub.new");
  }
  #elseif cs
  public function new(subscriptionMode: String, items: cs.NativeArray<String>, fields: cs.NativeArray<String>) {
    trace("Sub.new");
  }
  #end

  public function addListener(listener: SubscriptionListener): Void {}
  public function removeListener(listener: SubscriptionListener): Void {}
  public function getListeners(): Array<SubscriptionListener> {
    return null;
  }
  public function isActive(): Bool {
    return false;
  }
  public function isSubscribed(): Bool {
    return false;
  }
  public function getDataAdapter(): String {
    return null;
  }
  public function setDataAdapter(dataAdapter: String): Void {}
  public function getMode(): String {
    return null;
  }
  public function getItems(): Array<String> {
    return null;
  }
  public function setItems(items: Array<String>): Void {}
  public function getItemGroup(): String {
    return null;
  }
  public function setItemGroup(groupName: String): Void {}
  public function getFields(): Array<String> {
    return null;
  }
  public function setFields(fields: Array<String>): Void {}
  public function getFieldSchema(): String {
    return null;
  }
  public function setFieldSchema(schemaName: String): Void {}
  public function getRequestedBufferSize(): String {
    return null;
  }
  public function setRequestedBufferSize(size: String): Void {}
  public function getRequestedSnapshot(): String {
    return null;
  }
  public function setRequestedSnapshot(required: String): Void {}
  public function getRequestedMaxFrequency(): String {
    return null;
  }
  public function setRequestedMaxFrequency(freq: String): Void {}
  public function getSelector(): String {
    return null;
  }
  public function setSelector(selector: String): Void {}
  public function getCommandPosition(): Int {
    return 0;
  }
  public function getKeyPosition(): Int {
    return 0;
  }
  public function getCommandSecondLevelDataAdapter(): String {
    return null;
  }
  public function setCommandSecondLevelDataAdapter(dataAdapter: String): Void {}
  // TODO getCommandSecondLevelFields/setCommandSecondLevelFields
  // public function getCommandSecondLevelFields(): java.NativeArray<String> {}
  // public function setCommandSecondLevelFields(fields: java.NativeArray<String>) {}
  public function getCommandSecondLevelFieldSchema(): String {
    return null;
  }
  public function setCommandSecondLevelFieldSchema(schemaName: String): Void {}
  public function getValue(itemName: String, fieldName: String): String {
    return null;
  }
  // TODO overload
  // public function getValue(itemPos: Int, fieldPos: Int): String {}
  // public function getValue(itemName: String, fieldPos: Int): String {}
  // public function getValue(itemPos: Int, fieldName: String): String {}
  public function getCommandValue(itemName: String, keyValue: String, fieldName: String): String {
    return null;
  }
  // TODO overload
  // public function getCommandValue(itemPos: Int, keyValue: String, fieldPos: Int): String {}
  // public function getCommandValue(itemPos: Int, keyValue: String, fieldName: String): String {}
  // public function getCommandValue(itemName: String, keyValue: String, fieldPos: Int): String {}
}