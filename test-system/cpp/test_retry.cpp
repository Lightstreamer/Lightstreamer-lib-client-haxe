/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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