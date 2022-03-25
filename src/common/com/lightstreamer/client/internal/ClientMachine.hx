package com.lightstreamer.client.internal;

import com.lightstreamer.internal.*;
import com.lightstreamer.internal.Debug;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.PlatformApi;
import com.lightstreamer.internal.Timer;
import com.lightstreamer.internal.Constants;
import com.lightstreamer.client.LightstreamerClient.ClientEventDispatcher;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

// TODO synchronize
@:nullSafety(Off)
@:access(com.lightstreamer.client.ConnectionDetails)
@:access(com.lightstreamer.client.ConnectionOptions)
class ClientMachine {
  final details: ConnectionDetails;
  final options: ConnectionOptions;
  final clientEventDispatcher: ClientEventDispatcher;
  final state: ClientStates.State = new ClientStates.State();
  // resource factories
  final wsFactory: IWsClientFactory;
  final httpFactory: IHttpClientFactory;
  final ctrlFactory: IHttpClientFactory;
  final timerFactory: ITimerFactory;
  final randomGenerator: Int->Int;
  // attributes
  final delayCounter: RetryDelayCounter = new RetryDelayCounter();
  var m_status: ClientStatus = DISCONNECTED;
  var m_nextReqId: Int = 0;
  var m_nextSubId: Int = 0;
  var defaultServerAddress: Null<ServerAddress>;
  var requestLimit: Null<RequestLimit>;
  var keepaliveInterval: Null<Millis>;
  var idleTimeout: Null<Millis>;
  var sessionId: Null<String>;
  var serverInstanceAddress: Null<ServerAddress>;
  var lastKnownClientIp: Null<String>;
  var cause: Null<String>;
  var connectTs: TimerStamp = new TimerStamp(0);
  var recoverTs: TimerStamp = new TimerStamp(0);
  var suspendedTransports: Set<TransportSelection> = new Set();
  var disabledTransports: Set<TransportSelection> = new Set();
  // messages
  final sequenceMap: Map<String, Int> = [];
  final messageManagers: Array<MessageManager> = [];
  // subscriptions
  final subscriptionManagers: AssocArray<SubscriptionManager> = new AssocArray();
  // request types
  var switchRequest: Null<Requests.SwitchRequest>;
  var constrainRequest: Null<Requests.ConstrainRequest>;
  // TODO MPN
  //var mpnRegisterRequest: Null<Requests.MpnRegisterRequest>;
  //var mpnFilterUnsubscriptionRequest: Null<Requests.MpnFilterUnsubscriptionRequest>;
  //var mpnBadgeResetRequest: Null<Requests.MpnBadgeResetRequest>;
  //
  var ctrl_connectTs: TimerStamp = new TimerStamp(0);
  // transport switch
  var swt_lastReqId: Null<Int>;
  // reverse heartbeat
  var rhb_grantedInterval: Null<Millis>;
  var rhb_currentInterval: Null<Millis>;
  // bandwidith
  var bw_requestedMaxBandwidth: Null<RequestedMaxBandwidth>;
  var bw_lastReqId: Null<Int>;
  // reachability
  final reachabilityFactory: IReachabilityFactory;
  var nr_reachabilityManager: Null<IReachability>;
  // recovery
  var rec_serverProg: Int = 0;
  var rec_clientProg: Int = 0;
  // slowing
  var slw_refTime: TimerStamp = new TimerStamp(0);
  var slw_avgDelayMs: TimerMillis = new TimerMillis(0);
  var slw_maxAvgDelayMs: TimerMillis = new TimerMillis(7_000);
  var slw_hugeDelayMs: TimerMillis = new TimerMillis(20_000);
  var slw_m: Float = 0.5;
  // connections
  var ws: Null<IWsClient>;
  var http: Null<IHttpClient>;
  var ctrl_http: Null<IHttpClient>;
  // timeouts
  var transportTimer: Null<ITimer>;
  var retryTimer: Null<ITimer>;
  var keepaliveTimer: Null<ITimer>;
  var stalledTimer: Null<ITimer>;
  var reconnectTimer: Null<ITimer>;
  var rhbTimer: Null<ITimer>;
  var recoveryTimer: Null<ITimer>;
  var idleTimer: Null<ITimer>;
  var pollingTimer: Null<ITimer>;
  var ctrlTimer: Null<ITimer>;

