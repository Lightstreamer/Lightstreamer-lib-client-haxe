package com.lightstreamer.internal;

import com.lightstreamer.internal.Cookie;

using StringTools;
using com.lightstreamer.internal.CookieJar.CookieJarUtils;

private class CookieJarUtils {
  static public function empty(s: String) return s.length == 0;
  static public function size(s: String) return s.length;
  static public function at(s: String, i: Int) return s.charAt(i);
  static public function mid(s: String, pos: Int) return s.substr(pos);
  static public function left(s: String, n: Int) return s.substr(0, n);
}

// This class is an adaptation of QNetworkCookieJar by the Qt Company Ltd,
// and is used under a LGPL-3.0-only license
class CookieJar {
  final allCookies: Array<Cookie> = [];

  public function new() {}

  function isParentPath(path: String, reference: String) {
    if ((path.empty() && reference == "/") || path.startsWith(reference))
    {
      // The cookie-path and the request-path are identical.
      if (path.size() == reference.size())
        return true;
      // The cookie-path is a prefix of the request-path, and the last
      // character of the cookie-path is %x2F ("/").
      if (reference.endsWith("/"))
        return true;
      // The cookie-path is a prefix of the request-path, and the first
      // character of the request-path that is not included in the cookie-
      // path is a %x2F ("/") character.
      if (path.at(reference.size()) == '/')
        return true;
    }
    return false;
  }

  function isParentDomain(domain: String, reference: String)
  {
    if (!reference.startsWith("."))
      return domain == reference;

    return domain.endsWith(reference) || domain == reference.mid(1);
  }

  function qIsEffectiveTLD(domain: String)
  {
      // provide minimal checking by not accepting cookies on real TLDs
      return !domain.contains(".");
  }

  function validateCookie(cookie: Cookie, url: Url) {
    var cookieDomain = cookie.domain;
    var domain = cookieDomain;
    var host = url.hostname;
    if (!isParentDomain(domain, host) && !isParentDomain(host, domain))
      return false; // not accepted
  
    if (domain.startsWith("."))
      domain = domain.mid(1);
  
    // We shouldn't reject if:
    // "[...] the domain-attribute is identical to the canonicalized request-host"
    // https://tools.ietf.org/html/rfc6265#section-5.3 step 5
    if (host == domain)
      return true;
    // the check for effective TLDs makes the "embedded dot" rule from RFC 2109 section 4.3.2
    // redundant; the "leading dot" rule has been relaxed anyway, see QNetworkCookie::normalize()
    // we remove the leading dot for this check if it's present
    // Normally defined in qtldurl_p.h, but uses fall-back in this file when topleveldomain isn't
    // configured:
    return !qIsEffectiveTLD(domain);
  }

  function normalize(cookie: Cookie, url: Url): Cookie {
    var cookie = cookie.clone();

    if (cookie.path.empty())
    {
      var pathAndFileName = url.pathname;
      var defaultPath = pathAndFileName.left(pathAndFileName.lastIndexOf('/') + 1);
      if (defaultPath.empty())
        defaultPath = '/';
      cookie.path = defaultPath;
    }
  
    if (cookie.domain.empty())
    {
      cookie.domain = url.hostname;
    }
    else
    {
      var protocol = getIPFamily(cookie.domain);
      if (protocol != IPv4 && protocol != IPv6 && !cookie.domain.startsWith(".")) {
        // Ensure the domain starts with a dot if its field was not empty
        // in the HTTP header. There are some servers that forget the
        // leading dot and this is actually forbidden according to RFC 2109,
        // but all browsers accept it anyway so we do that as well.
        cookie.domain = "." + cookie.domain;
      }
    }
    return cookie.build();
  }

