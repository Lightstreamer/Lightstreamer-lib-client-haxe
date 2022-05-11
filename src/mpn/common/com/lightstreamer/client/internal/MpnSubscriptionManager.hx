package com.lightstreamer.client.internal;

import com.lightstreamer.internal.RequestBuilder;
import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.client.mpn.Types.MpnSubscriptionMode;
import com.lightstreamer.internal.RLock;
import com.lightstreamer.client.internal.ClientRequests.Encodable;
import com.lightstreamer.client.mpn.MpnSubscription;
import com.lightstreamer.internal.MacroTools;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;
using com.lightstreamer.internal.NullTools;

private  enum abstract State_uu(Int) {
  var s10 = 10; var s11 = 11; var s12 = 12;
}

private enum abstract State_fu(Int) {
  var s20 = 20; var s21 = 21; var s22 = 22; var s23 = 23;
}

private enum abstract State_tu(Int) {
  var s30 = 30; var s31 = 31; var s32 = 32; var s33 = 33;
}

private enum abstract State_m(Int) {
  var s40 = 40; var s41 = 41; var s42 = 42; var s43 = 43; var s44 = 44; var s45 = 45;
  var s50 = 50; var s51 = 51; var s52 = 52;
}

private enum abstract State_st(Int) {
  var s60 = 60; var s61 = 61;
}

private enum abstract State_ab(Int) {
  var s80 = 80; var s81 = 81;
}

private  enum abstract State_ct(Int) {
  var s70 = 70; var s71 = 71; var s72 = 72; var s73 = 73; var s74 = 74; var s75 = 75; var s76 = 76;
}

private class State {
  public var s_m(default, null): State_m;
  public var s_uu(default, null): State_uu = s10;
  public var s_fu(default, null): State_fu = s20;
  public var s_tu(default, null): State_tu = s30;
  public var s_st(default, null): Null<State_st>;
  public var s_ab(default, null): Null<State_ab>;
  public var s_ct(default, null): Null<State_ct>;
  final manager: MpnSubscriptionManager;

  public function new(m: State_m, manager: MpnSubscriptionManager) {
    this.s_m = m;
    this.manager = manager;
  }

  public function toString() {
    var s = "<m=" + s_m;
    s += " uu=" + s_uu;
    s += " fu=" + s_fu;
    s += " tu=" + s_tu;
    if (s_st != null) s += " st=" + s_st;
    if (s_ab != null) s += " ab=" + s_ab;
    if (s_ct != null) s += " ct=" + s_ct;
    s += ">";
    return s;
  }

  public function traceState() {
    internalLogger.logTrace('mpn#sub#goto(${manager.m_subId}:${manager.get_mpnSubId()}) ' + this.toString());
  }
}

