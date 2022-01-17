var Ls = require('lightstreamer-client-node');

Ls.LightstreamerClient.setLoggerProvider(new Ls.ConsoleLoggerProvider(Ls.ConsoleLogLevel.DEBUG));
var sub = new Ls.Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"]);
sub.setDataAdapter("QUOTE_ADAPTER");
sub.setRequestedSnapshot("yes");
sub.addListener({
    onItemUpdate: function(obj) {
      console.log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"));
    }
});
//var client = new Ls.LightstreamerClient("http://push.lightstreamer.com","DEMO");  
var client = new Ls.LightstreamerClient("http://localhost:8080","DEMO");
client.connect();
client.subscribe(sub);

var headers = {"Foo": "bar"};
client.connectionOptions.setHttpExtraHeaders(headers);

// setTimeout(function() {
//     client.disconnect();
// }, 5*1000);
