package com.lightstreamer.client.internal;

import com.lightstreamer.internal.Types;
import com.lightstreamer.client.internal.ClientRequests;

// TODO SubscriptionManager
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