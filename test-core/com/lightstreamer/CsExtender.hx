package com.lightstreamer;

import com.lightstreamer.client.*;
import com.lightstreamer.internal.NativeTypes;

@:publicFields
class CsExtender {
  static function setForcedTransport(obj: ConnectionOptions, value: String) {
    obj.ForcedTransport = value;
  }

  static function setPollingInterval(obj: ConnectionOptions, value: Long) {
    obj.PollingInterval = value;
  }

  static function setIdleTimeout(obj: ConnectionOptions, value: Long) {
    obj.IdleTimeout = value;
  }

  static function setRequestedMaxBandwidth(obj: ConnectionOptions, value: String) {
    obj.RequestedMaxBandwidth = value;
  }

  static function setHttpExtraHeaders(obj: ConnectionOptions, value: NativeStringMap<String>) {
    obj.HttpExtraHeaders = value;
  }

  static function getHttpExtraHeaders(obj: ConnectionOptions): NativeStringMap<String> {
    return obj.HttpExtraHeaders;
  }

  static function getRequestedMaxBandwidth(obj: ConnectionOptions): String {
    return obj.RequestedMaxBandwidth;
  }

  static function getRealMaxBandwidth(obj: ConnectionOptions): String {
    return obj.RealMaxBandwidth;
  }

  static function getContentLength(obj: ConnectionOptions): Long {
    return obj.ContentLength;
  }

  static function getRetryDelay(obj: ConnectionOptions): Long {
    return obj.RetryDelay;
  }

  static function getSessionRecoveryTimeout(obj: ConnectionOptions): Long {
    return obj.SessionRecoveryTimeout;
  }

  static function getKeepaliveInterval(obj: ConnectionOptions): Long {
    return obj.KeepaliveInterval;
  }

  static function getIdleTimeout(obj: ConnectionOptions): Long {
    return obj.IdleTimeout;
  }

  static function getPollingInterval(obj: ConnectionOptions): Long {
    return obj.PollingInterval;
  }

  static function getStatus(obj: LightstreamerClient): String {
    return obj.Status;
  }

  overload static function getListeners(obj: LightstreamerClient): NativeList<ClientListener> {
    return obj.Listeners;
  }

  static function getSubscriptions(obj: LightstreamerClient): NativeList<Subscription> {
    return obj.Subscriptions;
  }

  overload static function getListeners(obj: Subscription): NativeList<SubscriptionListener> {
    return obj.Listeners;
  }

  static function isSubscribed(obj: Subscription): Bool {
    return obj.Subscribed;
  }

  static function setCommandSecondLevelFields(obj: Subscription, fields: Null<NativeArray<String>>){
    obj.CommandSecondLevelFields = fields;
  }

  static function setDataAdapter(obj: Subscription, value: String) {
    obj.DataAdapter = value;
  }

  static function getKeyPosition(obj: Subscription): Int {
    return obj.KeyPosition;
  }

  static function getCommandPosition(obj: Subscription): Int {
    return obj.CommandPosition;
  }

  static function setCommandSecondLevelDataAdapter(obj: Subscription, value: String) {
    obj.CommandSecondLevelDataAdapter = value;
  }

  static function setRequestedSnapshot(obj: Subscription, value: String) {
    obj.RequestedSnapshot = value;
  }

  static function setRequestedMaxFrequency(obj: Subscription, value: String) {
    obj.RequestedMaxFrequency = value;
  }

  static function isActive(obj: Subscription): Bool {
    return obj.Active;
  }

  static function getDataAdapter(obj: Subscription): String {
    return obj.DataAdapter;
  }

  static function getMode(obj: Subscription): String {
    return obj.Mode;
  }

  static function getClientIp(obj: ConnectionDetails): String {
    return obj.ClientIp;
  }

  static function getServerSocketName(obj: ConnectionDetails): String {
    return obj.ServerSocketName;
  }

  static function getSessionId(obj: ConnectionDetails): String {
    return obj.SessionId;
  }

  static function getAdapterSet(obj: ConnectionDetails): String {
    return obj.AdapterSet;
  }

  static function getServerAddress(obj: ConnectionDetails): String {
    return obj.ServerAddress;
  }
}