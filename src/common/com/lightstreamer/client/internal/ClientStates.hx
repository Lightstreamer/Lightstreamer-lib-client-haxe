package com.lightstreamer.client.internal;

import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

enum abstract State_m(Int) {
  var s100 = 100; var s101 = 101;
  var s110 = 110; var s111 = 111; var s112 = 112; var s113 = 113; var s114 = 114; var s115 = 115; var s116 = 116;
  var s120 = 120; var s121 = 121; var s122 = 122;
  var s130 = 130;
  var s140 = 140;
  var s150 = 150;
}

enum abstract State_du(Int) {
  var s20 = 20; var s21 = 21; var s22 = 22; var s23 = 23;
}

enum abstract State_tr(Int) {
  var s200 = 200; var s210 = 210; var s220 = 220; var s230 = 230; var s240 = 240; var s250 = 250; var s260 = 260; var s270 = 270;
}

enum abstract State_h(Int) {
  var s710 = 710; var s720 = 720;
}

enum abstract State_ctrl(Int) {
  var s1100 = 1100; var s1101 = 1101; var s1102 = 1102; var s1103 = 1103;
}

enum abstract State_swt(Int) {
  var s1300 = 1300; var s1301 = 1301; var s1302 = 1302; var s1303 = 1303;
}

enum abstract State_rhb(Int) {
  var s320 = 320; var s321 = 321; var s322 = 322; var s323 = 323; var s324 = 324;
}

enum abstract State_slw(Int) {
  var s330 = 330; var s331 = 331; var s332 = 332; var s333 = 333; var s334 = 334;
}

enum abstract State_w_p(Int) {
  var s300 = 300;
}

enum abstract State_w_k(Int) {
  var s310 = 310; var s311 = 311; var s312 = 312;
}

enum abstract State_w_s(Int) {
  var s340 = 340;
}

enum abstract State_ws_m(Int) {
  var s500 = 500; var s501 = 501; var s502 = 502; var s503 = 503;
}

enum abstract State_ws_p(Int) {
  var s510 = 510;
}

enum abstract State_ws_k(Int) {
  var s520 = 520; var s521 = 521; var s522 = 522;
}

enum abstract State_ws_s(Int) {
  var s550 = 550;
}

enum abstract State_wp_m(Int) {
  var s600 = 600; var s601 = 601; var s602 = 602;
}

enum abstract State_wp_p(Int) {
  var s610 = 610; var s611 = 611; var s612 = 612; var s613 = 613;
}

enum abstract State_wp_c(Int) {
  var s620 = 620;
}

enum abstract State_wp_s(Int) {
  var s630 = 630;
}

enum abstract State_hs_m(Int) {
  var s800 = 800; var s801 = 801; var s802 = 802;
}

enum abstract State_hs_p(Int) {
  var s810 = 810; var s811 = 811;
}

enum abstract State_hs_k(Int) {
  var s820 = 820; var s821 = 821; var s822 = 822;
}

enum abstract State_hp_m(Int) {
  var s900 = 900; var s901 = 901; var s902 = 902; var s903 = 903; var s904 = 904;
}

enum abstract State_rec(Int) {
  var s1000 = 1000; var s1001 = 1001; var s1002 = 1002; var s1003 = 1003;
}

enum abstract State_bw(Int) {
  var s1200 = 1200; var s1201 = 1201; var s1202 = 1202;
}

enum abstract State_nr(Int) {
  var s1400 = 1400; var s1410 = 1410; var s1411 = 1411; var s1412 = 1412;
}

class StateVar_w {
  public var p(default, null): State_w_p;
  public var k(default, null): State_w_k;
  public var s(default, null): State_w_s;
  
  public function new(p: State_w_p, k: State_w_k, s: State_w_s) {
    this.p = p;
    this.k = k;
    this.s = s;
  }

  public function toString() {
    return '<w_p=$p w_k=$k w_s=$s>';
  }
}

class StateVar_ws {
  public var m(default, null): State_ws_m;
  public var p(default, null): Null<State_ws_p>;
  public var k(default, null): Null<State_ws_k>;
  public var s(default, null): Null<State_ws_s>;
  
  public function new(m: State_ws_m) {
    this.m = m;
  }

  public function toString() {
    var str = "<ws_m=" + m;
    if (p != null) str += " ws_p=" + p;
    if (k != null) str += " ws_k=" + k;
    if (s != null) str += " ws_s=" + s;
    str += ">";
    return str;
  }
}

class StateVar_wp {
  public var m(default, null): State_wp_m;
  public var p(default, null): Null<State_wp_p>;
  public var c(default, null): Null<State_wp_c>;
  public var s(default, null): Null<State_wp_s>;
  
  public function new(m: State_wp_m) {
    this.m = m;
  }

  public function toString() {
    var str = "<wp_m=" + m;
    if (p != null) str += " wp_p=" + p;
    if (c != null) str += " wp_c=" + c;
    if (s != null) str += " wp_s=" + s;
    str += ">";
    return str;
  }
}

class StateVar_hs {
  public var m(default, null): State_hs_m;
  public var p(default, null): Null<State_hs_p>;
  public var k(default, null): Null<State_hs_k>;
  
  public function new(m: State_hs_m) {
    this.m = m;
  }

  public function toString() {
    var str = "<hs_m=" + m;
    if (p != null) str += " hs_p=" + p;
    if (k != null) str += " hs_k=" + k;
    str += ">";
    return str;
  }
}

