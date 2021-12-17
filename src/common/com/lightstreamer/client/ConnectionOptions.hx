package com.lightstreamer.client;

import com.lightstreamer.client.Types;

class ConnectionOptions {
  public function getConnectTimeout(): String {
    return null;
  }
  public function setConnectTimeout(connectTimeout: String): Void {}
  public function getCurrentConnectTimeout(): Millis {
    return 0;
  }
  public function setCurrentConnectTimeout(connectTimeout: Millis): Void {}
  public function getContentLength(): haxe.Int64 {
    return 0;
  }
  public function setContentLength(contentLength: haxe.Int64): Void {}
  public function getFirstRetryMaxDelay(): Millis {
    return 0;
  }
  public function setFirstRetryMaxDelay(firstRetryMaxDelay: Millis): Void {}
  public function getForcedTransport(): String {
    return null;
  }
  public function setForcedTransport(forcedTransport: String): Void {}
  public function getHttpExtraHeaders(): Map<String, String> {
    return null;
  }
  public function setHttpExtraHeaders(httpExtraHeaders: Map<String, String>): Void {}
  public function getIdleTimeout(): Millis {
    return 0;
  }
  public function setIdleTimeout(idleTimeout: Millis): Void {}
  public function getKeepaliveInterval(): Millis {
    return 0;
  }
  public function setKeepaliveInterval(keepaliveInterval: Millis): Void {}
  public function getRequestedMaxBandwidth(): String {
    return null;
  }
  public function setRequestedMaxBandwidth(maxBandwidth: String): Void {}
  public function getRealMaxBandwidth(): String {
    return null;
  }
  public function getPollingInterval(): Millis {
    return 0;
  }
  public function setPollingInterval(pollingInterval: Millis): Void {}
  public function getReconnectTimeout(): Millis {
    return 0;
  }
  public function setReconnectTimeout(reconnectTimeout: Millis): Void {}
  public function getRetryDelay(): Millis {
    return 0;
  }
  public function setRetryDelay(retryDelay: Millis): Void {}
  public function getReverseHeartbeatInterval(): Millis {
    return 0;
  }
  public function setReverseHeartbeatInterval(reverseHeartbeatInterval: Millis): Void {}
  public function getStalledTimeout(): Millis {
    return 0;
  }
  public function setStalledTimeout(stalledTimeout: Millis): Void {}
  public function getSessionRecoveryTimeout(): Millis {
    return 0;
  }
  public function setSessionRecoveryTimeout(sessionRecoveryTimeout: Millis): Void {}
  public function isEarlyWSOpenEnabled(): Bool {
    return false;
  }
  public function setEarlyWSOpenEnabled(earlyWSOpenEnabled: Bool): Void {}
  public function isHttpExtraHeadersOnSessionCreationOnly(): Bool {
    return false;
  }
  public function setHttpExtraHeadersOnSessionCreationOnly(httpExtraHeadersOnSessionCreationOnly: Bool): Void {}
  public function isServerInstanceAddressIgnored(): Bool {
    return false;
  }
  public function setServerInstanceAddressIgnored(serverInstanceAddressIgnored: Bool): Void {}
  public function isSlowingEnabled(): Bool {
    return false;
  }
  public function setSlowingEnabled(slowingEnabled: Bool): Void {}
  // TODO javase Proxy
  // public function setProxy(proxy: Proxy): Void {}
}