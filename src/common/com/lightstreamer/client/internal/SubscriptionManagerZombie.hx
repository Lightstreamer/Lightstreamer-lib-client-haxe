package com.lightstreamer.client.internal;

import com.lightstreamer.internal.Types;

// TODO SubscriptionManagerZombie
class SubscriptionManagerZombie {
  public function new(subId: Int, clientSM: ClientMachine) {}
  public function evtU(itemIdx: Pos, values: Map<Pos, FieldValue>) {}
  public function evtSUBOK(nItems: Int, nFields: Int) {}
  public function evtSUBCMD(nItems: Int, nFields: Int, keyIdx: Pos, cmdIdx: Pos) {}
  public function evtEOS(itemIdx: Pos) {}
  public function evtCS(itemIdx: Pos) {}
  public function evtOV(itemIdx: Pos, lostUpdates: Int) {}
  public function evtCONF(freq: RealMaxFrequency) {}
}