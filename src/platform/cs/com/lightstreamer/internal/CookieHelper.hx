package com.lightstreamer.internal;

import com.lightstreamer.cs.CookieHelper as CookieHelperCs;

abstract CookieHelper(CookieHelperCs) {
  public static final instance = new CookieHelper();

  function new() {
    this = CookieHelperCs.instance;
  }

  public function addCookies(uri: cs.system.Uri, cookies: cs.system.net.CookieCollection): Void {
    this.AddCookies(uri, cookies);
  }

  public function getCookies(uri: cs.system.Uri): cs.system.net.CookieCollection {
    return this.GetCookies(uri);
  }

  public function clearCookies(uri: String): Void {
    this.ClearCookies(uri);
  }
}