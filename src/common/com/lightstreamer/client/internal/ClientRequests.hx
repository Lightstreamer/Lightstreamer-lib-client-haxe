/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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