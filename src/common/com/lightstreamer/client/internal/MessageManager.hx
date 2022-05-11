package com.lightstreamer.client.internal;

import com.lightstreamer.internal.EventDispatcher;
import com.lightstreamer.client.internal.ClientRequests;
import com.lightstreamer.internal.RequestBuilder;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

private class MessageEventDispatcher extends EventDispatcher<ClientMessageListener> {}

private enum abstract State_m(Int) {
  var s1 = 1;
  var s10 = 10; var s11 = 11; var s12 = 12; var  s13 = 13; var s14 = 14; var s15 = 15;
  var s20 = 20; var s21 = 21; var s22 = 22; var  s23 = 23; var s24 = 24;
  var s30 = 30; var s31 = 31; var s32 = 32; var  s33 = 33; var s34 = 34; var s35 = 35;
}

class MessageManager implements Encodable {
  final eventDispatcher = new MessageEventDispatcher();
  final txt: String;
  public final sequence: String;
  public final prog: Int;
  final maxWait: Int;
  final delegate: Null<ClientMessageListener>;
  final enqueueWhileDisconnected: Bool;
  final client: ClientMachine;
  var lastReqId: Null<Int>;
  var s_m: State_m;

  public function new(txt: String, sequence: String, maxWait: Int, delegate: Null<ClientMessageListener>, enqueueWhileDisconnected: Bool, client: ClientMachine) {
    this.txt = txt;
    this.sequence = sequence;
    var isOrdered = sequence != "UNORDERED_MESSAGES";
    var hasListener = delegate != null;
    if (isOrdered || hasListener) {
      this.prog = client.getAndSetNextMsgProg(sequence);
    } else {
      // fire-and-forget;
      this.prog = -1;
    }
    this.maxWait = maxWait;
    this.delegate = delegate;
    this.enqueueWhileDisconnected = enqueueWhileDisconnected;
    this.client = client;
    if (delegate != null) {
      s_m = s10;
    } else if (sequence != "UNORDERED_MESSAGES") {
      s_m = s20;
    } else {
      s_m = s30;
    }
    client.relateMsgManager(this);
  }

  function finalize() {
    client.unrelateMsgManager(this);
  }

  function evtExtSendMessage() {
    traceEvent("sendMessage");
    switch s_m {
    case s10:
      goto(s11);
      client.evtSendMessage(this);
    case s20:
      goto(s21);
      client.evtSendMessage(this);
    case s30:
      goto(s31);
      client.evtSendMessage(this);
    default:
      // ignore
    }
  }

  public function evtMSGFAIL(code: Int, msg: String) {
    traceEvent("MSGFAIL");
    switch s_m {
    case s10:
      finalize();
      goto(s13);
    case s11:
      doMSGFAIL(code, msg);
      finalize();
      goto(s14);
    case s12:
      doMSGFAIL(code, msg);
      finalize();
      goto(s14);
    default:
      // ignore
    }
  }

  public function evtMSGDONE() {
    traceEvent("MSGDONE");
    switch s_m {
    case s10:
      finalize();
      goto(s13);
    case s11:
      doMSGDONE();
      finalize();
      goto(s13);
    case s12:
      doMSGDONE();
      finalize();
      goto(s13);
    default:
      // ignore
    }
  }

  public function evtREQOK(reqId: Int) {
    traceEvent("REQOK");
    switch s_m {
    case s11 if (reqId == lastReqId):
      goto(s12);
    case s21 if (reqId == lastReqId):
      finalize();
      goto(s22);
    case s31 if (reqId == lastReqId):
      finalize();
      goto(s33);
    default:
      // ignore
    }
  }

  public function evtREQERR(reqId: Int, code: Int, msg: String) {
    traceEvent("REQERR");
    switch s_m {
    case s11 if (reqId == lastReqId):
      doREQERR(code, msg);
      finalize();
      goto(s14);
    case s21 if (reqId == lastReqId):
      finalize();
      goto(s23);
    case s31 if (reqId == lastReqId):
      finalize();
      goto(s34);
    default:
      // ignore
    }
  }

