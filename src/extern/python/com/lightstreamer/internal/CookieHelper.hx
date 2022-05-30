package com.lightstreamer.internal;

@:pythonImport("com_lightstreamer", "CookieHelper")
extern class CookieHelper {
  static function getInstance(): CookieHelper;
  function addCookies(uri: String, cookies: SimpleCookie): Void;
  function getCookies(uri: Null<String>): SimpleCookie;
  function clearCookies(): Void;
}