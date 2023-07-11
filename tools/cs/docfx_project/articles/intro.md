# Lightstreamer .NET Standard Client [!include[version](~/version.md)]

Lightstreamer Client SDK enables any .NET application to communicate bidirectionally with a **Lightstreamer Server**. The API allows to subscribe to real-time data pushed by the server and to send any message to the server.

The library offers automatic recovery from connection failures, automatic selection of the best available transport, and full decoupling of subscription and connection operations. It is responsible of forwarding the subscriptions to the Server and re-forwarding all the subscriptions whenever the connection is broken and then reopened.

## Installing

You can get the library from [nuget](https://www.nuget.org/packages/Lightstreamer.DotNetStandard.Client).

## Quickstart

To connect to a Lightstreamer Server, a [LightstreamerClient](xref:com.lightstreamer.client.LightstreamerClient) object has to be created, configured, and instructed to connect to the Lightstreamer Server. 
A minimal version of the code that creates a LightstreamerClient and connects to the Lightstreamer Server on *https://push.lightstreamer.com* will look like this:

```
LightstreamerClient client = new LightstreamerClient("https://push.lightstreamer.com/","DEMO");
client.connect();
```

For each subscription to be subscribed to a Lightstreamer Server a [Subscription](xref:com.lightstreamer.client.Subscription) instance is needed.
A simple Subscription containing three items and two fields to be subscribed in *MERGE* mode is easily created (see [Lightstreamer General Concepts](https://lightstreamer.com/docs/ls-server/latest/General%20Concepts.pdf)):

```
Subscription sub = new Subscription("MERGE",new string[] {"item1","item2","item3"},new string[] {"stock_name","last_price"});
sub.DataAdapter = "QUOTE_ADAPTER";
sub.RequestedSnapshot = "yes";
client.subscribe(sub);
```

Before sending the subscription to the server, usually at least one [SubscriptionListener](xref:com.lightstreamer.client.SubscriptionListener) is attached to the Subscription instance in order to consume the real-time updates. The following code shows the values of the fields *stock_name* and *last_price* each time a new update is received for the subscription:

```
sub.addListener(new QuoteListener());

class QuoteListener : SubscriptionListener
{
  void SubscriptionListener.onItemUpdate(ItemUpdate itemUpdate)
  {
      Console.WriteLine(itemUpdate.getValue("stock_name") + " " + itemUpdate.getValue("last_price"));
  }
  // other methods
}
```

Below is the complete code:

```
using System;
using com.lightstreamer.client;
using com.lightstreamer.log;

namespace myapp
{
  class Program
    {
        static void Main(string[] args)
        {
            LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.WARN));

            Subscription sub = new Subscription("MERGE", new string[] { "item1", "item2", "item3" }, new string[] { "stock_name", "last_price" });
            sub.DataAdapter = "QUOTE_ADAPTER";
            sub.RequestedSnapshot = "yes";
            sub.addListener(new QuoteListener());

            LightstreamerClient client = new LightstreamerClient("http://push.lightstreamer.com", "DEMO");
            client.subscribe(sub);
            client.connect();

            System.Threading.Thread.Sleep(5000);
        }

        class QuoteListener : SubscriptionListener
        {
            void SubscriptionListener.onItemUpdate(ItemUpdate itemUpdate)
            {
                Console.WriteLine(itemUpdate.getValue("stock_name") + " " + itemUpdate.getValue("last_price"));
            }
            void SubscriptionListener.onClearSnapshot(string itemName, int itemPos) {}
            void SubscriptionListener.onCommandSecondLevelItemLostUpdates(int lostUpdates, string key) {}
            void SubscriptionListener.onCommandSecondLevelSubscriptionError(int code, string message, string key) {}
            void SubscriptionListener.onEndOfSnapshot(string itemName, int itemPos) {}
            void SubscriptionListener.onItemLostUpdates(string itemName, int itemPos, int lostUpdates) {}
            void SubscriptionListener.onListenEnd() {}
            void SubscriptionListener.onListenStart() {}
            void SubscriptionListener.onRealMaxFrequency(string frequency) {}
            void SubscriptionListener.onSubscription() {}
            void SubscriptionListener.onSubscriptionError(int code, string message) {}
            void SubscriptionListener.onUnsubscription() {}
        }
    }
}
```

## Logging

To enable the internal client logger, create a [LoggerProvider](xref:com.lightstreamer.log.ILoggerProvider) and set it as the default provider of [LightstreamerClient](xref:com.lightstreamer.client.LightstreamerClient.setLoggerProvider(com.lightstreamer.log.ILoggerProvider)).

```
using com.lightstreamer.client;
using com.lightstreamer.log;

LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.DEBUG));
```

## Compatibility ##

.NET Client is compatible with .NET Standard 2.1 or higher.

The library requires Server 7.4.0. 

## Documentation

- [Live demos](https://demos.lightstreamer.com/?p=lightstreamer&t=client&sclientmicrosoft=dotnet)

- [API Reference](../api/index.md)

- [Changelog](https://github.com/Lightstreamer/Lightstreamer-lib-client-haxe/blob/main/CHANGELOG-.NET.md)

## Support

For questions and support please use the [Official Forum](https://forums.lightstreamer.com/). The issue list of this page is **exclusively** for bug reports and feature requests.

## License

[Apache 2.0](https://opensource.org/licenses/Apache-2.0)