private enum CtorArgs {
  Ctor1(sub: MpnSubscription, coalescing: Bool, client: MpnClientMachine);
  Ctor2(mpnSubId: String, client: MpnClientMachine);
}

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class MpnSubscriptionManager implements Encodable {
  final state: State;
  final lock: RLock;
  public final m_subId: Null<Int>;
  final m_coalescing: Bool;
  var m_lastActivateReqId: Null<Int>;
  var m_lastConfigureReqId: Null<Int>;
  var m_lastDeactivateReqId: Null<Int>;
  final m_initFormat: Null<String>;
  final m_initTrigger: Null<String>;
  var m_currentFormat: Null<String>;
  var m_currentTrigger: Null<String>;
  final m_subscription: MpnSubscription;
  final m_client: MpnClientMachine;

  public function new(args: CtorArgs) {
    var sub: Null<MpnSubscription> = null;
    var coalescing: Null<Bool> = null;
    var client: Null<MpnClientMachine> = null;
    var mpnSubId: Null<String> = null;
    switch args {
    case Ctor1(_sub, _coalescing, _client):
      sub = _sub;
      coalescing = _coalescing;
      client = _client;
    case Ctor2(_mpnSubId, _client):
      mpnSubId = _mpnSubId;
      client = _client;
    }
    if (mpnSubId == null) {
      lock = client.lock;
      m_subId = client.generateFreshSubId();
      m_coalescing = coalescing;
      m_initFormat = sub.getNotificationFormat();
      m_initTrigger = sub.getTriggerExpression();
      m_subscription = sub;
      m_client = client;
      state = new State(s40, @:nullSafety(Off) this);
      m_subscription.relate(this);
      m_client.relate(this);
    } else {
      lock = client.lock;
      m_subId = null;
      m_coalescing = false;
      m_initFormat = null;
      m_initTrigger = null;
      m_subscription = new MpnSubscription(Merge, null, null);
      m_subscription.reInit(mpnSubId);
      m_client = client;
      state = new State(s45, @:nullSafety(Off) this);
      m_subscription.relate(this);
      m_client.relate(this);
    }
  }

  function finalize() {
    m_subscription.reset();
    m_client.unrelate(this);
    m_subscription.unrelate(this);
  }

  public function get_mpnSubId(): Null<String> {
    return m_subscription.get_mpnSubId();
  }

  public function start() {
    // nothing to do
  }

  public function evtExtMpnUnsubscribe() {
    traceEvent("unsubscribe");
    var forward = true;
    if (state.s_m == s41) {
      notifyStatus(Unknown);
      notifyOnSubscriptionDiscarded();
      finalize();
      goto(state.s_m = s50);
      forward = evtExtMpnUnsubscribe_UnsubRegion();
    } else if (state.s_ct == s71) {
      goto(state.s_ct = s70);
      forward = evtExtMpnUnsubscribe_UnsubRegion();
      evtCheck();
    }
    if (forward) {
      forward = evtExtMpnUnsubscribe_UnsubRegion();
    }
  }

  function evtExtMpnUnsubscribe_UnsubRegion(): Bool {
    traceEvent("unsubscribe");
    if (state.s_uu == s10) {
      goto(state.s_uu = s11);
    } else if (state.s_uu == s12) {
      goto(state.s_uu = s11);
    }
    return false;
  }

  public function evtAbort() {
    traceEvent("abort");
    if (state.s_m == s41) {
      notifyStatus(Unknown);
      notifyOnSubscriptionDiscarded();
      finalize();
      goto(state.s_m = s50);
    } else if (state.s_m == s42 || state.s_m == s43) {
      notifyStatus(Unknown);
      notifyOnSubscriptionAbort();
      finalize();
      goto(state.s_m = s50);
    } else if (state.s_m == s44) {
      goto(state.s_m = s44);
      evtAbort_AbortRegion();
    }
  }

  function evtAbort_AbortRegion() {
    traceEvent("abort");
    var forward = true;
    if (state.s_ab == s80) {
      goto(state.s_ab = s81);
      forward = evtAbort_ControlRegion();
    }
    if (forward) {
      forward = evtAbort_ControlRegion();
    }
  }

  function evtAbort_ControlRegion(): Bool {
    traceEvent("abort");
    if (state.s_ct == s70 || state.s_ct == s71 || state.s_ct == s72 || state.s_ct == s73 || state.s_ct == s74) {
      goto(state.s_ct = s76);
      evtAbortFormat();
      evtAbortTrigger();
      evtAbortUnsubscribe();
    }
    return false;
  }

  public function evtRestoreSession() {
    traceEvent("restore.session");
    if (state.s_ct == s76) {
      goto(state.s_ct = s70);
      evtCheck();
    }
  }

  public function evtREQOK(reqId: Int) {
    traceEvent("REQOK");
    var forward = true;
    if (state.s_fu == s22 && reqId == m_lastConfigureReqId) {
      goto(state.s_fu = s20);
      forward = evtREQOK_TriggerRegion(reqId);
    } else if (state.s_fu == s23 && reqId == m_lastConfigureReqId) {
      goto(state.s_fu = s21);
      forward = evtREQOK_TriggerRegion(reqId);
    }
    if (forward) {
      forward = evtREQOK_TriggerRegion(reqId);
    }
  }

  function evtREQOK_TriggerRegion(reqId: Int): Bool {
    traceEvent("REQOK");
    var forward = true;
    if (state.s_tu == s32 && reqId == m_lastConfigureReqId) {
      goto(state.s_tu = s30);
      forward = evtREQOK_MainRegion(reqId);
    } else if (state.s_tu == s33 && reqId == m_lastConfigureReqId) {
      goto(state.s_tu = s31);
      forward = evtREQOK_MainRegion(reqId);
    }
    if (forward) {
      forward = evtREQOK_MainRegion(reqId);
    }
    return false;
  }

  function evtREQOK_MainRegion(reqId: Int): Bool {
    traceEvent("REQOK");
    if (state.s_m == s42 && reqId == m_lastActivateReqId) {
      goto(state.s_m = s43);
    } else if (state.s_m == s44) {
      goto(state.s_m = s44);
      evtREQOK_ControlRegion(reqId);
    }
    return false;
  }

  function evtREQOK_ControlRegion(reqId: Int) {
    traceEvent("REQOK");
    if (state.s_ct == s72 && reqId == m_lastDeactivateReqId) {
      notifyStatus(Unknown);
      notifyOnUnsubscription();
      notifyOnSubscriptionsUpdated();
      finalize();
      goto({
        state.s_m = s52;
        state.s_st = null;
        state.s_ct = null;
        state.s_ab = null;
      });
    } else if ((state.s_ct == s73 || state.s_ct == s74) && reqId == m_lastConfigureReqId) {
      goto(state.s_ct = s70);
      evtCheck();
    }
  }

  public function evtREQERR(reqId: Int, code: Int, msg: String) {
    traceEvent("REQERR");
    var forward = true;
    if (state.s_uu == s11 && reqId == m_lastDeactivateReqId) {
      notifyOnUnsubscriptionError(code, msg);
      goto(state.s_uu = s12);
      forward = evtREQERR_FormatRegion(reqId, code, msg);
    }
    if (forward) {
      forward = evtREQERR_FormatRegion(reqId, code, msg);
    }
  }

  function evtREQERR_FormatRegion(reqId: Int, code: Int, msg: String): Bool {
    traceEvent("REQERR");
    var forward = true;
    if (state.s_fu == s22 && reqId == m_lastConfigureReqId) {
      notifyOnModificationError_Format(code, msg);
      goto(state.s_fu = s20);
      forward = evtREQERR_TriggerRegion(reqId, code, msg);
    } else if (state.s_fu == s23 && reqId == m_lastConfigureReqId) {
      goto(state.s_fu = s21);
      forward = evtREQERR_TriggerRegion(reqId, code, msg);
    }
    if (forward) {
      forward = evtREQERR_TriggerRegion(reqId, code, msg);
    }
    return false;
  }

  function evtREQERR_TriggerRegion(reqId: Int, code: Int, msg: String): Bool {
    traceEvent("REQERR");
    var forward = true;
    if (state.s_tu == s32 && reqId == m_lastConfigureReqId) {
      notifyOnModificationError_Trigger(code, msg);
      goto(state.s_tu = s30);
      forward = evtREQERR_MainRegion(reqId, code, msg);
    } else if (state.s_tu == s33 && reqId == m_lastConfigureReqId) {
      goto(state.s_tu = s31);
      forward = evtREQERR_MainRegion(reqId, code, msg);
    }
    if (forward) {
      forward = evtREQERR_MainRegion(reqId, code, msg);
    }
    return false;
  }

  function evtREQERR_MainRegion(reqId: Int, code: Int, msg: String): Bool {
    traceEvent("REQERR");
    if (state.s_m == s42 && reqId == m_lastActivateReqId) {
      notifyStatus(Unknown);
      notifyOnSubscriptionError(code, msg);
      finalize();
      goto(state.s_m = s50);
    } else if (state.s_m == s44) {
      goto(state.s_m = s44);
      evtREQERR_ControlRegion(reqId, code, msg);
    }
    return false;
  }

  function evtREQERR_ControlRegion(reqId: Int, code: Int, msg: String) {
    traceEvent("REQERR");
    if (state.s_ct == s72 && reqId == m_lastDeactivateReqId) {
      goto(state.s_ct = s70);
      evtCheck();
    }  else if ((state.s_ct == s73 || state.s_ct == s74) && reqId == m_lastConfigureReqId) {
      goto(state.s_ct = s70);
      evtCheck();
    }
  }

  public function evtAbortUnsubscribe() {
    traceEvent("abort.unsubscribe");
    if (state.s_uu == s11) {
      notifyOnUnsubscriptionAbort();
      goto(state.s_uu = s12);
    }
  }

  function evtExtMpnSetFormat() {
    traceEvent("setFormat");
    var forward = true;
    if (state.s_fu == s20) {
      goto(state.s_fu = s21);
      forward = evtExtMpnSetFormat_ControlRegion();
    } else if (state.s_fu == s22) {
      goto(state.s_fu = s23);
      forward = evtExtMpnSetFormat_ControlRegion();
    }
    if (forward) {
      forward = evtExtMpnSetFormat_ControlRegion();
    }
  }

  function evtExtMpnSetFormat_ControlRegion(): Bool {
    traceEvent("setFormat");
    if (state.s_ct == s71) {
      goto(state.s_ct = s70);
      evtCheck();
    }
    return false;
  }

  public function evtExtMpnSetTrigger() {
    traceEvent("setTrigger");
    var forward = true;
    if (state.s_tu == s30) {
      goto(state.s_tu = s31);
      forward = evtExtMpnSetTrigger_ControlRegion();
    } else if (state.s_tu == s32) {
      goto(state.s_tu = s33);
      forward = evtExtMpnSetTrigger_ControlRegion();
    }
    if (forward) {
      forward = evtExtMpnSetTrigger_ControlRegion();
    }
  }

  function evtExtMpnSetTrigger_ControlRegion(): Bool {
    traceEvent("setTrigger");
    if (state.s_ct == s71) {
      goto(state.s_ct = s70);
      evtCheck();
    }
    return false;
  }

  public function evtChangeFormat() {
    traceEvent("change.format");
    if (state.s_fu == s21) {
      doSetCurrentFormat();
      goto(state.s_fu = s22);
    }
  }

  public function evtChangeTrigger() {
    traceEvent("change.trigger");
    if (state.s_tu == s31) {
      doSetCurrentTrigger();
      goto(state.s_tu = s32);
    }
  }

  public function evtAbortFormat() {
    traceEvent("abort.format");
    switch state.s_fu {
    case s21, s22, s23:
      notifyOnModificationAbort_Format();
      goto(state.s_fu = s20);
    default:
      // nothing to do
    }
  }

  public function evtAbortTrigger() {
    traceEvent("abort.trigger");
    switch state.s_tu {
    case s31, s32, s33:
      notifyOnModificationAbort_Trigger();
      goto(state.s_tu = s30);
    default:
      // nothing to do
    }
  }

  public function evtCheck() {
    traceEvent("check");
    if (state.s_ct == s70) {
      if (state.s_uu == s11) {
        goto(state.s_ct = s72);
        genSendUnsubscribe();
      } else if (state.s_fu == s21) {
        goto(state.s_ct = s74);
        evtChangeFormat();
        genSendConfigure();
      } else if (state.s_tu == s31) {
        goto(state.s_ct = s73);
        evtChangeTrigger();
        genSendConfigure();
      } else {
        goto(state.s_ct = s71);
      }
    }
  }

  public function evtExtMpnSubscribe() {
    traceEvent("subscribe");
    if (state.s_m == s40) {
      if (m_client.state.s_mpn.m == s405) {
        notifyStatus(Active);
        goto(state.s_m = s42);
        genSendSubscribe();
      } else {
        notifyStatus(Active);
        goto(state.s_m = s41);
      }
    }
  }

  public function evtDeviceActive() {
    traceEvent("device.active");
    if (state.s_m == s41) {
      goto(state.s_m = s42);
      genSendSubscribe();
    }
  }

  public function evtMPNOK(mpnSubId: String) {
    traceEvent("MPNOK");
    if (state.s_m == s42) {
      doMPNOK(mpnSubId);
      notifyStatus(Subscribed);
      notifyOnSubscription();
      notifyOnSubscriptionsUpdated();
      goto({
        state.s_m = s44;
        state.s_st = s60;
        state.s_ct = s70;
        state.s_ab = s80;
      });
      evtCheck();
    } else if (state.s_m == s43) {
      doMPNOK(mpnSubId);
      notifyStatus(Subscribed);
      notifyOnSubscription();
      notifyOnSubscriptionsUpdated();
      goto({
        state.s_m = s44;
        state.s_st = s60;
        state.s_ct = s70;
        state.s_ab = s80;
      });
      evtCheck();
    }
  }

  public function evtMPNDEL() {
    traceEvent("MPNDEL");
    if (state.s_ct == s72) {
      notifyStatus(Unknown);
      notifyOnUnsubscription();
      notifyOnSubscriptionsUpdated();
      finalize();
      goto({
        state.s_m = s52;
        state.s_st = null;
        state.s_ct = null;
        state.s_ab = null;
      });
    }
  }

  public function evtMpnUpdate(update: ItemUpdate) {
    traceEvent("update");
    var ts = update.getValue("status_timestamp");
    var nextStatus = update.getValue("status");
    nextStatus = nextStatus != null ? nextStatus.toUpperCase() : null;
    var command = update.getValue("command");
    command = command != null ? command.toUpperCase() : null;
    if (state.s_m == s44 && command == "DELETE") {
      notifyStatus(Unknown);
      notifyOnUnsubscription();
      notifyOnSubscriptionsUpdated();
      finalize();
      goto({
        state.s_m = s52;
        state.s_st = null;
        state.s_ct = null;
        state.s_ab = null;
      });
    } else if (state.s_m == s45) {
      if (nextStatus == "ACTIVE") {
        notifyStatus(Subscribed, ts);
        notifyOnSubscription();
        notifyUpdate(update);
        goto({
          state.s_m = s44;
          state.s_st = s60;
          state.s_ct = s70;
          state.s_ab = s80;
        });
        evtCheck();
      } else if (nextStatus == "TRIGGERED") {
        notifyStatus(Triggered, ts);
        notifyOnSubscription();
        notifyOnTriggered();
        notifyUpdate(update);
        goto({
          state.s_m = s44;
          state.s_st = s61;
          state.s_ct = s70;
          state.s_ab = s80;
        });
        evtCheck();
      }
    } else if (state.s_m == s44) {
      goto(state.s_m = s44);
      evtMpnUpdate_AbortRegion(update);
    }
  }

  function evtMpnUpdate_AbortRegion(update: ItemUpdate) {
    traceEvent("update");
    var forward = true;
    if (state.s_ab == s81) {
      goto(state.s_ab = s80);
      forward = evtMpnUpdate_StatusRegion(update);
      evtRestoreSession();
    }
    if (forward) {
      forward = evtMpnUpdate_StatusRegion(update);
    }
  }

  function evtMpnUpdate_StatusRegion(update: ItemUpdate): Bool {
    traceEvent("update");
    var ts = update.getValue("status_timestamp");
    var nextStatus = update.getValue("status");
    nextStatus = nextStatus != null ? nextStatus.toUpperCase() : null;
    if (state.s_st == s60) {
      if (nextStatus == "ACTIVE") {
        notifyUpdate(update);
        goto(state.s_st = s60);
      } else if (nextStatus == "TRIGGERED") {
        notifyStatus(Triggered, ts);
        notifyOnTriggered();
        notifyUpdate(update);
        goto(state.s_st = s61);
      }
    } else if (state.s_st == s61) {
      if (nextStatus == "ACTIVE") {
        notifyStatus(Subscribed, ts);
        notifyUpdate(update);
        goto(state.s_st = s60);
      } else if (nextStatus == "TRIGGERED") {
        notifyUpdate(update);
        goto(state.s_st = s61);
      }
    }
    return false;
  }

  public function evtMpnEOS() {
    traceEvent("EOS");
    if (state.s_ab == s81) {
      notifyStatus(Unknown);
      notifyOnUnsubscription();
      notifyOnSubscriptionsUpdated();
      finalize();
      goto({
        state.s_m = s51;
        state.s_st = null;
        state.s_ct = null;
        state.s_ab = null;
      });
    }
  }

	public function isPending(): Bool {
    return state.s_m == s42 || state.s_ct == s72 || state.s_ct == s73 || state.s_ct == s74;
	}

	public function encode(isWS:Bool): String {
    if (state.s_m == s42) {
      return encodeActivate();
    } else if (state.s_ct == s72) {
      return encodeDeactivate();
    } else if (state.s_ct == s73 || state.s_ct == s74) {
      return encodeConfigure();
    } else {
      throw new IllegalStateException("Can't encode request");
    }
	}

	public function encodeWS(): String {
    return "control\r\n" + encode(true);
	}

  function encodeActivate(): String {
    var req = new RequestBuilder();
    m_lastActivateReqId = m_client.generateFreshReqId();
    req.LS_reqId(m_lastActivateReqId);
    req.LS_op("activate");
    req.LS_subId(m_subId.sure());
    req.LS_mode(m_subscription.fetchMode().sure());
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
    var freq = m_subscription.fetchRequestedMaxFrequency();
    if (freq != null) {
      switch freq {
      case FreqLimited(var limit):
        req.LS_requested_max_frequency_Float(limit);
      case FreqUnlimited:
        req.LS_requested_max_frequency("unlimited");
      }
    }
    var buff = m_subscription.fetchRequestedBufferSize();
    if (buff != null) {
      switch buff {
      case BSLimited(var limit):
        req.LS_requested_buffer_size_Int(limit);
      case BSUnlimited:
        req.LS_requested_buffer_size("unlimited");
      }
    }
    req.PN_deviceId(m_client.get_mpn_deviceId().sure());
    req.PN_notificationFormat(m_initFormat.sure());
    var trigger = m_initTrigger;
    if (trigger != null) {
      req.PN_trigger(trigger);
    }
    if (m_coalescing) {
      req.PN_coalescing(true);
    }
    protocolLogger.logInfo('Sending MPNSubscription activate: $req');
    return req.getEncodedString();
  }

  function encodeDeactivate(): String {
    var req = new RequestBuilder();
    m_lastDeactivateReqId = m_client.generateFreshReqId();
    req.LS_reqId(m_lastDeactivateReqId);
    req.LS_op("deactivate");
    req.PN_deviceId(m_client.get_mpn_deviceId().sure());
    req.PN_subscriptionId(m_subscription.getSubscriptionId().sure());
    protocolLogger.info('Sending MPNSubscription deactivate: $req');
    return req.getEncodedString();
  }

  function encodeConfigure(): String {
    var req = new RequestBuilder();
    m_lastConfigureReqId = m_client.generateFreshReqId();
    req.LS_reqId(m_lastConfigureReqId);
    req.LS_op("pn_reconf");
    req.LS_mode(m_subscription.fetchMode().sure());
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
    req.PN_deviceId(m_client.get_mpn_deviceId().sure());
    req.PN_subscriptionId(m_subscription.getSubscriptionId().sure());
    if (state.s_ct == s74) {
      req.PN_notificationFormat(m_currentFormat.sure());
    }
    if (state.s_ct == s73) {
      req.PN_trigger(m_currentTrigger ?? "");
    }
    protocolLogger.info('Sending MPNSubscription configuration: $req');
    return req.getEncodedString();
  }

  function genSendSubscribe() {
    m_client.evtSendControl(this);
  }
  
  function genSendConfigure() {
    m_client.evtSendControl(this);
  }
  
  function genSendUnsubscribe() {
    m_client.evtSendControl(this);
  }
  
  function notifyStatus(status: MpnSubscriptionStatus, statusTs: Null<String> = null) {
    m_subscription.changeStatus(status, statusTs);
  }

  function notifyOnSubscriptionError(code: Int, msg: String) {
    m_subscription.fireOnSubscriptionError(code, msg);
  }
  
  function notifyOnSubscriptionAbort() {
    m_subscription.fireOnSubscriptionError(54, "The request was aborted because the operation could not be completed");
  }
  
  function notifyOnSubscriptionDiscarded() {
    m_subscription.fireOnSubscriptionError(55, "The request was discarded because the operation could not be completed");
  }
  
  function notifyOnUnsubscriptionError(code: Int, msg: String) {
    m_subscription.fireOnUnsubscriptionError(code, msg);
  }
  
  function notifyOnUnsubscriptionAbort() {
    m_subscription.fireOnUnsubscriptionError(54, "The request was aborted because the operation could not be completed");
  }

  function doMPNOK(mpnSubId: String) {
    m_subscription.setSubscriptionId(mpnSubId);
  }
  
  function notifyOnSubscription() {
    m_subscription.fireOnSubscription();
  }
  
  function notifyOnUnsubscription() {
    m_subscription.fireOnUnsubscription();
  }
  
  function notifyOnTriggered() {
    m_subscription.fireOnTriggered();
  }
  
  function notifyOnSubscriptionsUpdated() {
    m_client.get_mpn_device().sure().fireOnSubscriptionsUpdated();
  }

  function notifyUpdate(update: ItemUpdate) {
    m_subscription.changeStatusTs(update.getValue("status_timestamp"));
    m_subscription.changeMode(update.getValue("mode"));
    m_subscription.changeAdapter(update.getValue("adapter"));
    m_subscription.changeGroup(update.getValue("group"));
    m_subscription.changeSchema(update.getValue("schema"));
    m_subscription.changeFormat(update.getValue("notification_format"));
    m_subscription.changeTrigger(update.getValue("trigger"));
    m_subscription.changeBufferSize(update.getValue("requested_buffer_size"));
    m_subscription.changeMaxFrequency(update.getValue("requested_max_frequency"));
  }

  function doSetCurrentFormat() {
    m_currentFormat = m_subscription.fetchRequestedFormat();
  }
  
  function doSetCurrentTrigger() {
    m_currentTrigger = m_subscription.fetchRequestedTrigger();
  }
  
  function notifyOnModificationError_Format(code: Int, msg: String) {
    m_subscription.fireOnModificationError(code, msg, "notification_format");
  }
  
  function notifyOnModificationAbort_Format() {
    m_subscription.fireOnModificationError(54, "The request was aborted because the operation could not be completed", "notification_format");
  }
  
  function notifyOnModificationError_Trigger(code: Int, msg: String) {
    m_subscription.fireOnModificationError(code, msg, "trigger");
  }
  
  function notifyOnModificationAbort_Trigger() {
    m_subscription.fireOnModificationError(54, "The request was aborted because the operation could not be completed", "trigger");
  }

  function traceEvent(evt: String) {
    internalLogger.logTrace('mpn#sub#$evt($m_subId:${get_mpnSubId()}) in $state');
  }
}