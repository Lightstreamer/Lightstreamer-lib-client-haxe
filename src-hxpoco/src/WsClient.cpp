#include "Lightstreamer/HxPoco/WsClient.h"

#include "Poco/URI.h"
#include "Poco/Net/Context.h"
#include "Poco/Net/HTTPRequest.h"
#include "Poco/Net/HTTPResponse.h"
#include "Poco/Net/HTTPSClientSession.h"
#include "Poco/Net/NameValueCollection.h"
#include "Lightstreamer/HxPoco/Network.h"

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
  if (_ws) {
    _ws->sendFrame(txt.data(), txt.size());
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
      _ws = nullptr;
    }
  }
  catch(...)
  {
    // there is nothing we can do
  }

  try
  {
    stop();
    wait();
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

    if (secure) {
      Context::Ptr pContext = Network::_sslCtx;
      HTTPSClientSession cs(pContext);
      cs.setHost(host);
      cs.setPort(port);
      cs.setProxyConfig(_proxy);
      _ws = std::make_unique<WebSocket>(cs, request, response);
    } else {
      HTTPClientSession cs(host, port, _proxy);
      _ws = std::make_unique<WebSocket>(cs, request, response);
    }

    // retrieve cookies
    std::vector<Poco::Net::HTTPCookie> outCookies;
    response.getCookies(outCookies);
    if (!outCookies.empty()) {
      Network::_cookieJar.setCookiesFromUrl(url, outCookies);
    }

    onOpen();
    int flags, n;
    Poco::Buffer<char> buf(1024);
    while (!isStopped()) {
      buf.resize(0);
      n = _ws->receiveFrame(buf, flags);
      if (n == 0 && flags == 0) { // connection has been closed
        break;
      }
      if (n > 0 && isTextFrame(flags)) {
        std::string output(buf.begin(), buf.end());
        onText(output.data());
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