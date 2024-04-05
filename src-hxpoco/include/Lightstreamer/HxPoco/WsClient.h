#ifndef INCLUDED_Lightstreamer_HxPoco_WsClient
#define INCLUDED_Lightstreamer_HxPoco_WsClient

#include <string>
#include <unordered_map>
#include "Poco/Net/HTTPClientSession.h"
#include "Poco/Net/WebSocket.h"
#include "Lightstreamer/HxPoco/Activity.h"

namespace Lightstreamer {
namespace HxPoco {

class WsClient : public Activity
{
public:
  WsClient(const char* url, const char* subProtocol, const std::unordered_map<std::string, std::string>& headers, const Poco::Net::HTTPClientSession::ProxyConfig& proxy);
  virtual ~WsClient();

  void connect() {
    Activity::start();
  }
  void send(const std::string& txt);
  void dispose();
  bool isDisposed() const {
    return _disposed;
  }

  WsClient() = delete;
  WsClient(const WsClient&) = delete;
  WsClient& operator = (const WsClient&) = delete;

protected:
  virtual void gc_enter_blocking() = 0;
  virtual void gc_exit_blocking() = 0;
  virtual void onOpen() {}
  virtual void onText(const char* line) {}
  virtual void onError(const char* line) {}
  virtual void run() override;

private:
  void doSendFrame(const void *buffer, int length);
  Poco::Net::WebSocket* doCreateWebSocket(Poco::Net::HTTPClientSession& cs, Poco::Net::HTTPRequest& request, Poco::Net::HTTPResponse& response);
  int doReceiveFrame(Poco::Buffer<char>& buffer, int& flags);
  void doWait();

  std::string _url;
  std::string _subProtocol;
  std::unordered_map<std::string, std::string> _headers;
  Poco::Net::HTTPClientSession::ProxyConfig _proxy;
  std::unique_ptr<Poco::Net::WebSocket> _ws;
  std::atomic_bool _disposed;
};

}}
#endif