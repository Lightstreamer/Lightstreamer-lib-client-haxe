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