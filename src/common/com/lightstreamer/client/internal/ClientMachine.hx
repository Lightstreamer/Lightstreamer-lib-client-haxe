package com.lightstreamer.client.internal;

import com.lightstreamer.internal.*;
import com.lightstreamer.internal.MacroTools;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.PlatformApi;
import com.lightstreamer.internal.Timer;
import com.lightstreamer.internal.Constants;
import com.lightstreamer.client.LightstreamerClient.ClientEventDispatcher;
import com.lightstreamer.client.internal.ClientStates;
import com.lightstreamer.client.internal.ClientRequests;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;
using StringTools;

// TODO synchronize
@:nullSafety(Off)
@:access(com.lightstreamer.client.ConnectionDetails)
@:access(com.lightstreamer.client.ConnectionOptions)
@:access(com.lightstreamer.client.LightstreamerClient)
class ClientMachine {
  final details: ConnectionDetails;
  final options: ConnectionOptions;
  final lock: com.lightstreamer.internal.RLock;
  final clientEventDispatcher: ClientEventDispatcher;
  final state: ClientStates.State = new ClientStates.State();
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
    // TODO MPN
    // mpnRegisterRequest = MpnRegisterRequest(self)
    // mpnFilterUnsubscriptionRequest = MpnFilterUnsubscriptionRequest(self)
    // mpnBadgeResetRequest = MpnBadgeResetRequest(self)
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
      // TODO MPN
      //forward = evtExtConnect_MpnRegion();
      evtSelectCreate();
    }
    if (forward) {
      // TODO MPN
      //forward = evtExtConnect_MpnRegion();
    }
  }

  function evtExtConnect_NetworkReachabilityRegion() {
    // TODO connect with evtExtConnect 
    traceEvent("nr:connect");
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
      oldManager.stopListening();
      nr_reachabilityManager.startListening(status -> 
        switch status {
          case RSNotReachable:
            evtNetworkNotReachable(hostAddress);
          case RSReachable:
            evtNetworkReachable(hostAddress);
        });
    default:
    }
  }

  function evtExtDisconnect() {
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
        if (state.s_ws.m == s500) {
          disposeWS();
          notifyStatus(DISCONNECTED);
          state.goto_m_from_ws(s100);
          exit_ws_to_m();
          evtTerminate(terminationCause);
        } else if (state.s_ws.m == s501 || state.s_ws.m == s502 || state.s_ws.m == s503) {
          sendDestroyWS();
          closeWS();
          notifyStatus(DISCONNECTED);
          state.goto_m_from_ws(s100);
          exit_ws_to_m();
          evtTerminate(terminationCause);
        } 
      case s250:
        if (state.s_wp.m == s600 || state.s_wp.m == s601) {
          disposeWS();
          notifyStatus(DISCONNECTED);
          state.goto_m_from_wp(s100);
          exit_ws_to_m();
          evtTerminate(terminationCause);
        } else if (state.s_wp.m == s602) {
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
      }
    case s110, s111, s112, s113, s114, s115, s116:
        notifyStatus(DISCONNECTED);
        goto(state.s_m = s100);
        cancel_evtRetryTimeout();
        evtTerminate(terminationCause);
    default:
    }
  }

  function evtSelectCreate() {
    traceEvent("select.create");
    if (state.s_m == s101 || state.s_m == s116) {
      switch getBestForCreating() {
        case bfc_ws:
          notifyStatus(CONNECTING);
          openWS_Create();
          goto(state.s_m = s120);
          evtCreate();
          schedule_evtTransportTimeout(delayCounter.currentRetryDelay);
        case bfc_http:
          notifyStatus(CONNECTING);
          sendCreateHTTP();
          goto(state.s_m = s130);
          evtCreate();
          schedule_evtTransportTimeout(delayCounter.currentRetryDelay);
      }
    }
  }

  function evtWSOpen() {
    // TODO synchronize (called by openWS)
    traceEvent("ws.open");
    if (state.s_m == s120) {
      sendCreateWS();
      goto(state.s_m = s121);
    } else if (state.s_ws.m == s500) {
      sendBindWS_Streaming();
      goto(state.s_ws.m = s501);
    } else if (state.s_wp.m == s600) {
      ws.send("wsok");
      goto(state.s_wp.m = s601);
    }
  }

  function evtMessage(line: String) {
    // TODO synchronize (called by openWS)
    /*
    if (line.startsWith("U,")) {
      // U,<subscription id>,<itemd index>,<field values>
      var update = parseUpdate(line);
      evtU(update.subId, update.itemIdx, update.values, line);
    } else if (line.startsWith("REQOK")) {
      // REQOK,<request id>
      if (line == "REQOK") {
        evtREQOK();
      } else {
        var args = line.split(",");
        var reqId = Std.parseInt(args[1]);
        evtREQOK(reqId);
      }
    } else if (line.startsWith("PROBE")) {
      evtPROBE();
    } else if (line.startsWith("LOOP")) {
      // LOOP,<delay [ms]>
      var args = line.split(",");
      var pollingMs = Std.parseInt(args[1]);
      evtLOOP(pollingMs);
    } else if (line.startsWith("CONOK")) {
      // CONOK,<session id>,<request limit>,<keepalive/idle timeout [ms]>,(*|<control link>);
      var args = line.split(",");
      var sessionId = args[1];
      var reqLimit = Std.parseInt(args[2]);
      var keepalive = Std.parseInt(args[3]);
      var clink = args[4];
      evtCONOK(sessionId, reqLimit, keepalive, clink);
    } else if (line.startsWith("WSOK")) {
      evtWSOK();
    } else if (line.startsWith("SERVNAME")) {
      let args = line.split(",");
      let serverName = String(args[1]);
      evtSERVNAME(serverName);
    } else if (line.startsWith("CLIENTIP")) {
      let args = line.split(",");
      let ip = String(args[1]);
      evtCLIENTIP(ip);
    } else if (line.startsWith("CONS")) {
      // CONS,(unmanaged|unlimited|<bandwidth>);
      let args = line.split(",");
      let bw = String(args[1]);
      switch bw {
      case "unlimited":
        evtCONS(.unlimited);
      case "unmanaged":
        evtCONS(.unmanaged);
      default:
        let n = Double(bw)!
        evtCONS(.limited(n));
      }
    } else if (line.startsWith("MSGDONE")) {
      // MSGDONE,(*|<sequence>),<prog>
      let args = line.split(",");
      var seq = String(args[1]);
      if seq == "*" {
        seq = "UNORDERED_MESSAGES"
      }
      let prog = Int(args[2])!
      evtMSGDONE(seq, prog);
    } else if (line.startsWith("MSGFAIL")) {
      // MSGFAIL,(*|<sequence>),<prog>,<code>,<message>
      let args = line.split(",");
      var seq = String(args[1]);
      if seq == "*" {
        seq = "UNORDERED_MESSAGES"
      }
      let prog = Int(args[2])!
      let errorCode = Int(args[3])!
      let errorMsg = args[4].removingPercentEncoding!
      evtMSGFAIL(seq, prog, errorCode: errorCode, errorMsg: errorMsg);
    } else if (line.startsWith("REQERR")) {
      // REQERR,<request id>,<code>,<message>
      let args = line.split(",");
      let reqId = Int(args[1])!
      let code = Int(args[2])!
      let msg = args[3].removingPercentEncoding!
      evtREQERR(reqId, code, msg);
    } else if (line.startsWith("PROG")) {
      // PROG,<prog>
      let args = line.split(",");
      let prog = Int(args[1])!
      evtPROG(prog);
    } else if (line.startsWith("SUBOK")) {
      // SUBOK,<subscription id>,<total items>,<total fields>
      let args = line.split(",");
      let subId = Int(args[1])!
      let nItems = Int(args[2])!
      let nFields = Int(args[3])!
      evtSUBOK(subId, nItems, nFields);
    } else if (line.startsWith("SUBCMD")) {
      // SUBCMD,<subscription id>,<total items>,<total fields>,<key index>,<command index>
      let args = line.split(",");
      let subId = Int(args[1])!
      let nItems = Int(args[2])!
      let nFields = Int(args[3])!
      let keyIdx = Pos(args[4])!
      let cmdIdx = Pos(args[5])!
      evtSUBCMD(subId, nItems, nFields, keyIdx, cmdIdx);
    } else if (line.startsWith("UNSUB")) {
      // UNSUB,<subscription id>
      let args = line.split(",");
      let subId = Int(args[1])!
      evtUNSUB(subId);
    } else if (line.startsWith("CONF")) {
      // CONF,<subscription id>,(unlimited|<frequency>),(filtered|unfiltered);
      let args = line.split(",");
      let subId = Int(args[1])!
      if args[2] == "unlimited" {
        evtCONF(subId, .unlimited);
      } else {
        let freq = Double(args[2])!
        evtCONF(subId, .limited(freq));
      }
    } else if (line.startsWith("EOS")) {
      // EOS,<subscription id>,<item index>
      let args = line.split(",");
      let subId = Int(args[1])!
      let itemIdx = Int(args[2])!
      evtEOS(subId, itemIdx);
    } else if (line.startsWith("CS")) {
      // CS,<subscription id>,<item index>
      let args = line.split(",");
      let subId = Int(args[1])!
      let itemIdx = Int(args[2])!
      evtCS(subId, itemIdx);
    } else if (line.startsWith("OV")) {
      // OV,<subscription id>,<item index>,<lost updates>
      let args = line.split(",");
      let subId = Int(args[1])!
      let itemIdx = Int(args[2])!
      let lostUpdates = Int(args[3])!
      evtOV(subId, itemIdx, lostUpdates);
    } else if (line.startsWith("NOOP")) {
      evtNOOP();
    } else if (line.startsWith("CONERR")) {
      // CONERR,<code>,<message>
      let args = line.split(",");
      let code = Int(args[1])!
      let msg = args[2].removingPercentEncoding!
      evtCONERR(code, msg);
    } else if (line.startsWith("END")) {
      // END,<code>,<message>
      let args = line.split(",");
      let code = Int(args[1])!
      let msg = args[2].removingPercentEncoding!
      evtEND(code, msg);
    } else if (line.startsWith("ERROR")) {
      // ERROR,<code>,<message>
      let args = line.split(",");
      let code = Int(args[1])!
      let msg = args[2].removingPercentEncoding!
      evtERROR(code, msg);
    } else if (line.startsWith("SYNC")) {
      // SYNC,<elapsed time [sec]>
      let args = line.split(",");
      let seconds = UInt64(args[1])!
      evtSYNC(seconds);
    } else if (line.startsWith("MPNREG")) {
      // MPNREG,<device id>,<adapter name>
      let args = line.split(",");
      let deviceId = String(args[1]);
      let adapterName = String(args[2]);
      evtMPNREG(deviceId, adapterName);
    } else if (line.startsWith("MPNZERO")) {
      // MPNZERO,<device id>
      let args = line.split(",");
      let deviceId = String(args[1]);
      evtMPNZERO(deviceId);
    } else if (line.startsWith("MPNOK")) {
      // MPNOK,<subscription id>, <mpn subscription id>
      let args = line.split(",");
      let subId = Int(args[1])!
      let mpnSubId = String(args[2]);
      evtMPNOK(subId, mpnSubId);
    } else if (line.startsWith("MPNDEL")) {
      // MPNDEL,<mpn subscription id>
      let args = line.split(",");
      let mpnSubId = String(args[1]);
      evtMPNDEL(mpnSubId);
    } else if (line.startsWith("MPNCONF")) {
      // MPNCONF,<mpn subscription id>
      let args = line.split(",");
      let mpnSubId = String(args[1]);
      evtMPNCONF(mpnSubId);
    }
    */
  }

  function evtCtrlMessage(line: String) {
    // TODO synchronize (called by sendBatchHTTP)
    if (line.startsWith("REQOK")) {
      // REQOK,<request id>
      if (line == "REQOK") {
        evtREQOK();
      } else {
        var args = line.split(",");
        var reqId = Std.parseInt(args[1]);
        evtREQOK_reqId(reqId);
      }
    } else if (line.startsWith("REQERR")) {
      // REQERR,<request id>,<code>,<message>
      var args = line.split(",");
      var reqId = Std.parseInt(args[1]);
      var code = Std.parseInt(args[2]);
      var msg = args[3].urlDecode();
      evtREQERR(reqId, code, msg);
    } else if (line.startsWith("ERROR")) {
      // ERROR,<code>,<message>
      var args = line.split(",");
      var code = Std.parseInt(args[1]);
      var msg = args[2].urlDecode();
      evtERROR(code, msg);
    }
  }

  function evtRestartKeepalive() {
    traceEvent("restart.keepalive");
    if (state.s_w?.k != null) {
      goto(state.s_w.k = s310);
      exit_keepalive_unit();
      schedule_evtKeepaliveTimeout(keepaliveInterval);
    } else if (state.s_ws?.k != null) {
      goto(state.s_ws.k = s520);
      exit_keepalive_unit();
      schedule_evtKeepaliveTimeout(keepaliveInterval);
    } else if (state.s_hs?.k != null) {
      goto(state.s_hs.k = s820);
      exit_keepalive_unit();
      schedule_evtKeepaliveTimeout(keepaliveInterval);
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

  function evtREQOK() {
    traceEvent("REQOK");
    protocolLogger.logDebug("REQOK");
    if (state.s_ctrl == s1102) {
      // heartbeat response (only in HTTP)
      goto(state.s_ctrl = s1102);
    }
  }

  function evtREQOK_reqId(reqId: Int) {
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
    }
    // TODO MPN 
    /*else if s_mpn.m == .s403 && reqId == mpn_lastRegisterReqId {
      s_mpn.m = .s404
      forward = evtREQOK_TransportRegion(reqId)
    } else if s_mpn.m == .s406 && reqId == mpn_lastRegisterReqId {
      s_mpn.m = .s407
      forward = evtREQOK_TransportRegion(reqId)
    } else if s_mpn.tk == .s453 && reqId == mpn_lastRegisterReqId {
      s_mpn.tk = .s454
      forward = evtREQOK_TransportRegion(reqId)
    } else if s_mpn.ft == .s432 && reqId == mpn_filter_lastDeactivateReqId {
      doREQMpnUnsubscribeFilter()
      s_mpn.ft = .s430
      forward = evtREQOK_TransportRegion(reqId)
      evtMpnCheckFilter()
    } else if s_mpn.bg == .s442 && reqId == mpn_badge_lastResetReqId {
      doREQOKMpnResetBadge()
      forward = evtREQOK_TransportRegion(reqId)
      s_mpn.bg = .s440
      evtMpnCheckReset()
    }*/
    if (forward) {
      forward = evtREQOK_TransportRegion(reqId);
    }
  }

  function evtREQOK_TransportRegion(reqId: Int) {
    traceEvent("REQOK");
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

  function evtCreate() {
    traceEvent("du:create");
    if (state.s_du == s20) {
      goto(state.s_du = s21);
    } else if (state.s_du == s23) {
      goto(state.s_du = s21);
    }
  }

  function evtCheckBW() {
    traceEvent("check.bw");
    if (state.s_bw == s1200) {
      if (bw_requestedMaxBandwidth != options.requestedMaxBandwidth
        && options.realMaxBandwidth != BWUnmanaged) {
        bw_requestedMaxBandwidth = options.requestedMaxBandwidth;
        goto(state.s_bw = s1202);
        evtSendControl(constrainRequest);
      } else {
        goto(state.s_bw = s1201);
      }
    }
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
    }
    // TODO MPN
    /*else if s_mpn.m == .s403 && reqId == mpn_lastRegisterReqId {
      trace(evt, State_mpn_m.s403, State_mpn_m.s402);
      notifyDeviceError(code, msg);
      s_mpn.m = .s402
      forward = evtREQERR_TransportRegion(reqId, code, msg);
      evtMpnCheckNext();
    } else if s_mpn.m == .s406 && reqId == mpn_lastRegisterReqId {
      trace(evt, State_mpn_m.s406, State_mpn_m.s408);
      notifyDeviceError(code, msg);
      s_mpn.m = .s408
      forward = evtREQERR_TransportRegion(reqId, code, msg);
      evtMpnCheckNext();
    } else if s_mpn.tk == .s453 && reqId == mpn_lastRegisterReqId {
      trace(evt, State_mpn_tk.s453, State_mpn_tk.s452);
      notifyDeviceError(code, msg);
      s_mpn.tk = .s452
      forward = evtREQERR_TransportRegion(reqId, code, msg);
      evtMpnCheckNext();
    } else if s_mpn.ft == .s432 && reqId == mpn_filter_lastDeactivateReqId {
      trace(evt, State_mpn_ft.s432, State_mpn_ft.s430);
      doREQMpnUnsubscribeFilter();
      s_mpn.ft = .s430
      forward = evtREQERR_TransportRegion(reqId, code, msg);
      evtMpnCheckFilter();
    } else if s_mpn.bg == .s442 && reqId == mpn_badge_lastResetReqId {
      trace(evt, State_mpn_bg.s442, State_mpn_bg.s440);
      doREQERRMpnResetBadge();
      notifyOnBadgeResetFailed(code, msg);
      s_mpn.bg = .s440
      forward = evtREQERR_TransportRegion(reqId, code, msg);
      evtMpnCheckReset();
    }*/
    if (forward) {
      forward = evtREQERR_TransportRegion(reqId, code, msg);
    }
  }

  function evtREQERR_TransportRegion(reqId: Int, code: Int, msg: String) {
    traceEvent("REQERR");
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
    // TODO
    return false;
  }

  function evtCheckTransport() {
    // TODO
  }
  
  function evtSendControl(req: ConstrainRequest) {
    // TODO
  }
  function evtTerminate(cause: TerminationCause) {
    // TODO
  }

  function evtTransportError() {
    // TODO synchronize (called by openWS)
  }
  function evtCtrlError() {
    // TODO synchronize (called by sendBatchHTTP)
  }
  function evtCtrlDone() {
   // TODO synchronize (called by sendBatchHTTP) 
  }
  function evtTransportTimeout() {
    // TODO synchronize (called by timer)
  }
  function evtRetryTimeout() {
    // TODO synchronize (called by timer)
  }
  function evtRecoveryTimeout() {
    // TODO synchronize (called by timer)
  }
  function evtIdleTimeout() {
    // TODO synchronize (called by timer)
  }
  function evtPollingTimeout() {
    // TODO synchronize (called by timer)
  }
  function evtCtrlTimeout() {
    // TODO synchronize (called by timer)
  }
  function evtKeepaliveTimeout() {
    // TODO synchronize (called by timer)
  }
  function evtStalledTimeout() {
    // TODO synchronize (called by timer)
  }
  function evtReconnectTimeout() {
    // TODO synchronize (called by timer)
  }
  function evtRhbTimeout() {
    // TODO synchronize (called by timer)
  }
  function evtEndSession() {
    // TODO
  }
  function evtRetry(retryCause: RetryCause, timeout: Null<Millis> = null) {
    // TODO
  }
  function evtDisposeCtrl() {
    // TODO
  }
  function evtStartRecovery() {
    // TODO
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
        lock.execute(() -> {
          if (client.isDisposed())
            return;
          evtWSOpen();
        });
      },
      function onText(client, line) {
        lock.execute(() -> {
          if (client.isDisposed())
            return;
          evtMessage(line);
        });
      },
      function onError(client, error) {
        lock.execute(() -> {
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
        lock.execute(() -> {   
          if (client.isDisposed())
            return;
          evtMessage(line);
        });
      },
      function onError(client, error) {
        lock.execute(() -> {   
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
    return timerFactory(id, timeout, timer -> lock.execute(() -> {
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
    return diffMs < expected ? new Millis((expected - diffMs).toFloat()) : new Millis(0);
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

  function generateFreshReqId() {
    // TODO synchronize
    m_nextReqId += 1;
    return m_nextReqId;
  }

  function generateFreshSubId() {
    // TODO synchronize
    m_nextSubId += 1;
    return m_nextSubId;
  }

  function genAbortSubscriptions() {
    for (_ => sub in subscriptionManagers) {
      sub.evtExtAbort();
    }
    // TODO MPN
    // for (sub in mpnSubscriptionManagers) {
    //   sub.evtAbort();
    // }
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

  function encodeSwitch(isWS: Bool) {
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

  function encodeConstrain() {
    var req = new RequestBuilder();
    bw_lastReqId = generateFreshReqId();
    req.LS_reqId(bw_lastReqId);
    req.LS_op("constrain");
    switch bw_requestedMaxBandwidth {
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
    if (switchRequest.isPending()) {
      res.push(switchRequest);
    }
    if (constrainRequest.isPending()) {
      res.push(constrainRequest);
    }
    for (_ => sub in subscriptionManagers) {
      if (sub.isPending()) {
        res.push(sub);
      }
    }
    // TODO MPN
    // if mpnRegisterRequest.isPending() {
    //     res.append(mpnRegisterRequest)
    // }
    // for sub in mpnSubscriptionManagers.filter({ $0.isPending() }) {
    //     res.append(sub)
    // }
    // if mpnFilterUnsubscriptionRequest.isPending() {
    //     res.append(mpnFilterUnsubscriptionRequest)
    // }
    // if mpnBadgeResetRequest.isPending() {
    //     res.append(mpnBadgeResetRequest)
    // }
    return res;
  }

  function sendControlWS(request: Encodable) {
    ws.send(request.encodeWS());
  }

  function sendMsgWS(msg: MessageManager) {
    ws.send(msg.encodeWS());
  }

  function sendPengingControlsWS(pendings: Array<Encodable>) {
      var batches = prepareBatchWS("control", pendings, requestLimit);
      sendBatchWS(batches);
  }

  function sendPendingMessagesWS() {
    var messages = [for (msg in messageManagers) if (msg.isPending()) (msg : Encodable)];
    // ASSERT (for each i, j in DOMAIN messages :
    // i < j AND messages[i].sequence = messages[j].sequence => messages[i].prog < messages[j].prog)
    var batches = prepareBatchWS("msg", messages, requestLimit);
    sendBatchWS(batches);
  }

  function sendBatchWS(batches: Array<String>) {
    for (batch in batches) {
      ws.send(batch);
    }
  }

  function sendHeartbeatWS() {
    protocolLogger.logInfo("Heartbeat request");
    ws.send("heartbeat\r\n\r\n"); // since the request has no parameter, it must include EOL
  }

  function sendPendingControlsHTTP(pendings: Array<Encodable>) {
    var body = prepareBatchHTTP(pendings, requestLimit);
    sendBatchHTTP(body, "control");
  }

  function sendPendingMessagesHTTP() {
    var messages = [for (msg in messageManagers) if (msg.isPending()) (msg : Encodable)];
    // ASSERT (for each i, j in DOMAIN messages :
    // i < j AND messages[i].sequence = messages[j].sequence => messages[i].prog < messages[j].prog)
    var body = prepareBatchHTTP(messages, requestLimit);
    sendBatchHTTP(body, "msg");
  }

  function sendHeartbeatHTTP() {
    protocolLogger.logInfo("Heartbeat request");
    sendBatchHTTP("\r\n", "heartbeat"); // since the request has no parameter, it must include EOL
  }

  function sendBatchHTTP(body: String, reqType: String) {
    ctrl_connectTs = TimerStamp.now();
    var url = Url.build(serverInstanceAddress, '/lightstreamer/$reqType.txt?LS_protocol=$TLCP_VERSION&LS_session=$sessionId');
    var headers = getHeadersForRequestOtherThanCreate();
    ctrl_http = ctrlFactory(url, body, headers,
      function onText(client, line) {
        lock.execute(() -> {
          if (client.isDisposed())
            return;
          evtCtrlMessage(line);
        });
      },
      function onError(client, error) {
        lock.execute(() -> {
          if (client.isDisposed())
            return;
          evtCtrlError();
        });
      },
      function onDone(client) {
        lock.execute(() -> {
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

  function getServerAddress() {
    var addr = details.serverAddress;
    return addr != null ? addr : defaultServerAddress;
  }

  function relateSubManager(subManager: SubscriptionManager) {
    assert(subscriptionManagers[subManager.subId] == null);
    subscriptionManagers[subManager.subId] = subManager;
  }

  function unrelateSubManager(subManager: SubscriptionManager) {
    subscriptionManagers.remove(subManager.subId);
  }

  function relateMsgManager(msgManager: MessageManager) {
    messageManagers.push(msgManager);
  }

  function unrelateMsgManager(msgManager: MessageManager) {
    messageManagers.remove(msgManager);
  }

  function getAndSetNextMsgProg(sequence: String) {
    var prog = sequenceMap[sequence];
    prog = prog == null ? 1 : prog;
    sequenceMap[sequence] = prog + 1;
    return prog;
  }

  function traceEvent(event: String) {
    internalLogger.logTrace("event: " + event + " " +  state.toString());
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