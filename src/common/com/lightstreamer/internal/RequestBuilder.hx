package com.lightstreamer.internal;

import com.lightstreamer.internal.NativeTypes.Long;
using StringTools;

class RequestBuilder {
  final params: Array<String> = [];

  public inline function new() {}

  public function LS_reqId(val: Int) {
    addParam("LS_reqId", val);
  }

  public function LS_message(val: String) {
    addParam("LS_message", val);
  }

  public function LS_sequence(val: String) {
    addParam("LS_sequence", val);
  }

  public function LS_msg_prog(val: Int) {
    addParam("LS_msg_prog", val);
  }

  public function LS_max_wait(val: Int) {
    addParam("LS_max_wait", val);
  }

  public function LS_outcome(val: Bool) {
    addParam("LS_outcome", val);
  }

  public function LS_ack(val: Bool) {
    addParam("LS_ack", val);
  }

  public function LS_op(val: String) {
    addParam("LS_op", val);
  }

  public function LS_subId(val: Int) {
    addParam("LS_subId", val);
  }

  public function LS_mode(val: String) {
    addParam("LS_mode", val);
  }

  public function LS_group(val: String) {
    addParam("LS_group", val);
  }

  public function LS_schema(val: String) {
    addParam("LS_schema", val);
  }

  public function LS_data_adapter(val: String) {
    addParam("LS_data_adapter", val);
  }

  public function PN_deviceId(val: String) {
    addParam("PN_deviceId", val);
  }

  public function PN_notificationFormat(val: String) {
    addParam("PN_notificationFormat", val);
  }

  public function PN_trigger(val: String) {
    addParam("PN_trigger", val);
  }

  public function PN_coalescing(val: Bool) {
    addParam("PN_coalescing", val);
  }

  public function LS_requested_max_frequency(val: String) {
    addParam("LS_requested_max_frequency", val);
  }

  public function LS_requested_max_frequency_Float(val: Float) {
    addParam("LS_requested_max_frequency", val);
  }

  public function LS_requested_buffer_size(val: String) {
    addParam("LS_requested_buffer_size", val);
  }

  public function LS_requested_buffer_size_Int(val: Int) {
    addParam("LS_requested_buffer_size", val);
  }

  public function PN_subscriptionId(val: String) {
    addParam("PN_subscriptionId", val);
  }

  public function PN_type(val: String) {
    addParam("PN_type", val);
  }

  public function PN_appId(val: String) {
    addParam("PN_appId", val);
  }

  public function PN_deviceToken(val: String) {
    addParam("PN_deviceToken", val);
  }

  public function PN_newDeviceToken(val: String) {
    addParam("PN_newDeviceToken", val);
  }

  public function PN_subscriptionStatus(val: String) {
    addParam("PN_subscriptionStatus", val);
  }

  public function LS_cause(val: String) {
    addParam("LS_cause", val);
  }

  public function LS_keepalive_millis(val: Int) {
    addParam("LS_keepalive_millis", val);
  }

  public function LS_inactivity_millis(val: Int) {
    addParam("LS_inactivity_millis", val);
  }

  public function LS_requested_max_bandwidth(val: String) {
    addParam("LS_requested_max_bandwidth", val);
  }

  public function LS_requested_max_bandwidth_Float(val: Float) {
    addParam("LS_requested_max_bandwidth", val);
  }

  public function LS_adapter_set(val: String) {
    addParam("LS_adapter_set", val);
  }

  public function LS_user(val: String) {
    addParam("LS_user", val);
  }

  public function LS_password(val: String) {
    addParam("LS_password", val);
  }

  public function LS_cid(val: String) {
    addParam("LS_cid", val);
  }

  public function LS_old_session(val: String) {
    addParam("LS_old_session", val);
  }

  public function LS_session(val: String) {
    addParam("LS_session", val);
  }

  public function LS_send_sync(val: Bool) {
    addParam("LS_send_sync", val);
  }

  public function LS_polling(val: Bool) {
    addParam("LS_polling", val);
  }

  public function LS_polling_millis(val: Int) {
    addParam("LS_polling_millis", val);
  }

  public function LS_idle_millis(val: Int) {
    addParam("LS_idle_millis", val);
  }

  public function LS_content_length(val: Long) {
    addParamAny("LS_content_length", val);
  }

  public function LS_ttl_millis(val: String) {
    addParam("LS_ttl_millis", val);
  }

  public function LS_recovery_from(val: Int) {
    addParam("LS_recovery_from", val);
  }

  public function LS_close_socket(val: Bool) {
    addParam("LS_close_socket", val);
  }

  public function LS_selector(val: String) {
    addParam("LS_selector", val);
  }

  public function LS_snapshot(val: Bool) {
    addParam("LS_snapshot", val);
  }

  public function LS_snapshot_Int(val: Int) {
    addParam("LS_snapshot", val);
  }

  overload inline extern function addParam(key: String, val: String) {
    addParamString(key, val);
  }

  overload inline extern function addParam(key: String, val: Int) {
    addParamAny(key, val);
  }

  overload inline extern function addParam(key: String, val: Float) {
    addParamAny(key, val);
  }

  overload inline extern function addParam(key: String, val: Bool) {
    addParamBool(key, val);
  }

  function addParamString(key: String, val: String) {
    params.push(key.urlEncode() + "=" + val.urlEncode());
  }

  function addParamAny(key: String, val: Any) {
    addParamString(key, '$val');
  }

  function addParamBool(key: String, val: Bool) {
    addParamString(key, val ? "true" : "false");
  }

  public function getEncodedString() {
    return params.join("&");
  }
}