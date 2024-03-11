#ifndef INCLUDED_HxPoco
#define INCLUDED_HxPoco

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

namespace Lightstreamer {
namespace HxPoco {

class HttpClientCpp {
public:
  HttpClientCpp(const char* url, const char* body, const std::unordered_map<std::string, std::string>& headers, const Poco::Net::HTTPClientSession::ProxyConfig& proxy);
  virtual ~HttpClientCpp();

  HttpClientCpp() = delete;
  HttpClientCpp(const HttpClientCpp&) = delete;
  HttpClientCpp& operator = (const HttpClientCpp&) = delete;

  void start();
  void dispose();
  bool isDisposed() const {
    return _disposed;
  }

  static void setSSLContext(Poco::Net::Context::Ptr pCtx) {
    _sslCtx = pCtx;
  }

  static void clearSSLContext() {
    _sslCtx = new Poco::Net::Context(Poco::Net::Context::TLS_CLIENT_USE, "", "", "", Poco::Net::Context::VERIFY_RELAXED, 9, true, "ALL:!ADH:!LOW:!EXP:!MD5:@STRENGTH");
  }

protected:
  virtual void onText(const char* line) {}
  virtual void onError(const char* line) {}
  virtual void onDone() {}
  virtual void submit() {
    run();
  }
  void run();

private:
  void stop();
  bool isStopped() const {
		return _stopped;
	}
  void wait();
  void sendRequestAndReadResponse();

  static Poco::Net::Context::Ptr _sslCtx;

  std::string _url;
  std::string _body;
  std::unordered_map<std::string, std::string> _headers;
  Poco::Net::HTTPClientSession::ProxyConfig _proxy;
  std::unique_ptr<Poco::Net::HTTPClientSession> _session;
  std::atomic_bool    _disposed;
  std::atomic<bool>   _stopped;
  std::atomic<bool>   _running;
  Poco::Event         _done;
  Poco::FastMutex     _mutex;
};

}}

#endif
