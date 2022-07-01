from lightstreamer_client.client import *
import time

loggerProvider = ConsoleLoggerProvider(ConsoleLogLevel.WARN)
logger = loggerProvider.getLogger("test")
LightstreamerClient.setLoggerProvider(loggerProvider)

def log(s):
  print(s)

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
  def onItemUpdate(self, update):
    log("UPDATE " + update.getValue("stock_name") + " " + update.getValue("last_price"))
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
# client = LightstreamerClient("http://localhost:8080","DEMO")
class ClientListener:
  def onListenStart(self, aClient):
    log("ClientListener.onListenStart")
    assert client == aClient
  def onListenEnd(self, aClient):
    log("ClientListener.onListenEnd")
  def onServerError(self, errorCode, errorMessage):
    log("onServerError " + errorCode)
  def onStatusChange(self, status):
    log(status)
  def onPropertyChange(self, property):
    pass

client.addListener(ClientListener())

client.connectionDetails.setUser("user")
assert client.connectionDetails.getUser() == "user"

client.connectionOptions.setHttpExtraHeaders({"Foo": "bar"})
assert client.connectionOptions.getHttpExtraHeaders() == {"Foo": "bar"}

client.subscribe(sub)
client.connect()

time.sleep(2)