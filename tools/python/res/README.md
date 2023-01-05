# Lightstreamer Python Client SDK

Lightstreamer Python Client SDK enables any Python application to communicate bidirectionally with a **Lightstreamer Server**. The API allows to subscribe to real-time data pushed by the server and to send any message to the server.

The library offers automatic recovery from connection failures, automatic selection of the best available transport, and full decoupling of subscription and connection operations. It is responsible of forwarding the subscriptions to the Server and re-forwarding all the subscriptions whenever the connection is broken and then reopened.

## Installation

You can install the Lightstreamer Client SDK from [PyPI](https://pypi.org/project/lightstreamer-client-lib/):

```
python -m pip install lightstreamer-client-lib
```

The sdk is supported on Python 3.7 and above.

## Quickstart

To connect to a Lightstreamer Server, a [LightstreamerClient](https://lightstreamer.com/api/ls-python-client/@VERSION@/lightstreamer.html#lightstreamer.client.ls_python_client_wrapper.LightstreamerClient) object has to be created, configured, and instructed to connect to the Lightstreamer Server. 
A minimal version of the code that creates a LightstreamerClient and connects to the Lightstreamer Server on *https://push.lightstreamer.com* will look like this:

```python
from lightstreamer.client import *

client = LightstreamerClient("http://push.lightstreamer.com/","DEMO")
client.connect()
```

For each subscription to be subscribed to a Lightstreamer Server a [Subscription](https://lightstreamer.com/api/ls-python-client/@VERSION@/lightstreamer.html#lightstreamer.client.ls_python_client_wrapper.Subscription) instance is needed.
A simple Subscription containing three items and two fields to be subscribed in *MERGE* mode is easily created (see [Lightstreamer General Concepts](https://lightstreamer.com/docs/ls-server/latest/General%20Concepts.pdf)):

```python
sub = Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"])
sub.setDataAdapter("QUOTE_ADAPTER")
sub.setRequestedSnapshot("yes")
client.subscribe(sub)
```

Before sending the subscription to the server, usually at least one [SubscriptionListener](https://lightstreamer.com/api/ls-python-client/@VERSION@/lightstreamer.html#lightstreamer.client.ls_python_client_api.SubscriptionListener) is attached to the Subscription instance in order to consume the real-time updates. The following code shows the values of the fields *stock_name* and *last_price* each time a new update is received for the subscription:

```python
class SubListener(SubscriptionListener):
  def onItemUpdate(self, update):
    print("UPDATE " + update.getValue("stock_name") + " " + update.getValue("last_price"))

  # other methods...

sub.addListener(SubListener())
```

Below is the complete Python code:

```python
from lightstreamer.client import *

sub = Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"])
sub.setDataAdapter("QUOTE_ADAPTER")
sub.setRequestedSnapshot("yes")

class SubListener(SubscriptionListener):
  def onItemUpdate(self, update):
    print("UPDATE " + update.getValue("stock_name") + " " + update.getValue("last_price"))

sub.addListener(SubListener())

client = LightstreamerClient("http://push.lightstreamer.com","DEMO")
client.subscribe(sub)
client.connect()
```

## Logging

To enable the internal client logger, create a [LoggerProvider](https://lightstreamer.com/api/ls-python-client/@VERSION@/lightstreamer.html#lightstreamer.client.ls_python_client_api.LoggerProvider) and set it as the default provider of [LightstreamerClient](https://lightstreamer.com/api/ls-python-client/@VERSION@/lightstreamer.html#lightstreamer.client.ls_python_client_wrapper.LightstreamerClient.setLoggerProvider).

```python
import sys, logging

logging.basicConfig(level=logging.DEBUG, format="%(message)s", stream=sys.stdout)

loggerProvider = ConsoleLoggerProvider(ConsoleLogLevel.DEBUG)
LightstreamerClient.setLoggerProvider(loggerProvider)
```

## Compatibility ##

Compatible with Lightstreamer Server since version 7.3.2.

## Documentation

- [Live demos](https://demos.lightstreamer.com/?p=lightstreamer&t=client&lclient=python)

- [API Reference](https://lightstreamer.com/api/ls-python-client/@VERSION@/index.html)

## Support

For questions and support please use the [Official Forum](https://forums.lightstreamer.com/). The issue list of this page is **exclusively** for bug reports and feature requests.

## License

[Apache 2.0](https://opensource.org/licenses/Apache-2.0)
