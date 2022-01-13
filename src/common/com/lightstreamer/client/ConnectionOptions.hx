package com.lightstreamer.client;

import com.lightstreamer.client.Types;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

@:nativeGen
class ConnectionOptions {
  // TODO synchronize methods
  // TODO fire property listeners
  var contentLength: ContentLength = new ContentLength(50000000);
  var firstRetryMaxDelay: Millis = new Millis(100);
  var forcedTransport: Null<TransportSelection> = null;
  var httpExtraHeaders: Null<Map<String, String>> = null;
  var idleTimeout: Millis = new Millis(19000);
  var keepaliveInterval: Millis = new Millis(0);
  var requestedMaxBandwidth: RequestedMaxBandwidth = BWUnlimited;
  var realMaxBandwidth: Null<RealMaxBandwidth> = null;
  var pollingInterval: Millis = new Millis(0);
  var reconnectTimeout: Millis = new Millis(3000);
  var retryDelay: Millis = new Millis(4000);
  var reverseHeartbeatInterval: Millis = new Millis(0);
  var sessionRecoveryTimeout: Millis = new Millis(15000);
  var stalledTimeout: Millis = new Millis(2000);
  var httpExtraHeadersOnSessionCreationOnly: Bool = false;
  var serverInstanceAddressIgnored: Bool = false;
  var slowingEnabled: Bool = false;
  
  public function new() {}
  
  public function getContentLength(): Long {
    return contentLength;
  }
  public function setContentLength(contentLength: Long): Void {
    var newValue = ContentLength.fromIntGt0(contentLength);
    actionLogger.info('contentLength changed: $newValue');
    this.contentLength = newValue;
  }

  public function getFirstRetryMaxDelay(): Long {
    return firstRetryMaxDelay;
  }
  public function setFirstRetryMaxDelay(firstRetryMaxDelay: Long): Void {
    var newValue = Millis.fromIntGt0(firstRetryMaxDelay);
    actionLogger.info('firstRetryMaxDelay changed: $newValue');
    this.firstRetryMaxDelay = newValue;
  }

  public function getForcedTransport(): Null<String> {
    return forcedTransport;
  }
  public function setForcedTransport(forcedTransport: Null<String>): Void {
    var newValue = TransportSelection.fromString(forcedTransport);
    actionLogger.info('forcedTransport changed: $newValue');
    this.forcedTransport = newValue;
    // TODO forward to client
  }

  public function getHttpExtraHeaders(): Null<Map<String, String>> {
    return httpExtraHeaders;
  }
  public function setHttpExtraHeaders(httpExtraHeaders: Null<Map<String, String>>): Void {
    actionLogger.info('httpExtraHeaders changed: $httpExtraHeaders');
    this.httpExtraHeaders = httpExtraHeaders;
  }

  public function getIdleTimeout(): Long {
    return idleTimeout;
  }
  public function setIdleTimeout(idleTimeout: Long): Void {
    var newValue = Millis.fromIntGtEq0(idleTimeout);
    actionLogger.info('idleTimeout changed: $newValue');
    this.idleTimeout = newValue;
  }

  public function getKeepaliveInterval(): Long {
    return keepaliveInterval;
  }
  public function setKeepaliveInterval(keepaliveInterval: Long): Void {
    var newValue = Millis.fromIntGtEq0(keepaliveInterval);
    actionLogger.info('keepaliveInterval changed: $newValue');
    this.keepaliveInterval = newValue;
  }

  public function getRequestedMaxBandwidth(): String {
    return requestedMaxBandwidth.toString();
  }
  public function setRequestedMaxBandwidth(maxBandwidth: String): Void {
    var newValue = RequestedMaxBandwidthTools.fromString(maxBandwidth);
    actionLogger.info('keepaliveInterval changed: ${newValue.toString()}');
    this.requestedMaxBandwidth = newValue;
    // TODO forward to client
  }

  public function getRealMaxBandwidth(): Null<String> {
    return realMaxBandwidth == null ? null : realMaxBandwidth.toString();
  }

  public function getPollingInterval(): Long {
    return pollingInterval;
  }
  public function setPollingInterval(pollingInterval: Long): Void {
    var newValue = Millis.fromIntGtEq0(pollingInterval);
    actionLogger.info('pollingInterval changed: $newValue');
    this.pollingInterval = newValue;
  }

  public function getReconnectTimeout(): Long {
    return reconnectTimeout;
  }
  public function setReconnectTimeout(reconnectTimeout: Long): Void {
    var newValue = Millis.fromIntGt0(reconnectTimeout);
    actionLogger.info('reconnectTimeout changed: $newValue');
    this.reconnectTimeout = newValue;
  }

  public function getRetryDelay(): Long {
    return retryDelay;
  }
  public function setRetryDelay(retryDelay: Long): Void {
    var newValue = Millis.fromIntGt0(retryDelay);
    actionLogger.info('retryDelay changed: $newValue');
    this.retryDelay = newValue;
  }

  public function getReverseHeartbeatInterval(): Long {
    return reverseHeartbeatInterval;
  }
  public function setReverseHeartbeatInterval(reverseHeartbeatInterval: Long): Void {
    var newValue = Millis.fromIntGtEq0(reverseHeartbeatInterval);
    actionLogger.info('reverseHeartbeatInterval changed: $newValue');
    this.reverseHeartbeatInterval = newValue;
    // TODO forward to client
  }

  public function getSessionRecoveryTimeout(): Long {
    return sessionRecoveryTimeout;
  }
  public function setSessionRecoveryTimeout(sessionRecoveryTimeout: Long): Void {
    var newValue = Millis.fromIntGtEq0(sessionRecoveryTimeout);
    actionLogger.info('sessionRecoveryTimeout changed: $newValue');
    this.sessionRecoveryTimeout = newValue;
  }

  public function getStalledTimeout(): Long {
    return stalledTimeout;
  }
  public function setStalledTimeout(stalledTimeout: Long): Void {
    var newValue = Millis.fromIntGt0(stalledTimeout);
    actionLogger.info('stalledTimeout changed: $newValue');
    this.stalledTimeout = newValue;
  }

  public function isHttpExtraHeadersOnSessionCreationOnly(): Bool {
    return httpExtraHeadersOnSessionCreationOnly;
  }
  public function setHttpExtraHeadersOnSessionCreationOnly(httpExtraHeadersOnSessionCreationOnly: Bool): Void {
    actionLogger.info('httpExtraHeadersOnSessionCreationOnly changed: $httpExtraHeadersOnSessionCreationOnly');
    this.httpExtraHeadersOnSessionCreationOnly = httpExtraHeadersOnSessionCreationOnly;
  }

  public function isServerInstanceAddressIgnored(): Bool {
    return serverInstanceAddressIgnored;
  }
  public function setServerInstanceAddressIgnored(serverInstanceAddressIgnored: Bool): Void {
    actionLogger.info('serverInstanceAddressIgnored changed: $serverInstanceAddressIgnored');
    this.serverInstanceAddressIgnored = serverInstanceAddressIgnored;
  }

  public function isSlowingEnabled(): Bool {
    return slowingEnabled;
  }
  public function setSlowingEnabled(slowingEnabled: Bool): Void {
    actionLogger.info('slowingEnabled changed: $slowingEnabled');
    this.slowingEnabled = slowingEnabled;
  }

  // TODO javase Proxy
  // public function setProxy(proxy: Proxy): Void {}
}