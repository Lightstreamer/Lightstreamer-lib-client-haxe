import {Subscription, LightstreamerClient, StatusWidget} from 'lightstreamer-client-web/lightstreamer.esm';

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

setTimeout(function() {
    client.disconnect();
}, 5*1000);
