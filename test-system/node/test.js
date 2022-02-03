var {Subscription, LightstreamerClient, ConsoleLoggerProvider, ConsoleLogLevel} = require('lightstreamer-client-node');

var loggerProvider = new ConsoleLoggerProvider(ConsoleLogLevel.DEBUG)
var logger = loggerProvider.getLogger("test")
LightstreamerClient.setLoggerProvider(loggerProvider)

function assert(c) { console.assert(c) }
function log(s) { logger.info(s) }

var sub = new Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"])
sub.setDataAdapter("QUOTE_ADAPTER")
sub.setRequestedSnapshot("yes")
assert(sub.getDataAdapter() == "QUOTE_ADAPTER")
assert(sub.getRequestedSnapshot() == "yes")
sub.addListener({
    onListenStart: function(aSub) {
      log("SubscriptionListener.onListenStart")
      assert(sub == aSub)
    },
    onItemUpdate: function(obj) {
      log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"))
    }
})

//var client = new LightstreamerClient("http://localhost:8080","DEMO")
var client = new LightstreamerClient("http://push.lightstreamer.com","DEMO")  
client.addListener({
  onListenStart: function(aClient) {
    log("ClientListener.onListenStart")
    assert(client == aClient)
  }
})

client.connectionDetails.setUser("user")
assert(client.connectionDetails.getUser() == "user")

client.connectionOptions.setHttpExtraHeaders({"Foo": "bar"})

client.subscribe(sub)
client.connect()