// This class is an adaptation of QNetworkCookieJar by the Qt Company Ltd,
// and is used under a LGPL-3.0-only license

#include "Lightstreamer/HxPoco/CookieJar.h"

#include "Poco/Timespan.h"
#include "Poco/Net/IPAddress.h"
#include "Poco/Net/NetException.h"
#include "Lightstreamer/HxPoco/Utils.h"

using namespace Lightstreamer::HxPoco;

bool isParentPath(const std::string& path, const std::string& reference)
{
  if ((path.empty() && reference == "/") || starts_with(path, reference))
  {
    // The cookie-path and the request-path are identical.
    if (path.size() == reference.size())
      return true;
    // The cookie-path is a prefix of the request-path, and the last
    // character of the cookie-path is %x2F ("/").
    if (ends_with(reference, "/"))
      return true;
    // The cookie-path is a prefix of the request-path, and the first
    // character of the request-path that is not included in the cookie-
    // path is a %x2F ("/") character.
    if (path.at(reference.size()) == u'/')
      return true;
  }
  return false;
}

bool isParentDomain(const std::string& domain, const std::string& reference)
{
  if (!starts_with(reference, "."))
    return domain == reference;

  return ends_with(domain, reference) || domain == mid(reference, 1);
}

bool qIsEffectiveTLD(const std::string& domain)
{
    // provide minimal checking by not accepting cookies on real TLDs
    return !contains(domain, ".");
}

bool validateCookie(const Poco::Net::HTTPCookie& cookie, const Poco::URI& url) {
  std::string cookieDomain = cookie.getDomain();
  std::string domain = cookieDomain;
  std::string host = url.getHost();
  if (!isParentDomain(domain, host) && !isParentDomain(host, domain))
    return false; // not accepted

  if (starts_with(domain, "."))
    domain = mid(domain, 1);

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

Poco::Net::IPAddress::Family getProtocol(const std::string& s) {
  try {
    return Poco::Net::IPAddress(s).family();
  } catch(const Poco::Net::InvalidAddressException&) {
    return Poco::Net::IPAddress::Family::UNKNOWN;
  }
}

void normalize(Poco::Net::HTTPCookie& cookie, const Poco::URI& url) {
  if (cookie.getPath().empty())
  {
    std::string pathAndFileName = url.getPath();
    std::string defaultPath = left(pathAndFileName, lastIndexOf(pathAndFileName, u'/') + 1);
    if (defaultPath.empty())
      defaultPath = u'/';
    cookie.setPath(defaultPath);
  }

  if (cookie.getDomain().empty())
  {
    cookie.setDomain(url.getHost());
  }
  else
  {
    Poco::Net::IPAddress::Family protocol = getProtocol(cookie.getDomain());
    if (protocol != Poco::Net::IPAddress::Family::IPv4 && protocol != Poco::Net::IPAddress::Family::IPv6 && !starts_with(cookie.getDomain(), "."))
    {
      // Ensure the domain starts with a dot if its field was not empty
      // in the HTTP header. There are some servers that forget the
      // leading dot and this is actually forbidden according to RFC 2109,
      // but all browsers accept it anyway so we do that as well.
      cookie.setDomain("." + cookie.getDomain());
    }
  }
}

/*!
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
std::vector<Poco::Net::HTTPCookie> CookieJar::cookiesForUrl(const Poco::URI& url) const {
//     \b Warning! This is only a dumb implementation!
//     It does NOT follow all of the recommendations from
//     http://wp.netscape.com/newsref/std/cookie_spec.html
//     It does not implement a very good cross-domain verification yet.

  Poco::Timestamp now;
  std::vector<Poco::Net::HTTPCookie> result;
  bool isEncrypted = url.getScheme() == "https";

  for (const auto& cookie : allCookies) {
    if (!isEncrypted && cookie._data.getSecure())
      continue;
    if (!cookie.isSessionCookie() && cookie._expirationDate < now)
      continue;
    std::string urlHost = url.getHost();
    std::string cookieDomain = cookie._data.getDomain();
    if (!isParentDomain(urlHost, cookieDomain))
      continue;
    if (!isParentPath(url.getPath(), cookie._data.getPath()))
      continue;

    std::string domain = cookieDomain;
    if (starts_with(domain, "."))
      domain = mid(domain, 1);
    if (!contains(domain, ".") && urlHost != domain)
      continue;

    result.push_back(cookie._data);
  }

  auto longerPath = [](const auto &c1, const auto &c2) { 
    return c1.getPath().size() > c2.getPath().size(); 
  };
  std::sort(result.begin(), result.end(), longerPath);
  return result;
}

/*!
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
bool CookieJar::setCookiesFromUrl(const Poco::URI& url, const std::vector<Poco::Net::HTTPCookie>& cookieList) {
  bool added = false;
  for (Poco::Net::HTTPCookie cookie : cookieList) {
    normalize(cookie, url);
    if (validateCookie(cookie, url) && insertCookie(cookie))
      added = true;
  }
  return added;
}

void CookieJar::clearAllCookies() {
  allCookies.clear();
}

bool CookieJar::insertCookie(const Poco::Net::HTTPCookie& cookie)
{
  Poco::Timestamp now;
  _HTTPCookie _cookie = cookie;
  bool isDeletion = !_cookie.isSessionCookie() && _cookie._expirationDate < now;

  deleteCookie(cookie);

  if (!isDeletion)
  {
    allCookies.push_back(_cookie);
    return true;
  }
  return false;
}

bool CookieJar::deleteCookie(const Poco::Net::HTTPCookie& cookie)
{
  const auto it = std::find_if(
    allCookies.cbegin(),
    allCookies.cend(),
    [&cookie](const auto &c) { return c.hasSameIdentifier(cookie); });
  if (it != allCookies.cend())
  {
    allCookies.erase(it);
    return true;
  }
  return false;
}

bool CookieJar::updateCookie(const Poco::Net::HTTPCookie& cookie)
{
  if (deleteCookie(cookie))
    return insertCookie(cookie);
  return false;
}

_HTTPCookie::_HTTPCookie(const Poco::Net::HTTPCookie& cookie) :
  _data(cookie)
{
  int secs = _data.getMaxAge();
  if (secs <= 0)
  {
    // earliest representable time (RFC6265 section 5.2.2)
    _expirationDate = Poco::Timestamp::TIMEVAL_MIN;
  }
  else
  {
    Poco::Timespan ts(secs, 0);
    _expirationDate += ts;
  }
}

bool _HTTPCookie::isSessionCookie() const {
  return _data.getMaxAge() < 0;
}

bool _HTTPCookie::hasSameIdentifier(const Poco::Net::HTTPCookie& other) const {
  return _data.getName() == other.getName() && _data.getDomain() == other.getDomain() && _data.getPath() == other.getPath();
}
