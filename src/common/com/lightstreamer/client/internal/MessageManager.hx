package com.lightstreamer.client.internal;

import com.lightstreamer.client.internal.ClientRequests;

// TODO MessageManager
@:access(com.lightstreamer.client.internal.ClientMachine)
class MessageManager implements Encodable {
  public var sequence: String;
  public var prog: Int;
  final client: ClientMachine;

  public function new(client: ClientMachine) {
    this.client = client;
    // TODO complete
    sequence = "";
    prog = 0;
  }

  public function evtMSGDONE() {}
  public function evtMSGFAIL(errorCode: Int, errorMsg: String) {}
  public function evtREQOK(reqId: Int) {}
  public function evtREQERR(reqId: Int, errorCode: Int, errorMsg: String) {}
  public function evtWSSent() {}
  public function evtAbort() {}

  public function isPending(): Bool {
    // TODO
    return false;
  }

  public function encode(isWS: Bool): String {
    return encodeMsg(isWS);
  }

  public function encodeWS(): String {
    return "msg\r\n" + encode(true);
  }

  function encodeMsg(isWS: Bool): String {
    // TODO
    return "";
  }
}