package com.lightstreamer.client.internal;

import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

enum abstract State_m(Int) {
  var M_100 = 100; var M_101 = 101;
  var M_110 = 110; var M_111 = 111; var M_112 = 112; var M_113 = 113; var M_114 = 114; var M_115 = 115; var M_116 = 116;
  var M_120 = 120; var M_121 = 121; var M_122 = 122;
  var M_130 = 130;
  var M_140 = 140;
  var M_150 = 150;
}

enum abstract State_du(Int) {
  var DU_20 = 20; var DU_21 = 21; var DU_22 = 22; var DU_23 = 23;
}

enum abstract State_tr(Int) {
  var TR_200 = 200; var TR_210 = 210; var TR_220 = 220; var TR_230 = 230; var TR_240 = 240; var TR_250 = 250; var TR_260 = 260; var TR_270 = 270;
}

enum abstract State_h(Int) {
  var H_710 = 710; var H_720 = 720;
}

enum abstract State_ctrl(Int) {
  var CTRL_1100 = 1100; var CTRL_1101 = 1101; var CTRL_1102 = 1102; var CTRL_1103 = 1103;
}

enum abstract State_swt(Int) {
  var SWT_1300 = 1300; var SWT_1301 = 1301; var SWT_1302 = 1302; var SWT_1303 = 1303;
}

enum abstract State_rhb(Int) {
  var RHB_320 = 320; var RHB_321 = 321; var RHB_322 = 322; var RHB_323 = 323; var RHB_324 = 324;
}

enum abstract State_slw(Int) {
  var SLW_330 = 330; var SLW_331 = 331; var SLW_332 = 332; var SLW_333 = 333; var SLW_334 = 334;
}

enum abstract State_w_p(Int) {
  var W_P_300 = 300;
}

enum abstract State_w_k(Int) {
  var W_K_310 = 310; var W_K_311 = 311; var W_K_312 = 312;
}

enum abstract State_w_s(Int) {
  var W_S_340 = 340;
}

enum abstract State_ws_m(Int) {
  var WS_M_500 = 500; var WS_M_501 = 501; var WS_M_502 = 502; var WS_M_503 = 503;
}

enum abstract State_ws_p(Int) {
  var WS_P_510 = 510;
}

enum abstract State_ws_k(Int) {
  var WS_K_520 = 520; var WS_K_521 = 521; var WS_K_522 = 522;
}

enum abstract State_ws_s(Int) {
  var WS_S_550 = 550;
}

enum abstract State_wp_m(Int) {
  var WP_M_600 = 600; var WP_M_601 = 601; var WP_M_602 = 602;
}

enum abstract State_wp_p(Int) {
  var WP_P_610 = 610; var WP_P_611 = 611; var WP_P_612 = 612; var WP_P_613 = 613;
}

enum abstract State_wp_c(Int) {
  var WP_C_620 = 620;
}

enum abstract State_wp_s(Int) {
  var WP_S_630 = 630;
}

enum abstract State_hs_m(Int) {
  var HS_M_800 = 800; var HS_M_801 = 801; var HS_M_802 = 802;
}

enum abstract State_hs_p(Int) {
  var HS_P_810 = 810; var HS_P_811 = 811;
}

enum abstract State_hs_k(Int) {
  var HS_K_820 = 820; var HS_K_821 = 821; var HS_K_822 = 822;
}

enum abstract State_hp_m(Int) {
  var HP_M_900 = 900; var HP_M_901 = 901; var HP_M_902 = 902; var HP_M_903 = 903; var HP_M_904 = 904;
}

enum abstract State_rec(Int) {
  var REC_1000 = 1000; var REC_1001 = 1001; var REC_1002 = 1002; var REC_1003 = 1003;
}

enum abstract State_bw(Int) {
  var BW_1200 = 1200; var BW_1201 = 1201; var BW_1202 = 1202;
}

enum abstract State_nr(Int) {
  var NR_1400 = 1400; var NR_1410 = 1410; var NR_1411 = 1411; var NR_1412 = 1412;
}

class StateVar_w {
  public var p: State_w_p;
  public var k: State_w_k;
  public var s: State_w_s;
  
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
  public var m: State_ws_m;
  public var p: Null<State_ws_p>;
  public var k: Null<State_ws_k>;
  public var s: Null<State_ws_s>;
  
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
  public var m: State_wp_m;
  public var p: Null<State_wp_p>;
  public var c: Null<State_wp_c>;
  public var s: Null<State_wp_s>;
  
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
  var s_m: State_m = M_100;
  var s_du: State_du = DU_20;
  var s_tr: Null<State_tr>;
  var s_w: Null<StateVar_w>;
  var s_ws: Null<StateVar_ws>;
  var s_wp: Null<StateVar_wp>;
  var s_hs: Null<StateVar_hs>;
  var s_hp: Null<StateVar_hp>;
  var s_rec: Null<State_rec>;
  var s_h: Null<State_h>;
  var s_ctrl: Null<State_ctrl>;
  var s_swt: Null<State_swt>;
  var s_bw: Null<State_bw>;
  var s_rhb: Null<State_rhb>;
  var s_slw: Null<State_slw>;
  // TODO MPN
  // var s_mpn: StateVar_mpn = StateVar_mpn()
  var s_nr: State_nr = NR_1400;

  inline public function new() {}

  public function event(event: String) {
    internalLogger.logTrace("event: " + event + " from: " +  toString());
  }

  inline public function is(value: State_m)
    return s_m == value;

  public function goTo(newValue: State_m) {
    s_m = newValue;
    internalLogger.logTrace("goto: " + toString());
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

  function goto_m_from_hs(m: State_m) {
    clear_hs();
    s_ctrl = null;
    s_h = null;
    goto_m_from_session(m);
  }

  function goto_m_from_rec(m: State_m) {
    s_tr = null;
    goto_m_from_session(m);
  }

  function goto_rec_from_hs() {
    clear_hs();
    s_ctrl = null;
    s_h = null;
    goto_rec();
  }

  function goto_m_from_hp(m: State_m) {
    clear_hp();
    s_ctrl = null;
    s_h = null;
    goto_m_from_session(m);
  }

  function goto_rec_from_hp() {
    clear_hp();
    s_ctrl = null;
    s_h = null;
    goto_rec();
  }

  function goto_rec() {
    s_tr = TR_260;
    s_rec = REC_1000;
  }

  function goto_m_from_session(m: State_m) {
    s_tr = null;
    s_swt = null;
    s_bw = null;
    s_m = m;
  }

  function goto_m_from_ctrl(m: State_m) {
    clear_hs();
    clear_hp();
    s_ctrl = null;
    s_h = null;
    goto_m_from_session(m);
  }

  function clear_w() {
    s_w = null;
    s_rhb = null;
    s_slw = null;
  }

  function clear_ws() {
    s_ws = null;
    s_rhb = null;
    s_slw = null;
  }

  function clear_wp() {
    s_wp = null;
  }

  function clear_hs() {
    s_hs = null;
    s_rhb = null;
    s_slw = null;
  }

  function clear_hp() {
    s_hp = null;
    s_rhb = null;
  }

  function isSwitching() {
    return s_m == M_150 && (s_swt == SWT_1302 || s_swt == SWT_1303);
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
}