  public function new(
    serverAddress: Null<String>,
    adapterSet: Null<String>,
    details: ConnectionDetails,
    options: ConnectionOptions,
    wsFactory: IWsClientFactory,
    httpFactory: IHttpClientFactory,
    ctrlFactory: IHttpClientFactory,
    timerFactory: ITimerFactory,
    randomGenerator: Int->Int,
    reachabilityFactory: IReachabilityFactory,
    clientEventDispatcher: ClientEventDispatcher) {
    this.details = details;
    this.options = options;
    this.wsFactory = wsFactory;
    this.httpFactory = httpFactory;
    this.ctrlFactory = ctrlFactory;
    this.timerFactory = timerFactory;
    this.randomGenerator = randomGenerator;
    this.reachabilityFactory = reachabilityFactory;
    this.clientEventDispatcher = clientEventDispatcher;
    delayCounter.reset(options.retryDelay);
    if (serverAddress != null) {
      details.setServerAddress(serverAddress);
    }
    if (adapterSet != null) {
      details.setAdapterSet(adapterSet);
    }
    // TODO complete
    /*
switchRequest = SwitchRequest(self)
constrainRequest = ConstrainRequest(self)
mpnRegisterRequest = MpnRegisterRequest(self)
mpnFilterUnsubscriptionRequest = MpnFilterUnsubscriptionRequest(self)
mpnBadgeResetRequest = MpnBadgeResetRequest(self)
*/
  }

  // ---------- event handlers ----------

  public function evtExtConnect() {
    state.event("connect");
    var forward = true;
    if (state.is(M_100)) {
      cause = "api";
      resetCurrentRetryDelay();
      state.goTo(M_101);
      // TODO MPN
      //forward = evtExtConnect_MpnRegion();
      evtSelectCreate();
    }
    if (forward) {
      // TODO MPN
      //forward = evtExtConnect_MpnRegion();
    }
  }

  function evtSelectCreate() {
    // TODO
  }

  function evtWSOpen() {
    // TODO called by openWS: synchronize
  }
  function evtMessage(line: String) {
    // TODO called by openWS: synchronize
  }
  function evtTransportError() {
    // TODO called by openWS: synchronize
  }

  // ---------- event actions ----------

  function onFreshData() {
    assert(rec_serverProg == rec_clientProg);
    rec_serverProg += 1;
    rec_clientProg += 1;
  }

  function onStaleData() {
    assert(rec_serverProg < rec_clientProg);
    rec_serverProg += 1;
  }

  function isFreshData() {
    return rec_serverProg == rec_clientProg;
  }
  
  function openWS(url: String, headers: Null<NativeStringMap>): IWsClient {
    return wsFactory(url, headers, 
      function onOpen(client) {
        if (client.isDisposed())
          return;
        evtWSOpen();
      },
      function onText(client, line) {
        if (client.isDisposed())
          return;
        evtMessage(line);
      },
      function onError(client, error) {
        if (client.isDisposed())
          return;
        evtTransportError();
      });
  }

  function openWS_Create() {
    connectTs = TimerStamp.now();
    serverInstanceAddress = getServerAddress();
    var url = Url.build(serverInstanceAddress, "lightstreamer");
    ws = openWS(url, options.httpExtraHeaders);
  }

  function openWS_Bind() {
    connectTs = TimerStamp.now();
    var url = Url.build(serverInstanceAddress, "lightstreamer");
    var headers = getHeadersForRequestOtherThanCreate();
    ws = openWS(url, headers);
  }

