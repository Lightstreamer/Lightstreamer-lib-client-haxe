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
package com.lightstreamer.client;

import com.lightstreamer.internal.InfoMap;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.Types;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

#if (js || python) @:expose @:native("LSConnectionOptions") #end
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
@:access(com.lightstreamer.client)
class LSConnectionOptions {
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
  #if js
  var cookieHandlingRequired: Bool = false;
  #end
  final client: LightstreamerClient;
  final lock: com.lightstreamer.internal.RLock;
  
  public function new(client: LightstreamerClient) {
    this.client = client;
    this.lock = client.lock;
  }
  
  public function getContentLength(): Long {
    return contentLength;
  }
  public function setContentLength(contentLength: Long): Void {
    var newValue = ContentLength.fromIntGt0(contentLength);
    if (newValue == this.contentLength) {
      return;
    }
    actionLogger.logInfo('contentLength changed: $newValue');
    this.contentLength = newValue;
    client.eventDispatcher.onPropertyChange("contentLength");
  }

  public function getFirstRetryMaxDelay(): Long {
    return firstRetryMaxDelay;
  }
  public function setFirstRetryMaxDelay(firstRetryMaxDelay: Long): Void {
    var newValue = Millis.fromIntGt0(firstRetryMaxDelay);
    if (newValue == this.firstRetryMaxDelay) {
      return;
    }
    actionLogger.logInfo('firstRetryMaxDelay changed: $newValue');
    this.firstRetryMaxDelay = newValue;
    client.eventDispatcher.onPropertyChange("firstRetryMaxDelay");
  }

  public function getForcedTransport(): Null<String> {
    return forcedTransport;
  }
  public function setForcedTransport(forcedTransport: Null<String>): Void {
    var newValue = TransportSelection.fromString(forcedTransport);
    if (newValue == this.forcedTransport) {
      return;
    }
    actionLogger.logInfo('forcedTransport changed: $newValue');
    this.forcedTransport = newValue;
    client.eventDispatcher.onPropertyChange("forcedTransport");
    client.machine.evtExtSetForcedTransport();
  }

  public function getHttpExtraHeaders(): Null<NativeStringMap<String>> {
    return httpExtraHeaders == null ? null : new NativeStringMap<String>(httpExtraHeaders);
  }
  public function setHttpExtraHeaders(httpExtraHeaders: Null<NativeStringMap<String>>): Void {
    var newValue = httpExtraHeaders?.toHaxe();
    if (mapEq(newValue, this.httpExtraHeaders)) {
      return;
    }
    actionLogger.logInfo('httpExtraHeaders changed: $newValue');
    this.httpExtraHeaders = newValue;
    client.eventDispatcher.onPropertyChange("httpExtraHeaders");
  }

  function mapEq(m1: Null<Map<String, String>>, m2: Null<Map<String, String>>) {
    if (m1 == m2) {
      return true;
    }
    if (m1 == null || m2 == null) {
      return false;
    }
    if (Lambda.count(m1) != Lambda.count(m2)){
      return false;
    }
    for (k => v in m1) {
      if (v != m2[k]) {
        return false;
      }
    }
    return true;
  }

  public function getIdleTimeout(): Long {
    return idleTimeout;
  }
  public function setIdleTimeout(idleTimeout: Long): Void {
    var newValue = Millis.fromIntGtEq0(idleTimeout);
    if (newValue == this.idleTimeout) {
      return;
    }
    actionLogger.logInfo('idleTimeout changed: $newValue');
    this.idleTimeout = newValue;
    client.eventDispatcher.onPropertyChange("idleTimeout");
  }

  public function getKeepaliveInterval(): Long {
    return keepaliveInterval;
  }
  public function setKeepaliveInterval(keepaliveInterval: Long): Void {
    var newValue = Millis.fromIntGtEq0(keepaliveInterval);
    if (newValue == this.keepaliveInterval) {
      return;
    }
    actionLogger.logInfo('keepaliveInterval changed: $newValue');
    this.keepaliveInterval = newValue;
    client.eventDispatcher.onPropertyChange("keepaliveInterval");
  }

