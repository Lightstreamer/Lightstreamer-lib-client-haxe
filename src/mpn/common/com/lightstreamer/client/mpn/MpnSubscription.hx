package com.lightstreamer.client.mpn;

import com.lightstreamer.client.internal.MpnSubscriptionManager;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.EventDispatcher;
import com.lightstreamer.client.mpn.Types;
import com.lightstreamer.client.internal.ParseTools;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

enum MpnSubscriptionStatus {
  Unknown; Active; Subscribed; Triggered;
}

private class MpnSubscriptionEventDispatcher extends EventDispatcher<MpnSubscriptionListener> {}

#if (js || python) @:expose @:native("MpnSubscription") #end
#if (java || cs || python) @:nativeGen #end
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class MpnSubscription {
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

  // #if android
  // public function new(appContext: android.content.Context) {
  //   var pkg = com.lightstreamer.client.mpn.AndroidUtils.getPackageName(appContext);
  //   trace("MPNSub.new", pkg);
  // }
  // #end

  // TODO implement overloaded constructors
  public function new(mode: String, items: Null<NativeArray<String>>, fields: Null<NativeArray<String>>) {
    if (items != null) {
      this.items = Items.fromArray(items.toHaxe());
    }
    if (fields != null) {
      this.fields = Fields.fromArray(fields.toHaxe());
    }
    this.mode = MpnSubscriptionMode.fromString(mode);
    this.madeByServer = false;
  }

  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function reInit(mpnSubId: String) {
    m_mpnSubId = mpnSubId;
    madeByServer = true;
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
    var statusTs = statusTs == null ? m_statusTs : new Timestamp(parseInt(statusTs));
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
    var statusTs = new Timestamp(parseInt(rawStatusTs));
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
    if (!RequestedBufferSizeTools.equals(bufferSize, _bufferSize)) {
      bufferSize = _bufferSize;
      fireOnPropertyChange("requested_buffer_size");
    }
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function changeMaxFrequency(rawFrequency: Null<String>) {
    var maxFreq = MpnRequestedMaxFrequencyTools.fromString(rawFrequency);
    if (!MpnRequestedMaxFrequencyTools.equals(maxFreq, requestedMaxFrequency)) {
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
        mpnSubscriptionLogger.info('${madeByServer ? "Server " : ""}MPNSubscription $property changed: $propVal pnSubId: ${m_mpnSubId != null ? m_mpnSubId : "n.a."}');
      }
    }
    eventDispatcher.onPropertyChanged(property);
  }

  @:synchronized
  @:allow(com.lightstreamer.client.internal.MpnSubscriptionManager)
  function fetch_subManager(): Null<MpnSubscriptionManager> {
    return m_manager;
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
}