  public function evtAbort() {
    traceEvent("abort");
    switch s_m {
    case s11:
      doAbort();
      finalize();
      goto(s15);
    case s12:
      doAbort();
      finalize();
      goto(s15);
    case s21:
      messageLogger.logWarn('Message $sequence:$prog aborted');
      finalize();
      goto(s24);
    case s31:
      messageLogger.logWarn('Message $sequence:$prog aborted');
      finalize();
      goto(s35);
    default:
      // ignore
    }
  }

  public function evtWSSent() {
    traceEvent("ws.sent");
    if (s_m == s31) {
      finalize();
      goto(s32);
    }
  }

  public function isPending(): Bool {
    return s_m == s11 || s_m == s21 || s_m == s31;
  }
  
  public function encode(isWS: Bool): String {
    return encodeMsg(isWS);
  }
  
  public function encodeWS(): String {
    return "msg\r\n" + encode(true);
  }

  function doMSGDONE() {
    fireOnProcessed();
  }

  function doMSGFAIL(code: Int, msg: String) {
    if (code == 38 || code == 39) {
      fireOnDiscarded();
    } else if (code <= 0) {
      fireOnDeny(code, msg);
    } else if (code != 32 && code != 33) {
      /*
        errors 32 and 33 must not be notified to the user
        because they are due to late responses of the server
      */
      fireOnError();
    }
  }

  function doREQERR(code: Int, msg: String) {
    if (code != 32 && code != 33) {
      /*
        errors 32 and 33 must not be notified to the user
        because they are due to late responses of the server
      */
      fireOnError();
    }
  }

  function doAbort() {
    fireOnAbort();
  }

  function encodeMsg(isWS: Bool): String {
    var isOrdered = sequence != "UNORDERED_MESSAGES";
    var hasListener = delegate != null;
    var req = new RequestBuilder();
    lastReqId = client.generateFreshReqId();
    req.LS_reqId(lastReqId);
    req.LS_message(txt);
    if (isOrdered && hasListener) {
      // LS_outcome=true is the default
      // LS_ack=true is the default
      req.LS_sequence(sequence);
      req.LS_msg_prog(prog);
      if (maxWait >= 0) {
        req.LS_max_wait(maxWait);
      }
    } else if (!isOrdered && hasListener) {
      // LS_outcome=true is the default
      // LS_ack=true is the default
      // LS_sequence=UNORDERED_MESSAGES is the default
      req.LS_msg_prog(prog);
      // LS_max_wait is ignored
    } else if (isOrdered && !hasListener) {
      req.LS_outcome(false);
      // LS_ack=true is the default
      req.LS_sequence(sequence);
      req.LS_msg_prog(prog);
      if (maxWait >= 0) {
        req.LS_max_wait(maxWait);
      }
    } else if (!isOrdered && !hasListener) { // fire-and-forget
      req.LS_outcome(false);
      if (isWS) {
        req.LS_ack(false);
      } // else ack is always sent in HTTP
      // LS_sequence=UNORDERED_MESSAGES is the default
      // LS_prog is ignored
      // LS_max_wait is ignored
    }
    protocolLogger.logInfo('Sending message: $req');
    return req.getEncodedString();
  }

  function fireOnProcessed() {
    messageLogger.logInfo('Message $sequence:$prog processed');
    eventDispatcher.onProcessed(txt);
  }
  
  function fireOnDiscarded() {
    messageLogger.logWarn('Message $sequence:$prog discarded');
    eventDispatcher.onDiscarded(txt);
  }
  
  function fireOnDeny(code: Int, msg: String) {
    messageLogger.logWarn('Message $sequence:$prog denied: $code - $msg');
    eventDispatcher.onDeny(txt, code, msg);
  }
  
  function fireOnError() {
    messageLogger.logWarn('Message $sequence:$prog failed');
    eventDispatcher.onError(this.txt);
  }
  
  function fireOnAbort() {
    messageLogger.logWarn('Message $sequence:$prog aborted');
    eventDispatcher.onAbort(txt, false);
  }

  function traceEvent(evt: String) {
    internalLogger.logTrace('msg#$evt($sequence:$prog) in $s_m');
  }

  function goto(target: State_m) {
    s_m = target;
    internalLogger.logTrace('msg#goto($sequence:$prog) $s_m');
  }
}