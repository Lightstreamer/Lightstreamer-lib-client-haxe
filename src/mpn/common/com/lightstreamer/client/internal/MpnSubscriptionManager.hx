package com.lightstreamer.client.internal;

import com.lightstreamer.client.internal.ClientRequests.Encodable;

class MpnSubscriptionManager implements Encodable {
  public final m_subId: Null<Int>;
  public var mpnSubId(get, null): Null<String>;

  public function new(mpnSubId: String, client: MpnClientMachine) {
    // TODO
    this.m_subId = null;
  }

  public function start() {
    // TODO
  }

  public function evtDeviceActive() {
    // TODO
  }

  public function evtMPNOK(mpnSubId: String) {
    // TODO
  }

  public function evtMPNDEL() {
    // TODO
  }

  public function evtMpnUpdate(update: ItemUpdate) {
    // TODO
  }

  public function evtMpnEOS() {
    // TODO
  }

  public function evtREQOK(reqId: Int) {
    // TODO
  }

  public function evtREQERR(reqId: Int, errorCode: Int, errorMsg: String) {
    // TODO
  }

  public function evtAbort() {
    // TODO
  }

  function get_mpnSubId() {
    // TODO
    return null;
  }

	public function isPending(): Bool {
    // TODO
		throw new haxe.exceptions.NotImplementedException();
	}

	public function encode(isWS:Bool): String {
    // TODO
		throw new haxe.exceptions.NotImplementedException();
	}

	public function encodeWS(): String {
    // TODO
		throw new haxe.exceptions.NotImplementedException();
	}
}