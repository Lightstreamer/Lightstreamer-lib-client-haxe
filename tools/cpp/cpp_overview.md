# Lightstreamer C++ Client SDK @version API Reference {#mainpage}

[TOC]

## Introduction

This C++ library enables any C++ application to communicate bidirectionally with the Lightstreamer Server. The API allows to subscribe to real-time data pushed by the server and to send any message to the server.

The library exposes a fully asynchronous API. All the API calls that require any action from the library itself are queued for processing by a dedicated thread before being carried out. The same thread is also used to carry notifications for the appropriate listeners as provided by the custom code. Blocking operations and internal housekeeping are performed on different threads.

The library offers automatic recovery from connection failures, automatic selection of the best available transport, and full decoupling of subscription and connection operations. The subscriptions are always meant as subscriptions "to the LightstreamerClient", not "to the Server"; the LightstreamerClient is responsible of forwarding the subscriptions to the Server and re-forwarding all the subscriptions whenever the connection is broken and then reopened.

The C++ library can be available depending on Edition and License Type. To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at /dashboard).

## Installing

TODO

## Quickstart

To connect to a Lightstreamer Server, a {@link Lightstreamer::LightstreamerClient}  object has to be created, configured, and instructed to connect to the Lightstreamer Server. 
A minimal version of the code that creates a LightstreamerClient and connects to the Lightstreamer Server on `%https://push.lightstreamer.com` will look like this:

```cpp
LightstreamerClient client("https://push.lightstreamer.com/","DEMO");
client.connect();
```

For each subscription to be subscribed to a Lightstreamer Server a {@link Lightstreamer::Subscription} instance is needed.
A simple Subscription containing three items and two fields to be subscribed in <i>MERGE</i> mode is easily created (see <a href="https://www.lightstreamer.com/docs/ls-server/latest/General%20Concepts.pdf">Lightstreamer General Concepts</a>):

```cpp
Subscription sub("MERGE", {"item1","item2","item3"}, {"stock_name","last_price"});
sub.setDataAdapter("QUOTE_ADAPTER");
sub.setRequestedSnapshot("yes");
client.subscribe(&sub);
```

Before sending the subscription to the server, usually at least one {@link Lightstreamer::SubscriptionListener} is attached to the Subscription instance in order to consume the real-time updates. The following code shows the values of the fields <i>stock_name</i> and <i>last_price</i> each time a new update is received for the subscription:

```cpp
class MySubscriptionListener: public SubscriptionListener {
public:
  void onItemUpdate(ItemUpdate& update) override {
    std::cout << update.getValue("stock_name") << ": " << update.getValue("last_price") << std::endl;
  }
};

sub.addListener(new MySubscriptionListener());
```

Below is the complete C++ code:

```cpp
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
  LightstreamerClient::initialize();
  LightstreamerClient::setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel::WARN));

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
```

## Logging

To enable the internal client logger, create an instance of {@link Lightstreamer::LoggerProvider} and set it as the default provider of {@link Lightstreamer::LightstreamerClient}.

```cpp
LightstreamerClient::setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel::DEBUG));
```

## Compatibility

The library is compatible with Lightstreamer Server since version 7.4.0.

## Documentation

TODO

## Support

For questions and support please use the <a href="https://forums.lightstreamer.com/">Official Forum</a>. The issue list of this page is <b>exclusively</b> for bug reports and feature requests.

## License

<a href="https://opensource.org/licenses/Apache-2.0">Apache 2.0</a>