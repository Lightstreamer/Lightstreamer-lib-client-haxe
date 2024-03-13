#include "Lightstreamer/HxPoco/HttpClient.h"

#include <iostream>
#include <sstream>
#include "Poco/URI.h"
#include "Poco/Net/HTTPClientSession.h"
#include "Poco/Net/HTTPSClientSession.h"
#include "Poco/Net/HTTPRequest.h"
#include "Poco/Net/HTTPResponse.h"
#include "Poco/Net/HTMLForm.h"

using Poco::URI;
using Poco::Net::HTTPClientSession;
using Poco::Net::HTTPSClientSession;
using Poco::Net::HTTPRequest;
using Poco::Net::HTTPResponse;
using Poco::Net::HTTPMessage;
using Poco::Net::HTMLForm;
using Poco::Net::Context;
using Poco::FastMutex;
using Poco::Event;

using Lightstreamer::HxPoco::HttpClient;

Poco::Net::Context::Ptr HttpClient::_sslCtx = new Poco::Net::Context(Poco::Net::Context::TLS_CLIENT_USE, "", "", "", Poco::Net::Context::VERIFY_RELAXED, 9, true, "ALL:!ADH:!LOW:!EXP:!MD5:@STRENGTH");

HttpClient::HttpClient(const char* url, const char* body, const std::unordered_map<std::string, std::string>& headers, const HTTPClientSession::ProxyConfig& proxy) : 
  _url(url),
  _body(body),
  _headers(headers),
  _proxy(proxy),
  _disposed(false),
  _stopped(true),
  _running(false),
  _done(Event::EVENT_MANUALRESET)
{}

HttpClient::~HttpClient()
{
  dispose();
}

void HttpClient::start()
{
  if (_disposed) {
    return;
  }

  FastMutex::ScopedLock lock(_mutex);

  if (!_running)
  {
    _done.reset();
    _stopped = false;
    _running = true;
    try
    {
      submit();
    }
    catch (...)
    {
      _running = false;
      throw;
    }
  }
}

void HttpClient::run()
{
  try
  {
    sendRequestAndReadResponse();
  }
  catch (...)
  {
    _done.set();
    throw;
  }
  _done.set();
}

void HttpClient::stop()
{
  _stopped = true;
}

void HttpClient::wait()
{
  if (_running)
  {
    _done.wait();
    _running = false;
  }
}

void HttpClient::dispose() {
  if (_disposed.exchange(true)) {
    return;
  }

  try
  {
    if (_session) {
      _session->abort();
    }
  }
  catch(...)
  {
    // there is nothing we cand do
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

void HttpClient::sendRequestAndReadResponse() {
  try 
  {
    URI url(_url);
    auto secure = url.getScheme() == "https";
    auto host = url.getHost();
    auto port = url.getPort();
    auto path = url.getPathAndQuery();

    if (secure) {
      Context::Ptr pContext = _sslCtx;
      _session = std::make_unique<HTTPSClientSession>(pContext);
    } else {
      _session = std::make_unique<HTTPClientSession>();
    }
    _session->setHost(host);
    _session->setPort(port);
    _session->setProxyConfig(_proxy);

    HTTPRequest request(HTTPRequest::HTTP_POST, path, HTTPMessage::HTTP_1_1);

    // add request headers
    for (const auto& h : _headers) {
      request.set(h.first, h.second);
    }

    // add post parameters
    HTMLForm form;
    form.read(_body);
    form.prepareSubmit(request);
    
    // send request: headers+parameters
    std::ostream& ros = _session->sendRequest(request);
    form.write(ros);

    Poco::Net::HTTPResponse response;
    std::istream& rs = _session->receiveResponse(response);
    
    std::string line;
    while (!isStopped() && std::getline(rs, line)) {
      onText(line.c_str());
    }
    onDone();
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
