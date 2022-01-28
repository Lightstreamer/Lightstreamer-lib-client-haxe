import {Subscription, LightstreamerClient, StatusWidget, ConsoleLoggerProvider, ConsoleLogLevel, MpnSubscription, MpnDevice, FirebaseMpnBuilder, SafariMpnBuilder} from 'lightstreamer-client-web';

LightstreamerClient.setLoggerProvider(new ConsoleLoggerProvider(ConsoleLogLevel.DEBUG));

var sub = new Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"]);
sub.setDataAdapter("QUOTE_ADAPTER");
sub.setRequestedSnapshot("yes");
sub.addListener({
    onItemUpdate: function(obj) {
      console.log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"));
    }
});
var client = new LightstreamerClient("http://push.lightstreamer.com","DEMO");  
//var client = new LightstreamerClient("http://localhost:8080","DEMO");
client.addListener(new StatusWidget("left", "0px", true));
client.connect();
client.subscribe(sub);

var headers = {"Foo": "bar"};
client.connectionOptions.setHttpExtraHeaders(headers);

var mpnSub = new MpnSubscription("MERGE",["item1","item2","item3"],["stock_name","last_price"]);
console.assert("MERGE", mpnSub.getMode());

var device = new MpnDevice(`${Math.round(Math.random() * 100)}`, "myapp", "Google");
console.assert(device.getApplicationId() == "myapp");

var fb = new FirebaseMpnBuilder();
fb.setTitle("title 1");
console.assert(fb.getTitle() == "title 1");

var sb = new SafariMpnBuilder();
sb.setTitle("title 2");
console.assert(sb.getTitle() == "title 2");

setTimeout(function() {
    client.disconnect();
}, 5*1000);
