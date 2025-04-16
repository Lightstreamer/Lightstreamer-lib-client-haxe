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

import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.client.internal.ClientRequests.Encodable;

class MpnRegisterRequest implements Encodable {
  final client: MpnClientMachine;
  
  public function new(client: MpnClientMachine) {
    this.client = client;
  }
  
  public function isPending(): Bool {
    return client.state.s_mpn.m == s403 || client.state.s_mpn.m == s406 || client.state.s_mpn.tk == s453;
  }
  
  public function encode(isWS: Bool): String {
    if (client.state.s_mpn.m == s403) {
      return client.encodeMpnRegister();
    } else if (client.state.s_mpn.m == s406) {
      return client.encodeMpnRestore();
    } else if (client.state.s_mpn.tk == s453) {
      return client.encodeMpnRefreshToken();
    } else {
      throw new IllegalStateException("Can't encode register request");
    }
  }
  
  public function encodeWS(): String {
    return "control\r\n" + encode(true);
  }
}

class MpnFilterUnsubscriptionRequest implements  Encodable {
  final client: MpnClientMachine;
  
  public function new(client: MpnClientMachine) {
    this.client = client;
  }
  
  public function isPending(): Bool {
    return client.state.s_mpn.ft == s432;
  }
  
  public function encode(isWS: Bool): String {
    if (isPending()) {
      return client.encodeDeactivateFilter();
    } else {
      throw new IllegalStateException("Can't encode unsubscription request");
    }
  }
  
  public function encodeWS(): String {
    return "control\r\n" + encode(true);
  }
}

class MpnBadgeResetRequest implements  Encodable {
  final client: MpnClientMachine;
  
  public function new(client: MpnClientMachine) {
    this.client = client;
  }
  
  public function isPending(): Bool {
    return client.state.s_mpn.bg == s442;
  }
  
  public function encode(isWS: Bool): String {
    if (isPending()) {
      return client.encodeBadgeReset();
    } else {
      throw new IllegalStateException("Can't encode badge reset request");
    }
  }
  
  public function encodeWS(): String {
    return "control\r\n" + encode(true);
  }
}