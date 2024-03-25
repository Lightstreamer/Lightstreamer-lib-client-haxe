#ifndef INCLUDED_Lightstreamer_HxPoco_HttpClient
#define INCLUDED_Lightstreamer_HxPoco_HttpClient

#include <string>
#include <atomic>
#include <thread>
#include <memory>
#include <unordered_map>
#include "Poco/Foundation.h"
#include "Poco/Event.h"
#include "Poco/Mutex.h"
#include "Poco/Net/HTTPClientSession.h"
#include "Poco/Net/Context.h"
#include "Lightstreamer/HxPoco/CookieJar.h"
#include "Lightstreamer/HxPoco/Activity.h"

namespace Lightstreamer {
namespace HxPoco {

class HttpClient : public Activity {
public:
  HttpClient(const char* url, const char* body, const std::unordered_map<std::string, std::string>& headers, const Poco::Net::HTTPClientSession::ProxyConfig& proxy);
  virtual ~HttpClient();

  HttpClient() = delete;
  HttpClient(const HttpClient&) = delete;
  HttpClient& operator = (const HttpClient&) = delete;

  void start() {
    Activity::start();
  }
  void dispose();
  bool isDisposed() const {
    return _disposed;
  }

protected:
  virtual void onText(const char* line) {}
  virtual void onError(const char* line) {}
  virtual void onDone() {}
  virtual void run() override;

private:
  std::streamsize computeContentLength();

  std::string _url;
  std::string _body;
  std::unordered_map<std::string, std::string> _headers;
  Poco::Net::HTTPClientSession::ProxyConfig _proxy;
  std::unique_ptr<Poco::Net::HTTPClientSession> _session;
  std::atomic_bool _disposed;
};

}}

#endif
