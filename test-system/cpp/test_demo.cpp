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
#include "Lightstreamer/LightstreamerClient.h"
#include "Lightstreamer/SubscriptionListener.h"
#include "Lightstreamer/ConsoleLoggerProvider.h"
#include <iostream>

using namespace Lightstreamer;

class MySubscriptionListener: public SubscriptionListener {
public:
  void onItemUpdate(ItemUpdate& update) override {
    std::cout << update.getValue("stock_name") << ": " << update.getValue("last_price") << std::endl;
  }
};

int main() {
  LightstreamerClient::initialize([](const char* info) {
    std::cout << "UNCAUGHT EXCEPTION: " << info << "\n";
    std::cout << "TERMINATING THE PROCESS...\n";
    exit(255);
  });
  LightstreamerClient::setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel::Warn));

  LightstreamerClient client("https://push.lightstreamer.com/","DEMO");
  client.connect();

  Subscription sub("MERGE", {"item1","item2","item3"}, {"stock_name","last_price"});
  sub.setDataAdapter("QUOTE_ADAPTER");
  sub.setRequestedSnapshot("yes");
  sub.addListener(new MySubscriptionListener());
  client.subscribe(&sub);

  std::string s;
  std::cin >> s;
}