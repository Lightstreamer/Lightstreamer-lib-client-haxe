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

enum abstract State_mpn_m(Int) {
  var s400 = 400; var s401 = 401; var s402 = 402; var s403 = 403; var s404 = 404; var s405 = 405; var s406 = 406; var s407 = 407; var s408 = 408;
}

enum abstract State_mpn_st(Int) {
  var s410 = 410; var s411 = 411;
}

enum abstract State_mpn_tk(Int) {
  var s450 = 450; var s451 = 451; var s452 = 452; var s453 = 453; var s454 = 454;
}

enum abstract State_mpn_sbs(Int) {
  var s420 = 420; var s421 = 421; var s422 = 422; var s423 = 423; var s424 = 424;
}

enum abstract State_mpn_ft(Int) {
  var s430 = 430; var s431 = 431; var s432 = 432;
}

enum abstract State_mpn_bg(Int) {
  var s440 = 440; var s441 = 441; var s442 = 442;
}

class StateVar_mpn {
  public var m(default, null): State_mpn_m = s400;
  public var st(default, null): Null<State_mpn_st>;
  public var tk(default, null): Null<State_mpn_tk>;
  public var sbs(default, null): Null<State_mpn_sbs>;
  public var ft(default, null): Null<State_mpn_ft>;
  public var bg(default, null): Null<State_mpn_bg>;

  public function new() {}

  public function toString() {
    var str = "<mpn_m=" + m;
    if (st != null) str += " mpn_st=" + st;
    if (tk != null) str += " mpn_tk=" + tk;
    if (sbs != null) str += " mpn_sbs=" + sbs;
    if (ft != null) str += " mpn_ft=" + ft;
    if (bg != null) str += " mpn_bg=" + bg;
    str += ">";
    return str;
  }
}