class StateVar_hp {
  public var m(default, null): State_hp_m;
  
  public function new(m: State_hp_m) {
    this.m = m;
  }

  public function toString() {
    return "<hp_m=" + m + ">";
  }
}

class State {
  public var s_m(default, null): State_m;
  public var s_du(default, null): State_du;
  public var s_tr(default, null): Null<State_tr>;
  public var s_w(default, null): Null<StateVar_w>;
  public var s_ws(default, null): Null<StateVar_ws>;
  public var s_wp(default, null): Null<StateVar_wp>;
  public var s_hs(default, null): Null<StateVar_hs>;
  public var s_hp(default, null): Null<StateVar_hp>;
  public var s_rec(default, null): Null<State_rec>;
  public var s_h(default, null): Null<State_h>;
  public var s_ctrl(default, null): Null<State_ctrl>;
  public var s_swt(default, null): Null<State_swt>;
  public var s_bw(default, null): Null<State_bw>;
  public var s_rhb(default, null): Null<State_rhb>;
  public var s_slw(default, null): Null<State_slw>;
  public var s_nr(default, null): State_nr;
  #if LS_MPN
  public var s_mpn(default, null) = new com.lightstreamer.client.internal.MpnStates.StateVar_mpn();
  #end

  public function new() {
    this.s_m = s100;
    this.s_du = s20;
    this.s_nr = s1400;
  }

  public function goto_m_from_w(m: State_m) {
    clear_w();
    goto_m_from_session(m);
  }

  public function goto_m_from_ws(m: State_m) {
    clear_ws();
    goto_m_from_session(m);
  }

  public function goto_rec_from_w() {
    clear_w();
    goto_rec();
  }

  public function goto_rec_from_ws() {
    clear_ws();
    goto_rec();
  }

  public function goto_m_from_wp(m: State_m) {
    clear_wp();
    goto_m_from_session(m);
  }

  public function goto_rec_from_wp() {
    clear_wp();
    goto_rec();
  }

  public function goto_m_from_hs(m: State_m) {
    clear_hs();
    s_ctrl = null;
    s_h = null;
    goto_m_from_session(m);
  }

  public function goto_m_from_rec(m: State_m) {
    s_tr = null;
    goto_m_from_session(m);
  }

  public function goto_rec_from_hs() {
    clear_hs();
    s_ctrl = null;
    s_h = null;
    goto_rec();
  }

  public function goto_m_from_hp(m: State_m) {
    clear_hp();
    s_ctrl = null;
    s_h = null;
    goto_m_from_session(m);
  }

  public function goto_rec_from_hp() {
    clear_hp();
    s_ctrl = null;
    s_h = null;
    goto_rec();
  }

  public function goto_rec() {
    s_tr = s260;
    s_rec = s1000;
    traceState();
  }

  public function goto_m_from_session(m: State_m) {
    s_tr = null;
    s_swt = null;
    s_bw = null;
    s_m = m;
    traceState();
  }

  public function goto_m_from_ctrl(m: State_m) {
    clear_hs();
    clear_hp();
    s_ctrl = null;
    s_h = null;
    goto_m_from_session(m);
  }

  public function goto_200_from_rec() {
    s_rec = null;
    s_tr = s200;
    traceState();
  }

  public function clear_w() {
    s_w = null;
    s_rhb = null;
    s_slw = null;
  }

  public function clear_ws() {
    s_ws = null;
    s_rhb = null;
    s_slw = null;
  }

  public function clear_wp() {
    s_wp = null;
  }

  public function clear_hs() {
    s_hs = null;
    s_rhb = null;
    s_slw = null;
  }

  public function clear_hp() {
    s_hp = null;
    s_rhb = null;
  }

  function isSwitching() {
    return s_m == s150 && (s_swt == s1302 || s_swt == s1303);
  }

  public function inPushing(): Bool {
    return inStreaming() || inPolling();
  }

  public function inStreaming(): Bool {
    return s_w?.p == s300 || s_ws?.p == s510 || s_hs?.p == s810;
  }

  public function inPolling(): Bool {
    return s_tr == s220 || s_tr == s230 || s_wp?.p == s611 || s_hp?.m == s901 || s_rec == s1001;
  }

  public function toString() {
    var str = "<m=" + s_m;
    str += " du=" + s_du;
    if (s_tr != null) str += " tr=" + s_tr;
    if (s_w != null) str += " " + s_w;
    if (s_ws != null) str += " " + s_ws;
    if (s_wp != null) str += " " + s_wp;
    if (s_hs != null) str += " " + s_hs;
    if (s_hp != null) str += " " + s_hp;
    if (s_rec != null) str += " rec=" + s_rec;
    if (s_h != null) str += " h=" + s_h;
    if (s_ctrl != null) str += " ctrl=" + s_ctrl;
    if (s_swt != null) str += " swt=" + s_swt;
    if (s_bw != null) str += " bw=" + s_bw;
    if (s_rhb != null) str += " rhb=" + s_rhb;
    if (s_slw != null) str += " slw=" + s_slw;
    str += " nr=" + s_nr;
    #if LS_MPN
    if (s_mpn != null) str += " " + s_mpn;
    #end
    str += ">";
    return str;
  }

  function traceState() {
    internalLogger.logTrace("goto: " + this.toString());
  }
}