  function sendCreateWS() {
    var req = new RequestBuilder();
    if (options.keepaliveInterval > 0) {
      req.LS_keepalive_millis(options.keepaliveInterval);
    }
    rhb_grantedInterval = options.reverseHeartbeatInterval;
    if (rhb_grantedInterval > 0) {
      req.LS_inactivity_millis(rhb_grantedInterval);
    }
    bw_requestedMaxBandwidth = options.requestedMaxBandwidth;
    switch bw_requestedMaxBandwidth {
      case BWLimited(bw):
        req.LS_requested_max_bandwidth_Float(bw);
      case _:
    }
    if (details.adapterSet != null) {
      req.LS_adapter_set(details.adapterSet);
    }
    if (details.user != null) {
      req.LS_user(details.user);
    }
    req.LS_cid(LS_CID);
    if (sessionId != null) {
      req.LS_old_session(sessionId);
    }
    if (!options.slowingEnabled) {
      req.LS_send_sync(false);
    }
    if (cause != null) {
      req.LS_cause(cause);
      cause = null;
    }
    protocolLogger.logInfo('Sending session create: $req');
    if (details.password != null) {
      req.LS_password(details.password);
    }

    ws.send("wsok");
    ws.send("create_session\r\n" + req.getEncodedString());
  }

  function sendBindWS_Streaming() {
    var req = new RequestBuilder();
    req.LS_session(sessionId);
    if (options.keepaliveInterval > 0) {
      req.LS_keepalive_millis(options.keepaliveInterval);
    }
    rhb_grantedInterval = options.reverseHeartbeatInterval;
    if (rhb_grantedInterval > 0) {
      req.LS_inactivity_millis(rhb_grantedInterval);
    }
    if (!options.slowingEnabled) {
      req.LS_send_sync(false);
    }
    if (cause != null) {
      req.LS_cause(cause);
      cause = null;
    }
    protocolLogger.logInfo('Sending session bind: $req');

    ws.send("wsok");
    ws.send("bind_session\r\n" + req.getEncodedString());
  }

  function sendBindWS_FirstPolling() {
    var req = new RequestBuilder();
    req.LS_session(sessionId);
    req.LS_polling(true);
    req.LS_polling_millis(options.pollingInterval);
    idleTimeout = options.idleTimeout;
    req.LS_idle_millis(idleTimeout);
    if (cause != null) {
      req.LS_cause(cause);
      cause = null;
    }
    protocolLogger.logInfo('Sending session bind: $req');

    ws.send("bind_session\r\n" + req.getEncodedString());
  }

  function sendBindWS_Polling() {
    var req = new RequestBuilder();
    req.LS_polling(true);
    req.LS_polling_millis(options.pollingInterval);
    idleTimeout = options.idleTimeout;
    req.LS_idle_millis(idleTimeout);
    if (cause != null) {
      req.LS_cause(cause);
      cause = null;
    }
    protocolLogger.logInfo('Sending session bind: $req');

    ws.send("bind_session\r\n" + req.getEncodedString());
  }

  function sendDestroyWS() {
    var req = new RequestBuilder();
    req.LS_reqId(generateFreshReqId());
    req.LS_op("destroy");
    req.LS_close_socket(true);
    req.LS_cause("api");
    protocolLogger.logInfo('Sending session destroy: $req');

    ws.send("control\r\n" + req.getEncodedString());
  }

  function sendHttpRequest(url: String, req: RequestBuilder, headers: Null<NativeStringMap>): IHttpClient {
    return httpFactory(url, req.getEncodedString(), headers,
      function onText(client, line) {
        if (client.isDisposed())
          return;
        evtMessage(line);
      },
      function onError(client, error) {
        if (client.isDisposed())
          return;
        evtTransportError();
      },
      function onDone(client) {
        // ignore
      });
  }

