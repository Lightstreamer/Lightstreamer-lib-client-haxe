## Summary

- [Introduction](#introduction)
- [Installing](#installing)
- [Quickstart](#quickstart)
- [Logging](#logging)
- [Compatibility](#compatibility)
- [Documentation](#documentation)
- [Support](#support)
- [License](#license)

<h2 id="introduction">Introduction</h2>

Lightstreamer Web Client SDK enables any JavaScript application running in a web browser to communicate bidirectionally with a **Lightstreamer Server**. The API allows to subscribe to real-time data pushed by the server, to display such data, and to send any message to the server.

The library offers automatic recovery from connection failures, automatic selection of the best available transport, and full decoupling of subscription and connection operations. It is responsible of forwarding the subscriptions to the Server and re-forwarding all the subscriptions whenever the connection is broken and then reopened.

The library also offers support for Web Push Notifications on Apple platforms via **Apple Push Notification Service (APNs)** and  Google platforms  via  **Firebase Cloud Messaging (FCM)**. With Web Push, subscriptions deliver their updates via push notifications even when the application is offline (see the [Stock-List Demos with Web Push Notifications](https://github.com/Lightstreamer/Lightstreamer-example-MPNStockList-client-javascript)). 

The library is distributed through the <a href="https://www.npmjs.com/package/lightstreamer-client-web" target="_top">npm service</a>. It supports module bundlers like Webpack, Rollup.js and Browserify; further it is compatible with an AMD loader like Require.js, and it can be accessed through global variables. 

Depending on the chosen deployment architecture, on the browser in use, and on some configuration parameters, the Web Client Library will try to connect to the designated Lightstreamer Server in the best possible way.
In order to allow communication between application pages and Lightstreamer Server, suitable configuration on the Server is needed, to deal with the browser's CORS restrictions. This is achieved through the cross_domain_policy configuration block. By factory settings, no restrictions are posed.

The JavaScript library can be available depending on Edition and License Type. To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at /dashboard).

Note the following documentation convention:

Function arguments qualified as `<optional>` can be omitted only if not followed by further arguments.
In some cases, arguments that can be omitted (subject to the same restriction) may not be qualified as `<optional>`, but their optionality will be clear from the description.

<h2 id="installing">Installing</h2>

You can install the package [lightstreamer-client-web](https://www.npmjs.com/package/lightstreamer-client-web) using npm

```
npm install lightstreamer-client-web
```

The package contains a variety of library formats to suit the needs of the major development flavors. It supports module bundlers like Webpack, Rollup.js and Browserify; it is compatible with an AMD loader like Require.js, and it can be accessed through global variables. For further details see the [README](https://www.npmjs.com/package/lightstreamer-client-web).

<h2 id="quickstart">Quickstart</h2>

To connect to a Lightstreamer Server, a {@link LightstreamerClient} object has to be created, configured, and instructed to connect to the Lightstreamer Server. 
A minimal version of the code that creates a LightstreamerClient and connects to the Lightstreamer Server on *https://push.lightstreamer.com* will look like this:

```
var client = new LightstreamerClient("https://push.lightstreamer.com/","DEMO");
client.connect();
```

For each subscription to be subscribed to a Lightstreamer Server a {@link Subscription} instance is needed.
A simple Subscription containing three items and two fields to be subscribed in *MERGE* mode is easily created (see [Lightstreamer General Concepts](https://lightstreamer.com/docs/ls-server/latest/General%20Concepts.pdf)):

```
var sub = new Ls.Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"]);
sub.setDataAdapter("QUOTE_ADAPTER");
sub.setRequestedSnapshot("yes");
client.subscribe(sub);
```

Before sending the subscription to the server, usually at least one {@link SubscriptionListener} is attached to the Subscription instance in order to consume the real-time updates. The following code shows the values of the fields *stock_name* and *last_price* each time a new update is received for the subscription:

```
sub.addListener({
    onItemUpdate: function(obj) {
      console.log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"));
    }
});
```

Below is the complete JavaScript code embedded in an HTML page:

```
<html>
<head>
    <script src="https://unpkg.com/lightstreamer-client-web/lightstreamer.min.js"></script>
    <script>
    var client = new Ls.LightstreamerClient("https://push.lightstreamer.com","DEMO");  
    client.connect();
    
    var sub = new Ls.Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"]);
    sub.setDataAdapter("QUOTE_ADAPTER");
    sub.setRequestedSnapshot("yes");
    sub.addListener({
        onItemUpdate: function(obj) {
          console.log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"));
        }
    });
    client.subscribe(sub);
    </script>
</head>
<body>
</body>
</html>
```

<h2 id="logging">Logging</h2>

To enable the internal client logger, create a {@link LoggerProvider} and set it as the default provider of {@link LightstreamerClient}.

```
var loggerProvider = new ConsoleLoggerProvider(ConsoleLogLevel.DEBUG);
LightstreamerClient.setLoggerProvider(loggerProvider);
```

<h2 id="compatibility">Compatibility</h2>

The library requires Server 7.4.0. 

<h2 id="documentation">Documentation</h2>

- [Live demos](http://demos.lightstreamer.com/?p=lightstreamer&t=client&a=javascriptclient)

- [API Reference](index.html)

- [Changelog](https://github.com/Lightstreamer/Lightstreamer-lib-client-haxe/blob/main/CHANGELOG-Web.md)

- [Web Client Guide](https://github.com/Lightstreamer/Lightstreamer-lib-client-haxe/blob/main/docs/WebClientGuide.adoc)

<h2 id="support">Support</h2>

For questions and support please use the [Official Forum](https://forums.lightstreamer.com/). The issue list of this page is **exclusively** for bug reports and feature requests.

<h2 id="license">License</h2>

[Apache 2.0](https://opensource.org/licenses/Apache-2.0)