  public function getRequestedMaxBandwidth(): String {
    return requestedMaxBandwidth.toString();
  }
  public function setRequestedMaxBandwidth(maxBandwidth: String): Void {
    #if !static
    maxBandwidth = maxBandwidth == null ? maxBandwidth : Std.string(maxBandwidth);
    #end
    var newValue = RequestedMaxBandwidthTools.fromString(maxBandwidth);
    if (newValue.equals(this.requestedMaxBandwidth)) {
      return;
    }
    actionLogger.logInfo('requestedMaxBandwidth changed: ${newValue.toString()}');
    this.requestedMaxBandwidth = newValue;
    client.eventDispatcher.onPropertyChange("requestedMaxBandwidth");
    client.machine.evtExtSetRequestedMaxBandwidth();
  }

  public function getRealMaxBandwidth(): Null<String> {
    return realMaxBandwidth.toString();
  }

  function setRealMaxBandwidth(newValue: Null<RealMaxBandwidth>) {
    if (newValue.eq(this.realMaxBandwidth)) {
      return;
    }
    realMaxBandwidth = newValue;
    client.eventDispatcher.onPropertyChange("realMaxBandwidth");
  }

  public function getPollingInterval(): Long {
    return pollingInterval;
  }
  public function setPollingInterval(pollingInterval: Long): Void {
    var newValue = Millis.fromIntGtEq0(pollingInterval);
    if (newValue == this.pollingInterval) {
      return;
    }
    actionLogger.logInfo('pollingInterval changed: $newValue');
    this.pollingInterval = newValue;
    client.eventDispatcher.onPropertyChange("pollingInterval");
  }

  public function getReconnectTimeout(): Long {
    return reconnectTimeout;
  }
  public function setReconnectTimeout(reconnectTimeout: Long): Void {
    var newValue = Millis.fromIntGt0(reconnectTimeout);
    if (newValue == this.reconnectTimeout) {
      return;
    }
    actionLogger.logInfo('reconnectTimeout changed: $newValue');
    this.reconnectTimeout = newValue;
    client.eventDispatcher.onPropertyChange("reconnectTimeout");
  }

  public function getRetryDelay(): Long {
    return retryDelay;
  }
  public function setRetryDelay(retryDelay: Long): Void {
    var newValue = Millis.fromIntGt0(retryDelay);
    if (newValue == this.retryDelay) {
      return;
    }
    actionLogger.logInfo('retryDelay changed: $newValue');
    this.retryDelay = newValue;
    client.eventDispatcher.onPropertyChange("retryDelay");
  }

  public function getReverseHeartbeatInterval(): Long {
    return reverseHeartbeatInterval;
  }
  public function setReverseHeartbeatInterval(reverseHeartbeatInterval: Long): Void {
    var newValue = Millis.fromIntGtEq0(reverseHeartbeatInterval);
    if (newValue == this.reverseHeartbeatInterval) {
      return;
    }
    actionLogger.logInfo('reverseHeartbeatInterval changed: $newValue');
    this.reverseHeartbeatInterval = newValue;
    client.eventDispatcher.onPropertyChange("reverseHeartbeatInterval");
    client.machine.evtExtSetReverseHeartbeatInterval();
  }

  public function getSessionRecoveryTimeout(): Long {
    return sessionRecoveryTimeout;
  }
  public function setSessionRecoveryTimeout(sessionRecoveryTimeout: Long): Void {
    var newValue = Millis.fromIntGtEq0(sessionRecoveryTimeout);
    if (newValue == this.sessionRecoveryTimeout) {
      return;
    }
    actionLogger.logInfo('sessionRecoveryTimeout changed: $newValue');
    this.sessionRecoveryTimeout = newValue;
    client.eventDispatcher.onPropertyChange("sessionRecoveryTimeout");
  }

  public function getStalledTimeout(): Long {
    return stalledTimeout;
  }
  public function setStalledTimeout(stalledTimeout: Long): Void {
    var newValue = Millis.fromIntGt0(stalledTimeout);
    if (newValue == this.stalledTimeout) {
      return;
    }
    actionLogger.logInfo('stalledTimeout changed: $newValue');
    this.stalledTimeout = newValue;
    client.eventDispatcher.onPropertyChange("stalledTimeout");
  }

