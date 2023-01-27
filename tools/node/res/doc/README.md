# Lightstreamer Client Node.js SDK #

The Lightstreamer Client Node.js SDK enables any Node.js application to communicate bidirectionally with a Lightstreamer server. The API allows to subscribe to real-time data pushed by a server and to send any message to the server.

## Use ##
Install the package using npm

```
npm install lightstreamer-client-node
```

The *SDK for Node.js Clients* allows you to develop JavaScript applications
by using the same API already provided by the *SDK for Web Clients*.

You can start writing your application by loading `lightstreamer-client-node` module as
in the following example. Alternatively, you can load a minified version of the library by requiring `lightstreamer-client-node/lightstreamer-node.min` module.

```
var Ls = require('lightstreamer-client-node');

var sub = new Ls.Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"]);
sub.setDataAdapter("QUOTE_ADAPTER");
sub.setRequestedSnapshot("yes");
sub.addListener({
    onItemUpdate: function(obj) {
      console.log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"));
    }
});
var client = new Ls.LightstreamerClient("http://push.lightstreamer.com","DEMO");  
client.connect();
client.subscribe(sub);
```

## Compatibility ##

The library requires Server 7.3.2.

## Documentation ##

- [API Reference](https://lightstreamer.com/api/ls-nodejs-client/@VERSION@)
- [Demos](https://demos.lightstreamer.com/?p=lightstreamer&t=client&a=nodejsclient)
- [Changelog](https://github.com/Lightstreamer/Lightstreamer-lib-client-haxe/blob/master/CHANGELOG.md)
