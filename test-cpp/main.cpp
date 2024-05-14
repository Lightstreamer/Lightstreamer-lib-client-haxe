#include "../Lightstreamer.h"
#include "Lightstreamer/LightstreamerClient.h"
#include "Lightstreamer/ClientListener.h"
#include "Lightstreamer/SubscriptionListener.h"
#include "Lightstreamer/ConsoleLoggerProvider.h"
#include "Lightstreamer/ItemUpdate.h"
#include "Lightstreamer/LightstreamerError.h"
#include "utpp/utpp.h"
#include "Poco/Semaphore.h"
#include <iostream>
#include <sstream>
#include <chrono>
#include <stdexcept>
#include <cstdlib>

using Lightstreamer::LightstreamerClient;
using Lightstreamer::Subscription;
using Lightstreamer::ItemUpdate;
using Lightstreamer::LightstreamerError;

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
  std::function<void(ItemUpdate& update)> _onItemUpdate;
  void onItemUpdate(ItemUpdate& update) override {
    if (_onItemUpdate) _onItemUpdate(update);
  }
  std::function<void(void)> _onUnsubscription;
  void onUnsubscription() override {
    if (_onUnsubscription) _onUnsubscription();
  }
  std::function<void(const std::string&, int)> _onClearSnapshot;
  void onClearSnapshot(const std::string& name, int pos) override {
    if (_onClearSnapshot) _onClearSnapshot(name, pos);
  }
  std::function<void(const std::string&)> _onRealMaxFrequency;
  void onRealMaxFrequency(const std::string& freq) override {
    if (_onRealMaxFrequency) _onRealMaxFrequency(freq);
  }
  std::function<void(const std::string&, int)> _onEndOfSnapshot;
  void onEndOfSnapshot(const std::string& name, int pos) override {
    if (_onEndOfSnapshot) _onEndOfSnapshot(name, pos);
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
  void wait(long ms, int expectedResumes = 1) {
    if (expectedResumes == 1) {
      _sem.wait(ms);
    } else {
      using std::chrono::high_resolution_clock;
      using std::chrono::duration_cast;
      using std::chrono::milliseconds;

      auto t0 = high_resolution_clock::now();
      auto left = ms;
      while (expectedResumes-- > 0) {
        if (left <= 0) {
          throw std::runtime_error("Timeout");
        }
        _sem.wait(left);
        left = ms - duration_cast<milliseconds>(high_resolution_clock::now() - t0).count();
      }
    }
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

TEST_FIXTURE(Setup, testSubscriptionAccessors) {
  Subscription sub("DISTINCT", {}, {});

  EXPECT_FALSE(sub.isActive());
  EXPECT_FALSE(sub.isSubscribed());

  EXPECT_EQ("", sub.getDataAdapter());
  sub.setDataAdapter("DEMO");
  EXPECT_EQ("DEMO", sub.getDataAdapter());
  sub.setDataAdapter("");
  EXPECT_EQ("", sub.getDataAdapter());

  EXPECT_EQ("DISTINCT", sub.getMode());

  EXPECT_EQ(0, sub.getItems().size());
  sub.setItems({"i1", "i2"});
  auto items = sub.getItems();
  EXPECT_EQ(2, items.size());
  EXPECT_EQ("i1", items.at(0));
  EXPECT_EQ("i2", items.at(1));
  sub.setItems({});
  EXPECT_EQ(0, sub.getItems().size());

  EXPECT_EQ("", sub.getItemGroup());
  sub.setItemGroup("grp");
  EXPECT_EQ("grp", sub.getItemGroup());
  sub.setItemGroup("");
  EXPECT_EQ("", sub.getItemGroup());

  EXPECT_EQ(0, sub.getFields().size());
  sub.setFields({"f1", "f2"});
  auto fields = sub.getFields();
  EXPECT_EQ(2, fields.size());
  EXPECT_EQ("f1", fields.at(0));
  EXPECT_EQ("f2", fields.at(1));
  sub.setFields({});
  EXPECT_EQ(0, sub.getFields().size());

  EXPECT_EQ("", sub.getFieldSchema());
  sub.setFieldSchema("scm");
  EXPECT_EQ("scm", sub.getFieldSchema());
  sub.setFieldSchema("");
  EXPECT_EQ("", sub.getFieldSchema());

  EXPECT_EQ("", sub.getRequestedBufferSize());
  sub.setRequestedBufferSize("unlimited");
  EXPECT_EQ("unlimited", sub.getRequestedBufferSize());
  sub.setRequestedBufferSize("123");
  EXPECT_EQ("123", sub.getRequestedBufferSize());
  sub.setRequestedBufferSize("");
  EXPECT_EQ("", sub.getRequestedBufferSize());

  EXPECT_EQ("yes", sub.getRequestedSnapshot());
  sub.setRequestedSnapshot("no");
  EXPECT_EQ("no", sub.getRequestedSnapshot());
  sub.setRequestedSnapshot("yes");
  EXPECT_EQ("yes", sub.getRequestedSnapshot());
  sub.setRequestedSnapshot("123");
  EXPECT_EQ("123", sub.getRequestedSnapshot());
  sub.setRequestedSnapshot("");
  EXPECT_EQ("", sub.getRequestedSnapshot());

  EXPECT_EQ("", sub.getRequestedMaxFrequency());
  sub.setRequestedMaxFrequency("unlimited");
  EXPECT_EQ("unlimited", sub.getRequestedMaxFrequency());
  sub.setRequestedMaxFrequency("unfiltered");
  EXPECT_EQ("unfiltered", sub.getRequestedMaxFrequency());
  sub.setRequestedMaxFrequency("123.45");
  EXPECT_EQ("123.45", sub.getRequestedMaxFrequency());
  sub.setRequestedMaxFrequency("");
  EXPECT_EQ("", sub.getRequestedMaxFrequency());

  EXPECT_EQ("", sub.getSelector());
  sub.setSelector("sel");
  EXPECT_EQ("sel", sub.getSelector());
  sub.setSelector("");
  EXPECT_EQ("", sub.getSelector());
}

TEST_FIXTURE(Setup, testSubscriptionCtor) {
  // invalid mode
  EXPECT_THROW(Subscription("XYZ", {}, {}), std::runtime_error);
  // no fields
  EXPECT_THROW(Subscription("MERGE", {"i1"}, {}), std::runtime_error);
  // no items
  EXPECT_THROW(Subscription("MERGE", {}, {"f1"}), std::runtime_error);
}

TEST_FIXTURE(Setup, testSubscriptionSetterValidators) {
  Subscription sub("DISTINCT", {"i1"}, {"f1"});
  
  EXPECT_THROW(sub.setItems({""}), std::runtime_error);
  EXPECT_THROW(sub.setFields({""}), std::runtime_error);
  EXPECT_THROW(sub.setRequestedBufferSize("xyz"), std::runtime_error);
  EXPECT_THROW(sub.setRequestedSnapshot("xyz"), std::runtime_error);
  EXPECT_THROW(sub.setRequestedMaxFrequency("xyz"), std::runtime_error);
  EXPECT_THROW(sub.getCommandPosition(), std::runtime_error);
  EXPECT_THROW(sub.getKeyPosition(), std::runtime_error);
  EXPECT_THROW(sub.setCommandSecondLevelDataAdapter("xyz"), std::runtime_error);
  EXPECT_THROW(sub.setCommandSecondLevelFields({"xyz"}), std::runtime_error);
  EXPECT_THROW(sub.setCommandSecondLevelFieldSchema("xyz"), std::runtime_error);

  client.subscribe(&sub);
  // can't change the properties when the subscription is active
  EXPECT_THROW(sub.setDataAdapter("xyz"), std::runtime_error);
  EXPECT_THROW(sub.setItems({"i1"}), std::runtime_error);
  EXPECT_THROW(sub.setItemGroup("i1"), std::runtime_error);
  EXPECT_THROW(sub.setFields({"f1"}), std::runtime_error);
  EXPECT_THROW(sub.setFieldSchema("f1"), std::runtime_error);
  EXPECT_THROW(sub.setRequestedBufferSize("123"), std::runtime_error);
  EXPECT_THROW(sub.setRequestedSnapshot("123"), std::runtime_error);
  EXPECT_THROW(sub.setRequestedMaxFrequency("unfiltered"), std::runtime_error);
  EXPECT_THROW(sub.setSelector("xyz"), std::runtime_error);
}

TEST_FIXTURE(Setup, testSubscriptionAccessorsInCommandMode) {
  Subscription sub("COMMAND", {}, {});

  EXPECT_THROW(sub.getCommandPosition(), std::runtime_error);
  EXPECT_THROW(sub.getKeyPosition(), std::runtime_error);

  EXPECT_EQ("", sub.getCommandSecondLevelDataAdapter());
  sub.setCommandSecondLevelDataAdapter("DEMO2");
  EXPECT_EQ("DEMO2", sub.getCommandSecondLevelDataAdapter());
  sub.setCommandSecondLevelDataAdapter("");
  EXPECT_EQ("", sub.getCommandSecondLevelDataAdapter());

  EXPECT_EQ(0, sub.getCommandSecondLevelFields().size());
  sub.setCommandSecondLevelFields({"f1", "f2"});
  auto fields = sub.getCommandSecondLevelFields();
  EXPECT_EQ(2, fields.size());
  EXPECT_EQ("f1", fields.at(0));
  EXPECT_EQ("f2", fields.at(1));
  sub.setCommandSecondLevelFields({});
  EXPECT_EQ(0, sub.getCommandSecondLevelFields().size());

  EXPECT_EQ("", sub.getCommandSecondLevelFieldSchema());
  sub.setCommandSecondLevelFieldSchema("scm");
  EXPECT_EQ("scm", sub.getCommandSecondLevelFieldSchema());
  sub.setCommandSecondLevelFieldSchema("");
  EXPECT_EQ("", sub.getCommandSecondLevelFieldSchema());
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

TEST_FIXTURE(Setup, testSubscribeCommand2Level){
  Subscription sub("COMMAND", {"two_level_command_count"}, {"key", "command"});
  sub.setDataAdapter("TWO_LEVEL_COMMAND");
  sub.setCommandSecondLevelDataAdapter("COUNT");
	sub.setCommandSecondLevelFields({"count"});
  sub.addListener(subListener);
  subListener->_onSubscription = [this, &sub] {
    EXPECT_TRUE(sub.isSubscribed());
    EXPECT_EQ(1, sub.getKeyPosition());
    EXPECT_EQ(2, sub.getCommandPosition());
  };
  subListener->_onItemUpdate = [this](auto& update) {
    auto val = update.getValue("count");
    auto key = update.getValue("key");
    auto cmd = update.getValue("command");
    if (!val.empty() && key == "count" && cmd == "UPDATE") {
      resume();
    }
  };
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testUnsubscribe) {
  Subscription sub("MERGE", {"count"}, {"count"});
  sub.setDataAdapter("COUNT");
  sub.addListener(subListener);
  subListener->_onSubscription = [this, &sub] {
    EXPECT_TRUE(sub.isSubscribed());
    client.unsubscribe(&sub);
  };
  subListener->_onUnsubscription = [this, &sub] {
    EXPECT_FALSE(sub.isSubscribed());
		EXPECT_FALSE(sub.isActive());
    resume();
  };
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testSubscribeNonAscii) {
  Subscription sub("MERGE", {"strange:àìùòlè"}, {"value🌐-", "value&+=\r\n%"});
  sub.setDataAdapter("STRANGE_NAMES");
  sub.addListener(subListener);
  subListener->_onSubscription = [this, &sub] {
    EXPECT_TRUE(sub.isSubscribed());
    resume();
  };
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT);
}

// TODO testBandwidth

TEST_FIXTURE(Setup, testClearSnapshot) {
  Subscription sub("DISTINCT", {"clear_snapshot"}, {"dummy"});
  sub.setDataAdapter("CLEAR_SNAPSHOT");
  sub.addListener(subListener);
  subListener->_onClearSnapshot = [this, &sub] (auto& name, auto pos) {
    EXPECT_EQ("clear_snapshot", name);
		EXPECT_EQ(1, pos);
    resume();
  };
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testRoundTrip) {
  // TODO to be completed
  Subscription sub("MERGE", {"count"}, {"count"});
  sub.setDataAdapter("COUNT");
  sub.addListener(subListener);
  subListener->_onSubscription = [this, &sub] {
    resume();
  };
  subListener->_onItemUpdate = [this](auto& update) {
    client.disconnect();
    resume();
  };
  subListener->_onUnsubscription = [this, &sub] {
    resume();
  };
  subListener->_onRealMaxFrequency = [this](auto& freq) {
    EXPECT_EQ("unlimited", freq);
    resume();
  };
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT, 4);
}

TEST_FIXTURE(Setup, testEndOfSnapshot) {
  Subscription sub("DISTINCT", {"end_of_snapshot"}, {"value"});
  sub.setRequestedSnapshot("yes");
  sub.setDataAdapter("END_OF_SNAPSHOT");
  sub.addListener(subListener);
  subListener->_onEndOfSnapshot = [this](auto& name, auto pos) {
    EXPECT_EQ("end_of_snapshot", name);
    EXPECT_EQ(1, pos);
    resume();
  };
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT);
}