  function sendCreateHTTP() {
    var req = new RequestBuilder();
    req.LS_polling(true);
    req.LS_polling_millis(0);
    req.LS_idle_millis(0);
    bw_requestedMaxBandwidth = options.requestedMaxBandwidth;
    switch bw_requestedMaxBandwidth {
      case BWLimited(bw):
        req.LS_requested_max_bandwidth_Float(bw);
      case _:
    }
    if (details.adapterSet != null) {
      req.LS_adapter_set(details.adapterSet);
    }
    if (details.user != null) {
      req.LS_user(details.user);
    }
    req.LS_cid(LS_CID);
    if (sessionId != null) {
      req.LS_old_session(sessionId);
    }
    if (cause != null) {
      req.LS_cause(cause);
      cause = null;
    }
    protocolLogger.logInfo('Sending session create: $req');
    if (details.password != null) {
      req.LS_password(details.password);
    }

    connectTs = TimerStamp.now();
    serverInstanceAddress = getServerAddress();
    var url = Url.build(serverInstanceAddress, "/lightstreamer/create_session.txt?LS_protocol=" + TLCP_VERSION);
    http = sendHttpRequest(url, req, options.httpExtraHeaders);
  }

  function sendBindHTTP_Streaming() {
    var req = new RequestBuilder();
    req.LS_session(sessionId);
    req.LS_content_length(options.contentLength);
    if (options.keepaliveInterval > 0) {
      req.LS_keepalive_millis(options.keepaliveInterval);
    }
    rhb_grantedInterval = options.reverseHeartbeatInterval;
    if (rhb_grantedInterval > 0) {
      req.LS_inactivity_millis(rhb_grantedInterval);
    }
    if (!options.slowingEnabled) {
      req.LS_send_sync(false);
    }
    if (cause != null) {
      req.LS_cause(cause);
      cause = null;
    }
    protocolLogger.logInfo('Sending session bind: $req');

    connectTs = TimerStamp.now();
    var url = Url.build(serverInstanceAddress, "/lightstreamer/bind_session.txt?LS_protocol=" + TLCP_VERSION);
    var headers = getHeadersForRequestOtherThanCreate();
    http = sendHttpRequest(url, req, headers);
  }

  function sendBindHTTP_Polling() {
    var req = new RequestBuilder();
    req.LS_session(sessionId);
    req.LS_polling(true);
    req.LS_polling_millis(options.pollingInterval);
    idleTimeout = options.idleTimeout;
    req.LS_idle_millis(idleTimeout);
    if (cause != null) {
      req.LS_cause(cause);
      cause = null;
    }
    // NB parameter LS_inactivity_millis is forbidden in polling
    rhb_grantedInterval = new Millis(0);
    protocolLogger.logInfo('Sending session bind: $req');

    connectTs = TimerStamp.now();
    var url = Url.build(serverInstanceAddress, "/lightstreamer/bind_session.txt?LS_protocol=" + TLCP_VERSION);
    var headers = getHeadersForRequestOtherThanCreate();
    http = sendHttpRequest(url, req, headers);
  }

  function sendCreateTTL() {
    var req = new RequestBuilder();
    req.LS_ttl_millis("unlimited");
    req.LS_polling(true);
    req.LS_polling_millis(0);
    req.LS_idle_millis(0);
    bw_requestedMaxBandwidth = options.requestedMaxBandwidth;
    switch bw_requestedMaxBandwidth {
      case BWLimited(bw):
        req.LS_requested_max_bandwidth_Float(bw);
      case _:
    }
    if (details.adapterSet != null) {
      req.LS_adapter_set(details.adapterSet);
    }
    if (details.user != null) {
      req.LS_user(details.user);
    }
    req.LS_cid(LS_CID);
    if (sessionId != null) {
      req.LS_old_session(sessionId);
    }
    if (cause != null) {
      req.LS_cause(cause);
      cause = null;
    }
    protocolLogger.logInfo('Sending session create: $req');
    if (details.password != null) {
      req.LS_password(details.password);
    }

    connectTs = TimerStamp.now();
    serverInstanceAddress = getServerAddress();
    var url = Url.build(serverInstanceAddress, "/lightstreamer/create_session.txt?LS_protocol=" + TLCP_VERSION);
    http = sendHttpRequest(url, req, options.httpExtraHeaders);
  }

