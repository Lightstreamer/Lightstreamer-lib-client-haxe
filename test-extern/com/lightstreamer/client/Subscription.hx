package com.lightstreamer.client;

#if python
@:pythonImport("lightstreamer.client", "Subscription")
#end
#if js @:native("Subscription") #end
#if LS_NODE @:jsRequire("lightstreamer-client-node","Subscription") #end
extern class Subscription {
  #if js
  public function new(mode: String, items: NativeArray<String>, fields: NativeArray<String>);
  #elseif (java || cs)
  overload public function new(mode: String, items: NativeArray<String>, fields: NativeArray<String>);
  overload public function new(mode: String);
  overload public function new(mode: String, item: String, fields: NativeArray<String>);
  #else
  public function new(mode: String, items: NativeArray<String>, fields: NativeArray<String>);
  #end
  public function addListener(listener: SubscriptionListener): Void;
  public function removeListener(listener: SubscriptionListener): Void;
  #if !cs
  public function getListeners(): NativeList<SubscriptionListener>;
  public function isActive(): Bool;
  public function isSubscribed(): Bool;
  public function getDataAdapter(): Null<String>;
  public function setDataAdapter(dataAdapter: Null<String>): Void;
  public function getMode(): String;
  public function getItems(): Null<NativeArray<String>>;
  public function setItems(items: Null<NativeArray<String>>): Void;
  public function getItemGroup(): Null<String>;
  public function setItemGroup(group: Null<String>): Void;
  public function getFields(): Null<NativeArray<String>>;
  public function setFields(fields: Null<NativeArray<String>>): Void;
  public function getFieldSchema(): Null<String>;
  public function setFieldSchema(schema: Null<String>): Void;
  public function getRequestedBufferSize(): Null<String>;
  public function setRequestedBufferSize(size: Null<String>): Void;
  public function getRequestedSnapshot(): Null<String>;
  public function setRequestedSnapshot(snapshot: Null<String>): Void;
  public function getRequestedMaxFrequency(): Null<String>;
  public function setRequestedMaxFrequency(freq: Null<String>): Void;
  public function getSelector(): Null<String>;
  public function setSelector(selector: Null<String>): Void;
  public function getCommandPosition(): Null<Int>;
  public function getKeyPosition(): Null<Int>;
  public function getCommandSecondLevelDataAdapter(): Null<String>;
  public function setCommandSecondLevelDataAdapter(dataAdapter: Null<String>): Void;
  public function getCommandSecondLevelFields(): Null<NativeArray<String>>;
  public function setCommandSecondLevelFields(fields: Null<NativeArray<String>>): Void;
  public function getCommandSecondLevelFieldSchema(): Null<String>;
  public function setCommandSecondLevelFieldSchema(schema: String): Void;
  #else
  public var Listeners(default, never): NativeList<SubscriptionListener>;
  public var Active(default, never): Bool;
  public var Subscribed(default, never): Bool;
  public var DataAdapter(default, default): Null<String>;
  public var Mode(default, never): String;
  public var Items(default, default): Null<NativeArray<String>>;
  public var ItemGroup(default, default): Null<String>;
  public var Fields(default, default): Null<NativeArray<String>>;
  public var FieldSchema(default, default): Null<String>;
  public var RequestedBufferSize(default, default): Null<String>;
  public var RequestedSnapshot(default, default): Null<String>;
  public var RequestedMaxFrequency(default, default): Null<String>;
  public var Selector(default, default): Null<String>;
  public var CommandPosition(default, never): Int;
  public var KeyPosition(default, never): Int;
  public var CommandSecondLevelDataAdapter(default, default): Null<String>;
  public var CommandSecondLevelFields(default, default): Null<NativeArray<String>>;
  public var CommandSecondLevelFieldSchema(default, default): Null<String>;
  #end

  #if (java || cs)
  overload public function getValue(itemPos: Int, fieldPos: Int): Null<String>;
  overload public function getValue(itemPos: Int, fieldName: String): String;
  overload public function getValue(itemName: String, fieldPos: Int): String;
  overload public function getValue(itemName: String, fieldName: String): String;
  overload public function getCommandValue(itemPos: Int, keyValue: String, fieldPos: Int): Null<String>;
  overload public function getCommandValue(itemPos: Int, keyValue: String, fieldName: String): Null<String>;
  overload public function getCommandValue(itemName: String, keyValue: String, fieldPos: Int): Null<String>;
  overload public function getCommandValue(itemName: String, keyValue: String, fieldName: String): Null<String>;
  #else
  public function getValue(itemNameOrPos: EitherType<Int, String>, fieldNameOrPos: EitherType<Int, String>): Null<String>;
  public function getCommandValue(itemNameOrPos: EitherType<Int, String>, keyValue: String, fieldNameOrPos: EitherType<Int, String>): Null<String>;
  #end
}