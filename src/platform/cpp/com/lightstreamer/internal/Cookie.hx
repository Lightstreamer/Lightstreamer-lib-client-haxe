package com.lightstreamer.internal;

using StringTools;
using com.lightstreamer.internal.Cookie.CookieUtils;

private class CookieUtils {
  static public function empty(s: String) return s.length == 0;
  static public function size(s: String) return s.length;
}

@:publicFields
class Cookie {
  final name: String; 
  final value: String;
  final expires: Null<Date>;
  final maxAge: Null<Int>;
  /**
   * If either expires or maxAge is set, expirationDate is set too.
   * If both of them are set, expirationDate is computed from maxAge.
   * See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#max-agenumber
   */
  final expirationDate: Null<Date>;
  final secure: Bool;
  final httpOnly: Bool;
  final partitioned: Bool;
  final sameSite: String; 
  final domain: String;
  final path: String;

  /**
   * Parses a list of Set-Cookie headers.
   */
  static function fromSetCookies(hs: Array<String>): Array<Cookie> {
    @:nullSafety(Off)
    return hs.map(parseSetCookie).filter(c -> c != null);
  }

  /**
   * Formats a list of cookies according to the Cookie header specification.
   * 
   * See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cookie
   */
  static function toCookie(cookies: Array<Cookie>): String {
    // name=value; name2=value2; name3=value3
    return cookies.map(c -> '${c.name}=${c.value}').join("; ");
  }

  function new(c: CookieBuilder) {
    this.name = c.name;
    this.value = c.value;
    this.expires = c.expires;
    this.maxAge = c.maxAge;
    this.expirationDate = c.expirationDate;
    this.secure = c.secure;
    this.httpOnly = c.httpOnly;
    this.partitioned = c.partitioned;
    this.sameSite = c.sameSite;
    this.domain = c.domain;
    this.path = c.path;
  }

  function isSessionCookie() {
    // if expires is unspecified, the cookie becomes a session cookie
    // see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#expiresdate
    return expires == null && maxAge == null;
  }

  function isExpired(now: Date) {
    // since it is not a session cookie, expirationDate is guaranteed to be not null
    @:nullSafety(Off)
    return !isSessionCookie() && expirationDate.getTime() < now.getTime();
  }

  function clone(): CookieBuilder {
    return CookieBuilder.fromCookie(this);
  }

  function equals(o: Cookie) {
    return name == o.name && value == o.value 
      && expires?.getTime() == o.expires?.getTime() && maxAge == o.maxAge
      && secure == o.secure && httpOnly == o.httpOnly && partitioned == o.partitioned
      && sameSite == o.sameSite && domain == o.domain && path == o.path;
  }

  function toString() {
    var result = new StringBuf();
    result.add(name);
	  result.add("=");
    result.add(value);
		if (!domain.empty())
		{
			result.add("; domain=");
			result.add(domain);
		}
		if (!path.empty())
		{
			result.add("; path=");
			result.add(path);
		}
    if (expires != null)
    {
      result.add("; Expires=" + formatCookieDate(expires));
    }
		if (maxAge != null)
		{
			result.add("; Max-Age=" + maxAge);
		}
		switch (sameSite)
		{
		case "None":
			result.add("; SameSite=None");
		case "Lax":
			result.add("; SameSite=Lax");
		case "Strict":
			result.add("; SameSite=Strict");
		case _:
		}
		if (secure)
		{
			result.add("; secure");
		}
		if (httpOnly)
		{
			result.add("; HttpOnly");
		}
    return result.toString();
  }
}

@:structInit
@:publicFields
class CookieBuilder {
  var name: String; 
  var value: String;
  var expires(default, set): Null<Date>;
  var maxAge(default, set): Null<Int>;
  /**
   * If expires or maxAge is set, expirationDate is set too.
   * If both of them are set, expirationDate is computed from maxAge.
   * See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#max-agenumber
   */
  var expirationDate(default, null): Null<Date>;
  var secure: Bool;
  var httpOnly: Bool;
  var partitioned: Bool;
  var sameSite: String; 
  var domain: String;
  var path: String;

  static function fromCookie(c: Cookie): CookieBuilder {
    var b: CookieBuilder = { name: c.name, value: c.value };
    b.expires = c.expires;
    b.maxAge = c.maxAge;
    b.expirationDate = c.expirationDate;
    b.secure = c.secure;
    b.httpOnly = c.httpOnly;
    b.partitioned = c.partitioned;
    b.sameSite = c.sameSite;
    b.domain = c.domain;
    b.path = c.path;
    return b;
  }

  function new(
    name: String, value: String,
    expires: Null<Date> = null, maxAge: Null<Int> = null,
    secure: Bool = false, httpOnly: Bool = false, partitioned: Bool = false,
    sameSite: String = "", domain: String = "", path: String = ""
  ) {
    this.name = name;
    this.value = value;
    this.secure = secure;
    this.httpOnly = httpOnly;
    this.partitioned = partitioned;
    this.sameSite = sameSite;
    this.domain = domain;
    this.path = path;
    this.expires = expires;
    this.maxAge = maxAge;
  }

