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

namespace Lightstreamer {
namespace HxPoco {

class HttpClient {
public:
  HttpClient(const char* url, const char* body, const std::unordered_map<std::string, std::string>& headers, const Poco::Net::HTTPClientSession::ProxyConfig& proxy);
  virtual ~HttpClient();

  HttpClient() = delete;
  HttpClient(const HttpClient&) = delete;
  HttpClient& operator = (const HttpClient&) = delete;

  void start();
  void dispose();
  bool isDisposed() const {
    return _disposed;
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
  std::streamsize computeContentLength();

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