  public function isHttpExtraHeadersOnSessionCreationOnly(): Bool {
    return httpExtraHeadersOnSessionCreationOnly;
  }
  public function setHttpExtraHeadersOnSessionCreationOnly(httpExtraHeadersOnSessionCreationOnly: Bool): Void {
    if (httpExtraHeadersOnSessionCreationOnly == this.httpExtraHeadersOnSessionCreationOnly) {
      return;
    }
    actionLogger.logInfo('httpExtraHeadersOnSessionCreationOnly changed: $httpExtraHeadersOnSessionCreationOnly');
    this.httpExtraHeadersOnSessionCreationOnly = httpExtraHeadersOnSessionCreationOnly;
    client.eventDispatcher.onPropertyChange("httpExtraHeadersOnSessionCreationOnly");
  }

  public function isServerInstanceAddressIgnored(): Bool {
    return serverInstanceAddressIgnored;
  }
  public function setServerInstanceAddressIgnored(serverInstanceAddressIgnored: Bool): Void {
    if (serverInstanceAddressIgnored == this.serverInstanceAddressIgnored) {
      return;
    }
    actionLogger.logInfo('serverInstanceAddressIgnored changed: $serverInstanceAddressIgnored');
    this.serverInstanceAddressIgnored = serverInstanceAddressIgnored;
    client.eventDispatcher.onPropertyChange("serverInstanceAddressIgnored");
  }

  #if js
  public function setCookieHandlingRequired(newValue: Bool) {
    if (newValue == this.cookieHandlingRequired) {
      return;
    }
    actionLogger.logInfo('cookieHandlingRequired changed: $newValue');
    this.cookieHandlingRequired = newValue;
    client.eventDispatcher.onPropertyChange("cookieHandlingRequired");
  }
  public function isCookieHandlingRequired(): Bool {
    return cookieHandlingRequired;
  }
  #end

  public function isSlowingEnabled(): Bool {
    return slowingEnabled;
  }
  public function setSlowingEnabled(slowingEnabled: Bool): Void {
    if (slowingEnabled == this.slowingEnabled) {
      return;
    }
    actionLogger.logInfo('slowingEnabled changed: $slowingEnabled');
    this.slowingEnabled = slowingEnabled;
    client.eventDispatcher.onPropertyChange("slowingEnabled");
  }

  #if LS_HAS_PROXY
  var proxy: Null<Proxy>;

  public function setProxy(proxy: Null<Proxy>): Void {
    if (Proxy.eq(proxy, this.proxy)) {
      return;
    }
    actionLogger.logInfo('proxy changed: $proxy');
    #if cs
    com.lightstreamer.internal.Globals.instance.setProxy(proxy);
    #end
    this.proxy = proxy;
    client.eventDispatcher.onPropertyChange("proxy");
  }

  @:synchronized
  @:allow(com.lightstreamer.internal.PlatformApi)
  function getProxy(): Null<Proxy> {
    return this.proxy;
  }
  #end

  public function toString(): String {
    var map = new InfoMap();
    map["forcedTransport"] = forcedTransport;
    map["requestedMaxBandwidth"] = requestedMaxBandwidth;
    map["realMaxBandwidth"] = realMaxBandwidth;
    map["retryDelay"] = retryDelay;
    map["firstRetryMaxDelay"] = firstRetryMaxDelay;
    map["sessionRecoveryTimeout"] = sessionRecoveryTimeout;
    map["reverseHeartbeatInterval"] = reverseHeartbeatInterval;
    map["stalledTimeout"] = stalledTimeout;
    map["reconnectTimeout"] = reconnectTimeout;
    map["keepaliveInterval"] = keepaliveInterval;
    map["pollingInterval"] = pollingInterval;
    map["idleTimeout"] = idleTimeout;
    map["contentLength"] = contentLength;
    map["slowingEnabled"] = slowingEnabled;
    map["serverInstanceAddressIgnored"] = serverInstanceAddressIgnored;
    map["HTTPExtraHeadersOnSessionCreationOnly"] = httpExtraHeadersOnSessionCreationOnly;
    map["HTTPExtraHeaders"] = httpExtraHeaders;
    #if LS_HAS_PROXY
    map["proxy"] = proxy;
    #end
    #if js
    map["cookieHandlingRequired"] = cookieHandlingRequired;
    #end
    return map.toString();
  }
}