  function sendRecovery() {
    var req = new RequestBuilder();
    req.LS_session(sessionId);
    req.LS_recovery_from(rec_clientProg);
    req.LS_polling(true);
    req.LS_polling_millis(0);
    req.LS_idle_millis(0);
    if (cause != null) {
      req.LS_cause(cause);
      cause = null;
    }
    protocolLogger.logInfo('Sending session recovery: $req');

    connectTs = TimerStamp.now();
    var url = Url.build(serverInstanceAddress, "/lightstreamer/bind_session.txt?LS_protocol=" + TLCP_VERSION);
    var headers = getHeadersForRequestOtherThanCreate();
    http = sendHttpRequest(url, req, headers);
  }

  function disposeWS() {
    if (ws != null) {
      ws.dispose();
      ws = null;
    }
  }

  function closeWS() {
    if (ws != null) {
      ws.dispose();
      ws = null;
    }
  }

  function suspendWS_Streaming() {
    sessionLogger.logWarn("Websocket suspended");
    suspendedTransports.insert(WS_STREAMING);
  }

  function disableWS() {
    sessionLogger.logWarn("Websocket disabled");
    disabledTransports = disabledTransports.union([WS_STREAMING, WS_POLLING]);
  }

  function disableHTTP_Streaming() {
    sessionLogger.logWarn("HTTP streaming disabled");
    disabledTransports = disabledTransports.union([HTTP_STREAMING]);
  }

  function disableStreaming() {
    sessionLogger.logWarn("Streaming disabled");
    disabledTransports = disabledTransports.union([WS_STREAMING, HTTP_STREAMING]);
  }

  function enableAllTransports() {
    if (sessionLogger.isInfoEnabled()) {
      if (disabledTransports.count() > 0 || suspendedTransports.count() > 0) {
          sessionLogger.info("Transports enabled again.");
      }
    }
    disabledTransports = new Set();
    suspendedTransports = new Set();
  }

  function disposeHTTP() {
    if (http != null) {
      http.dispose();
      http = null;
    }
  }

  function closeHTTP() {
    if (http != null) {
      http.dispose();
      http = null;
    }
  }

  function disposeCtrl() {
    if (ctrl_http != null) {
      ctrl_http.dispose();
      ctrl_http = null;
    }
  }

  function closeCtrl() {
    if (ctrl_http != null) {
      ctrl_http.dispose();
      ctrl_http = null;
    }
  }

  function notifyStatus(newStatus: ClientStatus) {
    var oldStatus = m_status;
    m_status = newStatus;
    if (oldStatus != newStatus) {
      sessionLogger.logInfo("Status: " + newStatus);
      clientEventDispatcher.onStatusChange(newStatus);
    }
  }

  function getBestForCreating() {
    var ft = options.forcedTransport;
    if (!suspendedTransports.union(disabledTransports.toArray()).contains(WS_STREAMING) && (ft == null || ft == WS || ft == WS_STREAMING)) {
      return bfc_ws;
    } else {
      return bfc_http;
    }
  }

  function getBestForBinding() {
    var ft = options.forcedTransport;
    if (!disabledTransports.contains(WS_STREAMING) && (ft == null || ft == WS || ft == WS_STREAMING)) {
      return bfb_ws_streaming;
    } else if (!disabledTransports.contains(HTTP_STREAMING) && (ft == null || ft == HTTP || ft == HTTP_STREAMING)) {
        return bfb_http_streaming;
    } else if (!disabledTransports.contains(WS_POLLING) && (ft == null || ft == WS || ft == WS_POLLING)) {
        return bfb_ws_polling;
    } else if (ft == null || ft == HTTP || ft == HTTP_POLLING) {
        return bfb_http_polling;
    } else {
        return bfb_none;
    }
  }

