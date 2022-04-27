package com.lightstreamer.client.internal;

class MpnSubscriptionManager {
  // TODO MPN
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

  function get_mpnSubId() {
    // TODO
    return null;
  }
}