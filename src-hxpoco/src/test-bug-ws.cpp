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