  function resetCurrentRetryDelay() {
    delayCounter.reset(options.retryDelay);
  }

  function notifyServerError_CONERR(code: Int, msg: String) {
    clientEventDispatcher.onServerError(code, msg);
  }

  function notifyServerError_END(code: Int, msg: String) {
    if ((0 < code && code < 30) || code > 39) {
      clientEventDispatcher.onServerError(39, msg);
    } else {
      clientEventDispatcher.onServerError(code, msg);
    }
  }

  function notifyServerError_ERROR(code: Int, msg: String) {
    clientEventDispatcher.onServerError(code, msg);
  }

  function  notifyServerError_REQERR(code: Int, msg: String) {
    if (code == 11) {
      clientEventDispatcher.onServerError(21, msg);
    } else {
      clientEventDispatcher.onServerError(code, msg);
    }
  }

  function doCONOK(sessionId: String, reqLimit: RequestLimit, keepalive: Null<Millis>, idleTimeout: Null<Millis>, clink: String) {
    this.sessionId = sessionId;
    details.setSessionId(sessionId);
    this.requestLimit = reqLimit;
    if (keepalive != null) {
      this.keepaliveInterval = keepalive;
      options.keepaliveInterval = keepalive;
    } else if (idleTimeout != null) {
      this.idleTimeout = idleTimeout;
      options.idleTimeout = idleTimeout;
    }
    if (clink != "*" && !options.serverInstanceAddressIgnored) {
      clink = Url.completeControlLink(clink, getServerAddress());
      this.serverInstanceAddress = new ServerAddress(clink);
      details.setServerInstanceAddress(clink);
    }
  }

  function doCONOK_CreateWS(sessionId: String, reqLimit: RequestLimit, keepalive: Millis, clink: String) {
    doCONOK(sessionId, reqLimit, keepalive, null, clink);
  }

  function doCONOK_BindWS_Streaming(sessionId: String, reqLimit: RequestLimit, keepalive: Millis, clink: String) {
    doCONOK(sessionId, reqLimit, keepalive, null, clink);
  }

  function doCONOK_BindWS_Polling(sessionId: String, reqLimit: RequestLimit, idleTimeout: Millis, clink: String) {
    doCONOK(sessionId, reqLimit, null, idleTimeout, clink);
  }

  function doCONOK_CreateHTTP(sessionId: String, reqLimit: RequestLimit, keepalive: Millis, clink: String) {
    // keepalive or idleTimeout will be set by next bind_session
    doCONOK(sessionId, reqLimit, null, null, clink);
  }

  function doCONOK_BindHTTP_Streaming(sessionId: String, reqLimit: RequestLimit, keepalive: Millis, clink: String) {
    doCONOK(sessionId, reqLimit, keepalive, null, clink);
  }

  function doCONOK_BindHTTP_Polling(sessionId: String, reqLimit: RequestLimit, idleTimeout: Millis, clink: String) {
    doCONOK(sessionId, reqLimit, null, idleTimeout, clink);
  }

  function doSERVNAME(serverName: String) {
    details.setServerSocketName(serverName);
  }

  function doCLIENTIP(clientIp: String) {
    details.setClientIp(clientIp);
    var lastIp = lastKnownClientIp;
    if (lastIp != null && lastIp != clientIp) {
      sessionLogger.logInfo('Client IP changed: $lastIp -> $clientIp');
      enableAllTransports();
    }
    lastKnownClientIp = clientIp;
  }

  function doCONS(bandwidth: RealMaxBandwidth) {
    options.setRealMaxBandwidth(bandwidth);
  }

  function doLOOP(pollingMs: Millis) {
    options.setPollingInterval(pollingMs);
  }

  function doPROG(prog: Int) {
    assert(prog <= rec_clientProg);
    rec_serverProg = prog;
  }

