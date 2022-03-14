package cookiejar;

import haxe.extern.EitherType;

/**
class to hold numerous cookies from multiple domains correctly
 */
@:jsRequire("cookiejar", "CookieJar")
extern class CookieJar {
  function new();
  /**
  modify (or add if not already-existing) a cookie to the jar
   */
  function setCookie(cookie: EitherType<Cookie, String>, ?request_domain: String, ?request_path: String): Cookie;
  /**
  modify (or add if not already-existing) a large number of cookies to the jar
   */
  function setCookies(cookies: EitherType<Array<Cookie>, EitherType<Array<String>, String>>, ?request_domain: String, ?request_path: String): Array<Cookie>;
  /**
   get a cookie with the name and access_info matching
   */
  function getCookie(cookie_name: String, access_info: CookieAccessInfo): Cookie;
  /**
  grab all cookies matching this access_info
   */
  function getCookies(access_info: CookieAccessInfo): Array<Cookie>;
}