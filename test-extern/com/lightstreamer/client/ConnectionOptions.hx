package com.lightstreamer.client;

#if python
@:pythonImport("lightstreamer.client", "ConnectionOptions")
#end
#if js @:native("ConnectionOptions") #end
#if LS_NODE @:jsRequire("lightstreamer-client-node", "ConnectionOptions") #end
extern class ConnectionOptions {
  #if !cs
  public function getContentLength(): Long;
  public function setContentLength(contentLength: Long): Void;
  public function getFirstRetryMaxDelay(): Long;
  public function setFirstRetryMaxDelay(firstRetryMaxDelay: Long): Void;
  public function getForcedTransport(): Null<String>;
  public function setForcedTransport(forcedTransport: Null<String>): Void;
  public function getHttpExtraHeaders(): Null<NativeStringMap<String>>;
  public function setHttpExtraHeaders(httpExtraHeaders: Null<NativeStringMap<String>>): Void;
  public function getIdleTimeout(): Long;
  public function setIdleTimeout(idleTimeout: Long): Void;
  public function getKeepaliveInterval(): Long;
  public function setKeepaliveInterval(keepaliveInterval: Long): Void;
  public function getRequestedMaxBandwidth(): String;
  public function setRequestedMaxBandwidth(maxBandwidth: String): Void;
  public function getRealMaxBandwidth(): Null<String>;
  public function getPollingInterval(): Long;
  public function setPollingInterval(pollingInterval: Long): Void;
  public function getReconnectTimeout(): Long;
  public function setReconnectTimeout(reconnectTimeout: Long): Void;
  public function getRetryDelay(): Long;
  public function setRetryDelay(retryDelay: Long): Void;
  public function getReverseHeartbeatInterval(): Long;
  public function setReverseHeartbeatInterval(reverseHeartbeatInterval: Long): Void;
  public function getSessionRecoveryTimeout(): Long;
  public function setSessionRecoveryTimeout(sessionRecoveryTimeout: Long): Void;
  public function getStalledTimeout(): Long;
  public function setStalledTimeout(stalledTimeout: Long): Void;
  public function isHttpExtraHeadersOnSessionCreationOnly(): Bool;
  public function setHttpExtraHeadersOnSessionCreationOnly(httpExtraHeadersOnSessionCreationOnly: Bool): Void;
  public function isServerInstanceAddressIgnored(): Bool;
  public function setServerInstanceAddressIgnored(serverInstanceAddressIgnored: Bool): Void;
  public function isSlowingEnabled(): Bool;
  public function setSlowingEnabled(slowingEnabled: Bool): Void;
  #else
  public var ContentLength(default, default): Long;
  public var FirstRetryMaxDelay(default, default): Long;
  public var ForcedTransport(default, default): Null<String>;
  public var HttpExtraHeaders(default, default): Null<NativeStringMap<String>>;
  public var IdleTimeout(default, default): Long;
  public var KeepaliveInterval(default, default): Long;
  public var RequestedMaxBandwidth(default, default): String;
  public var RealMaxBandwidth(default, never): Null<String>;
  public var PollingInterval(default, default): Long;
  public var ReconnectTimeout(default, default): Long;
  public var RetryDelay(default, default): Long;
  public var ReverseHeartbeatInterval(default, default): Long;
  public var SessionRecoveryTimeout(default, default): Long;
  public var StalledTimeout(default, default): Long;
  public var HttpExtraHeadersOnSessionCreationOnly(default, default): Bool;
  public var ServerInstanceAddressIgnored(default, default): Bool;
  public var SlowingEnabled(default, default): Bool;
  #end

  #if LS_HAS_PROXY
  #if !cs
  public function setProxy(proxy: Null<Proxy>): Void;
  #else
  public var Proxy(never, default): Null<Proxy>;
  #end
  #end
}