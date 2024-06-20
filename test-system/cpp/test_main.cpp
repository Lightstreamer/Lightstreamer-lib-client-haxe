#include "Lightstreamer/LightstreamerClient.h"
#include "Lightstreamer/ClientListener.h"
#include "Lightstreamer/SubscriptionListener.h"
#include "Lightstreamer/ConsoleLoggerProvider.h"
#include "Lightstreamer/ItemUpdate.h"
#include "Lightstreamer/LightstreamerError.h"
#include "Lightstreamer/ClientMessageListener.h"
#include "Lightstreamer/Proxy.h"
#include "Lightstreamer/ConsoleLoggerProvider.h"
#include "utest.h"
#include "Poco/Semaphore.h"
#include <iostream>
#include <sstream>
#include <thread>
#include <chrono>
#include <stdexcept>
#include <cstdlib>

using utest::runner;
using Lightstreamer::LightstreamerClient;
using Lightstreamer::Subscription;
using Lightstreamer::ItemUpdate;
using Lightstreamer::LightstreamerError;
using Lightstreamer::Proxy;
using Lightstreamer::ConsoleLoggerProvider;
using Lightstreamer::ConsoleLogLevel;

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
  std::function<void(const std::string&)> _onPropertyChange;
  void onPropertyChange(const std::string& prop) override {
    if (_onPropertyChange) _onPropertyChange(prop);
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
  std::function<void(const std::string&, int, int)> _onItemLostUpdates;
  void onItemLostUpdates(const std::string& name, int pos, int lost) override {
    if (_onItemLostUpdates) _onItemLostUpdates(name, pos, lost);
  }
};

class MyMessageListener: public Lightstreamer::ClientMessageListener {
public:
  std::function<void(const std::string&, bool)> _onAbort;
  void onAbort(const std::string& originalMessage, bool sentOnNetwork) {
    if (_onAbort) _onAbort(originalMessage, sentOnNetwork);
  }
  std::function<void(const std::string&, int, const std::string&)> _onDeny;
  void onDeny(const std::string& originalMessage, int code, const std::string& error) {
    if (_onDeny) _onDeny(originalMessage, code, error);
  }
  std::function<void(const std::string&)> _onDiscarded;
  void onDiscarded(const std::string& originalMessage) {
    if (_onDiscarded) _onDiscarded(originalMessage);
  }
  std::function<void(const std::string&)> _onError;
  void onError(const std::string& originalMessage) {
    if (_onError) _onError(originalMessage);
  }
  std::function<void(const std::string&, const std::string&)> _onProcessed;
  void onProcessed(const std::string& originalMessage, const std::string& response) {
    if (_onProcessed) _onProcessed(originalMessage, response);
  }
};

bool ends_with(const std::string& value, const std::string& ending)
{
  if (ending.size() > value.size()) 
    return false;
  return std::equal(ending.rbegin(), ending.rend(), value.rbegin());
}

constexpr long TIMEOUT = 3000;

struct Setup: public utest::Test {
  LightstreamerClient client;
  // TODO listener can leak if not added to client
  MyClientListener* listener{new MyClientListener()};
  MySubscriptionListener* subListener{new MySubscriptionListener()};
  std::string transport{"WS-STREAMING"};

  Setup(const std::string& name, const std::string& filename, int line, const std::string& param1)
    : utest::Test(name, filename, line, param1) {}

  void setup() override {
    client.connectionDetails.setServerAddress("http://localtest.me:8080");
    client.connectionDetails.setAdapterSet("TEST");
    if (!_param1.empty()) {
      transport = _param1;
      client.connectionOptions.setForcedTransport(transport);
      if (ends_with(transport, "POLLING")) {
			  client.connectionOptions.setIdleTimeout(0);
			  client.connectionOptions.setPollingInterval(100);
		  }
    }
  }