  public function build() {
    return new Cookie(this);
  }

  private function set_expires(val: Null<Date>) {
    expires = val;
    // set expirationDate only if Max-Age is not already set
    // since Max-Age has precedence over Expires
    if (maxAge == null) {
      expirationDate = expires;
    }
    return val;
  }

  private function set_maxAge(val: Null<Int>) {
    maxAge = val;
    if (maxAge != null) {
      // if both Expires and Max-Age are set, Max-Age has precedence
      expirationDate = Date.fromTime(Date.now().getTime() + maxAge * 1000);
    } else {
      expirationDate = expires;
    }
    return val;
  }
}

/**
 * Parses a [Set-Cookie header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie).
 * 
 * adapted from https://github.com/nfriedly/set-cookie-parser/blob/master/lib/set-cookie.js
 */
function parseSetCookie(setCookieValue: String): Null<Cookie> {
  var parts = setCookieValue.split(";").filter(isNonEmptyString);

  var nameValuePairStr = parts.shift();
  if (nameValuePairStr == null) {
    return null;
  }
  var parsed = parseNameValuePair(nameValuePairStr);
  var name = parsed.name;
  var value = parsed.value;

  value = value.urlDecode();

  var cookie: CookieBuilder = {
    name: name,
    value: value,
  };

  for (part in parts) {
    var sides = part.split("=");
    var lside = sides.shift();
    if (lside == null) {
      return null;
    }
    var key = lside.ltrim().toLowerCase();
    var value = sides.join("=");
    if (key == "expires") {
      cookie.expires = parseCookieDate(value);
    } else if (key == "max-age") {
      cookie.maxAge = Std.parseInt(value);
    } else if (key == "secure") {
      cookie.secure = true;
    } else if (key == "httponly") {
      cookie.httpOnly = true;
    } else if (key == "samesite") {
      cookie.sameSite = value;
    } else if (key == "domain") {
      cookie.domain = value;
    } else if (key == "partitioned") {
      cookie.partitioned = true;
    } else if (key == "path") {
      cookie.path = value;
    }
  }

  return cookie.build();
}

private final monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
private final dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

/**
 * Parses an HTTP-date timestamp and returns a Date.
 * Example: Wed, 21 Oct 2015 07:28:00 GMT
 * If the date is not valid, returns the Unix epoch, i.e. 1 Jan 1970.
 * 
 * See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Date
 */
 private function parseCookieDate(d: String): Date {
  // Date: <day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT
  // <day-name> One of "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", or "Sun" (case-sensitive).
  // <month> One of "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" (case sensitive).
  var rx = ~/(\w+),? (\d+) (\w+) (\d+) (\d+):(\d+):(\d+) GMT/;
  while (true) { // fake loop
    var ok = rx.match(d);
    if (!ok) break;
    var dayName = rx.matched(1);
    var day = Std.parseInt(rx.matched(2));
    if (day == null) break;
    var month = monthNames.indexOf(rx.matched(3));
    if (month == -1) break;
    var year = Std.parseInt(rx.matched(4));
    if (year == null) break;
    var hour = Std.parseInt(rx.matched(5));
    if (hour == null) break;
    var minute = Std.parseInt(rx.matched(6));
    if (minute == null) break;
    var second = Std.parseInt(rx.matched(7));
    if (second == null) break;
    return new Date(year, month, day, hour, minute, second);
  }
  return Date.fromTime(0); // the Unix epoch
}

/**
 * Formats a date according to the HTTP-date standard.
 * 
 * See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Date
 */
private function formatCookieDate(d: Date) {
  // Date: <day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT
  // <day-name> One of "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", or "Sun" (case-sensitive).
  // <month> One of "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" (case sensitive).
  var dayName = dayNames[d.getUTCDay()];
  var day = d.getUTCDate();
  var month = monthNames[d.getUTCMonth()];
  var year = d.getUTCFullYear();
  var hour = d.getUTCHours();
  var minute = d.getUTCMinutes();
  var second = d.getUTCSeconds();
  return '$dayName, $day $month $year $hour:$minute:$second GMT';
}

private function parseNameValuePair(nameValuePairStr): Cookie {
  // Parses name-value-pair according to rfc6265bis draft

  var name = "";
  var value = "";
  var nameValueArr = nameValuePairStr.split("=");
  if (nameValueArr.length > 1) {
    name = nameValueArr.shift();
    value = nameValueArr.join("="); // everything after the first =, joined by a "=" if there was more than one part
  } else {
    value = nameValuePairStr;
  }

  return ({ name: name, value: value } : CookieBuilder).build();
}

private function isNonEmptyString(s: String) {
  return s.trim().length > 0;
}