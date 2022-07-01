# Lightstreamer Client SDK

Lightstreamer Client SDK enables any Python application to communicate bidirectionally with a **Lightstreamer Server**. The API allows to subscribe to real-time data pushed by the server and to send any message to the server.

The library offers automatic recovery from connection failures, automatic selection of the best available transport, and full decoupling of subscription and connection operations. It is responsible of forwarding the subscriptions to the Server and re-forwarding all the subscriptions whenever the connection is broken and then reopened.

## Installation

You can install the Lightstreamer Client SDK from [PyPI](https://pypi.org/project/realpython-reader/):

```
python -m pip install lightstreamer-client
```

The sdk is supported on Python 3.9 and above.

## Quickstart

To connect to a Lightstreamer Server, a [LightstreamerClient](https://lightstreamer.com/api/ls-web-client/latest/LightstreamerClient.html) object has to be created, configured, and instructed to connect to the Lightstreamer Server. 
A minimal version of the code that creates a LightstreamerClient and connects to the Lightstreamer Server on *https://push.lightstreamer.com* will look like this:

```python
from lightstreamer_client.client import *

client = LightstreamerClient("http://push.lightstreamer.com/","DEMO")
client.connect()
```

For each subscription to be subscribed to a Lightstreamer Server a [Subscription](https://lightstreamer.com/api/ls-web-client/latest/Subscription.html) instance is needed.
A simple Subscription containing three items and two fields to be subscribed in *MERGE* mode is easily created (see [Lightstreamer General Concepts](https://lightstreamer.com/docs/ls-server/latest/General%20Concepts.pdf)):

```python
sub = Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"])
sub.setDataAdapter("QUOTE_ADAPTER")
sub.setRequestedSnapshot("yes")
client.subscribe(sub)
```

Before sending the subscription to the server, usually at least one [SubscriptionListener](https://lightstreamer.com/api/ls-web-client/latest/SubscriptionListener.html) is attached to the Subscription instance in order to consume the real-time updates. The following code shows the values of the fields *stock_name* and *last_price* each time a new update is received for the subscription:

```python
class SubListener:
  def onItemUpdate(self, update):
    print("UPDATE " + update.getValue("stock_name") + " " + update.getValue("last_price"))

  # other methods...

sub.addListener(SubListener())
```

Below is the complete Python code:

```python
from lightstreamer_client.client import *

sub = Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"])
sub.setDataAdapter("QUOTE_ADAPTER")
sub.setRequestedSnapshot("yes")

class SubListener:
  def onItemUpdate(self, update):
    print("UPDATE " + update.getValue("stock_name") + " " + update.getValue("last_price"))
  def onListenStart(self, aSub):
    pass
  def onClearSnapshot(self, itemName, itemPos):
    pass
  def onCommandSecondLevelItemLostUpdates(self, lostUpdates, key):
    pass
  def onCommandSecondLevelSubscriptionError(self, code, message, key):
    pass
  def onEndOfSnapshot(self, itemName, itemPos):
    pass
  def onItemLostUpdates(self, itemName, itemPos, lostUpdates):
    pass
  def onListenEnd(self, subscription):
    pass
  def onListenStart(self, subscription):
    pass
  def onSubscription(self):
    pass
  def onSubscriptionError(self, code, message):
    pass
  def onUnsubscription(self):
    pass
  def onRealMaxFrequency(self, frequency):
    pass

sub.addListener(SubListener())

client = LightstreamerClient("http://push.lightstreamer.com","DEMO")
client.subscribe(sub)
client.connect()
```

## Logging

To enable the internal client logger, create a [LoggerProvider](https://lightstreamer.com/api/ls-web-client/latest/LoggerProvider.html) and set it as the default provider of [LightstreamerClient](https://lightstreamer.com/api/ls-web-client/latest/LightstreamerClient.html).

```python
loggerProvider = ConsoleLoggerProvider(ConsoleLogLevel.DEBUG)
LightstreamerClient.setLoggerProvider(loggerProvider)
```

## Compatibility ##

Compatible with Lightstreamer Server since version 7.2.0.

## Documentation

- [Live demos](https://demos.lightstreamer.com/)

- [API Reference](https://lightstreamer.com/api/ls-web-client/latest/)

## Support

For questions and support please use the [Official Forum](https://forums.lightstreamer.com/). The issue list of this page is **exclusively** for bug reports and feature requests.

## License

[Apache 2.0](https://opensource.org/licenses/Apache-2.0)
