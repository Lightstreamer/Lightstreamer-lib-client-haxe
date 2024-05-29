#ifndef INCLUDED_Lightstreamer_HxPoco_Network
#define INCLUDED_Lightstreamer_HxPoco_Network

#include "Poco/Net/Context.h"
#include "Lightstreamer/HxPoco/CookieJar.h"

namespace Lightstreamer {
namespace HxPoco {

class Network
{
public:
  Network() = delete;

  inline static CookieJar _cookieJar;
  inline static Poco::Net::Context::Ptr _sslCtx = new Poco::Net::Context(Poco::Net::Context::TLS_CLIENT_USE, "", "", "", Poco::Net::Context::VERIFY_RELAXED, 9, true, "ALL:!ADH:!LOW:!EXP:!MD5:@STRENGTH");

  static void setSSLContext(Poco::Net::Context::Ptr pCtx) {
    _sslCtx = pCtx;
  }

  static void clearSSLContext() {
    _sslCtx = new Poco::Net::Context(Poco::Net::Context::TLS_CLIENT_USE, "", "", "", Poco::Net::Context::VERIFY_RELAXED, 9, true, "ALL:!ADH:!LOW:!EXP:!MD5:@STRENGTH");
  }
};

}}
#endif