// TODO testOverflow

TEST_FIXTURE(Setup, testFrequency) {
  Subscription sub("MERGE", {"count"}, {"count"});
  sub.setDataAdapter("COUNT");
  sub.addListener(subListener);
  subListener->_onRealMaxFrequency = [this](auto& freq) {
    EXPECT_EQ("unlimited", freq);
    resume();
  };
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testChangeFrequency) {
  std::atomic_int cnt(0);
  Subscription sub("MERGE", {"count"}, {"count"});
  sub.setDataAdapter("COUNT");
  sub.addListener(subListener);
  subListener->_onRealMaxFrequency = [&](auto& freq) {
    switch (++cnt) {
    case 1:
      EXPECT_EQ("unlimited", freq);
      sub.setRequestedMaxFrequency("2.5");
      break;
    case 2:
      EXPECT_EQ("2.5", freq);
      sub.setRequestedMaxFrequency("unlimited");
      break;
    case 3:
      EXPECT_EQ("unlimited", freq);
      resume();
      break;
    }
  };
  sub.setRequestedMaxFrequency("unlimited");
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT);
}

// TODO testHeaders

int main(int argc, char** argv) {
  Lightstreamer_initializeHaxeThread([](const char* info) {
    std::cout << "UNCAUGHT HAXE EXCEPTION: " << info << "\n";
    std::cout << "TERMINATING THE PROCESS...\n";
    exit(255);
  });

  HaxeObject log = ConsoleLoggerProvider_new(10);
  // HaxeObject log = ConsoleLoggerProvider_new(40);
  LightstreamerClient_setLoggerProvider(log);

  if (argc > 1) {
    UnitTest::TestPattern = argv[1];
  }
  return UnitTest::RunAllTests ();
}