package com.lightstreamer.client.internal;

import com.lightstreamer.client.internal.SubscriptionManager;
import com.lightstreamer.internal.*;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.MacroTools;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.PlatformApi;
import com.lightstreamer.internal.Timer;
import com.lightstreamer.internal.Constants;
import com.lightstreamer.client.LightstreamerClient.ClientEventDispatcher;
import com.lightstreamer.client.internal.ClientStates;
import com.lightstreamer.client.internal.ClientRequests;
import com.lightstreamer.log.LoggerTools;
import com.lightstreamer.client.internal.ParseTools;

using com.lightstreamer.log.LoggerTools;
using com.lightstreamer.internal.NullTools;
using StringTools;
using Lambda;

@:access(com.lightstreamer.client.ConnectionDetails)
@:access(com.lightstreamer.client.ConnectionOptions)
@:access(com.lightstreamer.client.LightstreamerClient)
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ClientMachine {
  final client: LightstreamerClient;
  final details: ConnectionDetails;
  final options: ConnectionOptions;
  public final lock: com.lightstreamer.internal.RLock;
  final clientEventDispatcher: ClientEventDispatcher;
  public final state: ClientStates.State = new ClientStates.State();
  // resource factories
  final wsFactory: IWsClientFactory;
  final httpFactory: IHttpClientFactory;
  final ctrlFactory: IHttpClientFactory;
  final timerFactory: ITimerFactory;
  final randomGenerator: Millis->Millis;
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
  var ctrl_connectTs: TimerStamp = new TimerStamp(0);
  var suspendedTransports: Set<TransportSelection> = new Set();
  var disabledTransports: Set<TransportSelection> = new Set();
  // messages
  final sequenceMap: Map<String, Int> = [];
  final messageManagers: Array<MessageManager> = [];
  // subscriptions
  final subscriptionManagers: AssocArray<SubscriptionManager> = new AssocArray();
  // request types
  var switchRequest: Null<SwitchRequest>;
  var constrainRequest: Null<ConstrainRequest>;
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

  function disposeSession() {
    disposeWS();
    disposeHTTP();
    disposeCtrl();
    
    details.serverInstanceAddress = null;
    details.serverSocketName = null;
    details.clientIp = null;
    details.sessionId = null;
    options.realMaxBandwidth = null;
    
    lastKnownClientIp = null;
    
    resetSequenceMap();
    
    rec_serverProg = 0;
    rec_clientProg = 0;
    
    bw_lastReqId = null;
    bw_requestedMaxBandwidth = null;
    
    swt_lastReqId = null;
  }

  function disposeClient() {
    sessionId = null;
    enableAllTransports();
    resetCurrentRetryDelay();
    resetSequenceMap();
    cause = null;
  }

  public function new(
    client: LightstreamerClient,
    serverAddress: Null<String>,
    adapterSet: Null<String>,
    wsFactory: IWsClientFactory,
    httpFactory: IHttpClientFactory,
    ctrlFactory: IHttpClientFactory,
    timerFactory: ITimerFactory,
    randomGenerator: Millis->Millis,
    reachabilityFactory: IReachabilityFactory) {
    this.client = client;
    this.lock = client.lock;
    this.details = client.connectionDetails;
    this.options = client.connectionOptions;
    this.wsFactory = wsFactory;
    this.httpFactory = httpFactory;
    this.ctrlFactory = ctrlFactory;
    this.timerFactory = timerFactory;
    this.randomGenerator = randomGenerator;
    this.reachabilityFactory = reachabilityFactory;
    this.clientEventDispatcher = client.eventDispatcher;
    this.switchRequest = new SwitchRequest(this);
    this.constrainRequest = new ConstrainRequest(this);
    delayCounter.reset(options.retryDelay);
    if (serverAddress != null) {
      details.setServerAddress(serverAddress);
    }
    if (adapterSet != null) {
      details.setAdapterSet(adapterSet);
    }
  }

  // ---------- event handlers ----------

  public function evtExtConnect() {
    traceEvent("connect");
    var forward = true;
    if (state.s_m == s100) {
      cause = "api";
      resetCurrentRetryDelay();
      goto(state.s_m = s101);
      forward = evtExtConnect_NextRegion();
      evtSelectCreate();
    }
    if (forward) {
      forward = evtExtConnect_NextRegion();
    }
  }

  function evtExtConnect_NextRegion(): Bool {
    return evtExtConnect_NetworkReachabilityRegion();
  }

  function evtExtConnect_NetworkReachabilityRegion() {
    if (state.s_nr == s1400) {
      var hostAddress = new Url(getServerAddress()).hostname;
      nr_reachabilityManager = reachabilityFactory(hostAddress);
      goto(state.s_nr = s1410);
      nr_reachabilityManager.startListening(status -> 
        switch status {
          case RSNotReachable:
            evtNetworkNotReachable(hostAddress);
          case RSReachable:
            evtNetworkReachable(hostAddress);
        });
    }
    return false;
  }

  function evtNetworkNotReachable(host: String) {
    reachabilityLogger.logInfo(host + " is NOT reachable");
    traceEvent("nr:network.not.reachable");
    if (state.s_nr == s1410) {
      goto(state.s_nr = s1411);
    } else if (state.s_nr == s1412) {
      goto(state.s_nr = s1411);
    }
  }

  function evtNetworkReachable(host: String) {
    reachabilityLogger.logInfo(host + " is reachable");
    traceEvent("nr:network.reachable");
    if (state.s_nr == s1410) {
      goto(state.s_nr = s1412);
    } else if (state.s_nr == s1411) {
      goto(state.s_nr = s1412);
      evtOnlineAgain();
    }
  }

  function evtOnlineAgain() {
    traceEvent("online.again");
    if (state.s_m == s112) {
      goto(state.s_m = s116);
      cancel_evtRetryTimeout();
      evtSelectCreate();
    } else if (state.s_rec == s1003) {
      sendRecovery();
      goto(state.s_rec = s1001);
      cancel_evtRetryTimeout();
      schedule_evtTransportTimeout(options.retryDelay);
    }
  }

  function evtServerAddressChanged() {
    traceEvent( "nr:serverAddress.changed");
    switch state.s_nr {
    case s1410, s1411, s1412:
      var oldManager = nr_reachabilityManager;
      var hostAddress = new Url(getServerAddress()).hostname;
      nr_reachabilityManager = reachabilityFactory(hostAddress);
      goto(state.s_nr = s1410);
      if (oldManager != null) {
        oldManager.stopListening();
      }
      nr_reachabilityManager.startListening(status -> 
        switch status {
          case RSNotReachable:
            evtNetworkNotReachable(hostAddress);
          case RSReachable:
            evtNetworkReachable(hostAddress);
        });
    default:
      // ignore
    }
  }

  public function evtExtDisconnect() {
    traceEvent("disconnect");
    var terminationCause = TerminationCause.TC_api;
    switch state.s_m {
    case s120, s121, s122:
      disposeWS();
      notifyStatus(DISCONNECTED);
      goto(state.s_m = s100);
      cancel_evtTransportTimeout();
      evtTerminate(terminationCause);
    case s130:
      disposeHTTP();
      notifyStatus(DISCONNECTED);
      goto(state.s_m = s100);
      cancel_evtTransportTimeout();
      evtTerminate(terminationCause);
    case s140:
      disposeHTTP();
      notifyStatus(DISCONNECTED);
      goto(state.s_m = s100);
      cancel_evtTransportTimeout();
      evtTerminate(terminationCause);
    case s150:
      switch state.s_tr {
      case s210:
        sendDestroyWS();
        closeWS();
        notifyStatus(DISCONNECTED);
        state.clear_w();
        state.goto_m_from_session(s100);
        exit_w();
        evtEndSession();
        evtTerminate(terminationCause);
      case s220:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        state.goto_m_from_session(s100);
        cancel_evtTransportTimeout();
        evtEndSession();
        evtTerminate(terminationCause);
      case s230:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        state.goto_m_from_session(s100);
        cancel_evtTransportTimeout();
        evtEndSession();
        evtTerminate(terminationCause);
      case s240:
        if (state.s_ws?.m == s500) {
          disposeWS();
          notifyStatus(DISCONNECTED);
          state.goto_m_from_ws(s100);
          exit_ws_to_m();
          evtTerminate(terminationCause);
        } else if (state.s_ws?.m == s501 || state.s_ws?.m == s502 || state.s_ws?.m == s503) {
          sendDestroyWS();
          closeWS();
          notifyStatus(DISCONNECTED);
          state.goto_m_from_ws(s100);
          exit_ws_to_m();
          evtTerminate(terminationCause);
        } 
      case s250:
        if (state.s_wp?.m == s600 || state.s_wp?.m == s601) {
          disposeWS();
          notifyStatus(DISCONNECTED);
          state.goto_m_from_wp(s100);
          exit_ws_to_m();
          evtTerminate(terminationCause);
        } else if (state.s_wp?.m == s602) {
          sendDestroyWS();
          closeWS();
          notifyStatus(DISCONNECTED);
          state.goto_m_from_wp(s100);
          exit_wp_to_m();
          evtTerminate(terminationCause);
        }
      case s260:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        state.goto_m_from_rec(s100);
        exit_rec_to_m();
        evtTerminate(terminationCause);
      case s270:
        if (state.s_h == s710) {
          disposeHTTP();
          notifyStatus(DISCONNECTED);
          state.goto_m_from_hs(s100);
          exit_hs_to_m();
          evtTerminate(terminationCause);
        } else if (state.s_h == s720) {
          disposeHTTP();
          notifyStatus(DISCONNECTED);
          state.goto_m_from_hp(s100);
          exit_hp_to_m();
          evtTerminate(terminationCause);
        }
      default:
        // ignore
      }
    case s110, s111, s112, s113, s114, s115, s116:
        notifyStatus(DISCONNECTED);
        goto(state.s_m = s100);
        cancel_evtRetryTimeout();
        evtTerminate(terminationCause);
    default:
      // ignore
    }
  }

  function evtSelectCreate() {
    traceEvent("select.create");
    if (state.s_m == s101 || state.s_m == s116) {
      switch getBestForCreating() {
        case BFC_ws:
          notifyStatus(CONNECTING);
          openWS_Create();
          goto(state.s_m = s120);
          evtCreate();
          schedule_evtTransportTimeout(delayCounter.currentRetryDelay);
        case BFC_http:
          notifyStatus(CONNECTING);
          sendCreateHTTP();
          goto(state.s_m = s130);
          evtCreate();
          schedule_evtTransportTimeout(delayCounter.currentRetryDelay);
      }
    }
  }

  function evtWSOpen() {
    traceEvent("ws.open");
    if (state.s_m == s120) {
      sendCreateWS();
      goto(state.s_m = s121);
    } else if (state.s_ws?.m == s500) {
      sendBindWS_Streaming();
      goto(state.s_ws.m = s501);
    } else if (state.s_wp?.m == s600) {
      ws.sure().send("wsok");
      goto(state.s_wp.m = s601);
    }
  }

  function evtMessage(line: String) {
    var matched = true;
    if (line.startsWith("U,")) {
      // U,<subscription id>,<itemd index>,<field values>
      var update = parseUpdate(line);
      evtU(update.subId, update.itemIdx, update.values, line);
    } else if (line.startsWith("REQOK")) {
      // REQOK,<request id>
      if (line == "REQOK") {
        evtREQOK_withoutReqId();
      } else {
        var args = line.split(",");
        var reqId = parseInt(args[1]);
        evtREQOK(reqId);
      }
    } else if (line.startsWith("PROBE")) {
      evtPROBE();
    } else if (line.startsWith("LOOP")) {
      // LOOP,<delay [ms]>
      var args = line.split(",");
      var pollingMs = new Millis(parseInt(args[1]));
      evtLOOP(pollingMs);
    } else if (line.startsWith("CONOK")) {
      // CONOK,<session id>,<request limit>,<keepalive/idle timeout [ms]>,(*|<control link>)
      var args = line.split(",");
      var sessionId = args[1];
      var reqLimit = parseInt(args[2]);
      var keepalive = new Millis(parseInt(args[3]));
      var clink = args[4];
      evtCONOK(sessionId, reqLimit, keepalive, clink);
    } else if (line.startsWith("WSOK")) {
      evtWSOK();
    } else if (line.startsWith("SERVNAME")) {
      var args = line.split(",");
      var serverName = args[1];
      evtSERVNAME(serverName);
    } else if (line.startsWith("CLIENTIP")) {
      var args = line.split(",");
      var ip = args[1];
      evtCLIENTIP(ip);
    } else if (line.startsWith("CONS")) {
      // CONS,(unmanaged|unlimited|<bandwidth>)
      var args = line.split(",");
      var bw = args[1];
      switch bw {
      case "unlimited":
        evtCONS(BWUnlimited);
      case "unmanaged":
        evtCONS(BWUnmanaged);
      default:
        var n = parseFloat(bw);
        evtCONS(BWLimited(n));
      }
    } else if (line.startsWith("MSGDONE")) {
      // MSGDONE,(*|<sequence>),<prog>
      var args = line.split(",");
      var seq = args[1];
      if (seq == "*") {
        seq = "UNORDERED_MESSAGES";
      }
      var prog = parseInt(args[2]);
      evtMSGDONE(seq, prog);
    } else if (line.startsWith("MSGFAIL")) {
      // MSGFAIL,(*|<sequence>),<prog>,<code>,<message>
      var args = line.split(",");
      var seq = args[1];
      if (seq == "*") {
        seq = "UNORDERED_MESSAGES";
      }
      var prog = parseInt(args[2]);
      var errorCode = parseInt(args[3]);
      var errorMsg = args[4].urlDecode();
      evtMSGFAIL(seq, prog, errorCode, errorMsg);
    } else if (line.startsWith("REQERR")) {
      // REQERR,<request id>,<code>,<message>
      var args = line.split(",");
      var reqId = parseInt(args[1]);
      var code = parseInt(args[2]);
      var msg = args[3].urlDecode();
      evtREQERR(reqId, code, msg);
    } else if (line.startsWith("PROG")) {
      // PROG,<prog>
      var args = line.split(",");
      var prog = parseInt(args[1]);
      evtPROG(prog);
    } else if (line.startsWith("SUBOK")) {
      // SUBOK,<subscription id>,<total items>,<total fields>
      var args = line.split(",");
      var subId = parseInt(args[1]);
      var nItems = parseInt(args[2]);
      var nFields = parseInt(args[3]);
      evtSUBOK(subId, nItems, nFields);
    } else if (line.startsWith("SUBCMD")) {
      // SUBCMD,<subscription id>,<total items>,<total fields>,<key index>,<command index>
      var args = line.split(",");
      var subId = parseInt(args[1]);
      var nItems = parseInt(args[2]);
      var nFields = parseInt(args[3]);
      var keyIdx = parseInt(args[4]);
      var cmdIdx = parseInt(args[5]);
      evtSUBCMD(subId, nItems, nFields, keyIdx, cmdIdx);
    } else if (line.startsWith("UNSUB")) {
      // UNSUB,<subscription id>
      var args = line.split(",");
      var subId = parseInt(args[1]);
      evtUNSUB(subId);
    } else if (line.startsWith("CONF")) {
      // CONF,<subscription id>,(unlimited|<frequency>),(filtered|unfiltered)
      var args = line.split(",");
      var subId = parseInt(args[1]);
      if (args[2] == "unlimited") {
        evtCONF(subId, RFreqUnlimited);
      } else {
        var freq = parseFloat(args[2]);
        evtCONF(subId, RFreqLimited(freq));
      }
    } else if (line.startsWith("EOS")) {
      // EOS,<subscription id>,<item index>
      var args = line.split(",");
      var subId = parseInt(args[1]);
      var itemIdx = parseInt(args[2]);
      evtEOS(subId, itemIdx);
    } else if (line.startsWith("CS")) {
      // CS,<subscription id>,<item index>
      var args = line.split(",");
      var subId = parseInt(args[1]);
      var itemIdx = parseInt(args[2]);
      evtCS(subId, itemIdx);
    } else if (line.startsWith("OV")) {
      // OV,<subscription id>,<item index>,<lost updates>
      var args = line.split(",");
      var subId = parseInt(args[1]);
      var itemIdx = parseInt(args[2]);
      var lostUpdates = parseInt(args[3]);
      evtOV(subId, itemIdx, lostUpdates);
    } else if (line.startsWith("NOOP")) {
      evtNOOP();
    } else if (line.startsWith("CONERR")) {
      // CONERR,<code>,<message>
      var args = line.split(",");
      var code = parseInt(args[1]);
      var msg = args[2].urlDecode();
      evtCONERR(code, msg);
    } else if (line.startsWith("END")) {
      // END,<code>,<message>
      var args = line.split(",");
      var code = parseInt(args[1]);
      var msg = args[2].urlDecode();
      evtEND(code, msg);
    } else if (line.startsWith("ERROR")) {
      // ERROR,<code>,<message>
      var args = line.split(",");
      var code = parseInt(args[1]);
      var msg = args[2].urlDecode();
      evtERROR(code, msg);
    } else if (line.startsWith("SYNC")) {
      // SYNC,<elapsed time [sec]>
      var args = line.split(",");
      var seconds = parseInt(args[1]);
      evtSYNC(seconds);
    } else {
      matched = false;
    }
    return matched;
  }

  function evtCtrlMessage(line: String) {
    if (line.startsWith("REQOK")) {
      // REQOK,<request id>
      if (line == "REQOK") {
        evtREQOK_withoutReqId();
      } else {
        var args = line.split(",");
        var reqId = parseInt(args[1]);
        evtREQOK(reqId);
      }
    } else if (line.startsWith("REQERR")) {
      // REQERR,<request id>,<code>,<message>
      var args = line.split(",");
      var reqId = parseInt(args[1]);
      var code = parseInt(args[2]);
      var msg = args[3].urlDecode();
      evtREQERR(reqId, code, msg);
    } else if (line.startsWith("ERROR")) {
      // ERROR,<code>,<message>
      var args = line.split(",");
      var code = parseInt(args[1]);
      var msg = args[2].urlDecode();
      evtERROR(code, msg);
    }
  }

  function evtTransportTimeout() {
    traceEvent("transport.timeout");
    switch state.s_m {
    case s120, s121:
      suspendWS_Streaming();
      disposeWS();
      cause = "ws.unavailable";
      goto(state.s_m = s115);
      cancel_evtTransportTimeout();
      entry_m115(ws_unavailable);
    case s122:
      disposeWS();
      notifyStatus(DISCONNECTED_WILL_RETRY);
      cause = "ws.timeout";
      goto(state.s_m = s112);
      cancel_evtTransportTimeout();
      entry_m112(ws_timeout);
    case s130:
      disposeHTTP();
      notifyStatus(DISCONNECTED_WILL_RETRY);
      cause = "http.timeout";
      goto(state.s_m = s112);
      cancel_evtTransportTimeout();
      entry_m112(http_timeout);
    case s140:
      disposeHTTP();
      notifyStatus(DISCONNECTED_WILL_RETRY);
      cause = "ttl.timeout";
      var pauseMs = waitingInterval(delayCounter.currentRetryDelay, connectTs);
      goto(state.s_m = s111);
      cancel_evtTransportTimeout();
      entry_m111(http_error, pauseMs);
    case s150:
      switch state.s_tr {
      case s220:
        if (options.sessionRecoveryTimeout == 0) {
          disposeHTTP();
          notifyStatus(DISCONNECTED_WILL_RETRY);
          cause = "http.timeout";
          state.goto_m_from_session(s112);
          cancel_evtTransportTimeout();
          evtEndSession();
          entry_m112(http_timeout);
        } else {
          disposeHTTP();
          notifyStatus(DISCONNECTED_TRYING_RECOVERY);
          cause = "http.timeout";
          var pauseMs = randomGenerator(options.firstRetryMaxDelay);
          state.goto_rec();
          cancel_evtTransportTimeout();
          entry_rec(pauseMs, http_timeout);
        }
      case s230:
        if (options.sessionRecoveryTimeout == 0) {
          disposeHTTP();
          notifyStatus(DISCONNECTED_WILL_RETRY);
          cause = "ttl.timeout";
          state.goto_m_from_session(s112);
          cancel_evtTransportTimeout();
          evtEndSession();
          entry_m112(http_timeout);
        } else {
          disposeHTTP();
          notifyStatus(DISCONNECTED_TRYING_RECOVERY);
          cause = "ttl.timeout";
          var pauseMs = randomGenerator(options.firstRetryMaxDelay);
          state.goto_rec();
          cancel_evtTransportTimeout();
          entry_rec(pauseMs, http_error);
        }
      case s240:
        switch state.s_ws?.m {
        case s500:
          disableWS();
          disposeWS();
          cause = "ws.unavailable";
          state.clear_ws();
          goto(state.s_tr = s200);
          cancel_evtTransportTimeout();
          evtSwitchTransport();
        case s501:
          if (options.sessionRecoveryTimeout == 0) {
            disableWS();
            disposeWS();
            notifyStatus(DISCONNECTED_WILL_RETRY);
            cause = "ws.unavailable";
            state.goto_m_from_ws(s112);
            exit_ws_to_m();
            entry_m112(ws_unavailable);
          } else {
            disableWS();
            disposeWS();
            notifyStatus(DISCONNECTED_TRYING_RECOVERY);
            cause = "ws.unavailable";
            var pauseMs = randomGenerator(options.firstRetryMaxDelay);
            state.goto_rec_from_ws();
            exit_ws();
            entry_rec(pauseMs, ws_unavailable);
          }
        case s502:
          if (options.sessionRecoveryTimeout == 0) {
            disposeWS();
            notifyStatus(DISCONNECTED_WILL_RETRY);
            cause = "ws.timeout";
            state.goto_m_from_ws(s112);
            exit_ws_to_m();
            entry_m112(ws_timeout);
          } else {
            disposeWS();
            notifyStatus(DISCONNECTED_TRYING_RECOVERY);
            cause = "ws.timeout";
            var pauseMs = randomGenerator(options.firstRetryMaxDelay);
            state.goto_rec_from_ws();
            exit_ws();
            entry_rec(pauseMs, ws_timeout);
          }
        default:
          // ignore
        }
      case s250:
        switch state.s_wp?.m {
        case s600, s601:
          disableWS();
          disposeWS();
          cause = "ws.unavailable";
          state.clear_wp();
          goto(state.s_tr = s200);
          exit_wp();
          evtSwitchTransport();
        default:
          // ignore
        }
      case s260:
        if (state.s_rec == s1001) {
          disposeHTTP();
          goto(state.s_rec = s1002);
          cancel_evtTransportTimeout();
          evtCheckRecoveryTimeout(RRC_transport_timeout);
        }
      case s270:
        switch state.s_h {
        case s710:
          switch state.s_hs?.m {
          case s800:
            disableHTTP_Streaming();
            disposeHTTP();
            cause = "http.streaming.unavailable";
            goto(state.s_hs.m = s801);
            cancel_evtTransportTimeout();
            evtForcePolling();
            schedule_evtTransportTimeout(options.retryDelay);
          case s801:
            if (options.sessionRecoveryTimeout == 0) {
              disposeHTTP();
              notifyStatus(DISCONNECTED_WILL_RETRY);
              cause = "http.timeout";
              state.goto_m_from_hs(s112);
              exit_hs_to_m();
              entry_m112(http_timeout);
            } else {
              disposeHTTP();
              notifyStatus(DISCONNECTED_TRYING_RECOVERY);
              cause = "http.timeout";
              var pauseMs = randomGenerator(options.firstRetryMaxDelay);
              state.goto_rec_from_hs();
              exit_hs_to_rec();
              entry_rec(pauseMs, http_timeout);
            }
          default:
            // ignore
          }
        default:
          // ignore
        }
      default:
        // ignore
      }
    default:
      // ignore
    }
  }

  function evtTransportError() {
    traceEvent("transport.error");
    switch state.s_m {
    case s120, s121:
      suspendWS_Streaming();
      disposeWS();
      cause = "ws.unavailable";
      goto(state.s_m = s115);
      cancel_evtTransportTimeout();
      evtRetry(ws_unavailable);
      evtRetryTimeout();
    case s122:
      disposeWS();
      notifyStatus(DISCONNECTED_WILL_RETRY);
      cause = "ws.error";
      var pauseMs = waitingInterval(delayCounter.currentRetryDelay, connectTs);
      goto(state.s_m = s112);
      cancel_evtTransportTimeout();
      evtRetry(ws_error, pauseMs);
      schedule_evtRetryTimeout(pauseMs);
    case s130:
      disposeHTTP();
      notifyStatus(DISCONNECTED_WILL_RETRY);
      cause = "http.error";
      var pauseMs = waitingInterval(delayCounter.currentRetryDelay, connectTs);
      goto(state.s_m = s112);
      cancel_evtTransportTimeout();
      evtRetry(http_error, pauseMs);
      schedule_evtRetryTimeout(pauseMs);
    case s140:
      disposeHTTP();
      notifyStatus(DISCONNECTED_WILL_RETRY);
      cause = "ttl.error";
      var pauseMs = waitingInterval(delayCounter.currentRetryDelay, connectTs);
      goto(state.s_m = s111);
      cancel_evtTransportTimeout();
      evtRetry(http_error, pauseMs);
      schedule_evtRetryTimeout(pauseMs);
    case s150:
      switch state.s_tr {
      case s210:
        if (options.sessionRecoveryTimeout == 0) {
          disposeWS();
          notifyStatus(DISCONNECTED_WILL_RETRY);
          cause = "ws.error";
          state.clear_w();
          state.goto_m_from_session(s113);
          exit_w();
          evtEndSession();
          entry_m113(ws_error);
        } else {
          disposeWS();
          notifyStatus(DISCONNECTED_TRYING_RECOVERY);
          cause = "ws.error";
          var pauseMs = randomGenerator(options.firstRetryMaxDelay);
          state.clear_w();
          goto({
            state.s_tr = s260;
            state.s_rec = s1000;
          });
          exit_w();
          entry_rec(pauseMs, ws_error);
        }
      case s220:
        if (options.sessionRecoveryTimeout == 0) {
          disposeHTTP();
          notifyStatus(DISCONNECTED_WILL_RETRY);
          cause = "http.error";
          var pauseMs = waitingInterval(delayCounter.currentRetryDelay, connectTs);
          state.goto_m_from_session(s112);
          cancel_evtTransportTimeout();
          evtEndSession();
          evtRetry(http_error, pauseMs);
          schedule_evtRetryTimeout(pauseMs);
        } else {
          disposeHTTP();
          notifyStatus(DISCONNECTED_TRYING_RECOVERY);
          cause = "http.error";
          var pauseMs = randomGenerator(options.firstRetryMaxDelay);
          state.goto_rec();
          cancel_evtTransportTimeout();
          entry_rec(pauseMs, http_error);
        }
      case s230:
        if (options.sessionRecoveryTimeout == 0) {
          disposeHTTP();
          notifyStatus(DISCONNECTED_WILL_RETRY);
          cause = "ttl.error";
          var pauseMs = waitingInterval(delayCounter.currentRetryDelay, connectTs);
          state.goto_m_from_session(s112);
          cancel_evtTransportTimeout();
          evtEndSession();
          evtRetry(http_error, pauseMs);
          schedule_evtRetryTimeout(pauseMs);
        } else {
          disposeHTTP();
          notifyStatus(DISCONNECTED_TRYING_RECOVERY);
          cause = "ttl.error";
          var pauseMs = randomGenerator(options.firstRetryMaxDelay);
          state.goto_rec();
          cancel_evtTransportTimeout();
          entry_rec(pauseMs, http_error);
        }
      case s240:
        switch state.s_ws.sure().m {
        case s500:
          disableWS();
          disposeWS();
          cause = "ws.unavailable";
          state.clear_ws();
          goto(state.s_tr = s200);
          cancel_evtTransportTimeout();
          evtSwitchTransport();
        case s501:
          if (options.sessionRecoveryTimeout == 0) {
            disableWS();
            disposeWS();
            notifyStatus(DISCONNECTED_WILL_RETRY);
            cause = "ws.unavailable";
            state.goto_m_from_ws(s112);
            exit_ws_to_m();
            entry_m112(ws_unavailable);
          } else {
            disableWS();
            disposeWS();
            notifyStatus(DISCONNECTED_TRYING_RECOVERY);
            cause = "ws.unavailable";
            var pauseMs = randomGenerator(options.firstRetryMaxDelay);
            state.goto_rec_from_ws();
            exit_ws();
            entry_rec(pauseMs, ws_unavailable);
          }
        case s502:
          if (options.sessionRecoveryTimeout == 0) {
            disposeWS();
            notifyStatus(DISCONNECTED_WILL_RETRY);
            cause = "ws.error";
            state.goto_m_from_ws(s112);
            exit_ws_to_m();
            entry_m112(ws_error);
          } else {
            disposeWS();
            notifyStatus(DISCONNECTED_TRYING_RECOVERY);
            cause = "ws.error";
            var pauseMs = randomGenerator(options.firstRetryMaxDelay);
            state.goto_rec_from_ws();
            cancel_evtTransportTimeout();
            entry_rec(pauseMs, ws_error);
          }
        case s503:
          if (options.sessionRecoveryTimeout == 0) {
            disposeWS();
            notifyStatus(DISCONNECTED_WILL_RETRY);
            cause = "ws.error";
            state.goto_m_from_ws(s113);
            exit_ws_to_m();
            entry_m113(ws_error);
          } else {
            disposeWS();
            notifyStatus(DISCONNECTED_TRYING_RECOVERY);
            cause = "ws.error";
            var pauseMs = randomGenerator(options.firstRetryMaxDelay);
            state.goto_rec_from_ws();
            exit_ws();
            entry_rec(pauseMs, ws_error);
          }
        }
      case s250:
        switch state.s_wp.sure().m {
        case s600, s601:
          disableWS();
          disposeWS();
          cause = "ws.unavailable";
          state.clear_wp();
          goto(state.s_tr = s200);
          cancel_evtTransportTimeout();
          evtSwitchTransport();
        case s602:
          if (options.sessionRecoveryTimeout == 0) {
            disposeWS();
            notifyStatus(DISCONNECTED_WILL_RETRY);
            cause = "ws.error";
            state.goto_m_from_wp(s113);
            exit_wp_to_m();
            entry_m113(ws_error);
          } else {
            disposeWS();
            notifyStatus(DISCONNECTED_TRYING_RECOVERY);
            cause = "ws.error";
            var pauseMs = randomGenerator(options.firstRetryMaxDelay);
            state.goto_rec_from_wp();
            exit_wp();
            entry_rec(pauseMs, ws_error);
          }
        }
      case s260:
        if (state.s_rec == s1001) {
          disposeHTTP();
          goto(state.s_rec = s1002);
          cancel_evtTransportTimeout();
          evtCheckRecoveryTimeout(RRC_transport_error);
        }
      case s270:
        switch state.s_h.sure() {
        case s710:
          switch state.s_hs.sure().m {
          case s800, s801:
            if (options.sessionRecoveryTimeout == 0) {
              disposeHTTP();
              notifyStatus(DISCONNECTED_WILL_RETRY);
              cause = "http.error";
              state.goto_m_from_hs(s112);
              exit_hs_to_m();
              entry_m112(http_error);
            } else {
              disposeHTTP();
              notifyStatus(DISCONNECTED_TRYING_RECOVERY);
              cause = "http.error";
              var pauseMs = randomGenerator(options.firstRetryMaxDelay);
              state.goto_rec_from_hs();
              exit_hs_to_rec();
              entry_rec(pauseMs, http_error);
            }
          case s802:
            if (options.sessionRecoveryTimeout == 0) {
              disposeHTTP();
              notifyStatus(DISCONNECTED_WILL_RETRY);
              cause = "http.error";
              state.goto_m_from_hs(s113);
              exit_hs_to_m();
              entry_m113(http_error);
            } else {
              disposeHTTP();
              notifyStatus(DISCONNECTED_TRYING_RECOVERY);
              cause = "http.error";
              var pauseMs = randomGenerator(options.firstRetryMaxDelay);
              state.goto_rec_from_hs();
              exit_hs_to_rec();
              entry_rec(pauseMs, http_error);
            }
          }
        case s720:
          switch state.s_hp.sure().m {
          case s900, s901, s902, s903, s904:
            if (options.sessionRecoveryTimeout == 0) {
              disposeHTTP();
              notifyStatus(DISCONNECTED_WILL_RETRY);
              cause = "http.error";
              state.goto_m_from_hp(s112);
              exit_hp_to_m();
              entry_m112(http_error);
            } else {
              disposeHTTP();
              notifyStatus(DISCONNECTED_TRYING_RECOVERY);
              cause = "http.error";
              var pauseMs = randomGenerator(options.firstRetryMaxDelay);
              state.goto_rec_from_hp();
              exit_hp_to_rec();
              entry_rec(pauseMs, http_error);
            }
          }
        }
      default:
        // ignore
      }
    default:
      // ignore
    }
  }

  function evtIdleTimeout() {
    traceEvent("idle.timeout");
    if (switch state.s_wp?.p {
      case s610, s611, s613: true;
      default: false;
    }) {
      if (options.sessionRecoveryTimeout == 0) {
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = "ws.idle.timeout";
        state.goto_m_from_wp(s113);
        exit_wp_to_m();
        entry_m113(idle_timeout);
      } else {
        disposeWS();
        notifyStatus(DISCONNECTED_TRYING_RECOVERY);
        cause = "ws.idle.timeout";
        var pauseMs = randomGenerator(options.firstRetryMaxDelay);
        state.goto_rec_from_wp();
        exit_wp();
        entry_rec(pauseMs, idle_timeout);
      }
    } else if (switch state.s_hp?.m {
      case s900, s901, s903: true;
      default: false;
    }) {
      if (options.sessionRecoveryTimeout == 0) {
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = "http.idle.timeout";
        state.goto_m_from_hp(s112);
        exit_hp_to_m();
        entry_m112(idle_timeout);
      } else {
        disposeHTTP();
        notifyStatus(DISCONNECTED_TRYING_RECOVERY);
        cause = "http.idle.timeout";
        var pauseMs = randomGenerator(options.firstRetryMaxDelay);
        state.goto_rec_from_hp();
        exit_hp_to_rec();
        entry_rec(pauseMs, idle_timeout);
      }
    }
  }

  function evtPollingTimeout() {
    traceEvent("polling.timeout");
    if (state.s_wp?.p == s612) {
      sendBindWS_Polling();
      goto(state.s_wp.p = s613);
      cancel_evtPollingTimeout();
      schedule_evtIdleTimeout(idleTimeout.sure() + options.retryDelay);
    } else if (state.s_hp?.m == s902) {
      sendBindHTTP_Polling();
      goto(state.s_hp.m = s903);
      cancel_evtPollingTimeout();
      schedule_evtIdleTimeout(idleTimeout.sure() + options.retryDelay);
    }
  }

  function evtKeepaliveTimeout() {
    traceEvent("keepalive.timeout");
    if (state.s_w?.k == s310) {
      goto(state.s_w.k = s311);
      cancel_evtKeepaliveTimeout();
      schedule_evtStalledTimeout(options.stalledTimeout);
    } else if (state.s_ws?.k == s520) {
      goto(state.s_ws.k = s521);
      cancel_evtKeepaliveTimeout();
      schedule_evtStalledTimeout(options.stalledTimeout);
    } else if (state.s_hs?.k == s820) {
      goto(state.s_hs.k = s821);
      cancel_evtKeepaliveTimeout();
      schedule_evtStalledTimeout(options.stalledTimeout);
    }
  }

  function evtStalledTimeout() {
    traceEvent("stalled.timeout");
    if (state.s_w?.k == s311) {
      goto(state.s_w.k = s312);
      cancel_evtStalledTimeout();
      schedule_evtReconnectTimeout(options.reconnectTimeout);
    } else if (state.s_ws?.k == s521) {
      goto(state.s_ws.k = s522);
      cancel_evtStalledTimeout();
      schedule_evtReconnectTimeout(options.reconnectTimeout);
    } else if (state.s_hs?.k == s821) {
      goto(state.s_hs.k = s822);
      cancel_evtStalledTimeout();
      schedule_evtReconnectTimeout(options.reconnectTimeout);
    }
  }

  function evtReconnectTimeout() {
    traceEvent("reconnect.timeout");
    if (state.s_w?.k == s312) {
      if (options.sessionRecoveryTimeout == 0) {
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = "ws.stalled";
        state.goto_m_from_w(s113);
        exit_w_to_m();
        entry_m113(stalled_timeout);
      } else {
        disposeWS();
        notifyStatus(DISCONNECTED_TRYING_RECOVERY);
        cause = "ws.stalled";
        var pauseMs = randomGenerator(options.firstRetryMaxDelay);
        state.goto_rec_from_w();
        exit_w();
        entry_rec(pauseMs, stalled_timeout);
      }
    } else if (state.s_ws?.k == s522) {
      if (options.sessionRecoveryTimeout == 0) {
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = "ws.stalled";
        state.goto_m_from_ws(s113);
        exit_ws_to_m();
        entry_m113(stalled_timeout);
      } else {
        disposeWS();
        notifyStatus(DISCONNECTED_TRYING_RECOVERY);
        cause = "ws.stalled";
        var pauseMs = randomGenerator(options.firstRetryMaxDelay);
        state.goto_rec_from_ws();
        exit_ws();
        entry_rec(pauseMs, stalled_timeout);
      }
    } else if (state.s_hs?.k == s822) {
      if (options.sessionRecoveryTimeout == 0) {
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = "http.stalled";
        state.goto_m_from_hs(s113);
        exit_hs_to_m();
        entry_m113(stalled_timeout);
      } else {
        disposeHTTP();
        notifyStatus(DISCONNECTED_TRYING_RECOVERY);
        cause = "http.stalled";
        var pauseMs = randomGenerator(options.firstRetryMaxDelay);
        state.goto_rec_from_hs();
        exit_hs_to_rec();
        entry_rec(pauseMs, stalled_timeout);
      }
    }
  }

  function evtRestartKeepalive() {
    traceEvent("restart.keepalive");
    if (state.s_w?.k != null) {
      goto(state.s_w.k = s310);
      exit_keepalive_unit();
      schedule_evtKeepaliveTimeout(keepaliveInterval.sure());
    } else if (state.s_ws?.k != null) {
      goto(state.s_ws.k = s520);
      exit_keepalive_unit();
      schedule_evtKeepaliveTimeout(keepaliveInterval.sure());
    } else if (state.s_hs?.k != null) {
      goto(state.s_hs.k = s820);
      exit_keepalive_unit();
      schedule_evtKeepaliveTimeout(keepaliveInterval.sure());
    }
  }

  function evtWSOK() {
    traceEvent("WSOK");
    protocolLogger.logDebug("WSOK");
    switch state.s_m {
      case s121:
        goto(state.s_m = s122);
      case s150:
        switch state.s_tr {
        case s240:
          switch state.s_ws?.m {
          case s501:
            goto(state.s_ws.m = s502);
          default:
            // ignore
          }
        case s250:
          switch state.s_wp?.m {
          case s601:
            sendBindWS_FirstPolling();
            goto({
              state.s_wp.m = s602;
              state.s_wp.p = s610;
              state.s_wp.c = s620;
              state.s_wp.s = s630;
            });
            cancel_evtTransportTimeout();
            evtSendPendingControls();
            evtSendPendingMessages();
            schedule_evtIdleTimeout(idleTimeout.sure() + options.retryDelay);
          default:
            // ignore
          }
        default:
          // ignore
        }
      default:
        // ignore
      }
  }

  function evtCONERR(code: Int, msg: String) {
    traceEvent("CONERR");
    protocolLogger.logDebug('CONERR $code $msg');
    var retryCause = RetryCause.standardError(code, msg);
    var terminationCause = TerminationCause.TC_standardError(code, msg);
    if (state.s_m == s122) {
      switch code {
      case 4, 6, 20, 40, 41, 48:
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ws.conerr.$code';
        var pauseMs = waitingInterval(delayCounter.currentRetryDelay, connectTs);
        goto(state.s_m = s112);
        cancel_evtTransportTimeout();
        evtRetry(retryCause, pauseMs);
        schedule_evtRetryTimeout(pauseMs);
      case 5:
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ws.conerr.$code';
        goto(state.s_m = s110);
        cancel_evtTransportTimeout();
        evtRetry(retryCause);
        evtRetryTimeout();
      default:
        disposeWS();
        notifyStatus(DISCONNECTED);
        notifyServerError_CONERR(code, msg);
        goto(state.s_m = s100);
        cancel_evtTransportTimeout();
        evtTerminate(terminationCause);
      }
    } else if (state.s_m == s130) {
      switch code {
      case 4, 6, 20, 40, 41, 48:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'http.conerr.$code';
        var pauseMs = waitingInterval(delayCounter.currentRetryDelay, connectTs);
        goto(state.s_m = s112);
        cancel_evtTransportTimeout();
        evtRetry(retryCause, pauseMs);
        schedule_evtRetryTimeout(pauseMs);
      case 5:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'http.conerr.$code';
        goto(state.s_m = s110);
        cancel_evtTransportTimeout();
        evtRetry(retryCause);
        evtRetryTimeout();
      default:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        notifyServerError_CONERR(code, msg);
        goto(state.s_m = s100);
        cancel_evtTransportTimeout();
        evtTerminate(terminationCause);
      }
    } else if (state.s_m == s140) {
      switch code {
      case 4, 6, 20, 40, 41, 48:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ttl.conerr.$code';
        var pauseMs = waitingInterval(delayCounter.currentRetryDelay, connectTs);
        goto(state.s_m = s112);
        cancel_evtTransportTimeout();
        evtRetry(retryCause, pauseMs);
        schedule_evtRetryTimeout(pauseMs);
      case 5:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ttl.conerr.$code';
        goto(state.s_m = s110);
        cancel_evtTransportTimeout();
        evtRetry(retryCause);
        evtRetryTimeout();
      default:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        notifyServerError_CONERR(code, msg);
        goto(state.s_m = s100);
        cancel_evtTransportTimeout();
        evtTerminate(terminationCause);
      }
    } else if (state.s_ws?.m == s502) {
      switch code {
      case 4,6,20,40,41,48:
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ws.conerr.$code';
        state.goto_m_from_ws(s112);
        exit_ws_to_m();
        entry_m112(standardError(code, msg));
      default:
        disposeWS();
        notifyStatus(DISCONNECTED);
        notifyServerError_CONERR(code, msg);
        state.goto_m_from_ws(s100);
        exit_ws_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_wp?.p == s610 || state.s_wp?.p == s613) {
      switch code {
      case 4,6,20,40,41,48:
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ws.conerr.$code';
        state.goto_m_from_wp(s112);
        exit_wp_to_m();
        entry_m112(standardError(code, msg));
      default:
        disposeWS();
        notifyStatus(DISCONNECTED);
        notifyServerError_CONERR(code, msg);
        state.goto_m_from_wp(s100);
        exit_wp_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_hs?.m == s800 || state.s_hs?.m == s801) {
      switch code {
      case 4,6,20,40,41,48:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'http.conerr.$code';
        state.goto_m_from_hs(s112);
        exit_hs_to_m();
        entry_m112(standardError(code, msg));
      default:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        notifyServerError_CONERR(code, msg);
        state.goto_m_from_hs(s100);
        exit_hs_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_hp?.m == s900 || state.s_hp?.m == s903) {
      switch code {
      case 4,6,20,40,41,48:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'http.conerr.$code';
        state.goto_m_from_hp(s112);
        exit_hp_to_m();
        entry_m112(standardError(code, msg));
      default:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        notifyServerError_CONERR(code, msg);
        state.goto_m_from_hp(s100);
        exit_hp_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_rec == s1001) {
      switch code {
      case 4, 6, 20, 40, 41, 48:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'recovery.conerr.$code';
        state.goto_m_from_rec(s113);
        exit_rec_to_m();
        entry_m113(retryCause);
      default:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        notifyServerError_CONERR(code, msg);
        state.goto_m_from_rec(s100);
        exit_rec_to_m();
        evtTerminate(terminationCause);
      }
    }
  }

  function evtEND(code: Int, msg: String) {
    traceEvent("END");
    protocolLogger.logDebug('END $code $msg');
    var retryCause = RetryCause.standardError(code, msg);
    var terminationCause = TerminationCause.TC_standardError(code, msg);
    if (state.s_w?.p == s300) {
      switch code {
      case 41, 48:
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ws.end.$code';
        var pauseMs = randomGenerator(options.firstRetryMaxDelay);
        state.clear_w();
        state.goto_m_from_session(s113);
        exit_w();
        evtEndSession();
        evtRetry(standardError(code, msg), pauseMs);
        schedule_evtRetryTimeout(pauseMs);
      default:
        disposeWS();
        notifyStatus(DISCONNECTED);
        notifyServerError_END(code, msg);
        state.clear_w();
        state.goto_m_from_session(s100);
        exit_w();
        evtEndSession();
        evtTerminate(terminationCause);
      }
    } else if (state.s_ws?.m == s502) {
      switch code {
      case 41, 48:
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ws.end.$code';
        state.goto_m_from_ws(s112);
        exit_ws_to_m();
        entry_m112(standardError(code, msg));
      default:
        disposeWS();
        notifyStatus(DISCONNECTED);
        notifyServerError_END(code, msg);
        state.goto_m_from_ws(s100);
        exit_ws_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_ws?.p == s510) {
      switch code {
      case 41, 48:
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ws.end.$code';
        state.goto_m_from_ws(s113);
        exit_ws_to_m();
        entry_m113(retryCause);
      default:
        disposeWS();
        notifyStatus(DISCONNECTED);
        notifyServerError_END(code, msg);
        state.goto_m_from_ws(s100);
        exit_ws_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_wp?.p == s610 || state.s_wp?.p == s613) {
      switch code {
      case 41, 48:
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ws.end.$code';
        state.goto_m_from_wp(s112);
        exit_wp_to_m();
        entry_m112(standardError(code, msg));
      default:
        disposeWS();
        notifyStatus(DISCONNECTED);
        notifyServerError_END(code, msg);
        state.goto_m_from_wp(s100);
        exit_wp_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_wp?.p == s611) {
      switch code {
      case 41, 48:
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ws.end.$code';
        state.goto_m_from_wp(s113);
        exit_wp_to_m();
        entry_m113(retryCause);
      default:
        disposeWS();
        notifyStatus(DISCONNECTED);
        notifyServerError_END(code, msg);
        state.goto_m_from_wp(s100);
        exit_wp_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_hs?.m == s800 || state.s_hs?.m == s801) {
      switch code {
      case 41, 48:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'http.end.$code';
        state.goto_m_from_hs(s112);
        exit_hs_to_m();
        entry_m112(standardError(code, msg));
      default:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        notifyServerError_END(code, msg);
        state.goto_m_from_hs(s100);
        exit_hs_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_hs?.p == s810) {
      switch code {
      case 41, 48:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'http.end.$code';
        state.goto_m_from_hs(s113);
        exit_hs_to_m();
        entry_m113(retryCause);
      default:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        notifyServerError_END(code, msg);
        state.goto_m_from_hs(s100);
        exit_hs_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_hp?.m == s900 || state.s_hp?.m == s903) {
      switch code {
      case 41, 48:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'http.end.$code';
        state.goto_m_from_hp(s112);
        exit_hp_to_m();
        entry_m112(standardError(code, msg));
      default:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        notifyServerError_END(code, msg);
        state.goto_m_from_hp(s100);
        exit_hp_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_hp?.m == s901) {
      switch code {
      case 41, 48:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'http.end.$code';
        state.goto_m_from_hp(s113);
        exit_hp_to_m();
        entry_m113(retryCause);
      default:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        notifyServerError_END(code, msg);
        state.goto_m_from_hp(s100);
        exit_hp_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_rec == s1001) {
      switch code {
      case 41, 48:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'recovery.end.$code';
        state.goto_m_from_rec(s113);
        exit_rec_to_m();
        entry_m113(retryCause);
      default:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        notifyServerError_END(code, msg);
        state.goto_m_from_rec(s100);
        exit_rec_to_m();
        evtTerminate(terminationCause);
      }
    }
  }

  function evtERROR(code: Int, msg: String) {
    traceEvent("ERROR");
    protocolLogger.logDebug('ERROR $code $msg');
    var terminationCause = TC_standardError(code, msg);
    if (state.s_w?.p == s300) {
      disposeWS();
      notifyStatus(DISCONNECTED);
      notifyServerError_ERROR(code, msg);
      state.clear_w();
      state.goto_m_from_session(s100);
      exit_w();
      evtEndSession();
      evtTerminate(terminationCause);
    } else if (state.s_ws?.p == s510) {
      disposeWS();
      notifyStatus(DISCONNECTED);
      notifyServerError_ERROR(code, msg);
      state.goto_m_from_ws(s100);
      exit_ws_to_m();
      evtTerminate(terminationCause);
    } else if (state.s_wp?.c == s620) {
      disposeWS();
      notifyStatus(DISCONNECTED);
      notifyServerError_ERROR(code, msg);
      state.goto_m_from_wp(s100);
      exit_wp_to_m();
      evtTerminate(terminationCause);
    } else if (state.s_ctrl == s1102) {
      disposeHTTP();
      notifyStatus(DISCONNECTED);
      notifyServerError_ERROR(code, msg);
      state.goto_m_from_ctrl(s100);
      exit_ctrl_to_m();
      evtTerminate(terminationCause);
    }
  }

  function evtREQOK_withoutReqId() {
    traceEvent("REQOK");
    protocolLogger.logDebug("REQOK");
    if (state.s_ctrl == s1102) {
      // heartbeat response (only in HTTP)
      goto(state.s_ctrl = s1102);
    }
  }

  function evtREQOK(reqId: Int) {
    traceEvent("REQOK");
    protocolLogger.logDebug("REQOK " + reqId);
    var forward = true;
    if (state.s_swt == s1302 && reqId == swt_lastReqId) {
      goto(state.s_swt = s1303);
      forward = evtREQOK_TransportRegion(reqId);
    } else if (state.s_bw == s1202 && reqId == bw_lastReqId) {
      goto(state.s_bw = s1200);
      forward = evtREQOK_TransportRegion(reqId);
      evtCheckBW();
    } else {
      forward = evtREQOK_Forward(reqId);
    }
    if (forward) {
      forward = evtREQOK_TransportRegion(reqId);
    }
  }

  function evtREQOK_Forward(reqId: Int) {
    return true;
  }

  function evtREQOK_TransportRegion(reqId: Int) {
    if (state.s_w?.p == s300) {
      goto(state.s_w.p = s300);
      doREQOK(reqId);
      evtRestartKeepalive();
    } else if (state.s_ws?.p == s510) {
      goto(state.s_ws.p = s510);
      doREQOK(reqId);
      evtRestartKeepalive();
    } else if (state.s_wp?.c == s620) {
      goto(state.s_wp.c = s620);
      doREQOK(reqId);
    } else if (state.s_ctrl == s1102) {
      goto(state.s_ctrl = s1102);
      doREQOK(reqId);
    }
    return false;
  }

  function evtREQERR(reqId: Int, code: Int, msg: String) {
    traceEvent("REQERR");
    protocolLogger.logDebug('REQERR $reqId $code $msg');
    var forward = true;
    if (state.s_swt == s1302 && reqId == swt_lastReqId) {
      goto(state.s_swt = s1301);
      forward = evtREQERR_TransportRegion(reqId, code, msg);
    } else if (state.s_bw == s1202 && reqId == bw_lastReqId) {
      goto(state.s_bw = s1200);
      forward = evtREQERR_TransportRegion(reqId, code, msg);
      evtCheckBW();
    } else {
      forward = evtREQERR_Forward(reqId, code, msg);
    }
    if (forward) {
      forward = evtREQERR_TransportRegion(reqId, code, msg);
    }
  }

  function evtREQERR_Forward(reqId: Int, code: Int, msg: String) {
    return true;
  }

  function evtREQERR_TransportRegion(reqId: Int, code: Int, msg: String) {
    var retryCause = RetryCause.standardError(code, msg);
    var terminationCause = TerminationCause.TC_standardError(code, msg);
    if (state.s_w?.p == s300) {
      switch code {
      case 20:
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ws.reqerr.$code';
        var pauseMs = randomGenerator(options.firstRetryMaxDelay);
        state.clear_w();
        state.goto_m_from_session(s113);
        exit_w();
        evtEndSession();
        evtRetry(standardError(code, msg), pauseMs);
        schedule_evtRetryTimeout(pauseMs);
      case 11, 65, 67:
        disposeWS();
        notifyStatus(DISCONNECTED);
        notifyServerError_REQERR(code, msg);
        state.clear_w();
        state.goto_m_from_session(s100);
        exit_w();
        evtEndSession();
        evtTerminate(terminationCause);
      default:
        goto(state.s_w.p = s300);
        doREQERR(reqId, code, msg);
        evtRestartKeepalive();
      }
    } else if (state.s_ws?.p == s510) {
      switch code {
      case 20:
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ws.reqerr.$code)';
        state.goto_m_from_ws(s113);
        exit_ws_to_m();
        entry_m113(retryCause);
      case 11, 65, 67:
        disposeWS();
        notifyStatus(DISCONNECTED);
        notifyServerError_REQERR(code, msg);
        state.goto_m_from_ws(s100);
        exit_ws_to_m();
        evtTerminate(terminationCause);
      default:
        goto(state.s_ws.p = s510);
        doREQERR(reqId, code, msg);
        evtRestartKeepalive();
      }
    } else if (state.s_wp?.c == s620) {
      switch code {
      case 20:
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'ws.reqerr.$code';
        state.goto_m_from_wp(s113);
        exit_wp_to_m();
        entry_m113(retryCause);
      case 11, 65, 67:
        disposeWS();
        notifyStatus(DISCONNECTED);
        notifyServerError_REQERR(code, msg);
        state.goto_m_from_wp(s100);
        exit_wp_to_m();
        evtTerminate(terminationCause);
      default:
        goto(state.s_wp.c = s620);
        doREQERR(reqId, code, msg);
      }
    } else if (state.s_ctrl == s1102) {
      switch code {
      case 20:
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'http.reqerr.$code';
        state.goto_m_from_ctrl(s113);
        exit_ctrl_to_m();
        entry_m113(retryCause);
      case 11, 65, 67:
        disposeHTTP();
        notifyStatus(DISCONNECTED);
        notifyServerError_REQERR(code, msg);
        state.goto_m_from_ctrl(s100);
        exit_ctrl_to_m();
        evtTerminate(terminationCause);
      default:
        goto(state.s_ctrl = s1102);
        doREQERR(reqId, code, msg);
      }
    }
    return false;
  }

  function evtPROG(prog: Int) {
    traceEvent("PROG");
    var retryCause = RetryCause.prog_mismatch(rec_serverProg, prog);
    protocolLogger.logDebug('PROG $prog');
    if (state.s_w?.p == s300) {
      if (prog != rec_serverProg) {
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'prog.mismatch.$prog.$rec_serverProg';
        state.clear_w();
        state.goto_m_from_session(s113);
        exit_w();
        evtEndSession();
        entry_m113(retryCause);
      } else {
        goto(state.s_w.p = s300);
        evtRestartKeepalive();
      }
    } else if (state.s_tr == s220) {
      if (prog != rec_serverProg) {
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'prog.mismatch.$prog.$rec_serverProg';
        state.goto_m_from_session(s113);
        cancel_evtTransportTimeout();
        evtEndSession();
        entry_m113(retryCause);
      } else {
        goto(state.s_tr = s220);
      }
    } else if (state.s_tr == s230) {
      if (prog != rec_serverProg) {
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'prog.mismatch.$prog.$rec_serverProg';
        state.goto_m_from_session(s113);
        cancel_evtTransportTimeout();
        evtEndSession();
        entry_m113(retryCause);
      } else {
        goto(state.s_tr = s230);
      }
    } else if (state.s_ws?.p == s510) {
      if (prog != rec_serverProg) {
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'prog.mismatch.$prog.$rec_serverProg';
        state.goto_m_from_ws(s113);
        exit_ws_to_m();
        entry_m113(retryCause);
      } else {
        goto(state.s_ws.p = s510);
        evtRestartKeepalive();
      }
    } else if (state.s_wp?.p == s611) {
      if (prog != rec_serverProg) {
        disposeWS();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'prog.mismatch.$prog.$rec_serverProg';
        state.goto_m_from_wp(s113);
        exit_wp_to_m();
        entry_m113(retryCause);
      } else {
        goto(state.s_wp.p = s611);
      }
    } else if (state.s_hs?.p == s810) {
      if (prog != rec_serverProg) {
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'prog.mismatch.$prog.$rec_serverProg';
        state.goto_m_from_hs(s113);
        exit_hs_to_m();
        entry_m113(retryCause);
      } else {
        goto(state.s_hs.p = s810);
        evtRestartKeepalive();
      }
    } else if (state.s_hp?.m == s901) {
      if (prog != rec_serverProg) {
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'prog.mismatch.$prog.$rec_serverProg';
        state.goto_m_from_hp(s113);
        exit_hp_to_m();
        entry_m113(retryCause);
      } else {
        goto(state.s_hp.m = s901);
      }
    } else if (state.s_rec == s1001) {
      if (prog > rec_clientProg) {
        disposeHTTP();
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = 'prog.mismatch.$prog.$rec_serverProg';
        state.goto_m_from_rec(s113);
        exit_rec_to_m();
        entry_m113(retryCause);
      } else {
        goto(state.s_rec = s1001);
        doPROG(prog);
      }
    }
  }

  function evtLOOP(pollingMs: Millis) {
    traceEvent("LOOP");
    protocolLogger.logDebug('LOOP $pollingMs');
    if (state.s_w?.p == s300) {
      closeWS();
      cause = "ws.loop";
      state.clear_w();
      goto(state.s_tr = s200);
      exit_w();
      evtSwitchTransport();
    } else if (state.s_tr == s220) {
      closeHTTP();
      cause = "http.loop";
      goto(state.s_tr = s200);
      cancel_evtTransportTimeout();
      evtSwitchTransport();
    } else if (state.s_tr == s230) {
      closeHTTP();
      cause = "ttl.loop";
      goto(state.s_tr = s200);
      cancel_evtTransportTimeout();
      evtSwitchTransport();
    } else if (state.s_ws?.p == s510) {
      closeWS();
      cause = "ws.loop";
      state.clear_ws();
      goto(state.s_tr = s200);
      exit_ws();
      evtSwitchTransport();
    } else if (state.s_wp?.p == s611) {
      if (isSwitching()) {
        closeWS();
        cause = "ws.loop";
        state.clear_wp();
        goto(state.s_tr = s200);
        exit_wp();
        evtSwitchTransport();
      } else {
        doLOOP(pollingMs);
        goto(state.s_wp.p = s612);
        cancel_evtIdleTimeout();
        schedule_evtPollingTimeout(options.pollingInterval);
      }
    } else if (state.s_hs?.p == s810) {
      closeHTTP();
      cause = "http.loop";
      goto(state.s_hs.p = s811);
      evtSwitchTransport();
    } else if (state.s_hp?.m == s901) {
      if (isSwitching()) {
        closeHTTP();
        goto(state.s_hp.m = s904);
        cancel_evtIdleTimeout();
        evtSwitchTransport();
      } else {
        doLOOP(pollingMs);
        closeHTTP();
        goto(state.s_hp.m = s902);
        cancel_evtIdleTimeout();
        schedule_evtPollingTimeout(options.pollingInterval);
      }
    } else if (state.s_rec == s1001) {
      closeHTTP();
      cause = "recovery.loop";
      state.goto_200_from_rec();
      exit_rec();
      evtSwitchTransport();
    }
  }

  function evtCONOK(sessionId: String, reqLimit: RequestLimit, keepalive: Millis, clink: String) {
    traceEvent("CONOK");
    protocolLogger.logDebug('CONOK $sessionId $reqLimit $keepalive $clink');
    if (state.s_m == s122) {
      doCONOK_CreateWS(sessionId, reqLimit, keepalive, clink);
      resetCurrentRetryDelay();
      notifyStatus(CONNECTED_STREAM_SENSING);
      notifyStatus(CONNECTED_WS_STREAMING);
      goto({
        state.s_m = s150;
        state.s_tr = s210;
        state.s_w = new StateVar_w(s300, s310, s340);
        state.s_rhb = s320;
        state.s_slw = s330;
        state.s_swt = s1300;
        state.s_bw = s1200;
      });
      cancel_evtTransportTimeout();
      evtSendPendingControls();
      evtSendPendingMessages();
      evtStartSession();
      schedule_evtKeepaliveTimeout(keepaliveInterval.sure());
      evtSelectRhb();
      evtCheckTransport();
      evtCheckBW();
    } else if (state.s_m == s130) {
      doCONOK_CreateHTTP(sessionId, reqLimit, keepalive, clink);
      resetCurrentRetryDelay();
      notifyStatus(CONNECTED_STREAM_SENSING);
      goto({
        state.s_m = s150;
        state.s_tr = s220;
        state.s_swt = s1300;
        state.s_bw = s1200;
      });
      cancel_evtTransportTimeout();
      evtStartSession();
      schedule_evtTransportTimeout(options.retryDelay);
      evtCheckTransport();
      evtCheckBW();
    } else if (state.s_m == s140) {
      doCONOK_CreateHTTP(sessionId, reqLimit, keepalive, clink);
      resetCurrentRetryDelay();
      notifyStatus(CONNECTED_STREAM_SENSING);
      goto({
        state.s_m = s150;
        state.s_tr = s230;
        state.s_swt = s1300;
        state.s_bw = s1200;
      });
      cancel_evtTransportTimeout();
      evtStartSession();
      schedule_evtTransportTimeout(options.retryDelay);
      evtCheckTransport();
      evtCheckBW();
    } else if (state.s_ws?.m == s502) {
      doCONOK_BindWS_Streaming(sessionId, reqLimit, keepalive, clink);
      notifyStatus(CONNECTED_WS_STREAMING);
      goto({
        state.s_ws.m = s503;
        state.s_ws.p = s510;
        state.s_ws.k = s520;
        state.s_ws.s = s550;
        state.s_rhb = s320;
        state.s_slw = s330;
      });
      cancel_evtTransportTimeout();
      evtSendPendingControls();
      evtSendPendingMessages();
      schedule_evtKeepaliveTimeout(keepaliveInterval.sure());
      evtSelectRhb();
    } else if (state.s_wp?.p == s610) {
      doCONOK_BindWS_Polling(sessionId, reqLimit, keepalive, clink);
      notifyStatus(CONNECTED_WS_POLLING);
      goto(state.s_wp.p = s611);
    } else if (state.s_wp?.p == s613) {
      doCONOK_BindWS_Polling(sessionId, reqLimit, keepalive, clink);
      goto(state.s_wp.p = s611);
    } else if (state.s_hs?.m == s800) {
      doCONOK_BindHTTP_Streaming(sessionId, reqLimit, keepalive, clink);
      notifyStatus(CONNECTED_HTTP_STREAMING);
      goto({
        state.s_hs.m = s802;
        state.s_hs.p = s810;
        state.s_hs.k = s820;
        state.s_rhb = s320;
        state.s_slw = s330;
      });
      cancel_evtTransportTimeout();
      schedule_evtKeepaliveTimeout(keepaliveInterval.sure());
      evtSelectRhb();
    } else if (state.s_hs?.m == s801) {
      doCONOK_BindHTTP_Streaming(sessionId, reqLimit, keepalive, clink);
      notifyStatus(CONNECTED_HTTP_STREAMING);
      goto({
        state.s_hs.m = s802;
        state.s_hs.p = s810;
        state.s_hs.k = s820;
        state.s_rhb = s320;
        state.s_slw = s330;
      });
      cancel_evtTransportTimeout();
      schedule_evtKeepaliveTimeout(keepaliveInterval.sure());
      evtSelectRhb();
    } else if (state.s_hp?.m == s900) {
      doCONOK_BindHTTP_Polling(sessionId, reqLimit, keepalive, clink);
      notifyStatus(CONNECTED_HTTP_POLLING);
      goto(state.s_hp.m = s901);
    } else if (state.s_hp?.m == s903) {
      doCONOK_BindHTTP_Polling(sessionId, reqLimit, keepalive, clink);
      goto(state.s_hp.m = s901);
    }
  }

  function evtSERVNAME(serverName: String) {
    traceEvent("SERVNAME");
    protocolLogger.logDebug('SERVNAME $serverName');
    if (state.inPushing()) {
      doSERVNAME(serverName);
      if (state.inStreaming()) {
        evtRestartKeepalive();
      }
    }
  }

  function evtCLIENTIP(clientIp: String) {
    traceEvent("CLIENTIP");
    protocolLogger.logDebug('CLIENTIP $clientIp');
    if (state.inPushing()) {
      doCLIENTIP(clientIp);
      if (state.inStreaming()) {
        evtRestartKeepalive();
      }
    }
  }

  function evtCONS(bandwidth: RealMaxBandwidth) {
    traceEvent("CONS");
    protocolLogger.logDebug('CONS $bandwidth');
    if (state.inPushing()) {
      doCONS(bandwidth);
      if (state.inStreaming()) {
        evtRestartKeepalive();
      }
    }
  }

  function evtPROBE() {
    traceEvent("PROBE");
    protocolLogger.logDebug("PROBE");
    if (state.inPushing()) {
      if (state.inStreaming()) {
        evtRestartKeepalive();
      }
    }
  }

  function evtNOOP() {
    traceEvent("NOOP");
    if (state.inPushing()) {
      if (state.inStreaming()) {
        evtRestartKeepalive();
      }
    }
  }

  function evtSYNC(seconds: Long) {
    traceEvent("SYNC");
    protocolLogger.logDebug('SYNC $seconds');
    var forward = true;
    if (state.s_w?.p == s300 || state.s_ws?.p == s510 || state.s_hs?.p == s810) {
      forward = evtSYNC_PushingRegion(seconds);
      evtRestartKeepalive();
    } else if (state.s_tr == s220 || state.s_tr == s230 || state.s_wp?.p == s611 || state.s_hp?.m == s901 || state.s_rec == s1001) {
      forward = evtSYNC_PushingRegion(seconds);
    }
    if (forward) {
      forward = evtSYNC_PushingRegion(seconds);
    }
  }

  function evtSYNC_PushingRegion(seconds: Long): Bool {
    var syncMs = new TimerMillis(cast seconds * 1_000);
    if (state.s_slw != null) {
      switch state.s_slw {
      case s330:
        doSYNC(syncMs);
        goto(state.s_slw = s331);
      case s331:
        var result = doSYNC_G(syncMs);
        goto(state.s_slw = s332);
        evtCheckAvg(result);
      case s333:
        var result = doSYNC_NG(syncMs);
        goto(state.s_slw = s332);
        evtCheckAvg(result);
      default:
        // ignore
      }
    }
    return false;
  }

  function evtMSGDONE(sequence: String, prog: Int) {
    traceEvent("MSGDONE");
    protocolLogger.logDebug('MSGDONE $sequence $prog');
    if (state.inPushing()) {
      if (isFreshData()) {
        doMSGDONE(sequence, prog);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtMSGFAIL(sequence: String, prog: Int, errorCode: Int, errorMsg: String) {
    traceEvent("MSGFAIL");
    protocolLogger.logDebug('MSGFAIL $sequence $prog $errorCode $errorMsg');
    if (state.inPushing()) {
      if (isFreshData()) {
        doMSGFAIL(sequence, prog, errorCode, errorMsg);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtU(subId: Int, itemIdx: Pos, values: Map<Pos, FieldValue>, rawValue: String) {
    traceEvent("U");
    protocolLogger.logDebug(rawValue);
    if (state.inPushing()) {
      if (isFreshData()) {
        doU(subId, itemIdx, values);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtSUBOK(subId: Int, nItems: Int, nFields: Int) {
    traceEvent("SUBOK");
    protocolLogger.logDebug('SUBOK $subId $nItems $nFields');
    if (state.inPushing()) {
      if (isFreshData()) {
        doSUBOK(subId, nItems, nFields);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtSUBCMD(subId: Int, nItems: Int, nFields: Int, keyIdx: Pos, cmdIdx: Pos) {
    traceEvent("SUBCMD");
    protocolLogger.logDebug('SUBCMD $subId $nItems $nFields $keyIdx $cmdIdx');
    if (state.inPushing()) {
      if (isFreshData()) {
        doSUBCMD(subId, nItems, nFields, keyIdx, cmdIdx);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtUNSUB(subId: Int) {
    traceEvent("UNSUB");
    protocolLogger.logDebug('UNSUB $subId');
    if (state.inPushing()) {
      if (isFreshData()) {
        doUNSUB(subId);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtEOS(subId: Int, itemIdx: Pos) {
    traceEvent("EOS");
    protocolLogger.logDebug('EOS $subId $itemIdx');
    if (state.inPushing()) {
      if (isFreshData()) {
        doEOS(subId, itemIdx);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtCS(subId: Int, itemIdx: Pos) {
    traceEvent("CS");
    protocolLogger.logDebug('CS $subId $itemIdx');
    if (state.inPushing()) {
      if (isFreshData()) {
        doCS(subId, itemIdx);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtOV(subId: Int, itemIdx: Pos, lostUpdates: Int) {
    traceEvent("OV");
    protocolLogger.logDebug('OV $subId $itemIdx $lostUpdates');
    if (state.inPushing()) {
      if (isFreshData()) {
        doOV(subId, itemIdx, lostUpdates);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtCONF(subId: Int, freq: RealMaxFrequency) {
    traceEvent("CONF");
    protocolLogger.logDebug('CONF $subId $freq');
    if (state.inPushing()) {
      if (isFreshData()) {
        doCONF(subId, freq);
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      } else {
        onStaleData();
        if (state.inStreaming()) {
          evtRestartKeepalive();
        }
      }
    }
  }

  function evtCheckAvg(result: SyncCheckResult) {
    traceEvent("check.avg");
    if (state.s_slw == s332) {
      switch result {
      case SCR_good:
        goto(state.s_slw = s331);
      case SCR_not_good:
        goto(state.s_slw = s333);
      case SCR_bad:
        disableStreaming();
        cause = "slow";
        goto(state.s_slw = s334);
        evtForcePolling();
      }
    }
  }

  function evtSendPendingControls() {
    traceEvent("send.pending.controls");
    var controls = getPendingControls();
    if (state.s_w?.s == s340 && !controls.empty()) {
      sendPengingControlsWS(controls);
      goto(state.s_w.s = s340);
      evtRestartHeartbeat();
    } else if (state.s_ws?.s == s550 && !controls.empty()) {
      sendPengingControlsWS(controls);
      goto(state.s_ws.s = s550);
      evtRestartHeartbeat();
    } else if (state.s_wp?.s == s630 && !controls.empty()) {
      sendPengingControlsWS(controls);
      goto(state.s_wp.s = s630);
    }
  }

  function evtSendPendingMessages() {
    traceEvent("send.pending.messages");
    if (state.s_w?.s == s340 && messageManagers.exists(msg -> msg.isPending())) {
      sendPendingMessagesWS();
      goto(state.s_w.s = s340);
      genAckMessagesWS();
      evtRestartHeartbeat();
    } else if (state.s_ws?.s == s550 && messageManagers.exists(msg -> msg.isPending())) {
      sendPendingMessagesWS();
      goto(state.s_ws.s = s550);
      genAckMessagesWS();
      evtRestartHeartbeat();
    } else if (state.s_wp?.s == s630 && messageManagers.exists(msg -> msg.isPending())) {
      sendPendingMessagesWS();
      goto(state.s_wp.s = s630);
      genAckMessagesWS();
    }
  }

  function evtSelectRhb() {
    traceEvent("select.rhb");
    if (state.s_rhb == s320) {
      if (rhb_grantedInterval == 0) {
        if (options.reverseHeartbeatInterval == 0) {
          goto(state.s_rhb = s321);
        } else {
          rhb_currentInterval = options.reverseHeartbeatInterval;
          goto(state.s_rhb = s322);
          schedule_evtRhbTimeout(rhb_currentInterval);
        }
      } else {
        if (options.reverseHeartbeatInterval > 0 && options.reverseHeartbeatInterval < rhb_grantedInterval.sure()) {
          rhb_currentInterval = options.reverseHeartbeatInterval;
          goto(state.s_rhb = s323);
          schedule_evtRhbTimeout(rhb_currentInterval);
        } else {
          rhb_currentInterval = rhb_grantedInterval;
          goto(state.s_rhb = s323);
          schedule_evtRhbTimeout(rhb_currentInterval.sure());
        }
      }
    }
  }

  function evtExtSetReverseHeartbeatInterval() {
    traceEvent("setReverseHeartbeatInterval");
    if (state.s_rhb != null) {
      switch state.s_rhb {
      case s321 if (options.reverseHeartbeatInterval != 0):
        rhb_currentInterval = options.reverseHeartbeatInterval;
        goto(state.s_rhb = s322);
        schedule_evtRhbTimeout(rhb_currentInterval);
      case s322:
        if (options.reverseHeartbeatInterval == 0) {
          goto(state.s_rhb = s321);
          cancel_evtRhbTimeout();
        } else {
          rhb_currentInterval = options.reverseHeartbeatInterval;
          goto(state.s_rhb = s322);
        }
      case s323:
        if (options.reverseHeartbeatInterval > 0 && options.reverseHeartbeatInterval < rhb_grantedInterval.sure()) {
          rhb_currentInterval = options.reverseHeartbeatInterval;
          goto(state.s_rhb = s323);
        } else {
          rhb_currentInterval = rhb_grantedInterval;
          goto(state.s_rhb = s323);
        }
      default:
        // ignore
      }
    }
  }

  function evtRestartHeartbeat() {
    traceEvent("restart.heartbeat");
    if (state.s_rhb != null) {
      switch state.s_rhb {
      case s322:
        goto(state.s_rhb = s322);
        cancel_evtRhbTimeout();
        schedule_evtRhbTimeout(rhb_currentInterval.sure());
      case s323:
        goto(state.s_rhb = s323);
        cancel_evtRhbTimeout();
        schedule_evtRhbTimeout(rhb_currentInterval.sure());
      case s324:
        if (rhb_grantedInterval == 0) {
          if (options.reverseHeartbeatInterval != 0) {
            rhb_currentInterval = options.reverseHeartbeatInterval;
            goto(state.s_rhb = s322);
            schedule_evtRhbTimeout(rhb_currentInterval);
          } else {
            goto(state.s_rhb = s321);
          }
        } else {
          if (options.reverseHeartbeatInterval > 0 && options.reverseHeartbeatInterval < rhb_grantedInterval.sure()) {
            rhb_currentInterval = options.reverseHeartbeatInterval;
            goto(state.s_rhb = s323);
            schedule_evtRhbTimeout(rhb_currentInterval);
          } else {
            rhb_currentInterval = rhb_grantedInterval;
            goto(state.s_rhb = s323);
            schedule_evtRhbTimeout(rhb_currentInterval.sure());
          }
        }
      default:
        // ignore
      }
    }
  }

  function evtRhbTimeout() {
    traceEvent("rhb.timeout");
    if (state.s_rhb == s322) {
      goto(state.s_rhb = s324);
      cancel_evtRhbTimeout();
      evtSendHeartbeat();
    } else if (state.s_rhb == s323) {
      goto(state.s_rhb = s324);
      cancel_evtRhbTimeout();
      evtSendHeartbeat();
    }
  }

  function evtDisposeCtrl() {
    traceEvent("du:dispose.ctrl");
    disposeCtrl();
  }

  function evtStartRecovery() {
    traceEvent("start.recovery");
    if (state.s_rec == s1000) {
      recoverTs = TimerStamp.now();
      goto(state.s_rec = s1000);
    }
  }

  function evtRecoveryTimeout() {
    traceEvent("recovery.timeout");
    if (state.s_rec == s1000) {
      sendRecovery();
      goto(state.s_rec = s1001);
      cancel_evtRecoveryTimeout();
      schedule_evtTransportTimeout(options.retryDelay);
    }
  }

  function evtCheckRecoveryTimeout(retryCause: RecoveryRetryCause) {
    traceEvent("check.recovery.timeout");
    if (state.s_rec == s1002) {
      var retryDelayMs = options.retryDelay;
      var sessionRecoveryMs = options.sessionRecoveryTimeout;
      if (connectTs + retryDelayMs < recoverTs + sessionRecoveryMs) {
        cause = "recovery.error";
        var diffMs = TimerStamp.now() - connectTs;
        var pauseMs = retryDelayMs > diffMs ? retryDelayMs - diffMs : Millis.ZERO;
        goto(state.s_rec = s1003);
        if (sessionLogger.isErrorEnabled()) {
          if (pauseMs > 0) {
            sessionLogger.error('Retrying recovery in ${pauseMs}ms. Cause: ${retryCause}');
          } else {
            sessionLogger.error('Retrying recovery. Cause: ${retryCause}');
          }
        }
        schedule_evtRetryTimeout(pauseMs);
      } else {
        notifyStatus(DISCONNECTED_WILL_RETRY);
        cause = "recovery.timeout";
        state.goto_m_from_rec(s113);
        exit_rec_to_m();
        entry_m113(recovery_timeout);
      }
    }
  }

  function evtCreate() {
    traceEvent("du:create");
    if (state.s_du == s20) {
      goto(state.s_du = s21);
    } else if (state.s_du == s23) {
      goto(state.s_du = s21);
    }
  }

  function evtCheckTransport() {
    traceEvent("check.transport");
    if (state.s_swt == s1300) {
      if (state.s_tr == s220 || state.s_tr == s230 || state.s_tr == s260) {
        goto(state.s_swt = s1301);
      } else {
        var best = getBestForBinding();
        if ((best == BFB_ws_streaming && (state.s_tr == s210 || state.s_tr == s240)) ||
          (best == BFB_http_streaming && state.s_tr == s270 && state.s_h == s710) ||
          (best == BFB_ws_polling && state.s_tr == s250) ||
          (best == BFB_http_polling && state.s_tr == s270 && state.s_h == s720)) {
          goto(state.s_swt = s1301);
        } else {
          goto(state.s_swt = s1302);
          evtSendControl(switchRequest.sure());
        }
      }
    }
  }

  function evtCheckBW() {
    traceEvent("check.bw");
    if (state.s_bw == s1200) {
      if (bw_requestedMaxBandwidth != options.requestedMaxBandwidth
        && options.realMaxBandwidth != BWUnmanaged) {
        bw_requestedMaxBandwidth = options.requestedMaxBandwidth;
        goto(state.s_bw = s1202);
        evtSendControl(constrainRequest.sure());
      } else {
        goto(state.s_bw = s1201);
      }
    }
  }

  function evtCheckCtrlRequests() {
    traceEvent("check.ctrl.requests");
    if (state.s_ctrl == s1100) {
      var controls = getPendingControls();
      if (!controls.empty()) {
        sendPendingControlsHTTP(controls);
        goto(state.s_ctrl = s1102);
        evtRestartHeartbeat();
        schedule_evtCtrlTimeout(options.retryDelay);
      } else if (messageManagers.exists(msg -> msg.isPending())) {
        sendPendingMessagesHTTP();
        goto(state.s_ctrl = s1102);
        evtRestartHeartbeat();
        schedule_evtCtrlTimeout(options.retryDelay);
      } else if (state.s_rhb == s324) {
        sendHeartbeatHTTP();
        goto(state.s_ctrl = s1102);
        evtRestartHeartbeat();
        schedule_evtCtrlTimeout(options.retryDelay);
      } else {
        goto(state.s_ctrl = s1101);
      }
    }
  }

  function evtCtrlDone() {
    traceEvent("ctrl.done");
    if (state.s_ctrl == s1102) {
      closeCtrl();
      goto(state.s_ctrl = s1100);
      cancel_evtCtrlTimeout();
      evtCheckCtrlRequests();
    }
  }

  function evtCtrlError() {
    traceEvent("ctrl.error");
    if (state.s_ctrl == s1102) {
      disposeCtrl();
      var pauseMs = waitingInterval(options.retryDelay, ctrl_connectTs);
      goto(state.s_ctrl = s1103);
      cancel_evtCtrlTimeout();
      schedule_evtCtrlTimeout(pauseMs);
    }
  }

  function evtCtrlTimeout() {
    traceEvent("ctrl.timeout");
    if (state.s_ctrl != null) {
      if (state.s_ctrl == s1102) {
        disposeCtrl();
        var pauseMs = waitingInterval(options.retryDelay, ctrl_connectTs);
        goto(state.s_ctrl = s1103);
        cancel_evtCtrlTimeout();
        schedule_evtCtrlTimeout(pauseMs);
      } else if (state.s_ctrl == s1103) {
        goto(state.s_ctrl = s1100);
        cancel_evtCtrlTimeout();
        evtCheckCtrlRequests();
      }
    }
  }

  public function evtSendControl(request: Encodable) {
    traceEvent("send.control");
    if (state.s_w?.s == s340) {
      sendControlWS(request);
      goto(state.s_w.s = s340);
      evtRestartHeartbeat();
    } else if (state.s_ws?.s == s550) {
      sendControlWS(request);
      goto(state.s_ws.s = s550);
      evtRestartHeartbeat();
    } else if (state.s_wp?.s == s630) {
      sendControlWS(request);
      goto(state.s_wp.s = s630);
    } else if (state.s_ctrl == s1101) {
      goto(state.s_ctrl = s1100);
      evtCheckCtrlRequests();
    }
  }

  function evtSendHeartbeat() {
    traceEvent("send.heartbeat");
    if (state.s_w?.s == s340) {
      sendHeartbeatWS();
      goto(state.s_w.s = s340);
      evtRestartHeartbeat();
    } else if (state.s_ws?.s == s550) {
      sendHeartbeatWS();
      goto(state.s_ws.s = s550);
      evtRestartHeartbeat();
    } else if (state.s_ctrl == s1101) {
      goto(state.s_ctrl = s1100);
      evtCheckCtrlRequests();
    }
  }

  function evtStartSession() {
    traceEvent("du:start.session");
    sessionLogger.logInfo('Starting new session: $sessionId');
    switch state.s_du {
    case s21:
      goto(state.s_du = s22);
    default:
      // ignore
    }
  }

  function evtEndSession() {
    sessionLogger.logInfo('Destroying session: $sessionId');
  }

  function evtRetry(retryCause: RetryCause, timeout: Null<Millis> = null) {
    traceEvent("du:retry");
    if (sessionLogger.isErrorEnabled()) {
      if (timeout != null && timeout > 0) {
        sessionLogger.error('Retrying connection in ${timeout}ms. Cause: ${asErrorMsg(retryCause)}');
      } else {
        sessionLogger.error('Retrying connection. Cause: ${asErrorMsg(retryCause)}');
      }
    }
    var forward = true;
    switch state.s_du {
    case s21:
      resetSequenceMap();
      goto(state.s_du = s23);
      forward = evtRetry_NextRegion();
      genAbortMessages();
    case s22:
      disposeSession();
      goto(state.s_du = s23);
      forward = evtRetry_NextRegion();
      genAbortSubscriptions();
      genAbortMessages();
    default:
      // ignore
    }
    if (forward) {
      forward = evtRetry_NextRegion();
    }
  }

  function evtRetry_NextRegion() {
    return false;
  }

  function evtTerminate(terminationCause: TerminationCause) {
    traceEvent("du:terminate");
    if (sessionLogger.isInfoEnabled()) {
      switch terminationCause {
      case TC_api:
        sessionLogger.info("Disconnected. Cause: Requested by user");
      default:
        // see below
      }
    }
    if (sessionLogger.isErrorEnabled()) {
      switch terminationCause {
      case TC_standardError(var code, var msg):
        sessionLogger.error('Disconnected. Cause: $code - $msg');
      case TC_otherError(var msg):
        sessionLogger.error('Disconnected. Cause: $msg');
      case TC_api:
        // see above
      }
    }
    var forward = true;
    switch state.s_du {
    case s22:
      disposeSession();
      disposeClient();
      goto(state.s_du = s20);
      forward = evtTerminate_NextRegion();
      genAbortSubscriptions();
      genAbortMessages();
    case s23:
      disposeClient();
      goto(state.s_du = s20);
      forward = evtTerminate_NextRegion();
      genAbortMessages();
    case s21:
      disposeClient();
      goto(state.s_du = s20);
      forward = evtTerminate_NextRegion();
      genAbortMessages();
    default:
      // ignore
    }
    if (forward) {
      forward = evtTerminate_NextRegion();
    }
  }

  function evtTerminate_NextRegion() {
    return evtTerminate_NetworkReachabilityRegion();
  }

  function evtTerminate_NetworkReachabilityRegion() {
    switch state.s_nr {
    case s1410, s1411, s1412:
      var rm = nr_reachabilityManager;
      nr_reachabilityManager = null;
      goto(state.s_nr = s1400);
      if (rm != null) {
        rm.stopListening();
      }
    default:
      // ignore
    }
    return false;
  }

  function evtRetryTimeout() {
    traceEvent("retry.timeout");
    switch state.s_m {
    case s115:
      goto(state.s_m = s116);
      evtSelectCreate();
    case s112:
      delayCounter.increase();
      goto(state.s_m = s116);
      cancel_evtRetryTimeout();
      evtSelectCreate();
    case s110:
      notifyStatus(CONNECTING);
      sendCreateTTL();
      goto(state.s_m = s140);
      evtCreate();
      schedule_evtTransportTimeout(new Millis(60_000));
    case s111:
      notifyStatus(CONNECTING);
      delayCounter.increase();
      sendCreateTTL();
      goto(state.s_m = s140);
      cancel_evtRetryTimeout();
      evtCreate();
      schedule_evtTransportTimeout(new Millis(60_000));
    case s113:
      goto(state.s_m = s116);
      cancel_evtRetryTimeout();
      evtSelectCreate();
    case s150:
      if (state.s_rec == s1003) {
        sendRecovery();
        goto(state.s_rec = s1001);
        cancel_evtRetryTimeout();
        schedule_evtTransportTimeout(options.retryDelay);
      }
    default:
      // ignore
    }
  }

  function evtExtSetForcedTransport() {
    traceEvent("setForcedTransport");
    if (state.s_swt == s1301) {
      goto(state.s_swt = s1300);
      evtCheckTransport();
    }
  }

  function evtExtSetRequestedMaxBandwidth() {
    traceEvent("setRequestedMaxBandwidth");
    if (state.s_bw == s1201) {
      goto(state.s_bw = s1200);
      evtCheckBW();
    }
  }

  function evtForceSlowing() {
    traceEvent("force.slowing");
    if (state.s_swt == s1301) {
      goto(state.s_swt = s1300);
      evtCheckTransport();
    }
  }

  function evtForcePolling() {
    traceEvent("force.polling");
    if (state.s_swt == s1301) {
      goto(state.s_swt = s1300);
      evtCheckTransport();
    }
  }

  public function evtSendMessage(msg: MessageManager) {
    traceEvent("send.message");
    if (state.s_w?.s == s340) {
      sendMsgWS(msg);
      goto(state.s_w.s = s340);
      msg.evtWSSent();
      evtRestartHeartbeat();
    } else if (state.s_ws?.s == s550) {
      sendMsgWS(msg);
      goto(state.s_ws.s = s550);
      msg.evtWSSent();
      evtRestartHeartbeat();
    } else if (state.s_wp?.s == s630) {
      sendMsgWS(msg);
      goto(state.s_wp.s = s630);
      msg.evtWSSent();
    } else if (state.s_ctrl == s1101) {
      goto(state.s_ctrl = s1100);
      evtCheckCtrlRequests();
    }
  }

  function evtSwitchTransport() {
    traceEvent("switch.transport");
    var forward = true;
    if (state.s_swt == s1302 || state.s_swt == s1303) {
      goto(state.s_swt = s1300);
      forward = evtSwitchTransport_forwardToTransportRegion();
      evtCheckTransport();
    }
    if (forward) {
      forward = evtSwitchTransport_forwardToTransportRegion();
    }
  }

  function evtSwitchTransport_forwardToTransportRegion() {
    var terminationCause = TC_otherError('Selected transport ${options.forcedTransport} is not available');
    if (state.s_tr == s200) {
      switch getBestForBinding() {
      case BFB_ws_streaming:
        openWS_Bind();
        goto({
          state.s_tr = s240;
          state.s_ws = new StateVar_ws(s500);
        });
        schedule_evtTransportTimeout(options.retryDelay);
      case BFB_http_streaming:
        sendBindHTTP_Streaming();
        goto({
          state.s_tr = s270;
          state.s_h = s710;
          state.s_hs = new StateVar_hs(s800);
          state.s_ctrl = s1100;
        });
        evtCheckCtrlRequests();
        schedule_evtTransportTimeout(options.retryDelay);
      case BFB_ws_polling:
        openWS_Bind();
        goto({
          state.s_tr = s250;
          state.s_wp = new StateVar_wp(s600);
        });
        schedule_evtTransportTimeout(options.retryDelay);
      case BFB_http_polling:
        sendBindHTTP_Polling();
        goto({
          state.s_tr = s270;
          state.s_h = s720;
          state.s_hp = new StateVar_hp(s900);
          state.s_rhb = s320;
          state.s_ctrl = s1100;
        });
        evtCheckCtrlRequests();
        schedule_evtIdleTimeout(idleTimeout.sure() + options.retryDelay);
        evtSelectRhb();
      case BFB_none:
        notifyStatus(DISCONNECTED);
        state.goto_m_from_session(s100);
        evtEndSession();
        evtTerminate(terminationCause);
      }
    } else if (state.s_hs?.p == s811) {
      switch getBestForBinding() {
      case BFB_ws_streaming:
        openWS_Bind();
        state.clear_hs();
        goto({
          state.s_h = null;
          state.s_ctrl = null;
          state.s_tr = s240;
          state.s_ws = new StateVar_ws(s500);
        });
        exit_hs();
        exit_ctrl();
        schedule_evtTransportTimeout(options.retryDelay);
      case BFB_http_streaming:
        sendBindHTTP_Streaming();
        goto(state.s_hs = new StateVar_hs(s800));
        exit_hs();
        schedule_evtTransportTimeout(options.retryDelay);
      case BFB_ws_polling:
        openWS_Bind();
        state.clear_hs();
        goto({
          state.s_h = null;
          state.s_ctrl = null;
          state.s_tr = s250;
          state.s_wp = new StateVar_wp(s600);
        });
        exit_hs();
        exit_ctrl();
        schedule_evtTransportTimeout(options.retryDelay);
      case BFB_http_polling:
        sendBindHTTP_Polling();
        state.clear_hs();
        goto({
          state.s_h = s720;
          state.s_hp = new StateVar_hp(s900);
          state.s_rhb = s320;
        });
        exit_hs();
        schedule_evtIdleTimeout(idleTimeout.sure() + options.retryDelay);
        evtSelectRhb();
      case BFB_none:
        notifyStatus(DISCONNECTED);
        state.goto_m_from_hs(s100);
        exit_hs_to_m();
        evtTerminate(terminationCause);
      }
    } else if (state.s_hp?.m == s904) {
      switch getBestForBinding() {
      case BFB_ws_streaming:
        openWS_Bind();
        state.clear_hp();
        goto({
          state.s_h = null;
          state.s_ctrl = null;
          state.s_tr = s240;
          state.s_ws = new StateVar_ws(s500);
        });
        exit_hp();
        exit_ctrl();
        schedule_evtTransportTimeout(options.retryDelay);
      case BFB_http_streaming:
        sendBindHTTP_Streaming();
        state.clear_hp();
        goto({
          state.s_h = s710;
          state.s_hs = new StateVar_hs(s800);
        });
        exit_hp();
        schedule_evtTransportTimeout(options.retryDelay);
      case BFB_ws_polling:
        openWS_Bind();
        state.clear_hp();
        goto({
          state.s_h = null;
          state.s_ctrl = null;
          state.s_tr = s250;
          state.s_wp = new StateVar_wp(s600);
        });
        exit_hp();
        exit_ctrl();
        schedule_evtTransportTimeout(options.retryDelay);
      case BFB_http_polling:
        sendBindHTTP_Polling();
        goto({
          state.s_hp = new StateVar_hp(s900);
          state.s_rhb = s320;
        });
        exit_hp();
        schedule_evtIdleTimeout(idleTimeout.sure() + options.retryDelay);
        evtSelectRhb();
      case BFB_none:
        notifyStatus(DISCONNECTED);
        state.goto_m_from_hp(s100);
        exit_hp_to_m();
        evtTerminate(terminationCause);
      }
    }
    return false;
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
  
  function openWS(url: String, headers: Null<Map<String, String>>): IWsClient {
    return wsFactory(url, headers, 
      function onOpen(client) {
        lock.synchronized(() -> {
          if (client.isDisposed())
            return;
          evtWSOpen();
        });
      },
      function onText(client, line) {
        lock.synchronized(() -> {
          if (client.isDisposed())
            return;
          evtMessage(line);
        });
      },
      function onError(client, error) {
        lock.synchronized(() -> {
          if (client.isDisposed())
            return;
          evtTransportError();
        });
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
    var url = Url.build(serverInstanceAddress.sure(), "lightstreamer");
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

    ws.sure().send("wsok");
    ws.sure().send("create_session\r\n" + req.getEncodedString());
  }

  function sendBindWS_Streaming() {
    var req = new RequestBuilder();
    req.LS_session(sessionId.sure());
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

    ws.sure().send("wsok");
    ws.sure().send("bind_session\r\n" + req.getEncodedString());
  }

  function sendBindWS_FirstPolling() {
    var req = new RequestBuilder();
    req.LS_session(sessionId.sure());
    req.LS_polling(true);
    req.LS_polling_millis(options.pollingInterval);
    idleTimeout = options.idleTimeout;
    req.LS_idle_millis(idleTimeout);
    if (cause != null) {
      req.LS_cause(cause);
      cause = null;
    }
    protocolLogger.logInfo('Sending session bind: $req');

    ws.sure().send("bind_session\r\n" + req.getEncodedString());
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

    ws.sure().send("bind_session\r\n" + req.getEncodedString());
  }

  function sendDestroyWS() {
    var req = new RequestBuilder();
    req.LS_reqId(generateFreshReqId());
    req.LS_op("destroy");
    req.LS_close_socket(true);
    req.LS_cause("api");
    protocolLogger.logInfo('Sending session destroy: $req');

    ws.sure().send("control\r\n" + req.getEncodedString());
  }

  function sendHttpRequest(url: String, req: RequestBuilder, headers: Null<Map<String, String>>): IHttpClient {
    return httpFactory(url, req.getEncodedString(), headers,
      function onText(client, line) {
        lock.synchronized(() -> {   
          if (client.isDisposed())
            return;
          evtMessage(line);
        });
      },
      function onError(client, error) {
        lock.synchronized(() -> {   
          if (client.isDisposed())
            return;
          evtTransportError();
        });
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
    req.LS_session(sessionId.sure());
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
    var url = Url.build(serverInstanceAddress.sure(), "/lightstreamer/bind_session.txt?LS_protocol=" + TLCP_VERSION);
    var headers = getHeadersForRequestOtherThanCreate();
    http = sendHttpRequest(url, req, headers);
  }

  function sendBindHTTP_Polling() {
    var req = new RequestBuilder();
    req.LS_session(sessionId.sure());
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
    var url = Url.build(serverInstanceAddress.sure(), "/lightstreamer/bind_session.txt?LS_protocol=" + TLCP_VERSION);
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
    req.LS_session(sessionId.sure());
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
    var url = Url.build(serverInstanceAddress.sure(), "/lightstreamer/bind_session.txt?LS_protocol=" + TLCP_VERSION);
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
      return BFC_ws;
    } else {
      return BFC_http;
    }
  }

  function getBestForBinding() {
    var ft = options.forcedTransport;
    if (!disabledTransports.contains(WS_STREAMING) && (ft == null || ft == WS || ft == WS_STREAMING)) {
      return BFB_ws_streaming;
    } else if (!disabledTransports.contains(HTTP_STREAMING) && (ft == null || ft == HTTP || ft == HTTP_STREAMING)) {
        return BFB_http_streaming;
    } else if (!disabledTransports.contains(WS_POLLING) && (ft == null || ft == WS || ft == WS_POLLING)) {
        return BFB_ws_polling;
    } else if (ft == null || ft == HTTP || ft == HTTP_POLLING) {
        return BFB_http_polling;
    } else {
        return BFB_none;
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
  }

  function doREQERR(reqId: Int, errorCode: Int, errorMsg: String) {
    for (_ => sub in subscriptionManagers) {
      sub.evtREQERR(reqId, errorCode, errorMsg);
    }
    for (msg in messageManagers) {
      msg.evtREQERR(reqId, errorCode, errorMsg);
    }
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

  function schedule_evtTransportTimeout(timeout: Millis) {
    transportTimer = createTimer("transport.timeout", timeout, evtTransportTimeout);
  }

  function schedule_evtRetryTimeout(timeout: Millis) {
    retryTimer = createTimer("retry.timeout", timeout, evtRetryTimeout);
  }

  function schedule_evtRecoveryTimeout(timeout: Millis) {
    recoveryTimer = createTimer("recovery.timeout", timeout, evtRecoveryTimeout);
  }

  function schedule_evtIdleTimeout(timeout: Millis) {
    idleTimer = createTimer("idle.timeout", timeout, evtIdleTimeout);
  }

  function schedule_evtPollingTimeout(timeout: Millis) {
    pollingTimer = createTimer("polling.timeout", timeout, evtPollingTimeout);
  }

  function schedule_evtCtrlTimeout(timeout: Millis) {
    ctrlTimer = createTimer("ctrl.timeout", timeout, evtCtrlTimeout);
  }

  function schedule_evtKeepaliveTimeout(timeout: Millis) {
    keepaliveTimer = createTimer("keepalive.timeout", timeout, evtKeepaliveTimeout);
  }

  function schedule_evtStalledTimeout(timeout: Millis) {
    stalledTimer = createTimer("stalled.timeout", timeout, evtStalledTimeout);
  }

  function schedule_evtReconnectTimeout(timeout: Millis) {
    reconnectTimer = createTimer("reconnect.timeout", timeout, evtReconnectTimeout);
  }

  function schedule_evtRhbTimeout(timeout: Millis) {
    rhbTimer = createTimer("rhb.timeout", timeout, evtRhbTimeout);
  }

  function createTimer(id: String, timeout: Millis, callback: ()->Void) {
    return timerFactory(id, timeout, timer -> 
      lock.synchronized(() -> {
        if (timer.isCanceled())
          return;
        callback();
      }));
  }

  function cancel_evtTransportTimeout() {
    if (transportTimer != null) {
      transportTimer.cancel();
      transportTimer = null;
    }
  }

  function cancel_evtRetryTimeout() {
    if (retryTimer != null) {
      retryTimer.cancel();
      retryTimer = null;
    }
  }

  function cancel_evtKeepaliveTimeout() {
    if (keepaliveTimer != null) {
      keepaliveTimer.cancel();
      keepaliveTimer = null;
    }
  }

  function cancel_evtStalledTimeout() {
    if (stalledTimer != null) {
      stalledTimer.cancel();
      stalledTimer = null;
    }
  }

  function cancel_evtReconnectTimeout() {
    if (reconnectTimer != null) {
      reconnectTimer.cancel();
      reconnectTimer = null;
    }
  }

  function cancel_evtRhbTimeout() {
    if (rhbTimer != null) {
      rhbTimer.cancel();
      rhbTimer = null;
    }
  }

  function cancel_evtIdleTimeout() {
    if (idleTimer != null) {
      idleTimer.cancel();
      idleTimer = null;
    }
  }

  function cancel_evtPollingTimeout() {
    if (pollingTimer != null) {
      pollingTimer.cancel();
      pollingTimer = null;
    }
  }

  function cancel_evtCtrlTimeout() {
    if (ctrlTimer != null) {
      ctrlTimer.cancel();
      ctrlTimer = null;
    }
  }

  function cancel_evtRecoveryTimeout() {
    if (recoveryTimer != null) {
      recoveryTimer.cancel();
      recoveryTimer = null;
    }
  }

  function waitingInterval(expectedMs: Millis, startTime: TimerStamp): Millis {
    var diffMs = TimerStamp.now() - startTime;
    var expected = new TimerMillis(expectedMs.toInt());
    return diffMs < expected ? new Millis((expected - diffMs).toLong()) : new Millis(0);
  }

  function exit_tr() {
    evtEndSession();
  }

  function entry_m111(retryCause: RetryCause, timeout: Millis) {
    evtRetry(retryCause, timeout);
    schedule_evtRetryTimeout(timeout);
  }

  function entry_m112(retryCause: RetryCause) {
    var pauseMs = waitingInterval(delayCounter.currentRetryDelay, connectTs);
    evtRetry(retryCause, pauseMs);
    schedule_evtRetryTimeout(pauseMs);
  }

  function entry_m113(retryCause: RetryCause) {
    var pauseMs = randomPause(options.firstRetryMaxDelay);
    evtRetry(retryCause, pauseMs);
    schedule_evtRetryTimeout(pauseMs);
  }

  function entry_m115(retryCause: RetryCause) {
    evtRetry(retryCause);
    evtRetryTimeout();
  }

  function entry_rec(pause: Millis, retryCause: RetryCause) {
    sessionLogger.logError('Recovering connection in $pause ms. Cause: ${asErrorMsg(retryCause)})');
    evtStartRecovery();
    schedule_evtRecoveryTimeout(pause);
  }

  function exit_w() {
    cancel_evtKeepaliveTimeout();
    cancel_evtStalledTimeout();
    cancel_evtReconnectTimeout();
    cancel_evtRhbTimeout();
  }

  function exit_ws() {
    cancel_evtTransportTimeout();
    cancel_evtKeepaliveTimeout();
    cancel_evtStalledTimeout();
    cancel_evtReconnectTimeout();
    cancel_evtRhbTimeout();
  }

  function exit_wp() {
    cancel_evtTransportTimeout();
    cancel_evtIdleTimeout();
    cancel_evtPollingTimeout();
  }

  function exit_hs() {
    cancel_evtTransportTimeout();
    cancel_evtKeepaliveTimeout();
    cancel_evtStalledTimeout();
    cancel_evtReconnectTimeout();
    cancel_evtRhbTimeout();
  }

  function exit_hp() {
    cancel_evtIdleTimeout();
    cancel_evtPollingTimeout();
    cancel_evtRhbTimeout();
  }

  function exit_ctrl() {
    cancel_evtCtrlTimeout();
    evtDisposeCtrl();
  }

  function exit_rec() {
    cancel_evtRecoveryTimeout();
    cancel_evtTransportTimeout();
    cancel_evtRetryTimeout();
  }

  function exit_keepalive_unit() {
    cancel_evtKeepaliveTimeout();
    cancel_evtStalledTimeout();
    cancel_evtReconnectTimeout();
  }

  function exit_w_to_m() {
    exit_w();
    exit_tr();
  }

  function exit_ws_to_m() {
    exit_ws();
    exit_tr();
  }

  function exit_wp_to_m() {
    exit_wp();
    exit_tr();
  }

  function exit_hs_to_m() {
    exit_ctrl();
    exit_hs();
    exit_tr();
  }

  function exit_hs_to_rec() {
    exit_ctrl();
    exit_hs();
  }

  function exit_hp_to_m() {
    exit_ctrl();
    exit_hp();
    exit_tr();
  }

  function exit_hp_to_rec() {
    exit_ctrl();
    exit_hp();
  }

  function exit_ctrl_to_m() {
    exit_ctrl();
    exit_hs();
    exit_hp();
    exit_tr();
  }

  function exit_rec_to_m() {
    exit_rec();
    exit_tr();
  }

  function randomPause(maxPause: Millis): Millis {
    return randomGenerator(maxPause);
  }

  public function generateFreshReqId(): Int {
    m_nextReqId += 1;
    return m_nextReqId;
  }

  public function generateFreshSubId(): Int {
    m_nextSubId += 1;
    return m_nextSubId;
  }

  function genAbortSubscriptions() {
    for (_ => sub in subscriptionManagers) {
      sub.evtExtAbort();
    }
  }

  function genAckMessagesWS() {
    var messages = messageManagers.filter(msg -> msg.isPending());
    for (msg in messages) {
      msg.evtWSSent();
    }
  }

  function genAbortMessages() {
    for (msg in messageManagers) {
      msg.evtAbort();
    }
  }

  function resetSequenceMap() {
    sequenceMap.clear();
  }

  function isSwitching() {
    return state.s_m == s150 && (state.s_swt == s1302 || state.s_swt == s1303);
  }

  public function encodeSwitch(isWS: Bool): String {
    var req = new RequestBuilder();
    swt_lastReqId = generateFreshReqId();
    req.LS_reqId(swt_lastReqId);
    req.LS_op("force_rebind");
    if (isWS) {
      req.LS_close_socket(true);
    }
    if (cause != null) {
      req.LS_cause(cause);
      cause = null;
    }
    protocolLogger.logInfo("Sending transport switch: " + req);
    return req.getEncodedString();
  }

  public function encodeConstrain(): String {
    var req = new RequestBuilder();
    bw_lastReqId = generateFreshReqId();
    req.LS_reqId(bw_lastReqId);
    req.LS_op("constrain");
    switch bw_requestedMaxBandwidth.sure() {
    case BWLimited(bw):
      req.LS_requested_max_bandwidth_Float(bw);
    case BWUnlimited:
      req.LS_requested_max_bandwidth("unlimited");
    }
    protocolLogger.logInfo("Sending bandwidth constrain: " + req);
    return req.getEncodedString();
  }

  function getPendingControls() {
    var res = new Array<Encodable>();
    if (switchRequest.sure().isPending()) {
      res.push(switchRequest.sure());
    }
    if (constrainRequest.sure().isPending()) {
      res.push(constrainRequest.sure());
    }
    for (_ => sub in subscriptionManagers) {
      if (sub.isPending()) {
        res.push(sub);
      }
    }
    return res;
  }

  function sendControlWS(request: Encodable) {
    ws.sure().send(request.encodeWS());
  }

  function sendMsgWS(msg: MessageManager) {
    ws.sure().send(msg.encodeWS());
  }

  function sendPengingControlsWS(pendings: Array<Encodable>) {
      var batches = prepareBatchWS("control", pendings, requestLimit.sure());
      sendBatchWS(batches);
  }

  function sendPendingMessagesWS() {
    var messages = [for (msg in messageManagers) if (msg.isPending()) (msg : Encodable)];
    // ASSERT (for each i, j in DOMAIN messages :
    // i < j AND messages[i].sequence = messages[j].sequence => messages[i].prog < messages[j].prog)
    var batches = prepareBatchWS("msg", messages, requestLimit.sure());
    sendBatchWS(batches);
  }

  function sendBatchWS(batches: Array<String>) {
    for (batch in batches) {
      ws.sure().send(batch);
    }
  }

  function sendHeartbeatWS() {
    protocolLogger.logInfo("Heartbeat request");
    ws.sure().send("heartbeat\r\n\r\n"); // since the request has no parameter, it must include EOL
  }

  function sendPendingControlsHTTP(pendings: Array<Encodable>) {
    var body = prepareBatchHTTP(pendings, requestLimit.sure());
    sendBatchHTTP(body, "control");
  }

  function sendPendingMessagesHTTP() {
    var messages = [for (msg in messageManagers) if (msg.isPending()) (msg : Encodable)];
    // ASSERT (for each i, j in DOMAIN messages :
    // i < j AND messages[i].sequence = messages[j].sequence => messages[i].prog < messages[j].prog)
    var body = prepareBatchHTTP(messages, requestLimit.sure());
    sendBatchHTTP(body, "msg");
  }

  function sendHeartbeatHTTP() {
    protocolLogger.logInfo("Heartbeat request");
    sendBatchHTTP("\r\n", "heartbeat"); // since the request has no parameter, it must include EOL
  }

  function sendBatchHTTP(body: String, reqType: String) {
    ctrl_connectTs = TimerStamp.now();
    var url = Url.build(serverInstanceAddress.sure(), '/lightstreamer/$reqType.txt?LS_protocol=$TLCP_VERSION&LS_session=$sessionId');
    var headers = getHeadersForRequestOtherThanCreate();
    ctrl_http = ctrlFactory(url, body, headers,
      function onText(client, line) {
        lock.synchronized(() -> {
          if (client.isDisposed())
            return;
          evtCtrlMessage(line);
        });
      },
      function onError(client, error) {
        lock.synchronized(() -> {
          if (client.isDisposed())
            return;
          evtCtrlError();
        });
      },
      function onDone(client) {
        lock.synchronized(() -> {
          if (client.isDisposed())
            return;
          evtCtrlDone();
        });
      });
  }

  function prepareBatchWS(reqType: String, pendings: Array<Encodable>, requestLimit: Int): Array<String> {
    assert(pendings.length > 0);
    // NB $requestLimit must always be respected unless
    // one single request surpasses the limit: in that case the requests is sent on its own even if
    // we already know that the server will refuse it
    var out = [];
    var i = 0;
    var subReq = pendings[i].encode(true);
    while (i < pendings.length) {
      // prepare next batch
      var mainReq = new Request();
      mainReq.addSubRequest(reqType);
      mainReq.addSubRequest(subReq);
      i += 1;
      while (i < pendings.length) {
        subReq = pendings[i].encode(true);
        if (mainReq.addSubRequestOnlyIfBodyIsLessThan(subReq, requestLimit)) {
          i += 1;
        } else {
          // batch is full: keep subReq for the next batch
          break;
        }
      }
      out.push(mainReq.getBody());
    }
    return out;
  }

  function prepareBatchHTTP(pendings: Array<Encodable>, requestLimit: Int) {
    assert(pendings.length > 0);
    // NB $requestLimit must always be respected unless
    // one single request surpasses the limit: in that case the requests is sent on its own even if
    // we already know that the server will refuse it
    var mainReq = new Request();
    var i = 0;
    var subReq = pendings[i].encode(false);
    mainReq.addSubRequest(subReq);
    i += 1;
    while (i < pendings.length) {
      subReq = pendings[i].encode(false);
      if (mainReq.addSubRequestOnlyIfBodyIsLessThan(subReq, requestLimit)) {
        i += 1;
      } else {
        break;
      }
    }
    return mainReq.getBody();
  }

  function getHeadersForRequestOtherThanCreate() {
    return options.httpExtraHeadersOnSessionCreationOnly ? null : options.httpExtraHeaders;
  }

  function getServerAddress(): ServerAddress {
    var addr = details.serverAddress;
    return addr != null ? addr : defaultServerAddress.sure();
  }

  public function relateSubManager(subManager: SubscriptionManager) {
    assert(subscriptionManagers[subManager.subId] == null);
    subscriptionManagers[subManager.subId] = subManager;
  }

  public function unrelateSubManager(subManager: SubscriptionManager) {
    subscriptionManagers.remove(subManager.subId);
  }

  function isRelatedWithSubManager(subManager: SubscriptionManager): Bool {
    return subscriptionManagers.containsValue(subManager);
  }

  public function relateMsgManager(msgManager: MessageManager) {
    messageManagers.push(msgManager);
  }

  public function unrelateMsgManager(msgManager: MessageManager) {
    messageManagers.remove(msgManager);
  }

  public function getAndSetNextMsgProg(sequence: String): Int {
    var prog = sequenceMap[sequence];
    prog = prog == null ? 1 : prog;
    sequenceMap[sequence] = prog + 1;
    return (prog : Int);
  }

  public function onPropertyChange(property: String) {
    clientEventDispatcher.onPropertyChange(property);
  }

  function traceEvent(event: String) {
    internalLogger.logTrace("event: " + event + " " +  state.toString());
  }

  public function connect() {
    var serverAddress = details.getServerAddress();
    if (serverAddress == null) {
      throw new IllegalStateException("Configure the server address before trying to connect");
    }
    actionLogger.logInfo('Connection requested: details: $details options: $options');
    defaultServerAddress = new ServerAddress(serverAddress);
    evtExtConnect();
  }

  public function disconnect() {
    actionLogger.logInfo("Disconnection requested");
    evtExtDisconnect();
  }

  public function getStatus(): String {
    return m_status;
  }

  public function sendMessage(message: String, sequence: Null<String>, delayTimeout: Int, listener: Null<ClientMessageListener>, enqueueWhileDisconnected: Bool): Void {
    if (!enqueueWhileDisconnected && (state.inDisconnected() || state.inRetryUnit())) {
      if (actionLogger.isInfoEnabled()) {
        var map = [
          "text" => message, 
          "sequence" => sequence != null ? sequence : "UNORDERED_MESSAGES",
          "timeout" => Std.string(delayTimeout),
          "enqueueWhileDisconnected" => Std.string(enqueueWhileDisconnected)
        ];
        actionLogger.info('Message sending requested: $map');
      }
      messageLogger.logWarn('Message ${sequence != null ? sequence : "UNORDERED_MESSAGES"} $message aborted');
      if (listener != null) {
        var dispatcher = new ClientMessageDispatcher();
        dispatcher.addListener(listener);
        dispatcher.onAbort(message, false);
      }
      return;
    }
    if (sequence != null) {
      #if python @:nullSafety(Off) #end
      if (!~/^[a-zA-Z0-9_]*$/.match(sequence)) {
        throw new IllegalArgumentException("The given sequence name is not valid. Use only alphanumeric characters plus underscore or null");
      }
      var msg = new MessageManager(message, sequence, delayTimeout, listener, enqueueWhileDisconnected, this);
      actionLogger.logInfo('Message sending requested: $msg');
      msg.evtExtSendMessage();
    } else {
      var sequence = "UNORDERED_MESSAGES";
      var msg = new MessageManager(message, sequence, delayTimeout, listener, enqueueWhileDisconnected, this);
      actionLogger.logInfo('Message sending requested: $msg');
      msg.evtExtSendMessage();
    }
  }

  public function subscribeExt(subscription: Subscription, isInternal: Bool = false) {
    if (subscription.isActive()) {
      throw new IllegalStateException("Cannot subscribe to an active Subscription");
    }
    if (subscription.getItems() == null && subscription.getItemGroup() == null) {
      throw new IllegalArgumentException("Specify property 'items' or 'itemGroup'");
    }
    if (subscription.getFields() == null && subscription.getFieldSchema() == null) {
      throw new IllegalArgumentException("Specify property 'fields' or 'fieldSchema'");
    }
    var sm = new SubscriptionManagerLiving(subscription, this);
    actionLogger.logInfo('${isInternal ? "Internal subscription" : "Subscription"} requested: subId: ${sm.subId} $subscription');
    sm.evtExtSubscribe();
  }

  public function unsubscribe(subscription: Subscription) {
    var sm = subscription.fetch_subManager();
    if (sm != null) {
      if (!isRelatedWithSubManager(sm)) {
        throw new IllegalArgumentException("The Subscription is not subscribed to this Client");
      }
      actionLogger.logInfo('Unsubscription requested: subId: ${sm.subId} $subscription');
      sm.evtExtUnsubscribe();
    }
  }

  public function getSubscriptions(): Array<Subscription> {
    var ls = new Array<Subscription>();
    for (_ => sm in subscriptionManagers) {
      var sml = @:nullSafety(Off) Std.downcast(sm, SubscriptionManagerLiving);
      if (sml != null) {
        var sub = sml.m_subscription;
        if (sub.isActive() && !sub.isInternal()) {
          ls.push(sub);
        }
      }
    }
    return ls;
  }
}

private enum BestForCreatingEnum {
  BFC_ws; BFC_http;
}

private enum BestForBindingEnum {
  BFB_none; BFB_ws_streaming; BFB_ws_polling; BFB_http_streaming; BFB_http_polling;
}

private enum SyncCheckResult {
  SCR_good; SCR_not_good; SCR_bad;
}

private enum RetryCause {
  standardError(code: Int, msg: String);
  ws_unavailable;
  ws_error;
  http_error;
  idle_timeout;
  stalled_timeout;
  ws_timeout;
  http_timeout;
  recovery_timeout;
  prog_mismatch(expected: Int, actual: Int);
}

private function asErrorMsg(cause: RetryCause) {
  return switch cause {
    case standardError(code, msg):
      '$code - $msg';
    case ws_unavailable:
      "Websocket transport not available";
    case ws_error:
      "Websocket error";
    case http_error:
      "HTTP error";
    case idle_timeout:
      "idleTimeout expired";
    case stalled_timeout:
      "stalledTimeout expired";
    case ws_timeout:
      "Websocket connect timeout expired";
    case http_timeout:
      "HTTP connect timeout expired";
    case recovery_timeout:
      "sessionRecoveryTimeout expired";
    case prog_mismatch(expected, actual):
      'Recovery counter mismatch: expected $expected but found $actual';
  };
}

private enum TerminationCause {
  TC_standardError(code: Int, msg: String);
  TC_otherError(error: String);
  TC_api;
}

private enum RecoveryRetryCause {
  RRC_transport_timeout; RRC_transport_error;
}

private class ClientMessageDispatcher extends EventDispatcher<ClientMessageListener> {}