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
  public var p(default, set): State_w_p;
  var k: State_w_k;
  var s: State_w_s;
  final parent: State;
  
  public function new(parent: State, p: State_w_p, k: State_w_k, s: State_w_s) {
    this.parent = parent;
    @:bypassAccessor this.p = p;
    @:bypassAccessor this.k = k;
    @:bypassAccessor this.s = s;
  }

  function set_p(newValue) {
    p = newValue;
    parent.traceState();
    return newValue;
  }

  public function toString() {
    return '<w_p=$p w_k=$k w_s=$s>';
  }
}

class StateVar_ws {
  public var m(default, set): State_ws_m;
  public var p(default, set): Null<State_ws_p>;
  var k: Null<State_ws_k>;
  var s: Null<State_ws_s>;
  final parent: State;
  
  public function new(parent: State, m: State_ws_m) {
    this.parent = parent;
    @:bypassAccessor this.m = m;
  }

  function set_m(newValue) {
    m = newValue;
    parent.traceState();
    return newValue;
  }

  function set_p(newValue) {
    p = newValue;
    parent.traceState();
    return newValue;
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
  public var m(default, set): State_wp_m;
  public var p(default, set): Null<State_wp_p>;
  public var c(default, set): Null<State_wp_c>;
  var s: Null<State_wp_s>;
  final parent: State;
  
  public function new(parent: State, m: State_wp_m) {
    this.parent = parent;
    @:bypassAccessor this.m = m;
  }

  function set_m(newValue) {
    m = newValue;
    parent.traceState();
    return newValue;
  }

  function set_p(newValue) {
    p = newValue;
    parent.traceState();
    return newValue;
  }

  function set_c(newValue) {
    c = newValue;
    parent.traceState();
    return newValue;
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
  public var m: State_hs_m;
  public var p: Null<State_hs_p>;
  public var k: Null<State_hs_k>;
  
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
  public var m: State_hp_m;
  
  public function new(m: State_hp_m) {
    this.m = m;
  }

  public function toString() {
    return "<hp_m=" + m + ">";
  }
}

class State {
  // TODO update toString
  public var s_m(default, set): State_m;
  public var s_du(default, set): State_du;
  public var s_tr(default, set): Null<State_tr>;
  public var s_w: Null<StateVar_w>;
  public var s_ws: Null<StateVar_ws>;
  public var s_wp: Null<StateVar_wp>;
  public var s_hs: Null<StateVar_hs>;
  public var s_hp: Null<StateVar_hp>;
  public var s_rec(default, set): Null<State_rec>;
  public var s_h(default, set): Null<State_h>;
  public var s_ctrl(default, set): Null<State_ctrl>;
  public var s_swt(default, set): Null<State_swt>;
  public var s_bw(default, set): Null<State_bw>;
  public var s_rhb(default, set): Null<State_rhb>;
  public var s_slw(default, set): Null<State_slw>;
  // TODO MPN
  // var s_mpn: StateVar_mpn = StateVar_mpn()
  public var s_nr(default, set): State_nr;

  public function new() {
    @:bypassAccessor s_m = s100;
    @:bypassAccessor s_du = s20;
    @:bypassAccessor s_nr = s1400;
  }

  function set_s_m(newValue) {
    s_m = newValue;
    traceState();
    return newValue;
  }

  function set_s_du(newValue) {
    s_du = newValue;
    traceState();
    return newValue;
  }

  function set_s_tr(newValue) {
    s_tr = newValue;
    traceState();
    return newValue;
  }

  function set_s_rec(newValue) {
    s_rec = newValue;
    traceState();
    return newValue;
  }

  function set_s_h(newValue) {
    s_h = newValue;
    traceState();
    return newValue;
  }

  function set_s_ctrl(newValue) {
    s_ctrl = newValue;
    traceState();
    return newValue;
  }

  function set_s_swt(newValue) {
    s_swt = newValue;
    traceState();
    return newValue;
  }

  function set_s_bw(newValue) {
    s_bw = newValue;
    traceState();
    return newValue;
  }

  function set_s_rhb(newValue) {
    s_rhb = newValue;
    traceState();
    return newValue;
  }

  function set_s_slw(newValue) {
    s_slw = newValue;
    traceState();
    return newValue;
  }

  function set_s_nr(newValue) {
    s_nr = newValue;
    traceState();
    return newValue;
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

  function goto_rec_from_wp() {
    clear_wp();
    goto_rec();
  }

  public function goto_m_from_hs(m: State_m) {
    clear_hs();
    @:bypassAccessor s_ctrl = null;
    @:bypassAccessor s_h = null;
    goto_m_from_session(m);
  }

  public function goto_m_from_rec(m: State_m) {
    @:bypassAccessor s_tr = null;
    goto_m_from_session(m);
  }

  function goto_rec_from_hs() {
    clear_hs();
    @:bypassAccessor s_ctrl = null;
    @:bypassAccessor s_h = null;
    goto_rec();
  }

  public function goto_m_from_hp(m: State_m) {
    clear_hp();
    @:bypassAccessor s_ctrl = null;
    @:bypassAccessor s_h = null;
    goto_m_from_session(m);
  }

  function goto_rec_from_hp() {
    clear_hp();
    @:bypassAccessor s_ctrl = null;
    @:bypassAccessor s_h = null;
    goto_rec();
  }

  function goto_rec() {
    @:bypassAccessor s_tr = s260;
    @:bypassAccessor s_rec = s1000;
    traceState();
  }

  public function goto_m_from_session(m: State_m) {
    @:bypassAccessor s_tr = null;
    @:bypassAccessor s_swt = null;
    @:bypassAccessor s_bw = null;
    @:bypassAccessor s_m = m;
    traceState();
  }

  function goto_m_from_ctrl(m: State_m) {
    clear_hs();
    clear_hp();
    @:bypassAccessor s_ctrl = null;
    @:bypassAccessor s_h = null;
    goto_m_from_session(m);
  }

  public function clear_w() {
    @:bypassAccessor s_w = null;
    @:bypassAccessor s_rhb = null;
    @:bypassAccessor s_slw = null;
  }

  function clear_ws() {
    @:bypassAccessor s_ws = null;
    @:bypassAccessor s_rhb = null;
    @:bypassAccessor s_slw = null;
  }

  function clear_wp() {
    @:bypassAccessor s_wp = null;
  }

  function clear_hs() {
    @:bypassAccessor s_hs = null;
    @:bypassAccessor s_rhb = null;
    @:bypassAccessor s_slw = null;
  }

  function clear_hp() {
    @:bypassAccessor s_hp = null;
    @:bypassAccessor s_rhb = null;
  }

  function isSwitching() {
    return s_m == s150 && (s_swt == s1302 || s_swt == s1303);
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
    // TODO log MPN
    str += " nr=" + s_nr;
    str += ">";
    return str;
  }

  public function traceState() {
    internalLogger.logTrace("goto: " + this.toString());
  }
}