  function doMSGDONE(sequence: String, prog: Int) {
    onFreshData();
    var messages = messageManagers.filter(msg -> msg.sequence == sequence && msg.prog == prog);
    assert(messages.length <= 1);
    for (msg in messages) {
        msg.evtMSGDONE();
    }
  }

  function doMSGFAIL(sequence: String, prog: Int, errorCode: Int, errorMsg: String) {
    onFreshData();
    if (errorCode == 39) {
      // list of discarded messages. errorMsg is actually a counter
      var count = Std.parseInt(errorMsg);
      assert(count != null);
      for (p in (prog - count + 1)...prog + 1) {
        var messages = messageManagers.filter(msg -> msg.sequence == sequence && msg.prog == p);
        assert(messages.length <= 1);
        for (msg in messages) {
          msg.evtMSGFAIL(errorCode, errorMsg);
        }
      }
    } else {
      var messages = messageManagers.filter(msg -> msg.sequence == sequence && msg.prog == prog);
      assert(messages.length <= 1);
      for (msg in messages) {
        msg.evtMSGFAIL(errorCode, errorMsg);
      }
    }
  }

  function doU(subId: Int, itemIdx: Pos, values: Map<Pos, FieldValue>) {
    onFreshData();
    var sub = subscriptionManagers[subId];
    if (sub != null) {
      sub.evtU(itemIdx, values);
    } else {
      var sub = new SubscriptionManagerZombie(subId, this);
      sub.evtU(itemIdx, values);
    }
  }

  function doSUBOK(subId: Int, nItems: Int, nFields: Int) {
    onFreshData();
    var sub = subscriptionManagers[subId];
    if (sub != null) {
      sub.evtSUBOK(nItems, nFields);
    } else {
      var sub = new SubscriptionManagerZombie(subId, this);
      sub.evtSUBOK(nItems, nFields);
    }
  }

  function doSUBCMD(subId: Int, nItems: Int, nFields: Int, keyIdx: Pos, cmdIdx: Pos) {
    onFreshData();
    var sub = subscriptionManagers[subId];
    if (sub != null) {
      sub.evtSUBCMD(nItems, nFields, keyIdx, cmdIdx);
    } else {
      var sub = new SubscriptionManagerZombie(subId, this);
      sub.evtSUBCMD(nItems, nFields, keyIdx, cmdIdx);
    }
  }

  function doUNSUB(subId: Int) {
    onFreshData();
    var sub = subscriptionManagers[subId];
    if (sub != null) {
      sub.evtUNSUB();
    }
  }

  function doEOS(subId: Int, itemIdx: Pos) {
    onFreshData();
    var sub = subscriptionManagers[subId];
    if (sub != null) {
      sub.evtEOS(itemIdx);
    } else {
      var sub = new SubscriptionManagerZombie(subId, this);
      sub.evtEOS(itemIdx);
    }
  }

  function doCS(subId: Int, itemIdx: Pos) {
    onFreshData();
    var sub = subscriptionManagers[subId];
    if (sub != null) {
      sub.evtCS(itemIdx);
    } else {
      var sub = new SubscriptionManagerZombie(subId, this);
      sub.evtCS(itemIdx);
    }
  }

  function doOV(subId: Int, itemIdx: Pos, lostUpdates: Int) {
    onFreshData();
    var sub = subscriptionManagers[subId];
    if (sub != null) {
      sub.evtOV(itemIdx, lostUpdates);
    } else {
      var sub = new SubscriptionManagerZombie(subId, this);
      sub.evtOV(itemIdx, lostUpdates);
    }
  }

  function doCONF(subId: Int, freq: RealMaxFrequency) {
    onFreshData();
    var sub = subscriptionManagers[subId];
    if (sub != null) {
      sub.evtCONF(freq);
    } else {
      var sub = new SubscriptionManagerZombie(subId, this);
      sub.evtCONF(freq);
    }
  }

