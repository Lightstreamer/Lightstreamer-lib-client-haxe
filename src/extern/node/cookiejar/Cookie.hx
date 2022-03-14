package cookiejar;

import haxe.extern.EitherType;

@:jsRequire("cookiejar", "Cookie")
extern class Cookie {
  /** name of the cookie */
  var name(default, null): String;
  /** string associated with the cookie */
  var value(default, null): String;
  /** domain to match (on a cookie a '.' at the start means a wildcard matching anything ending in the rest) */
  var domain(default, null): String;
  /** if the domain was explicitly set via the cookie string */
  var explicit_domain(default, null): Bool;
  /** base path to match (matches any path starting with this '/' is root) */
  var path(default, null): String;
  /** if the path was explicitly set via the cookie string */
  var explicit_path(default, null): Bool;
  /** if it should be kept from scripts */
  var noscript(default, null): Bool;
  /** should it only be transmitted over secure means */
  var secure(default, null): Bool;
  /** number of millis since 1970 at which this should be removed */
  var expiration_date(default, default): Int;
  /**
  It turns input into a Cookie (singleton if given a Cookie), the request_domain argument is used to default the domain if it is not explicit in the cookie string, the request_path argument is used to set the path if it is not explicit in a cookie String.

  Explicit domains/paths will cascade, implied domains/paths must exactly match (see http://en.wikipedia.org/wiki/HTTP_cookie#Domain_and_Pat).
   */
  function new(cookiestr: EitherType<Cookie, String>, ?request_domain: String, ?request_path: String);
  /**
  the **set-cookie:** string for this cookie
  */
  function toString(): String;
  /**
  the **cookie:** string for this cookie
   */
  function toValueString(): String;
}