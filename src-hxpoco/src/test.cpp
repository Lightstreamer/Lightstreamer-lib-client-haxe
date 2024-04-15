#include <iostream>
#include <sstream>
#include <mutex>
#include "Poco/URI.h"
#include "Poco/Net/HTTPClientSession.h"
#include "Poco/Net/HTTPSClientSession.h"
#include "Poco/Net/HTTPRequest.h"
#include "Poco/Net/HTTPResponse.h"
#include "Poco/Net/HTMLForm.h"
#include "Poco/Net/WebSocket.h"
#include "Poco/ThreadTarget.h"
#include "Poco/RunnableAdapter.h"
#include "Poco/Runnable.h"
#include "Poco/Thread.h"

#include "Lightstreamer/HxPoco/CookieJar.h"

using Poco::URI;
using Poco::Net::HTTPClientSession;
using Poco::Net::HTTPSClientSession;
using Poco::Net::HTTPRequest;
using Poco::Net::HTTPResponse;
using Poco::Net::HTTPMessage;
using Poco::Net::HTMLForm;
using Poco::Net::Context;
using Poco::Net::HTTPCookie;
using Poco::FastMutex;
using Poco::Event;
using std::cout;
using std::string;
using Lightstreamer::HxPoco::CookieJar;
using Poco::Net::WebSocket;

class Ctrl : public Poco::Runnable
{
  WebSocket& _ws;
public:
  Ctrl(WebSocket ws) : _ws(ws) {}

  virtual void run()
  {
    int i = 1;
    while (1)
    {
      Poco::Thread::sleep(1000);
      std::stringstream ss;
      ss << "hello " << i++;
      string s = ss.str();
      _ws.sendFrame(s.data(), s.size());
    }
  }
};

class Reader : public Poco::Runnable
{
  WebSocket& _ws;
public:
  Reader(WebSocket ws) : _ws(ws) {}

  virtual void run()
  {
    int flags, n;
    Poco::Buffer<char> buf(1024);
    while (1)
    {
      buf.resize(0);
      n = _ws.receiveFrame(buf, flags);
      if (n == 0 && flags == 0)
      {
        break;
      }
      if (n > 0 && (flags & 0xf) == Poco::Net::WebSocket::FrameOpcodes::FRAME_OP_TEXT)
      {
        string output(buf.begin(), buf.end());
        cout << output << "\n";
      }
    }
  }
};

int main() {
  // HTTPClientSession cs("echo.websocket.in", 80); // this is OK
  
  Poco::Net::Context::Ptr pContext = new Poco::Net::Context(Poco::Net::Context::TLS_CLIENT_USE, "", "", "", Poco::Net::Context::VERIFY_RELAXED, 9, true, "ALL:!ADH:!LOW:!EXP:!MD5:@STRENGTH");
  HTTPSClientSession cs(pContext);
  cs.setHost("echo.websocket.in");
  cs.setPort(443);
  
  HTTPRequest request(HTTPRequest::HTTP_GET, "/", HTTPRequest::HTTP_1_1);
  HTTPResponse response;
  WebSocket ws(cs, request, response);

  Reader rdr(ws);
  Poco::Thread tr;
  tr.start(rdr);

  Ctrl wrt(ws);
  Poco::Thread tw;
  tw.start(wrt);

  tr.join();
  tw.join();
}

/*
CookieJar jar;

void send(const URI& url, const string& _body, HTTPClientSession& _session) {
  HTTPRequest request(HTTPRequest::HTTP_POST, url.getPathAndQuery(), HTTPMessage::HTTP_1_1);

  Poco::Net::NameValueCollection nvc;
  for (const auto& c : jar.cookiesForUrl(url)) {
    nvc.add(c.getName(), c.getValue());
  }
  request.setCookies(nvc);

  // add request headers
  // for (const auto& h : _headers) {
  //   request.set(h.first, h.second);
  // }

  // add post parameters
  HTMLForm form;
  form.read(_body);
  form.prepareSubmit(request);
  
  // send request: headers+parameters
  std::ostream& ros = _session.sendRequest(request);
  form.write(ros);

  Poco::Net::HTTPResponse response;
  std::istream& rs = _session.receiveResponse(response);

  std::vector<HTTPCookie> cookies;
  response.getCookies(cookies);
  jar.setCookiesFromUrl(url, cookies);

  // for (const auto& c : jar.cookiesForUrl(url)) {
  //   std::cout << "xxx " << c.getName() << "=" << c.getValue() << "\n";
  // }
  
  std::string line;
  while (std::getline(rs, line)) {
    // onText(line.c_str());
    std::cout << line << "\n";
  }
  std::cout << "xxx done\n";
}

Poco::Net::HTTPClientSession _session;

class HelloRunnable : public Poco::Runnable
{
  virtual void run()
  {
    Poco::Thread::sleep(00);
    std::cout << "xxx abort\n";
    _session.abort();    
  }
};

int main() {
  auto _url = "http://localhost:8080/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0";
  auto _body = "LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg";

  URI url(_url);
  auto secure = url.getScheme() == "https";
  auto host = url.getHost();
  auto port = url.getPort();
  auto path = url.getPathAndQuery();

  _session.setHost(host);
  _session.setPort(port);

  HelloRunnable runnable;
  Poco::Thread thread;
  thread.start(runnable);

  send(url, _body, _session);
}
*/

