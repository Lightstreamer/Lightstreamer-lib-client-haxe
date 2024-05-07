#include "../Lightstreamer.h"
#include "Lightstreamer/LightstreamerClient.h"
#include "Lightstreamer/ClientListener.h"
#include "Lightstreamer/SubscriptionListener.h"
#include "Lightstreamer/ConsoleLoggerProvider.h"
#include "utpp/utpp.h"
#include "Poco/Semaphore.h"
#include <iostream>
#include <sstream>

using Lightstreamer::LightstreamerClient;
using Lightstreamer::Subscription;

class MyClientListener: public Lightstreamer::ClientListener {
public:
  std::function<void(const std::string&)> _onStatusChange;
  void onStatusChange(const std::string& status) override {
    if (_onStatusChange) _onStatusChange(status);
  }
  std::function<void(int, const std::string&)> _onServerError;
  void onServerError(int code, const std::string& msg) override {
    if (_onServerError) _onServerError(code, msg);
  }
};

class MySubscriptionListener: public Lightstreamer::SubscriptionListener {
public:
  std::function<void(void)> _onSubscription;
  void onSubscription() override {
    if (_onSubscription) _onSubscription();
  }
  std::function<void(int code, const std::string& msg)> _onSubscriptionError;
  void onSubscriptionError(int code, const std::string& msg) override {
    if (_onSubscriptionError) _onSubscriptionError(code, msg);
  }
};

struct Setup {
  Setup() : 
    client("http://127.0.0.1:8080", "TEST"), 
    listener(new MyClientListener()),
    subListener(new MySubscriptionListener()),
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
  MySubscriptionListener* subListener;
  static const long TIMEOUT = 3000;
};

TEST(testLibName) {
  EXPECT_EQ("cpp_client", LightstreamerClient::libName());
  EXPECT_FALSE(LightstreamerClient::libVersion().empty());
}

TEST_FIXTURE(Setup, testListeners) {
  EXPECT_EQ(0, client.getListeners().size());
  client.addListener(listener);
  EXPECT_EQ(1, client.getListeners().size());

  // adding the same listener again has no effect
  client.addListener(listener);
  EXPECT_EQ(1, client.getListeners().size());

  auto l2 = new MyClientListener();
  client.addListener(l2);
  EXPECT_EQ(2, client.getListeners().size());

  auto ls = client.getListeners();
  EXPECT_EQ(2, ls.size());
  EXPECT_EQ(listener, ls.at(0));
  EXPECT_EQ(l2, ls.at(1));

  client.removeListener(l2);
  ls = client.getListeners();
  EXPECT_EQ(1, ls.size());
  EXPECT_EQ(listener, ls.at(0));

  MyClientListener l3;
  client.removeListener(&l3);
  ls = client.getListeners();
  EXPECT_EQ(1, ls.size());
  EXPECT_EQ(listener, ls.at(0));
}

TEST_FIXTURE(Setup, testConnect) {
  listener->_onStatusChange = [this](auto status) {
    if (status == "CONNECTED:" + transport) {
      EXPECT_EQ("CONNECTED:" + transport, client.getStatus());
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
      EXPECT_EQ("CONNECTED:" + transport, client.getStatus());
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
    EXPECT_EQ("2 Requested Adapter Set not available", ss.str());
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
			EXPECT_EQ("DISCONNECTED", client.getStatus());
			resume();
		}
  };
  client.addListener(listener);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testGetSubscriptions) {
  auto xs = client.getSubscriptions();
  EXPECT_EQ(0, xs.size());

  Subscription sub("MERGE", {"count"}, {"count"});
  client.subscribe(&sub);
  xs = client.getSubscriptions();
  EXPECT_EQ(1, xs.size());
  EXPECT_EQ(&sub, xs.at(0));

  Subscription sub2("MERGE", {"count"}, {"count"});
  EXPECT_NE(&sub2, xs.at(0));

  client.subscribe(&sub2);
  xs = client.getSubscriptions();
  EXPECT_EQ(2, xs.size());
  EXPECT_EQ(&sub, xs.at(0));
  EXPECT_EQ(&sub2, xs.at(1));

  client.unsubscribe(&sub);
  xs = client.getSubscriptions();
  EXPECT_EQ(1, xs.size());
  EXPECT_NE(&sub, xs.at(0));
  EXPECT_EQ(&sub2, xs.at(0));

  client.unsubscribe(&sub2);
  xs = client.getSubscriptions();
  EXPECT_EQ(0, xs.size());
}

TEST_FIXTURE(Setup, testSubscriptionListeners) {
  Subscription sub("MERGE", {"count"}, {"count"});

  EXPECT_EQ(0, sub.getListeners().size());
  sub.addListener(subListener);
  EXPECT_EQ(1, sub.getListeners().size());

  // adding the same listener again has no effect
  sub.addListener(subListener);
  EXPECT_EQ(1, sub.getListeners().size());

  auto l2 = new MySubscriptionListener();
  sub.addListener(l2);
  EXPECT_EQ(2, sub.getListeners().size());

  auto ls = sub.getListeners();
  EXPECT_EQ(2, ls.size());
  EXPECT_EQ(subListener, ls.at(0));
  EXPECT_EQ(l2, ls.at(1));

  sub.removeListener(l2);
  ls = sub.getListeners();
  EXPECT_EQ(1, ls.size());
  EXPECT_EQ(subListener, ls.at(0));

  MySubscriptionListener l3;
  sub.removeListener(&l3);
  ls = sub.getListeners();
  EXPECT_EQ(1, ls.size());
  EXPECT_EQ(subListener, ls.at(0));
}

TEST_FIXTURE(Setup, testSubscribe) {
  Subscription sub("MERGE", {"count"}, {"count"});
  sub.setDataAdapter("COUNT");
  sub.addListener(subListener);
  subListener->_onSubscription = [this, &sub] {
    EXPECT_TRUE(sub.isSubscribed());
    resume();
  };
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testSubscriptionError) {
  Subscription sub("RAW", {"count"}, {"count"});
  sub.setDataAdapter("COUNT");
  sub.addListener(subListener);
  subListener->_onSubscriptionError = [this, &sub](auto code, auto msg) {
    std::stringstream ss;
    ss << code << " " << msg;
    EXPECT_EQ("24 Invalid mode for these items", ss.str());
    resume();
  };
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testSubscribeCommand){
  Subscription sub("COMMAND", {"mult_table"}, {"key", "value1", "value2", "command"});
  sub.setDataAdapter("MULT_TABLE");
  sub.addListener(subListener);
  subListener->_onSubscription = [this, &sub] {
    EXPECT_TRUE(sub.isSubscribed());
    EXPECT_EQ(1, sub.getKeyPosition());
    EXPECT_EQ(4, sub.getCommandPosition());
    resume();
  };
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT);
}

int main(int argc, char** argv) {
  Lightstreamer_initializeHaxeThread([](const char* info) {
    std::cerr << "Haxe exception: " << info << "\n";
	  Lightstreamer_stopHaxeThreadIfRunning(false);
  });

  HaxeObject log = ConsoleLoggerProvider_new(10);
  // HaxeObject log = ConsoleLoggerProvider_new(40);
  LightstreamerClient_setLoggerProvider(log);

  if (argc > 1) {
    UnitTest::TestPattern = argv[1];
  }
  return UnitTest::RunAllTests ();
}