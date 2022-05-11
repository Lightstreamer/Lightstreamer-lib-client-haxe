package com.lightstreamer.client.internal;

import com.lightstreamer.internal.RequestBuilder;
import com.lightstreamer.internal.RLock;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

private enum abstract State_m(Int) {
  var s1 = 1; var s2 = 2; var s3 = 3;
}

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class SubscriptionManagerZombie implements SubscriptionManager {
  public final subId: Int;
  var s_m: State_m = s1;
  final lock: RLock;
  var m_lastDeleteReqId: Null<Int>;
  final m_client: ClientMachine;

  public function new(subId: Int, client: ClientMachine) {
    this.subId = subId;
    this.lock = client.lock;
    this.m_client = client;
    client.relateSubManager(this);
  }

  function finalize() {
    m_client.unrelateSubManager(this);
  }

  public function evtExtAbort() {
    traceEvent("abort");
    if (s_m == s2) {
      finalize();
      goto(s3);
    }
  }

  public function evtREQERR(reqId: Int, code: Int, msg: String) {
    traceEvent("REQERR");
    if (s_m == s2 && reqId == m_lastDeleteReqId) {
      finalize();
      goto(s3);
    }
  }

  public function evtREQOK(reqId: Int) {
    traceEvent("REQOK");
    if (s_m == s2 && reqId == m_lastDeleteReqId) {
      finalize();
      goto(s3);
    }
  }

  public function evtSUBOK(nItems: Int, nFields: Int) {
    traceEvent("SUBOK");
    if (s_m == s1) {
      goto(s2);
      genSendControl();
    }
  }
  
  public function evtSUBCMD(nItems: Int, nFields: Int, keyIdx: Int, cmdIdx: Int) {
    traceEvent("SUBCMD");
    if (s_m == s1) {
      goto(s2);
      genSendControl();
    }
  }
  
  public function evtUNSUB() {
    traceEvent("UNSUB");
    if (s_m == s2) {
      finalize();
      goto(s3);
    }
  }
  
  public function evtU(itemIdx: Pos, values: Map<Pos, FieldValue>) {
    traceEvent("U");
    if (s_m == s1) {
      goto(s2);
      genSendControl();
    }
  }
  
  public function evtEOS(itemIdx: Pos) {
    traceEvent("EOS");
    if (s_m == s1) {
      goto(s2);
      genSendControl();
    }
  }
  
  public function evtCS(itemIdx: Pos) {
    traceEvent("CS");
    if (s_m == s1) {
      goto(s2);
      genSendControl();
    }
  }
  
  public  function evtOV(itemIdx: Pos, lostUpdates: Int) {
    traceEvent("OV");
    if (s_m == s1) {
      goto(s2);
      genSendControl();
    }
  }
  
  public function evtCONF(freq: RealMaxFrequency) {
    traceEvent("CONF");
    if (s_m == s1) {
      goto(s2);
      genSendControl();
    }
  }

  public function isPending(): Bool {
    return s_m == s2;
  }
  
  public function encode(isWS: Bool): String {
    if (isPending()) {
      return encodeDelete(isWS);
    } else {
      throw new IllegalStateException("Can't encode unsubscription request");
    }
  }
  
  public function encodeWS(): String {
    return "control\r\n" + encode(true);
  }
  
  function genSendControl() {
    m_client.evtSendControl(this);
  }

  function encodeDelete(isWS: Bool): String {
    var req = new RequestBuilder();
    m_lastDeleteReqId = m_client.generateFreshReqId();
    req.LS_reqId(m_lastDeleteReqId);
    req.LS_subId(subId);
    req.LS_op("delete");
    if (isWS) {
      req.LS_ack(false);
    }
    req.LS_cause("zombie");
    protocolLogger.logInfo('Sending Subscription delete: $req');
    return req.getEncodedString();
  }

  function traceEvent(evt: String) {
    internalLogger.logTrace('zsub#$evt($subId) in $s_m');
  }

  function goto(target: State_m) {
    s_m = target;
    internalLogger.logTrace('zsub#goto($subId) $s_m');
  }
}