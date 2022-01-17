import lightstreamer

lightstreamer.LightstreamerClient.setLoggerProvider(lightstreamer.ConsoleLoggerProvider(lightstreamer.ConsoleLogLevel.DEBUG))

sub = lightstreamer.Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"])
sub.setDataAdapter("QUOTE_ADAPTER")
sub.setRequestedSnapshot("yes")
# sub.addListener({
#     onItemUpdate: function(obj) {
#       console.log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"))
#     }
# })
# client = lightstreamer.LightstreamerClient("http://push.lightstreamer.com","DEMO")
client = lightstreamer.LightstreamerClient("http://localhost:8080","DEMO")
client.connect()
client.subscribe(sub)

headers = {"Foo": "bar"}
client.connectionOptions.setHttpExtraHeaders(headers)