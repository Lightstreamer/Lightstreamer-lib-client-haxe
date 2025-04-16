/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.lightstreamer.client.mpn;

import com.lightstreamer.internal.InfoMap;
import com.lightstreamer.client.internal.MpnSubscriptionManager;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.EventDispatcher;
import com.lightstreamer.client.mpn.Types;
import com.lightstreamer.client.internal.ParseTools;
import haxe.extern.EitherType;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

enum MpnSubscriptionStatus {
  Unknown; Active; Subscribed; Triggered;
}

private class MpnSubscriptionEventDispatcher extends EventDispatcher<MpnSubscriptionListener> {}

#if (js || python) @:expose @:native("LSMpnSubscription") #end
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class LSMpnSubscription {
  final eventDispatcher = new MpnSubscriptionEventDispatcher();
  var mode: MpnSubscriptionMode;
  var items: Null<Items>;
  var fields: Null<Fields>;
  var group: Null<Name>;
  var schema: Null<Name>;
  var dataAdapter: Null<Name>;
  var bufferSize: Null<RequestedBufferSize>;
  var requestedMaxFrequency: Null<MpnRequestedMaxFrequency>;
  var requestedTrigger: Null<TriggerExpression>;
  var requestedFormat: Null<NotificationFormat>;
  var realTrigger: Null<TriggerExpression>;
  var realFormat: Null<NotificationFormat>;
  var m_statusTs: Timestamp = new Timestamp(0);
  var m_mpnSubId: Null<String>;
  /* other variables */
  var madeByServer: Bool;
  var m_status: MpnSubscriptionStatus = Unknown;
  var m_manager: Null<MpnSubscriptionManager>;
  public final wrapper: Null<Any>;

  #if js
  public function new(mode: EitherType<String, EitherType<Subscription, MpnSubscription>>, items: NativeArray<String>, fields: NativeArray<String>, wrapper: Null<Any> = null) {
    this.wrapper = wrapper;
    if (mode is String) {
      this.mode = MpnSubscriptionMode.fromString(mode);
      this.madeByServer = false;
      initItemsAndFields(items is String ? [cast items] : items, fields);
    } else if (mode is Subscription) {
      var subscription: Subscription = cast mode;
      this.mode = MpnSubscriptionMode.fromString(subscription.getMode());
      this.madeByServer = false;
      initFromSubscription(subscription);
    } else if (mode is MpnSubscription) {
      var mpnSubscription: MpnSubscription = cast mode;
      this.mode = mpnSubscription.mode;
      this.madeByServer = false;
      initFromMpnSubscription(mpnSubscription);
    } else {
      // pseudo-initialization to please the compiler
      this.mode = Merge;
      this.madeByServer = false;
      throw new IllegalArgumentException("Wrong arguments for MpnSubscription constructor");
    }
  }
  #elseif java
  overload public function new(mode: String, items: NativeArray<String>, fields: NativeArray<String>, wrapper: Null<Any> = null) {
    this.wrapper = wrapper;
    this.mode = MpnSubscriptionMode.fromString(mode);
    this.madeByServer = false;
    initItemsAndFields(items, fields);
  }

  overload public function new(mode: String, wrapper: Null<Any> = null) {
    this.wrapper = wrapper;
    this.mode = MpnSubscriptionMode.fromString(mode);
    this.madeByServer = false;
  }

  overload public function new(mode: String, item: String, fields: NativeArray<String>, wrapper: Null<Any> = null) {
    this.wrapper = wrapper;
    this.mode = MpnSubscriptionMode.fromString(mode);
    this.madeByServer = false;
    initItemsAndFields([item], fields);
  }

  overload public function new(subscription: Subscription, wrapper: Null<Any> = null) {
    this.wrapper = wrapper;
    this.mode = MpnSubscriptionMode.fromString(subscription.getMode());
    this.madeByServer = false;
    initFromSubscription(subscription);
  }

  overload public function new(mpnSubscription: MpnSubscription, wrapper: Null<Any> = null) {
    this.wrapper = wrapper;
    this.mode = mpnSubscription.mode;
    this.madeByServer = false;
    initFromMpnSubscription(mpnSubscription);
  }
  #end

  // NB emulate constructor overloading: call it immediately after the constructor
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function reInit(mpnSubId: String) {
    m_mpnSubId = mpnSubId;
    madeByServer = true;
  }

  function initFromSubscription(subscription: Subscription) {
    var _items = subscription.getItems();
    var _fields = subscription.getFields();
    this.items = _items != null ? Items.fromArray(_items) : null;
    this.group = Name.fromString(subscription.getItemGroup());
    this.fields = _fields != null ? Fields.fromArray(_fields) : null;
    this.schema = Name.fromString(subscription.getFieldSchema());
    this.dataAdapter = Name.fromString(subscription.getDataAdapter());
    this.bufferSize = RequestedBufferSizeTools.fromString(subscription.getRequestedBufferSize());
    this.requestedMaxFrequency = MpnRequestedMaxFrequencyTools.fromString(subscription.getRequestedMaxFrequency());
  }

  function initFromMpnSubscription(mpnSubscription: MpnSubscription) {
    this.items = mpnSubscription.items;
    this.group = mpnSubscription.group;
    this.fields = mpnSubscription.fields;
    this.schema = mpnSubscription.schema;
    this.dataAdapter = mpnSubscription.dataAdapter;
    this.bufferSize = mpnSubscription.bufferSize;
    this.requestedMaxFrequency = mpnSubscription.requestedMaxFrequency;
    this.requestedFormat = mpnSubscription.requestedFormat;
    this.requestedTrigger = mpnSubscription.requestedTrigger;
  }

  function initItemsAndFields(items: NativeArray<String>, fields: NativeArray<String>) {
    if (items != null) {
      if (fields == null) {
        throw new IllegalArgumentException("Please specify a valid field list");
      }
      this.items = Items.fromArray(items.toHaxe());
      this.fields = Fields.fromArray(fields.toHaxe());
    } else if (fields != null) {
      throw new IllegalArgumentException("Please specify a valid item or item list");
    }
  }

  public function addListener(listener: MpnSubscriptionListener): Void {
    eventDispatcher.addListenerAndFireOnListenStart(listener);
  }
  public function removeListener(listener: MpnSubscriptionListener): Void {
    eventDispatcher.removeListenerAndFireOnListenEnd(listener);
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
  @:unsynchronized
  public function setTriggerExpression(expr: Null<String>): Void {
    var _manager;
    lock.synchronized(() -> {
      this.requestedTrigger = TriggerExpression.fromString(expr);
      _manager = m_manager;
    });
    if (_manager != null) {
      _manager.evtExtMpnSetTrigger();
    }
  }
  public function getActualTriggerExpression(): Null<String> {
    return realTrigger;
  }

  public function getNotificationFormat(): Null<String> {
    return requestedFormat;
  }
  @:unsynchronized
  public function setNotificationFormat(format: Null<String>): Void {
    var _manager;
    lock.synchronized(() -> {
      this.requestedFormat = NotificationFormat.fromString(format);
      _manager = m_manager;
    });
    if (_manager != null) {
      _manager.evtExtMpnSetFormat();
    }
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
    #if !static
    size = size == null ? size : Std.string(size);
    #end
    checkActive();
    this.bufferSize = RequestedBufferSizeTools.fromString(size);
  }

  public function getRequestedMaxFrequency(): Null<String> {
    return requestedMaxFrequency.toString();
  }
  public function setRequestedMaxFrequency(freq: Null<String>): Void {
    #if !static
    freq = freq == null ? freq : Std.string(freq);
    #end
    checkActive();
    this.requestedMaxFrequency = MpnRequestedMaxFrequencyTools.fromString(freq);
  }

  public function isActive(): Bool {
    return m_status != Unknown;
  }
  public function isSubscribed(): Bool {
    return m_status == Subscribed;
  }
  public function isTriggered(): Bool {
    return m_status == Triggered;
  }

  public function getStatus(): String {
    return switch m_status {
      case Unknown: "UNKNOWN";
      case Active: "ACTIVE";
      case Subscribed: "SUBSCRIBED";
      case Triggered: "TRIGGERED";
    }
  }

  public function getStatusTimestamp(): Long {
    return m_statusTs;
  }

  public function getSubscriptionId(): Null<String> {
    return m_mpnSubId;
  }

  function checkActive() {
    if (isActive()) {
      throw new IllegalStateException("Cannot modify an active MpnSubscription. Please unsubscribe before applying any change");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function setSubscriptionId(mpnSubId: String) {
    m_mpnSubId = mpnSubId;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function changeStatus(status: MpnSubscriptionStatus, statusTs: Null<String>) {
    var statusTs = statusTs == null ? m_statusTs : new Timestamp(parseLong(statusTs));
    if (status != m_status) {
      m_status = status;
      eventDispatcher.onStatusChanged(getStatus(), statusTs);
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function changeStatusTs(rawStatusTs: Null<String>) {
    if (rawStatusTs == null) {
      return;
    }
    var statusTs = new Timestamp(parseLong(rawStatusTs));
    if (statusTs != m_statusTs) {
      m_statusTs = statusTs;
      fireOnPropertyChange("status_timestamp");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function changeMode(rawMode: Null<String>) {
    if (rawMode == null) {
      return;
    }
    var _mode = MpnSubscriptionMode.fromString(rawMode);
    if (mode != _mode) {
      mode = _mode;
      fireOnPropertyChange("mode");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function changeGroup(_group: Null<String>) {
    if (_group == null) {
      return;
    }
    if (group != _group) {
      group = new Name(_group);
      items = null;
      fireOnPropertyChange("group");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function changeSchema(_schema: Null<String>) {
    if (_schema == null) {
      return;
    }
    if (schema != _schema) {
      schema = new Name(_schema);
      fields = null;
      fireOnPropertyChange("schema");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function changeAdapter(_adapter: Null<String>) {
    if (dataAdapter != _adapter) {
      dataAdapter = _adapter != null ? new Name(_adapter) : null;
      fireOnPropertyChange("adapter");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function changeFormat(_format: Null<String>) {
    if (_format == null) {
      return;
    }
    if (_format != realFormat) {
      realFormat = new NotificationFormat(_format);
      fireOnPropertyChange("notification_format");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function changeTrigger(_trigger: Null<String>) {
    if (_trigger != realTrigger) {
      realTrigger = _trigger != null ? new TriggerExpression(_trigger) : null;
      fireOnPropertyChange("trigger");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function changeBufferSize(rawBufferSize: Null<String>) {
    var _bufferSize = RequestedBufferSizeTools.fromString(rawBufferSize);
    if (!RequestedBufferSizeTools.extEquals(bufferSize, _bufferSize)) {
      bufferSize = _bufferSize;
      fireOnPropertyChange("requested_buffer_size");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function changeMaxFrequency(rawFrequency: Null<String>) {
    var maxFreq = MpnRequestedMaxFrequencyTools.fromString(rawFrequency);
    if (!MpnRequestedMaxFrequencyTools.extEquals(maxFreq, requestedMaxFrequency)) {
      requestedMaxFrequency = maxFreq;
      fireOnPropertyChange("requested_max_frequency");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function reset() {
    realFormat = null;
    realTrigger = null;
    m_statusTs = new Timestamp(0);
    m_mpnSubId = null;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fireOnSubscription() {
    mpnSubscriptionLogger.logInfo('${madeByServer ? "Server " : ""}MPNSubscription subscribed: pnSubId: $m_mpnSubId');
    eventDispatcher.onSubscription();
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fireOnUnsubscription() {
    mpnSubscriptionLogger.logInfo('${madeByServer ? "Server " : ""}MPNSubscription unsubscribed: pnSubId: $m_mpnSubId');
    eventDispatcher.onUnsubscription();
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fireOnTriggered() {
    mpnSubscriptionLogger.logInfo('${madeByServer ? "Server " : ""}MPNSubscription triggered: pnSubId: $m_mpnSubId');
    eventDispatcher.onTriggered();
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fireOnSubscriptionError(code: Int, msg: String) {
    mpnSubscriptionLogger.logWarn('${madeByServer ? "Server " : ""}MPNSubscription error: $code - $msg pnSubId: $m_mpnSubId');
    eventDispatcher.onSubscriptionError(code, msg);
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fireOnUnsubscriptionError(code: Int, msg: String) {
    mpnSubscriptionLogger.logWarn('${madeByServer ? "Server " : ""}MPNSubscription unsubscription error: $code - $msg pnSubId: $m_mpnSubId');
    eventDispatcher.onUnsubscriptionError(code, msg);
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fireOnModificationError(code: Int, message: String, property: String) {
    mpnSubscriptionLogger.logWarn('${madeByServer ? "Server " : ""}MPNSubscription $property modification error: $code - $message pnSubId: $m_mpnSubId');
    eventDispatcher.onModificationError(code, message, property);
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fireOnPropertyChange(property: String) {
    if (mpnSubscriptionLogger.isInfoEnabled()) {
      var propVal: String;
      switch property {
      case "mode":
        propVal = 'newValue: $mode';
      case "group":
        propVal = 'newValue: $group';
      case "schema":
        propVal = 'newValue: $schema';
      case "adapter":
        propVal = 'newValue: $dataAdapter';
      case "notification_format":
        propVal = 'newValue: $realFormat';
      case "trigger":
        propVal = 'newValue: $realTrigger';
      case "requested_buffer_size":
        propVal = 'newValue: ${bufferSize.toString()}';
      case "requested_max_frequency":
        propVal = 'newValue: ${requestedMaxFrequency.toString()}';
      case "status_timestamp":
        propVal = "";
      default:
        propVal = "";
      }
      // don't log timestamp: it's too verbose;
      if (property != "status_timestamp") {
        mpnSubscriptionLogger.logInfo('${madeByServer ? "Server " : ""}MPNSubscription $property changed: $propVal pnSubId: ${m_mpnSubId != null ? m_mpnSubId : "n.a."}');
      }
    }
    eventDispatcher.onPropertyChanged(property);
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  @:allow(com.lightstreamer.client.internal.MpnClientMachine)
  function fetch_subManager(): Null<MpnSubscriptionManager> {
    return m_manager;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnClientMachine)
  function fetch_status(): MpnSubscriptionStatus {
    return m_status;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnClientMachine)
  function fetch_madeByServer(): Bool {
    return madeByServer;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fetch_mpnSubId(): Null<String> {
    return m_mpnSubId;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fetch_requestedBufferSize(): Null<RequestedBufferSize> {
    return bufferSize;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fetch_mode(): Null<MpnSubscriptionMode> {
    return mode;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fetch_requestedMaxFrequency(): Null<MpnRequestedMaxFrequency> {
    return requestedMaxFrequency;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fetch_requestedFormat(): Null<String> {
    return requestedFormat;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fetch_requestedTrigger(): Null<String> {
    return requestedTrigger;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function relate(_manager: MpnSubscriptionManager) {
    m_manager = _manager;
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function unrelate(_manager: MpnSubscriptionManager) {
    if (_manager != m_manager) {
      return;
    }
    m_manager = null;
  }

  public function toString(): String {
    var map = new InfoMap();
    map["mode"] = mode;
    map["items"] = items != null ? Std.string(items) : group;
    map["fields"] = fields != null ? Std.string(fields) : schema;
    map["dataAdapter"] = dataAdapter;
    map["requestedBufferSize"] = bufferSize;
    map["requestedMaxFrequency"] = requestedMaxFrequency;
    map["trigger"] = requestedTrigger;
    map["notificationFormat"] = requestedFormat;
    return map.toString();
  }
}