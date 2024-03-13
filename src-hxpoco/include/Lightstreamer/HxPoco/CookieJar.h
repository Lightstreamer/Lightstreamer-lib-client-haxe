// This class is an adaptation of QNetworkCookieJar by the Qt Company Ltd,
// and is used under a LGPL-3.0-only license

#ifndef INCLUDED_Lightstreamer_HxPoco_CookieJar
#define INCLUDED_Lightstreamer_HxPoco_CookieJar

#include <vector>
#include <string>
#include "Poco/URI.h"
#include "Poco/Timestamp.h"
#include "Poco/Net/HTTPCookie.h"

namespace Lightstreamer {
namespace HxPoco {

struct _HTTPCookie {
  Poco::Net::HTTPCookie _data;
  Poco::Timestamp _expirationDate;

  _HTTPCookie(const Poco::Net::HTTPCookie& cookie);
  _HTTPCookie() = delete;

  bool isSessionCookie() const;
  bool hasSameIdentifier(const Poco::Net::HTTPCookie& other) const;
};

class CookieJar {
  std::vector<_HTTPCookie> allCookies;
public:
  virtual ~CookieJar() {}

  virtual std::vector<Poco::Net::HTTPCookie> cookiesForUrl(const Poco::URI& url) const;
  virtual bool setCookiesFromUrl(const Poco::URI& url, const std::vector<Poco::Net::HTTPCookie>& cookies);

  virtual bool insertCookie(const Poco::Net::HTTPCookie& cookie);
  virtual bool updateCookie(const Poco::Net::HTTPCookie& cookie);
  virtual bool deleteCookie(const Poco::Net::HTTPCookie& cookie);
};

}} // END NAMESPACE
#endif