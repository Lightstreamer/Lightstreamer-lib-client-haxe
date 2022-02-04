package com.lightstreamer.client.mpn;

import com.lightstreamer.client.NativeTypes;
import com.lightstreamer.client.Types;
import com.lightstreamer.client.mpn.Types;

private enum MpnSubscriptionState {
  Unknown; Active; Subscribed; Triggered;
}

private class MpnSubscriptionEventDispatcher extends EventDispatcher<MpnSubscriptionListener> {}

#if (js || python) @:expose @:native("MpnSubscription") #end
#if (java || cs || python) @:nativeGen #end
@:build(com.lightstreamer.client.Macros.synchronizeClass())
class MpnSubscription {
  final eventDispatcher = new MpnSubscriptionEventDispatcher();
  final mode: MpnSubscriptionMode;
  var items: Null<Items>;
  var fields: Null<Fields>;
  var group: Null<Name>;
  var schema: Null<Name>;
  var dataAdapter: Null<Name>;
  var bufferSize: Null<RequestedBufferSize>;
  var requestedMaxFrequency: Null<MpnRequestedMaxFrequency>;
  var mpnSubId: Null<MpnSubscriptionId>;
  var requestedTrigger: Null<TriggerExpression>;
  var requestedFormat: Null<NotificationFormat>;
  var realTrigger: Null<TriggerExpression>;
  var realFormat: Null<NotificationFormat>;
  var statusTs: Timestamp = new Timestamp(0);
  /* other variables */
  final madeByServer: Bool;
  var state: MpnSubscriptionState = Unknown;

  // #if android
  // public function new(appContext: android.content.Context) {
  //   var pkg = com.lightstreamer.client.mpn.AndroidUtils.getPackageName(appContext);
  //   trace("MPNSub.new", pkg);
  // }
  // #end

  // TODO implement overloaded constructors
  public function new(mode: String, items: NativeArray<String>, fields: NativeArray<String>) {
    this.items = Items.fromArray(items.toHaxe());
    this.fields = Fields.fromArray(fields.toHaxe());
    this.mode = MpnSubscriptionMode.fromString(mode);
    this.madeByServer = false;
  }

  public function addListener(listener: MpnSubscriptionListener): Void {
    eventDispatcher.addListenerAndFireOnListenStart(listener, this);
  }
  public function removeListener(listener: MpnSubscriptionListener): Void {
    eventDispatcher.removeListenerAndFireOnListenEnd(listener, this);
  }
  public function getListeners(): NativeList<MpnSubscriptionListener> {
    return new NativeList(eventDispatcher.getListeners());
  }

  public function getMode(): String {
    return mode;
  }

  public function getTriggerExpression(): Null<String> {
    return requestedTrigger;
  }
  public function setTriggerExpression(expr: Null<String>): Void {
    // TODO forward to manager
    this.requestedTrigger = TriggerExpression.fromString(expr);
  }
  public function getActualTriggerExpression(): Null<String> {
    return realTrigger;
  }

  public function getNotificationFormat(): Null<String> {
    return requestedFormat;
  }
  public function setNotificationFormat(format: Null<String>): Void {
    // TODO forward to manager
    this.requestedFormat = NotificationFormat.fromString(format);
  }
  public function getActualNotificationFormat(): Null<String> {
    return realFormat;
  }

  public function getDataAdapter(): Null<String> {
    return dataAdapter;
  }
  public function setDataAdapter(dataAdapter: Null<String>): Void {
    checkActive();
    this.dataAdapter = Name.fromString(dataAdapter);
  }

  public function getFields(): Null<NativeArray<String>> {
    return fields == null ? null : new NativeArray(fields);
  }
  public function setFields(fields: Null<NativeArray<String>>): Void {
    checkActive();
    this.fields = Fields.fromArray(fields == null ? null : fields.toHaxe());
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

  public function getRequestedBufferSize(): Null<String> {
    return bufferSize.toString();
  }
  public function setRequestedBufferSize(size: Null<String>): Void {
    checkActive();
    this.bufferSize = RequestedBufferSizeTools.fromString(size);
  }

  public function getRequestedMaxFrequency(): Null<String> {
    return requestedMaxFrequency.toString();
  }
  public function setRequestedMaxFrequency(freq: Null<String>): Void {
    checkActive();
    this.requestedMaxFrequency = MpnRequestedMaxFrequencyTools.fromString(freq);
  }

  public function isActive(): Bool {
    return state != Unknown;
  }
  public function isSubscribed(): Bool {
    return state == Subscribed;
  }
  public function isTriggered(): Bool {
    return state == Triggered;
  }

  public function getStatus(): String {
    return switch state {
      case Unknown: "UNKNOWN";
      case Active: "ACTIVE";
      case Subscribed: "SUBSCRIBED";
      case Triggered: "TRIGGERED";
    }
  }

  public function getStatusTimestamp(): Long {
    return statusTs;
  }

  public function getSubscriptionId(): Null<String> {
    return mpnSubId;
  }

  function checkActive() {
    if (isActive()) {
      throw new IllegalStateException("Cannot modify an active MpnSubscription. Please unsubscribe before applying any change");
    }
  }
}