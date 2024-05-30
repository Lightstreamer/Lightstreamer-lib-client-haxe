#include "Lightstreamer/HxPoco/WsClient.h"

#include "Poco/URI.h"
#include "Poco/Net/Context.h"
#include "Poco/Net/HTTPRequest.h"
#include "Poco/Net/HTTPResponse.h"
#include "Poco/Net/HTTPSClientSession.h"
#include "Poco/Net/NameValueCollection.h"
#include "Lightstreamer/HxPoco/Network.h"
#include "Lightstreamer/HxPoco/LineAssembler.h"

#ifndef LS_HXPOCO_WS_RECEIVE_TIMEOUT_MS
#define LS_HXPOCO_WS_RECEIVE_TIMEOUT_MS 250
#endif

namespace {

using Poco::URI;
using Poco::Net::Context;
using Poco::Net::WebSocket;
using Poco::Net::HTTPClientSession;
using Poco::Net::HTTPSClientSession;
using Poco::Net::HTTPRequest;
using Poco::Net::HTTPResponse;
using Poco::Net::NameValueCollection;

using Lightstreamer::HxPoco::WsClient;
using Lightstreamer::HxPoco::LineAssembler;

inline bool isTextFrame(int flags) {
  return (flags & 0xf) == Poco::Net::WebSocket::FrameOpcodes::FRAME_OP_TEXT;
}

class WorkNotification : public Poco::Notification
{
public:
  std::string _data;
  WorkNotification(const std::string& data) : _data(data) {}
};

} // END unnamed namespace

WsClient::WsClient(const char* url, const char* subProtocol, const std::map<std::string, std::string>& headers, const Poco::Net::HTTPClientSession::ProxyConfig& proxy) :
  _url(url),
  _subProtocol(subProtocol),
  _headers(headers),
  _proxy(proxy)
{}

WsClient::~WsClient() {}

void WsClient::send(const std::string& txt) {
  _queue.enqueueNotification(new WorkNotification(txt));
}

void WsClient::dispose() {
  try {
    if (_ws) {
      _ws->shutdown();
    } else if (_cs) {
      _cs->abort();
    }
  } catch(...) {
    // there is nothing we can do
  }

  try
  {
    stop();
    doWait();
  }
  catch (...)
  {
    poco_unexpected();
  }
}

void WsClient::run() {
  try {
    URI url(_url);
    auto secure = url.getScheme() == "https";
    auto host = url.getHost();
    auto port = url.getPort();
    auto path = url.getPathAndQuery();

    HTTPResponse response;

    HTTPRequest request(HTTPRequest::HTTP_GET, path, HTTPRequest::HTTP_1_1);
    request.set("Sec-WebSocket-Protocol", _subProtocol);

    // add cookies
    auto inCookies = Network::_cookieJar.cookiesForUrl(url);
    if (!inCookies.empty()) {
      NameValueCollection nvc;
      for (const auto& c : inCookies) {
        nvc.add(c.getName(), c.getValue());
      }
      request.setCookies(nvc);
    }

    // add request headers
    for (const auto& h : _headers) {
      request.set(h.first, h.second);
    }

    // open the websocket
    if (secure) {
      Context::Ptr pContext = Network::_sslCtx;
      _cs = std::make_unique<HTTPSClientSession>(pContext);
      _cs->setHost(host);
      _cs->setPort(port);
      _cs->setProxyConfig(_proxy);
      _ws = std::unique_ptr<WebSocket>(doCreateWebSocket(*_cs, request, response));
    } else {
      _cs = std::make_unique<HTTPClientSession>(host, port, _proxy);
      _ws = std::unique_ptr<WebSocket>(doCreateWebSocket(*_cs, request, response));
    }
    _ws->setReceiveTimeout(LS_HXPOCO_WS_RECEIVE_TIMEOUT_MS * 1000);

    // retrieve cookies
    std::vector<Poco::Net::HTTPCookie> outCookies;
    response.getCookies(outCookies);
    if (!outCookies.empty()) {
      Network::_cookieJar.setCookiesFromUrl(url, outCookies);
    }

    LineAssembler lineAssembler;
    Poco::Buffer<char> buf(1024);
    auto lineConsumer = [this](std::string_view line) {
      std::string _line(line);
      onText(_line.c_str());
    };

    onOpen();
    int flags, n;
    while (!isStopped()) {
      buf.resize(0);
      try {
        n = doReceiveFrame(_ws.get(), buf, flags);
      } catch (const Poco::TimeoutException& ex)  {
        sendPendingFrames(_ws.get());
        continue;
      }
      if (n == 0 && flags == 0) { // connection has been closed
        break;
      }
      if (n > 0 && isTextFrame(flags)) {
        lineAssembler.readBytes(buf, lineConsumer);
      }
    }
    _ws->shutdown();
  }
  catch(const Poco::Exception& e)
  {
    onError(e.displayText().c_str());
  }
  catch(const std::exception& e)
  {
    onError(e.what());
  }
  catch(...)
  {
    onError("unknown exception");
  }
}

Poco::Net::WebSocket* WsClient::doCreateWebSocket(Poco::Net::HTTPClientSession& cs, Poco::Net::HTTPRequest& request, Poco::Net::HTTPResponse& response) {
  try {
    gc_enter_blocking();
    auto ws = new WebSocket(cs, request, response);
    gc_exit_blocking();
    return ws;
  } catch(...) {
    gc_exit_blocking();
    throw;
  }
}

int WsClient::doReceiveFrame(WebSocket* ws, Poco::Buffer<char>& buffer, int& flags) {
  try {
    gc_enter_blocking();
    int n = ws->receiveFrame(buffer, flags);
    gc_exit_blocking();
    return n;
  } catch(...) {
    gc_exit_blocking();
    throw;
  }
}

void WsClient::doSendFrame(WebSocket* ws, const void *buffer, int length) {
  try {
    gc_enter_blocking();
    ws->sendFrame(buffer, length);
    gc_exit_blocking();
  } catch(...) {
    gc_exit_blocking();
    throw;
  }
}

void WsClient::doWait() {
  try {
    gc_enter_blocking();
    wait();
    gc_exit_blocking();
  } catch(...) {
    gc_exit_blocking();
    throw;
  }
}

void WsClient::sendPendingFrames(WebSocket* ws) {
  Poco::AutoPtr<Poco::Notification> pNf(_queue.dequeueNotification());
  while (pNf) {
    WorkNotification *pWorkNf = dynamic_cast<WorkNotification *>(pNf.get());
    if (pWorkNf) {
      ws->sendFrame(pWorkNf->_data.data(), pWorkNf->_data.size());
    }
    pNf = _queue.dequeueNotification();
  }
}
