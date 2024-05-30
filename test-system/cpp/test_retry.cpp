#include "Lightstreamer/LightstreamerClient.h"
#include "Lightstreamer/ConsoleLoggerProvider.h"
#include "utest.h"

using utest::runner;
using Lightstreamer::LightstreamerClient;
using Lightstreamer::ConsoleLoggerProvider;
using Lightstreamer::ConsoleLogLevel;

TEST(testRetryDelay) {
  LightstreamerClient client("http://127.0.0.1:1234");
  client.connect();
  wait(300'000);
}

int main(int argc, char** argv) {
  LightstreamerClient::initialize([](const char* info) {
    std::cout << "UNCAUGHT HAXE EXCEPTION: " << info << "\n";
    std::cout << "TERMINATING THE PROCESS...\n";
    exit(255);
  });
  LightstreamerClient::setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel::WARN));

  runner.add(new testRetryDelay());
  return runner.start(argc > 1 ? argv[1]: "");
}