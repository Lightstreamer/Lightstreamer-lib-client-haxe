package com.lightstreamer.client.internal;

import com.lightstreamer.internal.RequestBuilder;
import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.RLock;
import com.lightstreamer.internal.Types;
import com.lightstreamer.client.internal.ClientRequests;
import com.lightstreamer.internal.MacroTools;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;
using com.lightstreamer.internal.NullTools;

interface SubscriptionManager extends Encodable {
  public final subId: Int;

  public function evtU(itemIdx: Pos, values: Map<Pos, FieldValue>): Void;
  public function evtSUBOK(nItems: Int, nFields: Int): Void;
  public function evtSUBCMD(nItems: Int, nFields: Int, keyIdx: Pos, cmdIdx: Pos): Void;
  public function evtUNSUB(): Void;
  public function evtEOS(itemIdx: Pos): Void;
  public function evtCS(itemIdx: Pos): Void;
  public function evtOV(itemIdx: Pos, lostUpdates: Int): Void;
  public function evtCONF(freq: RealMaxFrequency): Void;
  public function evtREQOK(reqId: Int): Void;
  public function evtREQERR(reqId: Int, errorCode: Int, errorMsg: String): Void;
  public function evtExtAbort(): Void;

	public function isPending(): Bool;
	public function encode(isWS:Bool): String;
	public function encodeWS(): String;
}

private enum abstract State_m(Int) {
  var s1 = 1; var s2 = 2; var s3 = 3; var s4 = 4; var s5 = 5;
  var s30 = 30; var s31 = 31; var s32 = 32;
}

private enum abstract State_s(Int) {
  var s10 = 10;
}

private enum abstract State_c(Int) {
  var s20 = 20; var s21 = 21; var s22 = 22;
}

private class State {
  public var s_m(default, null): State_m;
  public var s_s(default, null): Null<State_s>;
  public var s_c(default, null): Null<State_c>;
  final subId: Int;

  public function new(subId: Int) {
    this.subId = subId;
    this.s_m = s1;
  }

  public function toString() {
    var s = "<m=" + s_m;
    if (s_s != null) s += " s=" + s_s;
    if (s_c != null) s += " c=" + s_c;
    s += ">";
    return s;
  }