  /**
    Returns the cookies to be added to when a request is sent to
    \a url. This function is called by the default
    QNetworkAccessManager::createRequest(), which adds the
    cookies returned by this function to the request being sent.

    If more than one cookie with the same name is found, but with
    differing paths, the one with longer path is returned before the
    one with shorter path. In other words, this function returns
    cookies sorted decreasingly by path length.

    The default QNetworkCookieJar class implements only a very basic
    security policy (it makes sure that the cookies' domain and path
    match the reply's). To enhance the security policy with your own
    algorithms, override cookiesForUrl().

    \sa setCookiesFromUrl(), QNetworkAccessManager::setCookieJar()
  */
  public function cookiesForUrl(url: Url): Array<Cookie> {
    //     \b Warning! This is only a dumb implementation!
    //     It does NOT follow all of the recommendations from
    //     http://wp.netscape.com/newsref/std/cookie_spec.html
    //     It does not implement a very good cross-domain verification yet.
    
    var now = Date.now();
    var result: Array<Cookie> = [];
    var isEncrypted = url.protocol == "https:";
  
    for (cookie in allCookies) {
      if (!isEncrypted && cookie.secure)
        continue;
      if (!cookie.isSessionCookie() && cookie.isExpired(now))
        continue;
      var urlHost = url.hostname;
      var cookieDomain = cookie.domain;
      if (!isParentDomain(urlHost, cookieDomain))
        continue;
      if (!isParentPath(url.pathname, cookie.path))
        continue;
  
      var domain = cookieDomain;
      if (domain.startsWith("."))
        domain = domain.mid(1);
      if (!domain.contains(".") && urlHost != domain)
        continue;
  
      result.push(cookie);
    }
  
    var longerPath = (c1: Cookie, c2: Cookie) -> -Reflect.compare(c1.path.size(), c2.path.size());
    result.sort(longerPath);
    return result;
  }

  /**
    Adds the cookies in the list \a cookieList to this cookie
    jar. Before being inserted cookies are normalized.

    Returns \c true if one or more cookies are set for \a url,
    otherwise false.

    If a cookie already exists in the cookie jar, it will be
    overridden by those in \a cookieList.

    The default QNetworkCookieJar class implements only a very basic
    security policy (it makes sure that the cookies' domain and path
    match the reply's). To enhance the security policy with your own
    algorithms, override setCookiesFromUrl().

    Also, QNetworkCookieJar does not have a maximum cookie jar
    size. Reimplement this function to discard older cookies to create
    room for new ones.

    \sa cookiesForUrl(), QNetworkAccessManager::setCookieJar(), QNetworkCookie::normalize()
  */
  public function setCookiesFromUrl(url: Url, cookieList: Array<Cookie>) {
    var added = false;
    for (cookie in cookieList) {
      cookie = normalize(cookie, url);
      if (validateCookie(cookie, url) && insertCookie(cookie))
        added = true;
    }
    return added;
  }

  public function clearAllCookies() {
    allCookies.splice(0, allCookies.length);
  }

  function insertCookie(cookie: Cookie)
  {
    var now = Date.now();
    var _cookie = cookie;
    var isDeletion = !_cookie.isSessionCookie() && _cookie.isExpired(now);

    deleteCookie(cookie);

    if (!isDeletion)
    {
      allCookies.push(_cookie);
      return true;
    }
    return false;
  }

  function deleteCookie(cookie: Cookie)
  {
    var i = Lambda.findIndex(allCookies, c -> hasSameIdentifier(c, cookie));
    if (i != -1) {
      allCookies.splice(i, 1);
      return true;
    }
    return false;
  }

  function updateCookie(cookie: Cookie)
  {
    if (deleteCookie(cookie))
      return insertCookie(cookie);
    return false;
  }

  function hasSameIdentifier(c: Cookie, other: Cookie) {
    return c.name == other.name && c.domain == other.domain && c.path == other.path;
  }
}

private enum IPFamily {
  IPv4; IPv6; IPUnknown;
}

private function getIPFamily(address: String) {
  // a very crude way to establish the kind of an IP address
  if (~/^\d+\.\d+\.\d+\.\d+$/.match(address)) {
    return IPv4;
  } else if (~/^[0-9a-fA-F]*:[0-9a-fA-F]*:[0-9a-fA-F]*:[0-9a-fA-F]*:[0-9a-fA-F]*:[0-9a-fA-F]*:[0-9a-fA-F]*:[0-9a-fA-F]*$/.match(address)) {
    return IPv6;
  } else {
    return IPUnknown;
  }
}