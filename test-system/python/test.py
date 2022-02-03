from lightstreamer import *

loggerProvider = ConsoleLoggerProvider(ConsoleLogLevel.DEBUG)
logger = loggerProvider.getLogger("test")
LightstreamerClient.setLoggerProvider(loggerProvider)

def log(s):
  logger.info(s)

sub = Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"])
sub.setDataAdapter("QUOTE_ADAPTER")
sub.setRequestedSnapshot("yes")
assert sub.getDataAdapter() == "QUOTE_ADAPTER"
assert sub.getRequestedSnapshot() == "yes"
assert sub.getItems() == ["item1","item2","item3"]
assert sub.getFields() == ["stock_name","last_price"]
class SubListener:
  def onListenStart(self, aSub):
    log("SubscriptionListener.onListenStart")
    assert sub == aSub
sub.addListener(SubListener())

# client = lightstreamer.LightstreamerClient("http://push.lightstreamer.com","DEMO")
client = LightstreamerClient("http://localhost:8080","DEMO")
class ClientListener:
  def onListenStart(self, aClient):
    log("ClientListener.onListenStart")
    assert client == aClient
client.addListener(ClientListener())

client.connectionDetails.setUser("user")
assert client.connectionDetails.getUser() == "user"

client.connectionOptions.setHttpExtraHeaders({"Foo": "bar"})
assert client.connectionOptions.getHttpExtraHeaders() == {"Foo": "bar"}

client.subscribe(sub)
client.connect()