/*
struct Sender : public Poco::Runnable
{
  Poco::Net::WebSocket* _ws;

  Sender(Poco::Net::WebSocket& ws) : _ws(&ws) {}

  virtual void run()
  {
    // string hb("heartbeat\r\n\r\n");
    // while (1) {
    //   _ws->sendFrame(hb.data(), hb.size());

    //   Poco::Thread::sleep(1'000);
    // }
    Poco::Thread::sleep(2'000);
    cout << "ws closing...\n";
    _ws->shutdown();
  }
};

int main() {
  // Poco::Net::Context::Ptr pContext = new Poco::Net::Context(Poco::Net::Context::TLS_CLIENT_USE, "", "", "", Poco::Net::Context::VERIFY_RELAXED, 9, true, "ALL:!ADH:!LOW:!EXP:!MD5:@STRENGTH");
  // std::unique_ptr<Poco::Net::HTTPClientSession> cs = std::make_unique<HTTPSClientSession>(pContext);
  // cs->setHost("push.lightstreamer.com");
  // cs->setPort(443);

  // Poco::Net::HTTPClientSession::ProxyConfig proxy;
  // proxy.host = "localtest.me";
  // proxy.port = 8079;
  // proxy.username = "myuser";
  // proxy.password = "mypassword";

  HTTPClientSession cs("localhost", 8080);
  // cs.setProxyConfig(proxy);
  HTTPRequest request(HTTPRequest::HTTP_GET, "/lightstreamer", HTTPRequest::HTTP_1_1);
  request.set("Sec-WebSocket-Protocol", "TLCP-2.5.0.lightstreamer.com");
  request.set("X-Foo", "bar");
  HTTPResponse response;
  WebSocket ws(cs, request, response);

  std::vector<Poco::Net::HTTPCookie> cookies;
  response.getCookies(cookies);
  cout << cookies.at(0).toString() << "\n";

  string input("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
  ws.sendFrame(input.data(), input.size());

  Sender sndr(ws);
  Poco::Thread thr;
  thr.start(sndr);

  int flags, n;
  Poco::Buffer<char> buf(0);
  while (1) {
    buf.resize(0);
    n = ws.receiveFrame(buf, flags);
    if (n == 0 && flags == 0) {
      break;
    }
    cout << "flags " << std::hex << flags << " n " << std::dec << n << "\n";
    if (n > 0 && (flags & 0xf) == Poco::Net::WebSocket::FrameOpcodes::FRAME_OP_TEXT) {
      string output(buf.begin(), buf.end());
      cout << ">" << output;
    }
  }

  cout << "ws done\n";
  // Poco::Thread::sleep(500);
}
*/
/*
CookieJar jar;

void send(const URI& url, const string& _body, HTTPClientSession& _session) {
  HTTPRequest request(HTTPRequest::HTTP_POST, url.getPathAndQuery(), HTTPMessage::HTTP_1_1);

  Poco::Net::NameValueCollection nvc;
  for (const auto& c : jar.cookiesForUrl(url)) {
    nvc.add(c.getName(), c.getValue());
  }
  request.setCookies(nvc);

  // add request headers
  // for (const auto& h : _headers) {
  //   request.set(h.first, h.second);
  // }

  // add post parameters
  HTMLForm form;
  form.read(_body);
  form.prepareSubmit(request);
  
  // send request: headers+parameters
  std::ostream& ros = _session.sendRequest(request);
  form.write(ros);

  Poco::Net::HTTPResponse response;
  std::istream& rs = _session.receiveResponse(response);

  std::vector<HTTPCookie> cookies;
  response.getCookies(cookies);
  jar.setCookiesFromUrl(url, cookies);

  // for (const auto& c : jar.cookiesForUrl(url)) {
  //   std::cout << "xxx " << c.getName() << "=" << c.getValue() << "\n";
  // }
  
  std::string line;
  while (!isStopped() && std::getline(rs, line)) {
    // onText(line.c_str());
    std::cout << line << "\n";
  }
}

int main() {
  auto _url = "http://localhost:8080/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0";
  Poco::Net::HTTPClientSession _session;
  auto _body = "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg";

  URI url(_url);
  auto secure = url.getScheme() == "https";
  auto host = url.getHost();
  auto port = url.getPort();
  auto path = url.getPathAndQuery();

  _session.setHost(host);
  _session.setPort(port);

  send(url, _body, _session);
  send(url, _body, _session);
}
*/
