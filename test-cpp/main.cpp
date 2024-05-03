#include "../Lightstreamer.h"
#include "Lightstreamer/LightstreamerClient.h"
#include "utpp/utpp.h"
#include "Poco/Semaphore.h"
#include <iostream>

using Lightstreamer::LightstreamerClient;

class MyClientListener: public Lightstreamer::ClientListener {
public:
  std::function<void(const std::string&)> _onStatusChange;
  void onStatusChange(const std::string& status) {
    if (_onStatusChange) _onStatusChange(status);
  }
  std::function<void(int, const std::string&)> _onServerError;
  void onServerError(int code, const std::string& msg) {
    if (_onServerError) _onServerError(code, msg);
  }
};

struct Setup {
  Setup() : 
    client("http://127.0.0.1:8080", "TEST"), 
    listener(new MyClientListener()),
    _sem(0, 1) 
  {}
  ~Setup() {
    client.removeListener(listener);
    client.disconnect();
  }
  void resume() {
    _sem.set();
  }
  void wait(long ms) {
    _sem.wait(ms);
  }
  std::string transport = "WS-STREAMING";
  Poco::Semaphore _sem;
  LightstreamerClient client;
  // TODO listener can leak if not added to client
  MyClientListener* listener;
  static const long TIMEOUT = 3000;
};

TEST(testLibName) {
  CHECK_EQUAL("cpp_client", LightstreamerClient::libName());
  CHECK(!LightstreamerClient::libVersion().empty());
}

TEST_FIXTURE(Setup, testListeners) {
  CHECK_EQUAL(0, client.getListeners().size());
  client.addListener(listener);
  CHECK_EQUAL(1, client.getListeners().size());

  // adding the same listener again has no effect
  client.addListener(listener);
  CHECK_EQUAL(1, client.getListeners().size());

  auto l2 = new MyClientListener();
  client.addListener(l2);
  CHECK_EQUAL(2, client.getListeners().size());

  auto ls = client.getListeners();
  CHECK_EQUAL(2, ls.size());
  CHECK_EQUAL(listener, ls.at(0));
  CHECK_EQUAL(l2, ls.at(1));

  client.removeListener(l2);
  ls = client.getListeners();
  CHECK_EQUAL(1, ls.size());
  CHECK_EQUAL(listener, ls.at(0));

  MyClientListener l3;
  client.removeListener(&l3);
  ls = client.getListeners();
  CHECK_EQUAL(1, ls.size());
  CHECK_EQUAL(listener, ls.at(0));
}

TEST_FIXTURE(Setup, testConnect) {
  listener->_onStatusChange = [this](auto status) {
    if (status == "CONNECTED:" + transport) {
      CHECK_EQUAL("CONNECTED:" + transport, client.getStatus());
      resume();
    }
  };
  client.addListener(listener);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testOnlineServer) {
  // TODO listener leaks (use setServerAddress/setAdapterSet on fixture's client)
  LightstreamerClient client = LightstreamerClient("https://push.lightstreamer.com", "DEMO");
  listener->_onStatusChange = [this, &client](auto status) {
    if (status == "CONNECTED:" + transport) {
      CHECK_EQUAL("CONNECTED:" + transport, client.getStatus());
      resume();
    }
  };
  client.addListener(listener);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testError) {
  // TODO listener leaks (use setAdapterSet on fixture's client)
  LightstreamerClient client = LightstreamerClient("http://127.0.0.1:8080", "XXX");
  listener->_onServerError = [this, &client](auto code, auto msg) {
    std::stringstream ss;
    ss << code << " " << msg;
    CHECK_EQUAL("2 Requested Adapter Set not available", ss.str());
		resume();
  };
  client.addListener(listener);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testDisconnect) {
  listener->_onStatusChange = [this](auto status) {
    if (status == "CONNECTED:" + transport) {
			client.disconnect();
		} else if (status == "DISCONNECTED") {
			CHECK_EQUAL("DISCONNECTED", client.getStatus());
			resume();
		}
  };
  client.addListener(listener);
  client.connect();
  wait(TIMEOUT);
}

int main() {
  Lightstreamer_initializeHaxeThread([](const char* info) {
    std::cerr << "Haxe exception: " << info << "\n";
	  Lightstreamer_stopHaxeThreadIfRunning(false);
  });

  HaxeObject log = ConsoleLoggerProvider_new(10);
  // HaxeObject log = ConsoleLoggerProvider_new(40);
  LightstreamerClient_setLoggerProvider(log);

  return UnitTest::RunAllTests ();
}