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
#include "Poco/Exception.h"
#include "Poco/Notification.h"
#include "Poco/NotificationQueue.h"

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
using Poco::Net::WebSocket;

Poco::NotificationQueue queue;
std::atomic_bool stopped = false;

class WorkNotification : public Poco::Notification
{
  string _data;
public:
  WorkNotification(string data) : _data(data) {}
  string data() const
  {
    return _data;
  }
};

class Ctrl : public Poco::Runnable
{
public:
  virtual void run()
  {
    for (int i = 0; i < 10; i++)
    {
      Poco::Thread::sleep(1000);
      std::stringstream ss;
      ss << "hello " << i;

      queue.enqueueNotification(new WorkNotification(ss.str()));
    }
    stopped = true;
  }
};

class Worker: public Poco::Runnable {  
public:
  virtual void run() {
    Poco::Net::Context::Ptr pContext = new Poco::Net::Context(Poco::Net::Context::TLS_CLIENT_USE, "", "", "", Poco::Net::Context::VERIFY_RELAXED, 9, true, "ALL:!ADH:!LOW:!EXP:!MD5:@STRENGTH");
    HTTPSClientSession cs(pContext);
    cs.setHost("echo.websocket.in");
    cs.setPort(443);
    
    HTTPRequest request(HTTPRequest::HTTP_GET, "/", HTTPRequest::HTTP_1_1);
    HTTPResponse response;
    WebSocket ws(cs, request, response);

    Poco::Timespan rt(500'000);
    std::cout << "rcvTimeout " << ws.getReceiveTimeout().totalMilliseconds() << "\n";
    ws.setReceiveTimeout(rt);

    int flags, n;
    Poco::Buffer<char> buf(1024);
    while (1)
    {
      if (stopped) {
        break;
      }
      buf.resize(0);
      try 
      {
        n = ws.receiveFrame(buf, flags);
      } 
      catch (const Poco::TimeoutException& ex) 
      {
        Poco::AutoPtr<Poco::Notification> pNf(queue.dequeueNotification());
        while (pNf)
        {
          WorkNotification *pWorkNf = dynamic_cast<WorkNotification *>(pNf.get());
          if (pWorkNf)
          {
            ws.sendFrame(pWorkNf->data().data(), pWorkNf->data().size());
          }
          pNf = queue.dequeueNotification();
        }
        continue;
      }
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
    ws.close();
  }
};

int main() {

  Worker ws;
  Poco::Thread tws;
  tws.start(ws);

  Ctrl wrt;
  Poco::Thread twrt;
  twrt.start(wrt);

  // Poco::Thread::sleep(20000);

  tws.join();
}