  public function traceState() {
    internalLogger.logTrace('sub#goto($subId) ' + this.toString());
  }
}

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class SubscriptionManagerLiving implements SubscriptionManager {
  public final subId: Int;
  final m_subscription: Subscription;
  final m_strategy: ModeStrategy;
  var m_lastAddReqId: Null<Int>;
  var m_lastDeleteReqId: Null<Int>;
  var m_lastReconfReqId: Null<Int>;
  var m_currentMaxFrequency: Null<RequestedMaxFrequency>;
  var m_reqMaxFrequency: Null<RequestedMaxFrequency>;
  final m_client: ClientMachine;
  final lock: RLock;
  final state: State;

  public function new(sub: Subscription, client: ClientMachine) {
    lock = client.lock;
    subId = client.generateFreshSubId();
    m_strategy = switch sub.fetch_mode() {
    case Merge:
      new ModeStrategyMerge(sub, client, subId);
    case Command:
      if (is2LevelCommand(sub)) {
        new ModeStrategyCommand2Level(sub, client, subId);
      } else {
        new ModeStrategyCommand1Level(sub, client, subId);
      }
    case Distinct:
      new ModeStrategyDistinct(sub, client, subId);
    case Raw:
      new ModeStrategyRaw(sub, client, subId);
    };
    state = new State(subId);
    m_client = client;
    m_subscription = sub;
    m_client.relateSubManager(this);
    m_subscription.relate(this);
  }

  function finalize() {
    m_strategy.evtDispose();
    m_client.unrelateSubManager(this);
    m_subscription.unrelate(this);
  }

  public function evtExtSubscribe() {
    traceEvent("subscribe");
    if (state.s_m == s1) {
      doSetActive();
      doSubscribe();
      goto(state.s_m = s2);
      genSendControl();
    }
  }

  public function evtExtUnsubscribe() {
    traceEvent("unsubscribe");
    if (state.s_m == s2) {
      doSetInactive();
      finalize();
      goto(state.s_m = s30);
    } else if (state.s_m == s3) {
      doUnsubscribe();
      doSetInactive();
      goto(state.s_m = s5);
      genSendControl();
    } else if (state.s_s == s10) {
      doUnsubscribe();
      m_subscription.setInactive();
      notifyOnUnsubscription();
      goto({
        state.s_m = s5;
        state.s_s = null;
        state.s_c = null;
      });
      genSendControl();
    }
  }

  public function evtExtAbort() {
    traceEvent("abort");
    if (state.s_m == s2) {
      goto(state.s_m = s2);
    } else if (state.s_m == s3) {
      doAbort();
      doSetActive();
      goto(state.s_m = s2);
    } else if (state.s_s == s10) {
      doAbort();
      doSetActive();
      notifyOnUnsubscription();
      goto({
        state.s_s = null;
        state.s_c = null;
        state.s_m = s2;
      });
    } else if (state.s_m == s5) {
      finalize();
      goto(state.s_m = s32);
    }
  }

  public function evtREQERR(reqId: Int, code: Int, msg: String) {
    traceEvent("REQERR");
    if (state.s_m == s2 && reqId == m_lastAddReqId) {
      doSetInactive();
      notifyOnSubscriptionError(code, msg);
      finalize();
      goto(state.s_m = s30);
    } else if (state.s_m == s5 && reqId == m_lastDeleteReqId) {
      finalize();
      goto(state.s_m = s32);
    } else if (state.s_c == s22 && reqId == m_lastReconfReqId) {
      if (RequestedMaxFrequencyTools.equals(m_reqMaxFrequency, m_subscription.fetch_requestedMaxFrequency())) {
        goto(state.s_c = s21);
      } else {
        goto(state.s_c = s20);
        evtCheckFrequency();
      }
    }
  }

  public function evtREQOK(reqId: Int) {
    traceEvent("REQOK");
    if (state.s_m == s2 && reqId == m_lastAddReqId) {
      goto(state.s_m = s3);
    } else if (state.s_m == s5 && reqId == m_lastDeleteReqId) {
      finalize();
      goto(state.s_m = s32);
    } else if (state.s_c == s22 && reqId == m_lastReconfReqId) {
      doREQOKConfigure();
      goto(state.s_c = s20);
      evtCheckFrequency();
    }
  }

  public function evtSUBOK(nItems: Int, nFields: Int) {
    traceEvent("SUBOK");
    if (state.s_m == s2) {
      doSUBOK(nItems, nFields);
      notifyOnSubscription();
      goto({
        state.s_m = s4;
        state.s_s = s10;
        state.s_c = s20;
      });
      evtCheckFrequency();
    } else if (state.s_m == s3) {
      doSUBOK(nItems, nFields);
      notifyOnSubscription();
      goto({
        state.s_m = s4;
        state.s_s = s10;
        state.s_c = s20;
      });
      evtCheckFrequency();
    }
  }

  public function evtSUBCMD(nItems: Int, nFields: Int, keyIdx: Int, cmdIdx: Int) {
    traceEvent("SUBCMD");
    if (state.s_m == s2) {
      doSUBCMD(nItems, nFields, cmdIdx, keyIdx);
      notifyOnSubscription();
      goto({
        state.s_m = s4;
        state.s_s = s10;
        state.s_c = s20;
      });
      evtCheckFrequency();
    } else if (state.s_m == s3) {
      doSUBCMD(nItems, nFields, cmdIdx, keyIdx);
      notifyOnSubscription();
      goto({
        state.s_m = s4;
        state.s_s = s10;
        state.s_c = s20;
      });
      evtCheckFrequency();
    }
  }

  public function evtUNSUB() {
    traceEvent("UNSUB");
    if (state.s_s == s10) {
      doUNSUB();
      doSetInactive();
      notifyOnUnsubscription();
      finalize();
      goto({
        state.s_m = s31;
        state.s_s = null;
        state.s_c = null;
      });
    } else if (state.s_m == s5) {
      finalize();
      goto(state.s_m = s32);
    }
  }

  public function evtU(itemIdx: Int, values: Map<Pos, FieldValue>) {
    traceEvent("U");
    if (state.s_s == s10) {
      doU(itemIdx, values);
      goto(state.s_s = s10);
    }
  }

  public function evtEOS(itemIdx: Int) {
    traceEvent("EOS");
    if (state.s_s == s10) {
      doEOS(itemIdx);
      goto(state.s_s = s10);
    }
  }

  public function evtCS(itemIdx: Int) {
    traceEvent("CS");
    if (state.s_s == s10) {
      doCS(itemIdx);
      goto(state.s_s = s10);
    }
  }

  public function evtOV(itemIdx: Int, lostUpdates: Int) {
    traceEvent("OV");
    if (state.s_s == s10) {
      doOV(itemIdx, lostUpdates);
      goto(state.s_s = s10);
    }
  }

  public function evtCONF(freq: RealMaxFrequency) {
    traceEvent("CONF");
    if (state.s_s == s10) {
      doCONF(freq);
      goto(state.s_s = s10);
    }
  }

  public function evtCheckFrequency() {
    traceEvent("check.frequency");
    if (state.s_c == s20) {
      if (!RequestedMaxFrequencyTools.equals(m_subscription.fetch_requestedMaxFrequency(), m_currentMaxFrequency)) {
        doConfigure();
        goto(state.s_c = s22);
        genSendControl();
      } else {
        goto(state.s_c = s21);
      }
    }
  }

  public function evtExtConfigure() {
    traceEvent("configure");
    if (state.s_c == s21) {
      goto(state.s_c = s20);
      evtCheckFrequency();
    }
  }

	public function isPending(): Bool {
    return state.s_m == s2 || state.s_m == s5 || state.s_c == s22;
	}

	public function encode(isWS:Bool):String {
    if (state.s_m == s2) {
      return encodeAdd(isWS);
    } else if (state.s_m == s5) {
      return encodeDelete(isWS);
    } else if (state.s_c == s22) {
      return encodeReconf(isWS);
    } else {
      throw new IllegalStateException("Can't encode request");
    }
	}

	public function encodeWS():String {
    return "control\r\n" + encode(true);
	}

  public function getValue(itemPos: Pos, fieldPos: Pos): Null<String> {
    return m_strategy.getValue(itemPos, fieldPos);
  }

  public function getCommandValue(itemPos: Int, key: String, fieldPos: Int): Null<String> {
    return m_strategy.getCommandValue(itemPos, key, fieldPos);
  }

  function encodeAdd(isWS: Bool): String {
    var req = new RequestBuilder();
    m_lastAddReqId = m_client.generateFreshReqId();
    req.LS_reqId(m_lastAddReqId);
    req.LS_op("add");
    req.LS_subId(subId);
    req.LS_mode(m_subscription.fetch_mode());
    var group = m_subscription.getItemGroup();
    var items = m_subscription.getItems();
    if (group != null) {
      req.LS_group(group);
    } else if (items != null) {
      req.LS_group(items.toHaxe().join(" "));
    }
    var schema = m_subscription.getFieldSchema();
    var fields = m_subscription.getFields();
    if (schema != null) {
      req.LS_schema(schema);
    } else if (fields != null) {
      req.LS_schema(fields.toHaxe().join(" "));
    }
    var adapter = m_subscription.getDataAdapter();
    if (adapter != null) {
      req.LS_data_adapter(adapter);
    }
    var selector = m_subscription.getSelector();
    if (selector != null) {
      req.LS_selector(selector);
    }
    var snapshot = m_subscription.fetch_requestedSnapshot();
    if (snapshot != null) {
      switch snapshot {
      case SnpYes:
        req.LS_snapshot(true);
      case SnpNo:
        req.LS_snapshot(false);
      case SnpLength(var len):
        req.LS_snapshot_Int(len);
      }
    }
    var freq = m_currentMaxFrequency;
    if (freq != null) {
      switch freq {
      case FreqLimited(var limit):
        req.LS_requested_max_frequency_Float(limit);
      case FreqUnlimited:
        req.LS_requested_max_frequency("unlimited");
      case FreqUnfiltered:
        req.LS_requested_max_frequency("unfiltered");
      }
    }
    var buff = m_subscription.fetch_requestedBufferSize();
    if (buff != null) {
      switch buff {
      case BSLimited(var limit):
        req.LS_requested_buffer_size_Int(limit);
      case BSUnlimited:
        req.LS_requested_buffer_size("unlimited");
      }
    }
    if (isWS) {
      req.LS_ack(false);
    }
    protocolLogger.logInfo('Sending Subscription add: $req');
    return req.getEncodedString();
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
    protocolLogger.logInfo('Sending Subscription delete: $req');
    return req.getEncodedString();
  }

  function encodeReconf(isWS: Bool): String {
    var req = new RequestBuilder();
    m_lastReconfReqId = m_client.generateFreshReqId();
    req.LS_reqId(m_lastReconfReqId);
    req.LS_subId(subId);
    req.LS_op("reconf");
    var freq = m_reqMaxFrequency;
    if (freq != null) {
      switch freq {
      case FreqLimited(var limit):
        req.LS_requested_max_frequency_Float(limit);
      case FreqUnlimited:
        req.LS_requested_max_frequency("unlimited");
      case FreqUnfiltered:
        req.LS_requested_max_frequency("unfiltered");
      }
    }
    protocolLogger.logInfo('Sending Subscription configuration: $req');
    return req.getEncodedString();
  }

  function doSetActive() {
    m_subscription.setActive();
  }

  function doSetInactive() {
    m_subscription.setInactive();
  }

  function doSubscribe() {
    m_currentMaxFrequency = m_subscription.fetch_requestedMaxFrequency();
  }

  function doUnsubscribe() {
    m_strategy.evtUnsubscribe();
    m_subscription.unrelate(this);
  }

  function doAbort() {
    m_lastAddReqId = null;
    m_lastDeleteReqId = null;
    m_lastReconfReqId = null;
    m_reqMaxFrequency = null;
    m_currentMaxFrequency = m_subscription.fetch_requestedMaxFrequency();
    m_strategy.evtAbort();
  }

  function genSendControl() {
    m_client.evtSendControl(this);
  }

  function notifyOnSubscription() {
    m_subscription.fireOnSubscription(subId);
  }

  function notifyOnUnsubscription() {
    m_subscription.fireOnUnsubscription(subId);
  }

  function notifyOnSubscriptionError(code: Int, msg: String) {
    m_subscription.fireOnSubscriptionError(subId, code, msg);
  }

  function doConfigure() {
    m_reqMaxFrequency = m_subscription.fetch_requestedMaxFrequency();
    m_strategy.evtSetRequestedMaxFrequency(m_reqMaxFrequency);
  }

  function doREQOKConfigure() {
    m_currentMaxFrequency = m_reqMaxFrequency;
  }

  function doSUBOK(nItems: Int, nFields: Int) {
    m_subscription.setSubscribed(subId, nItems, nFields);
    m_strategy.evtOnSUB(nItems, nFields, null, null, null);
  }

  function doSUBCMD(nItems: Int, nFields: Int, cmdIdx: Int, keyIdx: Int) {
    m_subscription.setSubscribedCMD(subId, nItems, nFields, cmdIdx, keyIdx);
    m_strategy.evtOnSUB(nItems, nFields, cmdIdx, keyIdx, m_currentMaxFrequency);
  }

  function doUNSUB() {
    m_strategy.evtOnUNSUB();
  }

  function doU(itemIdx: Int, values: Map<Pos, FieldValue>) {
    assert(itemIdx <= m_subscription.fetch_nItems().sure());
    m_strategy.evtUpdate(itemIdx, values);
  }

  function doEOS(itemIdx: Int) {
    m_strategy.evtOnEOS(itemIdx);
    m_subscription.fireOnEndOfSnapshot(itemIdx, subId);
  }
  
  function doCS(itemIdx: Int) {
    m_strategy.evtOnCS(itemIdx);
    m_subscription.fireOnClearSnapshot(itemIdx, subId);
  }
  
  function doOV(itemIdx: Int, lostUpdates: Int) {
    m_subscription.fireOnLostUpdates(itemIdx, lostUpdates, subId);
  }
  
  function doCONF(freq: RealMaxFrequency) {
    m_strategy.evtOnCONF(freq);
  }

  function traceEvent(evt: String) {
    internalLogger.logTrace('sub#$evt($subId) in $state');
  }

  static function is2LevelCommand(sub: Subscription): Bool {
    return sub.fetch_mode() == Command && (sub.getCommandSecondLevelFields() != null || sub.getCommandSecondLevelFieldSchema() != null);
  }
}