  function doREQOK(reqId: Int) {
    for (_ => sub in subscriptionManagers) {
      sub.evtREQOK(reqId);
    }
    for (msg in messageManagers) {
      msg.evtREQOK(reqId);
    }
    // TODO MPN
    // for (sub in mpnSubscriptionManagers) {
    //   sub.evtREQOK(reqId);
    // }
  }

  function doREQERR(reqId: Int, errorCode: Int, errorMsg: String) {
    for (_ => sub in subscriptionManagers) {
      sub.evtREQERR(reqId, errorCode, errorMsg);
    }
    for (msg in messageManagers) {
      msg.evtREQERR(reqId, errorCode, errorMsg);
    }
    // TODO MPN
    // for (sub in mpnSubscriptionManagers) {
    //   sub.evtREQERR(reqId, errorCode, errorMsg);
    // }
  }

  function doSYNC(syncMs: TimerMillis) {
    slw_refTime = TimerStamp.now();
    slw_avgDelayMs = -syncMs;
  }

  function doSYNC_G(syncMs: TimerMillis): SyncCheckResult {
    var diffTime = diffTimeSync(syncMs);
    if (diffTime > slw_hugeDelayMs && diffTime > slw_avgDelayMs * 2) {
      if (slw_avgDelayMs > slw_maxAvgDelayMs && options.slowingEnabled) {
        return SCR_bad;
      } else {
        return SCR_not_good;
      }
    } else {
      slw_avgDelayMs = slowAvg(diffTime);
      if (slw_avgDelayMs > slw_maxAvgDelayMs && options.slowingEnabled) {
        return SCR_bad;
      } else {
        if (slw_avgDelayMs < new TimerMillis(60)) {
          slw_avgDelayMs = new TimerMillis(0);
        }
        return SCR_good;
      }
    }
  }

  function doSYNC_NG(syncMs: TimerMillis): SyncCheckResult {
    var diffTime = diffTimeSync(syncMs);
    if (diffTime > slw_hugeDelayMs && diffTime > slw_avgDelayMs * 2) {
        slw_avgDelayMs = slowAvg(diffTime);
        if (slw_avgDelayMs > slw_maxAvgDelayMs && options.slowingEnabled) {
          return SCR_bad;
        } else {
          if (slw_avgDelayMs < new TimerMillis(60)) {
            slw_avgDelayMs = new TimerMillis(0);
          }
          return SCR_good;
        }
    } else {
      slw_avgDelayMs = slowAvg(diffTime);
      if (slw_avgDelayMs > slw_maxAvgDelayMs && options.slowingEnabled) {
        return SCR_bad;
      } else {
        if (slw_avgDelayMs < new TimerMillis(60)) {
          slw_avgDelayMs = new TimerMillis(0);
        }
        return SCR_not_good;
      }
    }
  }

  function diffTimeSync(syncMs: TimerMillis) {
    var diffMs = TimerStamp.now() - slw_refTime;
    var diffTime = diffMs - syncMs;
    return diffTime;
  }

  function slowAvg(diffTime: TimerMillis) {
    return slw_avgDelayMs * slw_m + diffTime * (1.0 - slw_m);
  }

  function generateFreshReqId() {
    // TODO synchronize
    m_nextReqId += 1;
    return m_nextReqId;
  }

  function getHeadersForRequestOtherThanCreate() {
    return options.httpExtraHeadersOnSessionCreationOnly ? null : options.httpExtraHeaders;
  }

  function getServerAddress() {
    var addr = details.serverAddress;
    return addr != null ? addr : defaultServerAddress;
  }
}

private enum BestForCreatingEnum {
  bfc_ws; bfc_http;
}

private enum BestForBindingEnum {
  bfb_none; bfb_ws_streaming; bfb_ws_polling; bfb_http_streaming; bfb_http_polling;
}

private enum SyncCheckResult {
  SCR_good; SCR_not_good; SCR_bad;
}