  void tear_down() override {
    client.removeListener(listener);
    client.disconnect();
  }
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
  listener->_onStatusChange = [this](auto& status) {
    if (status == "CONNECTED:" + transport) {
      EXPECT_EQ("CONNECTED:" + transport, client.getStatus());
      EXPECT_EQ("", client.connectionDetails.getServerInstanceAddress());
      EXPECT_EQ("Lightstreamer HTTP Server", client.connectionDetails.getServerSocketName());
      EXPECT_EQ("127.0.0.1", client.connectionDetails.getClientIp());
      EXPECT_FALSE(client.connectionDetails.getSessionId().empty());
      resume();
    }
  };
  client.addListener(listener);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testOnlineServer) {
  client.connectionDetails.setServerAddress("https://push.lightstreamer.com");
  client.connectionDetails.setAdapterSet("DEMO");
  listener->_onStatusChange = [this](auto& status) {
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
  client.connectionDetails.setAdapterSet("XXX");
  listener->_onServerError = [this](auto code, auto msg) {
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
  listener->_onStatusChange = [this](auto& status) {
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

TEST_FIXTURE(Setup, testItemUpdate) {
  std::atomic_int cnt(1);
  Subscription sub("DISTINCT", {"cpp_value"}, {"value"});
  sub.setDataAdapter("CPP_ADAPTER");
  sub.setRequestedSnapshot("yes");
  sub.setRequestedMaxFrequency("unfiltered");
  sub.addListener(subListener);
  subListener->_onItemUpdate = [&](auto& u) {
    switch (cnt++) {
    case 1:
      EXPECT_EQ("cpp_value", u.getItemName());
      EXPECT_EQ(1, u.getItemPos());
      EXPECT_EQ("", u.getValue("value"));
      EXPECT_EQ("", u.getValue(1));
      EXPECT_TRUE(u.isNull("value"));
      EXPECT_TRUE(u.isNull(1));
      EXPECT_TRUE(u.isSnapshot());
      EXPECT_TRUE(u.isValueChanged("value"));
      EXPECT_TRUE(u.isValueChanged(1));

      EXPECT_THROW(u.getValue("xyz"), std::runtime_error);
      EXPECT_THROW(u.getValue(2), std::runtime_error);

      {
        auto fs = u.getChangedFields();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("", fs.at("value"));
      }
      {
        auto fs = u.getChangedFieldsByPosition();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("", fs.at(1));
      }
      {
        auto fs = u.getFields();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("", fs.at("value"));
      }
      {
        auto fs = u.getFieldsByPosition();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("", fs.at(1));
      }
      break;
    case 2:
      EXPECT_EQ("cpp_value", u.getItemName());
      EXPECT_EQ(1, u.getItemPos());
      EXPECT_EQ("", u.getValue("value"));
      EXPECT_EQ("", u.getValue(1));
      EXPECT_FALSE(u.isNull("value"));
      EXPECT_FALSE(u.isNull(1));
      EXPECT_FALSE(u.isSnapshot());
      EXPECT_TRUE(u.isValueChanged("value"));
      EXPECT_TRUE(u.isValueChanged(1));

      {
        auto fs = u.getChangedFields();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("", fs.at("value"));
      }
      {
        auto fs = u.getChangedFieldsByPosition();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("", fs.at(1));
      }
      {
        auto fs = u.getFields();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("", fs.at("value"));
      }
      {
        auto fs = u.getFieldsByPosition();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("", fs.at(1));
      }
      break;
    case 3:
      EXPECT_EQ("cpp_value", u.getItemName());
      EXPECT_EQ(1, u.getItemPos());
      EXPECT_EQ("msg1", u.getValue("value"));
      EXPECT_EQ("msg1", u.getValue(1));
      EXPECT_FALSE(u.isNull("value"));
      EXPECT_FALSE(u.isNull(1));
      EXPECT_FALSE(u.isSnapshot());
      EXPECT_TRUE(u.isValueChanged("value"));
      EXPECT_TRUE(u.isValueChanged(1));

      {
        auto fs = u.getChangedFields();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("msg1", fs.at("value"));
      }
      {
        auto fs = u.getChangedFieldsByPosition();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("msg1", fs.at(1));
      }
      {
        auto fs = u.getFields();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("msg1", fs.at("value"));
      }
      {
        auto fs = u.getFieldsByPosition();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("msg1", fs.at(1));
      }
      break;
    case 4:
      EXPECT_EQ("cpp_value", u.getItemName());
      EXPECT_EQ(1, u.getItemPos());
      EXPECT_EQ("msg1", u.getValue("value"));
      EXPECT_EQ("msg1", u.getValue(1));
      EXPECT_FALSE(u.isNull("value"));
      EXPECT_FALSE(u.isNull(1));
      EXPECT_FALSE(u.isSnapshot());
      EXPECT_FALSE(u.isValueChanged("value"));
      EXPECT_FALSE(u.isValueChanged(1));

      {
        auto fs = u.getChangedFields();
        EXPECT_EQ(0, fs.size());
      }
      {
        auto fs = u.getChangedFieldsByPosition();
        EXPECT_EQ(0, fs.size());
      }
      {
        auto fs = u.getFields();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("msg1", fs.at("value"));
      }
      {
        auto fs = u.getFieldsByPosition();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("msg1", fs.at(1));
      }
      break;
    case 5:
      EXPECT_EQ("cpp_value", u.getItemName());
      EXPECT_EQ(1, u.getItemPos());
      EXPECT_EQ("msg2", u.getValue("value"));
      EXPECT_EQ("msg2", u.getValue(1));
      EXPECT_FALSE(u.isNull("value"));
      EXPECT_FALSE(u.isNull(1));
      EXPECT_FALSE(u.isSnapshot());
      EXPECT_TRUE(u.isValueChanged("value"));
      EXPECT_TRUE(u.isValueChanged(1));

      EXPECT_EQ("msg2", sub.getValue("cpp_value", "value"));
      EXPECT_EQ("msg2", sub.getValue(1, 1));
      EXPECT_EQ("msg2", sub.getValue("cpp_value", 1));
      EXPECT_EQ("msg2", sub.getValue(1, "value"));

      {
        auto fs = u.getChangedFields();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("msg2", fs.at("value"));
      }
      {
        auto fs = u.getChangedFieldsByPosition();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("msg2", fs.at(1));
      }
      {
        auto fs = u.getFields();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("msg2", fs.at("value"));
      }
      {
        auto fs = u.getFieldsByPosition();
        EXPECT_EQ(1, fs.size());
        EXPECT_EQ("msg2", fs.at(1));
      }

      resume();
      break;
    }
  };
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT);

  client.unsubscribe(&sub);
  sleep(500); // allow time to complete the unsubscription request and enable CPP_ADAPTER to unsubscribe from the item
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
  subListener->_onItemUpdate = [&](auto& update) { 
    auto val = update.getValue("count");
    auto key = update.getValue("key");
    auto cmd = update.getValue("command");

    if (cmd == "ADD") {
      EXPECT_EQ("ADD", sub.getCommandValue("two_level_command_count", "count", "command"));
      EXPECT_EQ("ADD", sub.getCommandValue(1, "count", 2));
      EXPECT_EQ("ADD", sub.getCommandValue("two_level_command_count", "count", 2));
      EXPECT_EQ("ADD", sub.getCommandValue(1, "count", "command"));
    }

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

TEST_FIXTURE(Setup, testBandwidth) {
  std::atomic_int cnt(0);
  listener->_onPropertyChange = [&](auto& prop) {
    if (prop == "realMaxBandwidth") {
      auto bw = client.connectionOptions.getRealMaxBandwidth();
      switch (++cnt) {
      case 1:
        // after the connection, the server sends the default bandwidth
        EXPECT_EQ("40", bw);
        // request a bandwidth equal to 20.1: the request is accepted
        client.connectionOptions.setRequestedMaxBandwidth("20.1");
        break;
      case 2:
        EXPECT_EQ("20.1", bw);
        // request a bandwidth equal to 70.1: the meta-data adapter cuts it to 40 (which is the configured limit)
        client.connectionOptions.setRequestedMaxBandwidth("70.1");
        break;
      case 3:
        EXPECT_EQ("40", bw);
        // request a bandwidth equal to 39: the request is accepted
        client.connectionOptions.setRequestedMaxBandwidth("39");
        break;
      case 4:
        EXPECT_EQ("39", bw);
        // request an unlimited bandwidth: the meta-data adapter cuts it to 40 (which is the configured limit)
        client.connectionOptions.setRequestedMaxBandwidth("unlimited");
        break;
      case 5:
        EXPECT_EQ("40", bw);
        resume();
        break;
      }
    }
  };
  client.addListener(listener);
  EXPECT_EQ("unlimited", client.connectionOptions.getRequestedMaxBandwidth());
	client.connect();
	wait(TIMEOUT);
}

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
  std::atomic_bool sessionActive(true);
  EXPECT_EQ("TEST", client.connectionDetails.getAdapterSet());
  EXPECT_EQ("http://localtest.me:8080", client.connectionDetails.getServerAddress());
  EXPECT_EQ(50000000L, client.connectionOptions.getContentLength());
  EXPECT_EQ(4000L, client.connectionOptions.getRetryDelay());
  EXPECT_EQ(15000L, client.connectionOptions.getSessionRecoveryTimeout());
  Subscription sub("MERGE", {"count"}, {"count"});
  sub.setDataAdapter("COUNT");
  EXPECT_EQ("COUNT", sub.getDataAdapter());
	EXPECT_EQ("MERGE", sub.getMode());
  sub.addListener(subListener);
  subListener->_onSubscription = [this, &sub] {
    resume();
  };
  subListener->_onItemUpdate = [&](auto& update) {
    client.disconnect();
    sessionActive = false;
    resume();
  };
  subListener->_onUnsubscription = [this, &sub] {
    resume();
  };
  subListener->_onRealMaxFrequency = [this](auto& freq) {
    EXPECT_EQ("unlimited", freq);
    resume();
  };
  listener->_onPropertyChange = [&](auto& prop) {
    if (prop == "clientIp") {
      EXPECT_EQ(sessionActive ? "127.0.0.1" : "", client.connectionDetails.getClientIp());
    } else if (prop == "serverSocketName") {
      EXPECT_EQ(sessionActive ? "Lightstreamer HTTP Server" : "", client.connectionDetails.getServerSocketName());
    } else if (prop == "sessionId") {
      if (sessionActive)
        EXPECT_FALSE(client.connectionDetails.getSessionId().empty());
      else
        EXPECT_TRUE(client.connectionDetails.getSessionId().empty());
    } else if (prop == "keepaliveInterval") {
      EXPECT_EQ(5000L, client.connectionOptions.getKeepaliveInterval());
    } else if (prop == "idleTimeout") {
      EXPECT_EQ(0L, client.connectionOptions.getIdleTimeout());
    } else if (prop == "pollingInterval") {
      EXPECT_EQ(100L, client.connectionOptions.getPollingInterval());
    } else if (prop == "realMaxBandwidth") {
      EXPECT_EQ(sessionActive ? "40" : "", client.connectionOptions.getRealMaxBandwidth());
    }
  };
  client.addListener(listener);
  client.subscribe(&sub);
  client.connect();
  wait(TIMEOUT, 4);
}

TEST_FIXTURE(Setup, testLongMessage) {
  std::string msg = "{\"n\":\"MESSAGE_SEND\",\"c\":{\"u\":\"GEiIxthxD-1gf5Tk5O1NTw\",\"s\":\"S29120e92e162c244T2004863\",\"p\":\"localhost:3000/html/widget-responsive.html\",\"t\":\"2017-08-08T10:20:05.665Z\"},\"d\":\"{\\\"p\\\":\\\"🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐🌐\\\"}\"}";
  MyMessageListener* msgListener = new MyMessageListener();
  msgListener->_onProcessed = [&](auto& _msg, auto& resp) {
    EXPECT_EQ(msg, _msg);
    resume();
  };
  client.connect();
	client.sendMessage(msg, "test_seq", -1, msgListener, false);
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testMessage) {
  client.connect();
  client.sendMessage("test message ()", "", 0, nullptr, true);
  // no outcome expected
  client.sendMessage("test message (sequence)", "test_seq", 0, nullptr, true);
	// no outcome expected
  MyMessageListener* l1 = new MyMessageListener();
  l1->_onProcessed = [&](auto& msg, auto& resp) {
    EXPECT_EQ("onProcessed test message (listener)", "onProcessed " + msg);
		resume();
  };
  client.sendMessage("test message (listener)", "", -1, l1, true);
  MyMessageListener* l2 = new MyMessageListener();
  l2->_onProcessed = [&](auto& msg, auto& resp) {
    EXPECT_EQ("onProcessed test message (sequence+listener)", "onProcessed " + msg);
		resume();
  };
  client.sendMessage("test message (sequence+listener)", "test_seq", -1, l2, true);
  wait(TIMEOUT, 2);
}

TEST_FIXTURE(Setup, testMessageWithReturnValue) {
  MyMessageListener* msgListener = new MyMessageListener();
  msgListener->_onProcessed = [&](auto& msg, auto& resp) {
    EXPECT_EQ("give me a result", msg);
    EXPECT_EQ("result:ok", resp);
    resume();
  };
  client.connect();
	client.sendMessage("give me a result", "", -1, msgListener, false);
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testMessageWithSpecialChars) {
  MyMessageListener* msgListener = new MyMessageListener();
  msgListener->_onProcessed = [&](auto& msg, auto& resp) {
    EXPECT_EQ("hello +&=%\r\n", msg);
    resume();
  };
  client.connect();
	client.sendMessage("hello +&=%\r\n", "", -1, msgListener, false);
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testUnorderedMessage) {
  MyMessageListener* msgListener = new MyMessageListener();
  msgListener->_onProcessed = [&](auto& msg, auto& resp) {
    EXPECT_EQ("test message", msg);
    resume();
  };
  client.connect();
	client.sendMessage("test message", "UNORDERED_MESSAGES", -1, msgListener, false);
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testMessageDeny) {
  MyMessageListener* msgListener= new MyMessageListener();
  msgListener->_onDeny = [&](auto& msg, auto code, auto& error) {
    EXPECT_EQ("throw me an error", msg);
    EXPECT_EQ(-123, code);
    EXPECT_EQ("test error", error);
    resume();
  };
  client.connect();
	client.sendMessage("throw me an error", "test_seq", -1, msgListener, false);
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testMessageError) {
  MyMessageListener* msgListener = new MyMessageListener();
  msgListener->_onError = [&](auto& msg) {
    EXPECT_EQ("throw me a NPE", msg);
    resume();
  };
  client.connect();
	client.sendMessage("throw me a NPE", "test_seq", -1, msgListener, false);
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testMessageAbort) {
  MyMessageListener* msgListener = new MyMessageListener();
  msgListener->_onAbort = [&](auto& msg, auto sent) {
    EXPECT_EQ("test abort", msg);
    EXPECT_FALSE(sent);
    resume();
  };
	client.sendMessage("test abort", "", -1, msgListener, false);
  wait(TIMEOUT);
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

TEST_FIXTURE(Setup, testOverflow) {
  Subscription sub("MERGE", {"overflow"}, {"value"});
  sub.setRequestedSnapshot("yes");
	sub.setDataAdapter("OVERFLOW");
  sub.setRequestedMaxFrequency("unfiltered");
  sub.addListener(subListener);
  subListener->_onItemLostUpdates = [&](auto& name, auto pos, auto lost) {
    EXPECT_EQ("overflow", name);
	  EXPECT_EQ(1, pos);
	  client.unsubscribe(&sub);
  };
  subListener->_onUnsubscription = [&] {
    resume();
  };
  client.subscribe(&sub);
	// NB the bandwidth must not be too low otherwise the server can't write the response
  client.connectionOptions.setRequestedMaxBandwidth("10");
  client.connect();
  wait(TIMEOUT);
}

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

TEST_FIXTURE(Setup, testHeaders) {
  client.connectionOptions.setHttpExtraHeaders({{"X-Header", "header"}});
  listener->_onStatusChange = [this](auto& status) {
    if (status == "CONNECTED:" + transport) {
      resume();
    }
  };
  client.addListener(listener);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testConnectionOptions) {
  client.connectionOptions.setContentLength(123456);
  EXPECT_EQ(123456, client.connectionOptions.getContentLength());

  client.connectionOptions.setFirstRetryMaxDelay(123456);
  EXPECT_EQ(123456, client.connectionOptions.getFirstRetryMaxDelay());

  client.connectionOptions.setForcedTransport("WS");
  EXPECT_EQ("WS", client.connectionOptions.getForcedTransport());
  client.connectionOptions.setForcedTransport("");
  EXPECT_EQ("", client.connectionOptions.getForcedTransport());
  EXPECT_THROW(client.connectionOptions.setForcedTransport("xyz"), std::runtime_error);

  auto hs = client.connectionOptions.getHttpExtraHeaders();
  EXPECT_EQ(0, hs.size());
  client.connectionOptions.setHttpExtraHeaders({{"h1", "v1"}, {"h2", "v2"}});
  hs = client.connectionOptions.getHttpExtraHeaders();
  EXPECT_EQ(2, hs.size());
  EXPECT_EQ("v1", hs.at("h1"));
  EXPECT_EQ("v2", hs.at("h2"));

  client.connectionOptions.setIdleTimeout(123456);
  EXPECT_EQ(123456, client.connectionOptions.getIdleTimeout());

  client.connectionOptions.setKeepaliveInterval(123456);
  EXPECT_EQ(123456, client.connectionOptions.getKeepaliveInterval());

  client.connectionOptions.setRequestedMaxBandwidth("123.456");
  EXPECT_EQ("123.456", client.connectionOptions.getRequestedMaxBandwidth());
  client.connectionOptions.setRequestedMaxBandwidth("unlimited");
  EXPECT_EQ("unlimited", client.connectionOptions.getRequestedMaxBandwidth());
  EXPECT_THROW(client.connectionOptions.setRequestedMaxBandwidth(""), std::runtime_error);

  EXPECT_EQ("", client.connectionOptions.getRealMaxBandwidth());

  client.connectionOptions.setPollingInterval(123456);
  EXPECT_EQ(123456, client.connectionOptions.getPollingInterval());

  client.connectionOptions.setReconnectTimeout(123456);
  EXPECT_EQ(123456, client.connectionOptions.getReconnectTimeout());

  client.connectionOptions.setRetryDelay(123456);
  EXPECT_EQ(123456, client.connectionOptions.getRetryDelay());

  client.connectionOptions.setReverseHeartbeatInterval(123456);
  EXPECT_EQ(123456, client.connectionOptions.getReverseHeartbeatInterval());

  client.connectionOptions.setStalledTimeout(123456);
  EXPECT_EQ(123456, client.connectionOptions.getStalledTimeout());

  client.connectionOptions.setSessionRecoveryTimeout(123456);
  EXPECT_EQ(123456, client.connectionOptions.getSessionRecoveryTimeout());

  client.connectionOptions.setHttpExtraHeadersOnSessionCreationOnly(true);
  EXPECT_EQ(true, client.connectionOptions.isHttpExtraHeadersOnSessionCreationOnly());

  client.connectionOptions.setServerInstanceAddressIgnored(true);
  EXPECT_EQ(true, client.connectionOptions.isServerInstanceAddressIgnored());

  client.connectionOptions.setSlowingEnabled(true);
  EXPECT_EQ(true, client.connectionOptions.isSlowingEnabled());

  client.connectionOptions.setProxy(Proxy("HTTP", "http://proxy.com", 8090, "usr", "pwd"));
  // an empty host results in the proxy being removed
  client.connectionOptions.setProxy(Proxy("HTTP", "", 0));
  // invalid proxy type
  EXPECT_THROW(client.connectionOptions.setProxy(Proxy("ftp", "http://proxy.com", 8090)), std::runtime_error);
}

TEST_FIXTURE(Setup, testConnectionDetails) {
  EXPECT_EQ("TEST", client.connectionDetails.getAdapterSet());
  client.connectionDetails.setAdapterSet("AS");
  EXPECT_EQ("AS", client.connectionDetails.getAdapterSet());
  client.connectionDetails.setAdapterSet("");
  EXPECT_EQ("", client.connectionDetails.getAdapterSet());

  EXPECT_EQ("http://localtest.me:8080", client.connectionDetails.getServerAddress());
  client.connectionDetails.setServerAddress("https://example.com");
  EXPECT_EQ("https://example.com", client.connectionDetails.getServerAddress());
  client.connectionDetails.setServerAddress("");
  EXPECT_EQ("", client.connectionDetails.getServerAddress());
  EXPECT_THROW(client.connectionDetails.setServerAddress(",,,"), std::runtime_error);

  EXPECT_EQ("", client.connectionDetails.getUser());
  client.connectionDetails.setUser("usr");
  EXPECT_EQ("usr", client.connectionDetails.getUser());
  client.connectionDetails.setUser("");
  EXPECT_EQ("", client.connectionDetails.getUser());

  client.connectionDetails.setPassword("pwd");

  EXPECT_EQ("", client.connectionDetails.getServerInstanceAddress());
  EXPECT_EQ("", client.connectionDetails.getServerSocketName());
  EXPECT_EQ("", client.connectionDetails.getClientIp());
  EXPECT_EQ("", client.connectionDetails.getSessionId());
}

TEST_FIXTURE(Setup, testProxy) {
  client.connectionDetails.setServerAddress("http://localtest.me:8080");
  client.connectionOptions.setProxy(Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword"));

  listener->_onStatusChange = [this](auto& status) {
    if (status == "CONNECTED:" + transport) {
      resume();
    }
  };
  client.addListener(listener);
  client.connect();
  wait(TIMEOUT);
}

TEST_FIXTURE(Setup, testCookies) {
  LightstreamerClient_clearAllCookies();

  Poco::URI host("http://localtest.me:8080");
  client.connectionDetails.setServerAddress(host.toString());
  EXPECT_EQ(0, LightstreamerClient::getCookies(host).size());

  Poco::Net::HTTPCookie cookie("X-Client", "client");
  std::vector<Poco::Net::HTTPCookie> _cookies{cookie};
  LightstreamerClient::addCookies(host, _cookies);

  listener->_onStatusChange = [this](auto& status) {
    if (status == "CONNECTED:" + transport) {
      resume();
    }
  };
  client.addListener(listener);
  client.connect();
  wait(TIMEOUT);

  auto cookies = LightstreamerClient::getCookies(host);
  EXPECT_EQ(2, cookies.size());
  EXPECT_EQ("X-Client=client; domain=localtest.me; path=/", cookies.at(0).toString());
  EXPECT_EQ("X-Server=server; domain=localtest.me; path=/", cookies.at(1).toString());
}

TEST(testLogger) {
  {
    ConsoleLoggerProvider provider(ConsoleLogLevel::Trace);
    auto log = provider.getLogger("foo");
    EXPECT_EQ(log, provider.getLogger("foo"));
    EXPECT_NE(log, provider.getLogger("bar"));
  }
  {
    ConsoleLoggerProvider provider(ConsoleLogLevel::Trace);
    auto log = provider.getLogger("foo");
    EXPECT_TRUE(log->isTraceEnabled());
    EXPECT_TRUE(log->isDebugEnabled());
    EXPECT_TRUE(log->isInfoEnabled());
    EXPECT_TRUE(log->isWarnEnabled());
    EXPECT_TRUE(log->isErrorEnabled());
    EXPECT_TRUE(log->isFatalEnabled());
  }
  {
    ConsoleLoggerProvider provider(ConsoleLogLevel::Debug);
    auto log = provider.getLogger("foo");
    EXPECT_FALSE(log->isTraceEnabled());
    EXPECT_TRUE(log->isDebugEnabled());
    EXPECT_TRUE(log->isInfoEnabled());
    EXPECT_TRUE(log->isWarnEnabled());
    EXPECT_TRUE(log->isErrorEnabled());
    EXPECT_TRUE(log->isFatalEnabled());
  }
  {
    ConsoleLoggerProvider provider(ConsoleLogLevel::Info);
    auto log = provider.getLogger("foo");
    EXPECT_FALSE(log->isTraceEnabled());
    EXPECT_FALSE(log->isDebugEnabled());
    EXPECT_TRUE(log->isInfoEnabled());
    EXPECT_TRUE(log->isWarnEnabled());
    EXPECT_TRUE(log->isErrorEnabled());
    EXPECT_TRUE(log->isFatalEnabled());
  }
  {
    ConsoleLoggerProvider provider(ConsoleLogLevel::Warn);
    auto log = provider.getLogger("foo");
    EXPECT_FALSE(log->isTraceEnabled());
    EXPECT_FALSE(log->isDebugEnabled());
    EXPECT_FALSE(log->isInfoEnabled());
    EXPECT_TRUE(log->isWarnEnabled());
    EXPECT_TRUE(log->isErrorEnabled());
    EXPECT_TRUE(log->isFatalEnabled());
  }
  {
    ConsoleLoggerProvider provider(ConsoleLogLevel::Error);
    auto log = provider.getLogger("foo");
    EXPECT_FALSE(log->isTraceEnabled());
    EXPECT_FALSE(log->isDebugEnabled());
    EXPECT_FALSE(log->isInfoEnabled());
    EXPECT_FALSE(log->isWarnEnabled());
    EXPECT_TRUE(log->isErrorEnabled());
    EXPECT_TRUE(log->isFatalEnabled());
  }
  {
    ConsoleLoggerProvider provider(ConsoleLogLevel::Fatal);
    auto log = provider.getLogger("foo");
    EXPECT_FALSE(log->isTraceEnabled());
    EXPECT_FALSE(log->isDebugEnabled());
    EXPECT_FALSE(log->isInfoEnabled());
    EXPECT_FALSE(log->isWarnEnabled());
    EXPECT_FALSE(log->isErrorEnabled());
    EXPECT_TRUE(log->isFatalEnabled());
  }
}

ConsoleLoggerProvider* g_loggerProvider;

TEST(testSetLoggerProvider) {
  LightstreamerClient client;
  client.connectionDetails.setUser("you see me");
  LightstreamerClient::setLoggerProvider(nullptr);
  client.connectionDetails.setUser("you don't see me");
  LightstreamerClient::setLoggerProvider(g_loggerProvider);
  client.connectionDetails.setUser("you see me again");
}

struct GCClientListener: public Lightstreamer::ClientListener {
  std::shared_ptr<std::atomic_int> cnt;
  GCClientListener(std::shared_ptr<std::atomic_int> cnt) : cnt(cnt) {}
  ~GCClientListener() {
    (*cnt)++;
  }
};

struct GCSubListener: public Lightstreamer::SubscriptionListener {
  std::shared_ptr<std::atomic_int> cnt;
  GCSubListener(std::shared_ptr<std::atomic_int> cnt) : cnt(cnt) {}
  ~GCSubListener() {
    (*cnt)++;
  }
};

struct GCMsgListener: public Lightstreamer::ClientMessageListener {
  std::shared_ptr<std::atomic_int> cnt;
  GCMsgListener(std::shared_ptr<std::atomic_int> cnt) : cnt(cnt) {}
  ~GCMsgListener() {
    (*cnt)++;
  }
};

TEST(testGC_removeListeners) {
  std::shared_ptr<std::atomic_int> nCltLs = std::make_shared<std::atomic_int>(0);
  std::shared_ptr<std::atomic_int> nSubLs = std::make_shared<std::atomic_int>(0);
  std::shared_ptr<std::atomic_int> nMsgLs = std::make_shared<std::atomic_int>(0);

  LightstreamerClient client;
  Subscription sub("RAW", {}, {});
  for (int i = 0; i < 100; i++) {
    auto cl = new GCClientListener(nCltLs);
    client.addListener(cl);
    client.removeListener(cl);

    auto sl = new GCSubListener(nSubLs);
    sub.addListener(sl);
    sub.removeListener(sl);

    client.sendMessage("test", "seq", -1, new GCMsgListener(nMsgLs));
  }
  
  LightstreamerClient_GC();
  EXPECT_TRUE(*nCltLs > 50);
  EXPECT_TRUE(*nSubLs > 50);
  EXPECT_TRUE(*nMsgLs > 50);
}

TEST(testGC_destructors) {
  std::shared_ptr<std::atomic_int> nCltLs = std::make_shared<std::atomic_int>(0);
  std::shared_ptr<std::atomic_int> nSubLs = std::make_shared<std::atomic_int>(0);
  std::shared_ptr<std::atomic_int> nMsgLs = std::make_shared<std::atomic_int>(0);

  {
    LightstreamerClient client;
    Subscription sub("RAW", {}, {});
    for (int i = 0; i < 100; i++) {
      auto cl = new GCClientListener(nCltLs);
      client.addListener(cl);

      auto sl = new GCSubListener(nSubLs);
      sub.addListener(sl);

      client.sendMessage("test", "seq", -1, new GCMsgListener(nMsgLs), true);
    }
  }

  LightstreamerClient_GC();
  EXPECT_TRUE(*nCltLs > 50);
  EXPECT_TRUE(*nSubLs > 50);
  EXPECT_TRUE(*nMsgLs > 50);
}

int main(int argc, char** argv) {
  LightstreamerClient::initialize([](const char* info) {
    std::cout << "UNCAUGHT HAXE EXCEPTION: " << info << "\n";
    std::cout << "TERMINATING THE PROCESS...\n";
    exit(255);
  });

  g_loggerProvider = new ConsoleLoggerProvider(ConsoleLogLevel::Debug);
  LightstreamerClient::setLoggerProvider(g_loggerProvider);
  
  runner.add(new testGC_removeListeners());
  runner.add(new testGC_destructors());
  runner.add(new testLibName());
  runner.add(new testListeners());
  runner.add(new testGetSubscriptions());
  runner.add(new testSubscriptionListeners());
  runner.add(new testSubscriptionCtor());
  runner.add(new testSubscriptionAccessors());
  runner.add(new testSubscriptionAccessorsInCommandMode());
  runner.add(new testSubscriptionSetterValidators());
  runner.add(new testConnectionOptions());
  runner.add(new testConnectionDetails());
  runner.add(new testLogger());
  runner.add(new testSetLoggerProvider());

  for (auto& transport : { "WS-STREAMING", "HTTP-STREAMING", "HTTP-POLLING", "WS-POLLING" }) {
    runner.add(new testConnect(transport));
    runner.add(new testOnlineServer(transport));
    runner.add(new testError(transport));
    runner.add(new testDisconnect(transport));
    runner.add(new testSubscribe(transport));
    runner.add(new testItemUpdate(transport));
    runner.add(new testSubscriptionError(transport));
    runner.add(new testSubscribeCommand(transport));
    runner.add(new testSubscribeCommand2Level(transport));
    runner.add(new testUnsubscribe(transport));
    runner.add(new testSubscribeNonAscii(transport));
    runner.add(new testBandwidth(transport));
    runner.add(new testClearSnapshot(transport));
    runner.add(new testRoundTrip(transport));
    runner.add(new testLongMessage(transport));
    runner.add(new testMessage(transport));
    runner.add(new testMessageWithReturnValue(transport));
    runner.add(new testMessageWithSpecialChars(transport));
    runner.add(new testUnorderedMessage(transport));
    runner.add(new testMessageDeny(transport));
    runner.add(new testMessageError(transport));
    runner.add(new testMessageAbort(transport));
    runner.add(new testEndOfSnapshot(transport));
    runner.add(new testOverflow(transport));
    runner.add(new testFrequency(transport));
    runner.add(new testChangeFrequency(transport));
    runner.add(new testHeaders(transport));
    runner.add(new testProxy(transport));
    runner.add(new testCookies(transport));
  }

  return runner.start(argc > 1 ? argv[1]: "");
}