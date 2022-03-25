package com.lightstreamer.client.internal;

import com.lightstreamer.internal.Types;

// TODO SubscriptionManager
class SubscriptionManager {
  public function evtU(itemIdx: Pos, values: Map<Pos, FieldValue>) {}
  public function evtSUBOK(nItems: Int, nFields: Int) {}
  public function evtSUBCMD(nItems: Int, nFields: Int, keyIdx: Pos, cmdIdx: Pos) {}
  public function evtUNSUB() {}
  public function evtEOS(itemIdx: Pos) {}
  public function evtCS(itemIdx: Pos) {}
  public function evtOV(itemIdx: Pos, lostUpdates: Int) {}
  public function evtCONF(freq: RealMaxFrequency) {}
  public function evtREQOK(reqId: Int) {}
  public function evtREQERR(reqId: Int, errorCode: Int, errorMsg: String) {}
}