package com.lightstreamer.client.internal;

import com.lightstreamer.internal.RLock;
import com.lightstreamer.internal.Types;
import com.lightstreamer.client.internal.ClientRequests;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

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

// TODO synchronize method of ClientMachine accessed by SubscriptionManagerLiving
@:access(com.lightstreamer.client.internal.ClientMachine)
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
    m_strategy = new ModeStrategy(sub, client, subId);
    // TODO
    // switch sub.mode {
    // case MERGE:
    //   m_strategy = ModeStrategyMerge(sub, client, subId: m_subId);
    // case COMMAND:
    //   if (is2LevelCommand(sub)) {
    //     m_strategy = ModeStrategyCommand2Level(sub, client, subId: m_subId);
    //   } else {
    //     m_strategy = ModeStrategyCommand1Level(sub, client, subId: m_subId);
    //   }
    // case DISTINCT:
    //   m_strategy = ModeStrategyDistinct(sub, client, subId: m_subId);
    // case RAW:
    //   m_strategy = ModeStrategyRaw(sub, client, subId: m_subId);
    // }
    state = new State(subId);
    m_client = client;
    m_subscription = sub;
    m_client.relateSubManager(this);
    m_subscription.relate(this);
  }

  function traceEvent(evt: String) {
    internalLogger.logTrace('sub#$evt($subId) in $state');
  }

	public function isPending():Bool {
    // TODO
		throw new haxe.exceptions.NotImplementedException();
	}

	public function encode(isWS:Bool):String {
    // TODO
		throw new haxe.exceptions.NotImplementedException();
	}

	public function encodeWS():String {
    // TODO
		throw new haxe.exceptions.NotImplementedException();
	}

	public function evtU(itemIdx:Pos, values:Map<Pos, FieldValue>) {
    // TODO
  }

	public function evtSUBOK(nItems:Int, nFields:Int) {
    // TODO
  }

	public function evtSUBCMD(nItems:Int, nFields:Int, keyIdx:Pos, cmdIdx:Pos) {
    // TODO
  }

	public function evtUNSUB() {
    // TODO
  }

	public function evtEOS(itemIdx:Pos) {
    // TODO
  }

	public function evtCS(itemIdx:Pos) {
    // TODO
  }

	public function evtOV(itemIdx:Pos, lostUpdates:Int) {
    // TODO
  }

	public function evtCONF(freq:RealMaxFrequency) {
    // TODO
  }

	public function evtREQOK(reqId:Int) {
    // TODO
  }

	public function evtREQERR(reqId:Int, errorCode:Int, errorMsg:String) {
    // TODO
  }

	public function evtExtAbort() {
    // TODO
  }
}