#include "Lightstreamer/HxPoco/WsClient.h"

#include "Poco/URI.h"
#include "Poco/Net/Context.h"
#include "Poco/Net/HTTPRequest.h"
#include "Poco/Net/HTTPResponse.h"
#include "Poco/Net/HTTPSClientSession.h"
#include "Poco/Net/NameValueCollection.h"
#include "Lightstreamer/HxPoco/Network.h"
#include "Lightstreamer/HxPoco/LineAssembler.h"

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

} // END unnamed namespace

WsClient::WsClient(const char* url, const char* subProtocol, const std::unordered_map<std::string, std::string>& headers, const Poco::Net::HTTPClientSession::ProxyConfig& proxy) :
  _url(url),
  _subProtocol(subProtocol),
  _headers(headers),
  _proxy(proxy),
  _disposed(false)
{}

WsClient::~WsClient()
{
  dispose();
}

void WsClient::send(const std::string& txt) {
  if (!_disposed) {
    doSendFrame(txt.data(), txt.size());
  }
}

void WsClient::dispose() {
  if (_disposed.exchange(true)) {
    return;
  }

  try
  {
    if (_ws) {
      _ws->shutdown();
    }
  }
  catch(...)
  {
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
      HTTPSClientSession cs(pContext);
      cs.setHost(host);
      cs.setPort(port);
      cs.setProxyConfig(_proxy);
      _ws = std::unique_ptr<WebSocket>(doCreateWebSocket(cs, request, response));
    } else {
      HTTPClientSession cs(host, port, _proxy);
      _ws = std::unique_ptr<WebSocket>(doCreateWebSocket(cs, request, response));
    }

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
      n = doReceiveFrame(buf, flags);
      if (n == 0 && flags == 0) { // connection has been closed
        break;
      }
      if (n > 0 && isTextFrame(flags)) {
        lineAssembler.readBytes(buf, lineConsumer);
      }
    }
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

int WsClient::doReceiveFrame(Poco::Buffer<char>& buffer, int& flags) {
  try {
    gc_enter_blocking();
    int n = _ws->receiveFrame(buffer, flags);
    gc_exit_blocking();
    return n;
  } catch(...) {
    gc_exit_blocking();
    throw;
  }
}

void WsClient::doSendFrame(const void *buffer, int length) {
  try {
    gc_enter_blocking();
    _ws->sendFrame(buffer, length);
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
