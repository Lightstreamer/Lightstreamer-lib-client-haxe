package com.lightstreamer.internal;

#if LS_TEST
@:pythonImport("com_lightstreamer_net", "CookieHelper")
#else
@:pythonImport(".com_lightstreamer_net", "CookieHelper")
#end
extern class CookieHelper {
  static var instance(get, never): CookieHelper;
  inline static function get_instance() return getInstance();
  static function getInstance(): CookieHelper;
  function addCookies(uri: String, cookies: SimpleCookie): Void;
  function getCookies(uri: Null<String>): SimpleCookie;
  function clearCookies(): Void;
}