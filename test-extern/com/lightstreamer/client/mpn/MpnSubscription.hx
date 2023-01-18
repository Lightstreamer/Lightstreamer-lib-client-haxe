package com.lightstreamer.client.mpn;

#if js @:native("MpnSubscription") #end
extern class MpnSubscription {
  public function new(mode: EitherType<String, EitherType<Subscription, MpnSubscription>>, ?items: NativeArray<String>, ?fields: NativeArray<String>);
  public function addListener(listener: MpnSubscriptionListener): Void;
  public function removeListener(listener: MpnSubscriptionListener): Void;
  public function getListeners(): NativeList<MpnSubscriptionListener>;
  public function getMode(): String;
  public function getTriggerExpression(): Null<String>;
  public function setTriggerExpression(expr: Null<String>): Void;
  public function getActualTriggerExpression(): Null<String>;
  public function getNotificationFormat(): Null<String>;
  public function setNotificationFormat(format: Null<String>): Void;
  public function getActualNotificationFormat(): Null<String>;
  public function getDataAdapter(): Null<String>;
  public function setDataAdapter(dataAdapter: Null<String>): Void;
  public function getFields(): Null<NativeArray<String>>;
  public function setFields(fields: Null<NativeArray<String>>): Void;
  public function getFieldSchema(): Null<String>;
  public function setFieldSchema(schema: Null<String>): Void;
  public function getItems(): Null<NativeArray<String>>;
  public function setItems(items: Null<NativeArray<String>>): Void;
  public function getItemGroup(): Null<String>;
  public function setItemGroup(group: Null<String>): Void;
  public function getRequestedBufferSize(): Null<String>;
  public function setRequestedBufferSize(size: Null<String>): Void;
  public function getRequestedMaxFrequency(): Null<String>;
  public function setRequestedMaxFrequency(freq: Null<String>): Void;
  public function isActive(): Bool;
  public function isSubscribed(): Bool;
  public function isTriggered(): Bool;
  public function getStatus(): String;
  public function getStatusTimestamp(): Long;
  public function getSubscriptionId(): Null<String>;
}