package com.lightstreamer.client.internal;

interface Encodable {
  function isPending(): Bool;
  function encode(isWS: Bool): String;
  function encodeWS(): String;
}

class SwitchRequest implements  Encodable {
  final client: ClientMachine;

  public function new(client: ClientMachine) {
    this.client = client;
  }

	public function isPending(): Bool {
		return client.state.s_m == s150 && client.state.s_swt == s1302;
	}

	public function encode(isWS: Bool): String {
		return client.encodeSwitch(isWS);
	}

	public function encodeWS(): String {
		return "control\r\n" + encode(true);
	}
}

class ConstrainRequest implements Encodable {
  final client: ClientMachine;

  public function new(client: ClientMachine) {
    this.client = client;
  }

	public function isPending(): Bool {
		return client.state.s_bw == s1202;
	}

	public function encode(isWS: Bool): String {
		return client.encodeConstrain();
	}

	public function encodeWS(): String {
		return "control\r\n" + encode(true);
	}
}