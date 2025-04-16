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
package com.lightstreamer.client.hxcbridge;

import cpp.ConstStar;
import com.lightstreamer.cpp.CppString;
import com.lightstreamer.cpp.CppStringMap;
import com.lightstreamer.internal.NativeTypes.Long;
import com.lightstreamer.client.ConnectionOptions.LSConnectionOptions;

@:unreflective
@:build(HaxeCBridge.expose()) @HaxeCBridge.name("ConnectionOptions")
@:publicFields
class HxCBridgeConnectionOptions {
  private final _delegate: LSConnectionOptions;

  function new(options: LSConnectionOptions) {
    _delegate = options;
  }

  function getContentLength() {
    return _delegate.getContentLength();
  }

  function getFirstRetryMaxDelay() {
    return _delegate.getFirstRetryMaxDelay();
  }

  function getForcedTransport(): CppString {
    return _delegate.getForcedTransport() ?? "";
  }

  function getHttpExtraHeaders(): CppStringMap {
    var res = new CppStringMap();
    var headers = _delegate.getHttpExtraHeaders();
    if (headers != null) {
      res = headers;
    }
    return res;
  }

  function getIdleTimeout() {
    return _delegate.getIdleTimeout();
  }

  function getKeepaliveInterval() {
    return _delegate.getKeepaliveInterval();
  }

  function getRequestedMaxBandwidth(): CppString {
    return _delegate.getRequestedMaxBandwidth();
  }

  function getRealMaxBandwidth(): CppString {
    return _delegate.getRealMaxBandwidth() ?? "";
  }

  function getPollingInterval() {
    return _delegate.getPollingInterval();
  }

  function getReconnectTimeout() {
    return _delegate.getReconnectTimeout();
  }

  function getRetryDelay() {
    return _delegate.getRetryDelay();
  }

  function getReverseHeartbeatInterval() {
    return _delegate.getReverseHeartbeatInterval();
  }

  function getStalledTimeout() {
    return _delegate.getStalledTimeout();
  }

  function getSessionRecoveryTimeout() {
    return _delegate.getSessionRecoveryTimeout();
  }

  function isHttpExtraHeadersOnSessionCreationOnly() {
    return _delegate.isHttpExtraHeadersOnSessionCreationOnly();
  }

  function isServerInstanceAddressIgnored() {
    return _delegate.isServerInstanceAddressIgnored();
  }

  function isSlowingEnabled() {
    return _delegate.isSlowingEnabled();
  }

  function setContentLength(contentLength: Long) {
    _delegate.setContentLength(contentLength);
  }

  function setFirstRetryMaxDelay(firstRetryMaxDelay: Long) {
    _delegate.setFirstRetryMaxDelay(firstRetryMaxDelay);
  }

  function setForcedTransport(forcedTransport: ConstStar<CppString>) {
    @:nullSafety(Off)
    _delegate.setForcedTransport(forcedTransport.isEmpty() ? null : forcedTransport);
  }

  function setHttpExtraHeaders(@:nullSafety(Off) headers: ConstStar<CppStringMap>) {
    _delegate.setHttpExtraHeaders(headers);
  }

  function setHttpExtraHeadersOnSessionCreationOnly(httpExtraHeadersOnSessionCreationOnly: Bool) {
    _delegate.setHttpExtraHeadersOnSessionCreationOnly(httpExtraHeadersOnSessionCreationOnly);
  }

  function setIdleTimeout(idleTimeout: Long) {
    _delegate.setIdleTimeout(idleTimeout);
  }

  function setKeepaliveInterval(keepaliveInterval: Long) {
    _delegate.setKeepaliveInterval(keepaliveInterval);
  }

  function setRequestedMaxBandwidth(@:nullSafety(Off) maxBandwidth: ConstStar<CppString>) {
    _delegate.setRequestedMaxBandwidth(maxBandwidth);
  }

  function setPollingInterval(pollingInterval: Long) {
    _delegate.setPollingInterval(pollingInterval);
  }

  function setReconnectTimeout(reconnectTimeout: Long) {
    _delegate.setReconnectTimeout(reconnectTimeout);
  }

  function setRetryDelay(retryDelay: Long) {
    _delegate.setRetryDelay(retryDelay);
  }

  function setReverseHeartbeatInterval(reverseHeartbeatInterval: Long) {
    _delegate.setReverseHeartbeatInterval(reverseHeartbeatInterval);
  }

  function setServerInstanceAddressIgnored(serverInstanceAddressIgnored: Bool) {
    _delegate.setServerInstanceAddressIgnored(serverInstanceAddressIgnored);
  }

  function setSlowingEnabled(slowingEnabled: Bool) {
    _delegate.setSlowingEnabled(slowingEnabled);
  }

  function setStalledTimeout(stalledTimeout: Long) {
    _delegate.setStalledTimeout(stalledTimeout);
  }

  function setSessionRecoveryTimeout(sessionRecoveryTimeout: Long) {
    _delegate.setSessionRecoveryTimeout(sessionRecoveryTimeout);
  }

  #if LS_HAS_PROXY
  function setProxy(@:nullSafety(Off) proxy: ConstStar<NativeProxy>) {
    if (proxy.host.isEmpty()) {
      _delegate.setProxy(null);
    } else {
      _delegate.setProxy(proxy);
    }
  }
  #end
}