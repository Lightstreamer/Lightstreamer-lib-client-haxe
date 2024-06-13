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
  std::string transport{"WS-STREAMING"};

  Setup(const std::string& name, const std::string& filename, int line, const std::string& param1)
    : utest::Test(name, filename, line, param1) {}

  void setup() override {
    client.connectionDetails.setServerAddress("https://localtest.me:8443");
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

TEST_FIXTURE(Setup, testTrustManager) {
  auto privateKeyFile = "../../test/localtest.me.key";
  auto certificateFile = "../../test/localtest.me.crt";
  auto caLocation = "../../test/localtest.me.crt";
  Poco::Net::Context::Ptr pContext = new Poco::Net::Context(Poco::Net::Context::TLS_CLIENT_USE, privateKeyFile, certificateFile, caLocation);
  LightstreamerClient::setTrustManagerFactory(pContext);

  listener->_onStatusChange = [this](auto& status) {
    if (status == "CONNECTED:" + transport) {
      resume();
    }
  };
  client.addListener(listener);
  client.connect();
  wait(TIMEOUT);
}

int main(int argc, char** argv) {
  LightstreamerClient::initialize([](const char* info) {
    std::cout << "UNCAUGHT HAXE EXCEPTION: " << info << "\n";
    std::cout << "TERMINATING THE PROCESS...\n";
    exit(255);
  });

  LightstreamerClient::setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel::DEBUG));
  
  for (auto& transport : { "WS-STREAMING", "HTTP-STREAMING", "HTTP-POLLING", "WS-POLLING" }) {
    runner.add(new testTrustManager(transport));
  }

  return runner.start(argc > 1 ? argv[1]: "");
}