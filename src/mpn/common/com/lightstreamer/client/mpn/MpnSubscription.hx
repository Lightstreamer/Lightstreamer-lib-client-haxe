package com.lightstreamer.client.mpn;

#if (js || python) @:expose @:native("MpnSubscription") #end
class MpnSubscription {

  #if android
  public function new(appContext: android.content.Context) {
    var pkg = com.lightstreamer.client.mpn.AndroidUtils.getPackageName(appContext);
    trace("MPNSub.new", pkg);
  }
  #end

  public function addListener(listener: MpnSubscriptionListener): Void {}
  public function removeListener(listener: MpnSubscriptionListener): Void {}
  public function getListeners(): Array<MpnSubscriptionListener> {
    return null;
  }
  public function getNotificationFormat(): String {
    return null;
  }
  public function setNotificationFormat(format: String): Void {}
  public function getTriggerExpression(): String {
    return null;
  }
  public function setTriggerExpression(expr: String): Void {}
  public function isActive(): Bool {
    return false;
  }
  public function isSubscribed(): Bool {
    return false;
  }
  public function isTriggered(): Bool {
    return false;
  }
  public function getStatus(): String {
    return null;
  }
  public function getStatusTimestamp(): Long {
    return 0;
  }
  public function getItems(): Array<String> {
    return null;
  }
  public function setItems(items: Array<String>): Void {}
  public function setItemGroup(groupName: String): Void {}
  public function getItemGroup(): String {
    return null;
  }
  public function getFields(): Array<String> {
    return null;
  }
  public function setFields(fields: Array<String>): Void {}
  public function setFieldSchema(schemaName: String): Void {}
  public function getFieldSchema(): String {
    return null;
  }
  public function setDataAdapter(dataAdapter: String): Void {}
  public function getDataAdapter(): String {
    return null;
  }
  public function setRequestedBufferSize(size: String): Void {}
  public function getRequestedBufferSize(): String {
    return null;
  }
  public function setRequestedMaxFrequency(freq: String): Void {}
  public function getRequestedMaxFrequency(): String {
    return null;
  }
  public function getMode(): String {
    return null;
  }
  public function getSubscriptionId(): String {
    return null;
  }
}