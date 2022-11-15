package com.lightstreamer.internal;

@:build(com.lightstreamer.internal.Macros.buildPythonImport("com_lightstreamer_net", "CookieHelper"))
extern class CookieHelper {
  static var instance(get, never): CookieHelper;
  inline static function get_instance() return getInstance();
  static function getInstance(): CookieHelper;
  function addCookies(uri: String, cookies: SimpleCookie): Void;
  function getCookies(uri: Null<String>): SimpleCookie;
  function clearCookies(): Void;
}