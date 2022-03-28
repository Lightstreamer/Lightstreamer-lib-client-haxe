package com.lightstreamer.client.internal;

// TODO MessageManager
class MessageManager {
  public var sequence: String;
  public var prog: Int;

  public function new() {
    sequence = "";
    prog = 0;
  }

  public function evtMSGDONE() {}
  public function evtMSGFAIL(errorCode: Int, errorMsg: String) {}
  public function evtREQOK(reqId: Int) {}
  public function evtREQERR(reqId: Int, errorCode: Int, errorMsg: String) {}
  public function evtWSSent() {}
  public function evtAbort() {}

  public function isPending() {
    // TODO
    return false;
  }
}