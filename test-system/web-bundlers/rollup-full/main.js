import {Subscription, LightstreamerClient, StatusWidget, ConsoleLoggerProvider, ConsoleLogLevel, MpnSubscription, MpnDevice, FirebaseMpnBuilder, SafariMpnBuilder} from 'lightstreamer-client-web/lightstreamer.esm'

var loggerProvider = new ConsoleLoggerProvider(ConsoleLogLevel.INFO)
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
    onListenStart: function(s) {
      log("SubscriptionListener.onListenStart " + s.getDataAdapter())
    },
    onItemUpdate: function(obj) {
      log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"))
    }
})

//var client = new LightstreamerClient("http://localhost:8080","DEMO")
var client = new LightstreamerClient("http://push.lightstreamer.com","DEMO")  
client.addListener(new StatusWidget("left", "0px", true))
client.addListener({
  onListenStart: function(c) {
    log("ClientListener.onListenStart " + c.getStatus())
  }
})

client.connectionDetails.setUser("user")
assert(client.connectionDetails.getUser() == "user")

// client.connectionOptions.setHttpExtraHeaders({"Foo": "bar"})

var device = new MpnDevice(`${Math.round(Math.random() * 100)}`, "com.example.myapp", "Google")
assert(device.getPlatform() == "Google")
assert(device.getApplicationId() == "com.example.myapp")
device.addListener({
  onListenStart: function() {
    log("MpnDeviceListener.onListenStart")
  }
})

var sbuilder = new SafariMpnBuilder("{\"foo\": 123}")
sbuilder.setTitle("TITLE")
sbuilder.setBody("BODY")
assert(sbuilder.getTitle() == "TITLE")
assert(sbuilder.getBody() == "BODY")
assert(sbuilder.build() == '{"foo":123,"aps":{"alert":{"title":"TITLE","body":"BODY"}}}')

var fbuilder = new FirebaseMpnBuilder("{\"foo\": 123}")
fbuilder.setTitle("TITLE")
fbuilder.setBody("BODY")
assert(fbuilder.getTitle() == "TITLE")
assert(fbuilder.getBody() == "BODY")
assert(fbuilder.build() == '{"foo":123,"webpush":{"notification":{"title":"TITLE","body":"BODY"}}}')

var msub = new MpnSubscription("MERGE",["item1","item2","item3"],["stock_name","last_price"])
msub.setDataAdapter("MPN_ADAPTER")
msub.setNotificationFormat("{\"foo\": 123}")
msub.setTriggerExpression("x>0")
assert(msub.getDataAdapter() == "MPN_ADAPTER")
assert(msub.getNotificationFormat() == "{\"foo\": 123}")
assert(msub.getTriggerExpression() == "x>0")
msub.addListener({
  onListenStart: function() {
    log("MpnSubscriptionListener.onListenStart")
  }
})

client.subscribe(sub)
client.connect()

setTimeout(function() {
    client.disconnect()
}, 5*1000)
