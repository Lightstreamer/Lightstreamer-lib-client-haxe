// ***** INSTRUCTIONS *****
// Issue the command `haxe --run DumbServer` before launching this test.

#include "Lightstreamer/LightstreamerClient.h"
#include "Lightstreamer/ClientListener.h"
#include "Lightstreamer/ConsoleLoggerProvider.h"
#include "utest.h"

#include <ctime>
#include <iomanip>
#include <iostream>
#include <sstream>

using utest::runner;
using Lightstreamer::LightstreamerClient;
using Lightstreamer::ConsoleLoggerProvider;
using Lightstreamer::ConsoleLogLevel;

class MyClientListener: public Lightstreamer::ClientListener {
public:
  void onStatusChange(const std::string& status) override {
    std::time_t t = std::time(nullptr);
    std::cout << std::put_time(std::localtime(&t), "%T") << " " << status << std::endl;
  }
};

TEST(testRetryDelay) {
  LightstreamerClient client("http://127.0.0.1:1234");
  client.addListener(new MyClientListener());
  client.connect();
  wait(300'000);
}

int main(int argc, char** argv) {
  LightstreamerClient::initialize([](const char* info) {
    std::cout << "UNCAUGHT HAXE EXCEPTION: " << info << "\n";
    std::cout << "TERMINATING THE PROCESS...\n";
    exit(255);
  });
  // LightstreamerClient::setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel::Warn));

  runner.add(new testRetryDelay());
  return runner.start(argc > 1 ? argv[1]: "");
}