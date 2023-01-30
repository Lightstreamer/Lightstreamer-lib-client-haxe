# Lightstreamer Client Web SDK #

The Lightstreamer Client Web SDK enables any JavaScript application running in a web browser to communicate bidirectionally with a Lightstreamer server. The API allows to subscribe to real-time data pushed by a server, to display such data, and to send any message to the server.

## Use ##
Install the package using npm

```
npm install lightstreamer-client-web
```

### Available builds ###
The package contains a variety of library formats to suit the needs of the major development flavors. For [TypeScript](https://www.typescriptlang.org) users, the file `types.d.ts` declares the API types exported by the library.

|           | **UMD**                                               | **CommonJS**                  | **ES Module**              |
|-----------|-------------------------------------------------------|-------------------------------|----------------------------|
| **Full**  | lightstreamer.js<br> lightstreamer.min.js             | lightstreamer.common.js       | lightstreamer.esm.js       |
| **Core**  | lightstreamer-core.js<br> lightstreamer-core.min.js   | lightstreamer-core.common.js  | lightstreamer-core.esm.js  |
| **MPN**   | lightstreamer-mpn.js<br> lightstreamer-mpn.min.js     | lightstreamer-mpn.common.js   | lightstreamer-mpn.esm.js   |

- **Full**: builds with all the modules in the SDK

- **Core**: builds with only the core modules (Widgets and Mobile Push Notifications are excluded)

- **MPN**: builds with the core modules and Mobile Push Notifications (Widgets are excluded)

- **UMD**: UMD builds can be used directly in the browser via a `<script>` tag.

- **CommonJS**: CommonJS builds are intended for use with older bundlers like Browserify or Webpack 1.

- **ES Module**: ES module builds are intended for use with modern bundlers like Webpack 2+ or Rollup.

- **Development vs. Production Mode**: UMD libraries are provided in two variants: minified for production and un-minified for development. Since CommonJS and ES Module builds are intended for bundlers, they are provided only in un-minified form. You will be responsible for minifying the final bundle yourself.

- **Web Worker Compatibility**: The _full_ library is not suitable to be deployed in a web worker because it uses some APIs that are not available in that environment. If you need the Client Web SDK in a web worker, you should use the _core_ version instead. For example, to import the UMD core variant, put at the beginning of the web worker an import statement like this: `importScripts('node_modules/lightstreamer-client-web/lightstreamer-core.js')`. 

Below are some of the most common ways to include the library.

### Global Objects ###

You can include the downloaded library with a `<script>` tag pointing to the installation folder.
The data attribute `data-lightstreamer-ns` sets the namespace containing the library modules 
(if you want to inject the modules directly in `window` object, simply remove the data attribute).
Alternatively, you can get the library from [unpkg](https://unpkg.com) CDN: *https://unpkg.com/lightstreamer-client-web/lightstreamer.min.js*.

A plain version of the library, *lightstreamer.js*, is also available in the package.

```
---------- index.html ----------

<html>
<head>
    <script src="node_modules/lightstreamer-client-web/lightstreamer.min.js" data-lightstreamer-ns="Ls"></script>
    <script>
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
    </script>
</head>  
</html>
```

### Require.js ###

To use the API objects as AMD-compliant modules, import [Require.js](http://requirejs.org)
loader before importing the client library (you can also use the plain version *lightstreamer.js*).

```
---------- index.html ----------

<html>
<head>
    <script src="https://requirejs.org/docs/release/2.3.6/minified/require.js"></script>
    <script src="node_modules/lightstreamer-client-web/lightstreamer.min.js"></script>
    <script>
    require(["LightstreamerClient","Subscription"], 
            function(LightstreamerClient,Subscription) {
        var sub = new Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"]);
        sub.setDataAdapter("QUOTE_ADAPTER");
        sub.setRequestedSnapshot("yes");
        sub.addListener({
            onItemUpdate: function(obj) {
              console.log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"));
            }
        });
        var client = new LightstreamerClient("http://push.lightstreamer.com","DEMO");  
        client.connect();
        client.subscribe(sub);
    });
    </script>
</head>  
</html>
```

To set a namespace prefix for the module names, configure the property `ns` of the special module `lightstreamer`.  

```
---------- index.html ----------

<html>
<head>
    <script src="https://requirejs.org/docs/release/2.3.6/minified/require.js"></script>
    <script src="node_modules/lightstreamer-client-web/lightstreamer.min.js"></script>
    <script>
    require.config({
        config : {
            "lightstreamer" : {
                "ns" : "Ls"
            }
        }
    });
    require(["Ls/LightstreamerClient","Ls/Subscription"], 
            function(LightstreamerClient,Subscription) {
        var sub = new Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"]);
        sub.setDataAdapter("QUOTE_ADAPTER");
        sub.setRequestedSnapshot("yes");
        sub.addListener({
            onItemUpdate: function(obj) {
              console.log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"));
            }
        });
        var client = new LightstreamerClient("http://push.lightstreamer.com","DEMO");  
        client.connect();
        client.subscribe(sub);
    });
    </script>
</head>  
</html>
```

### ES6 module ###

In modern browsers, you can import the library as an ES6 module.

```
<html>
<head>
    <script type="module">
    import {Subscription,LightstreamerClient} from '../node_modules/lightstreamer-client-web/lightstreamer.esm.js';
    var sub = new Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"]);
    sub.setDataAdapter("QUOTE_ADAPTER");
    sub.setRequestedSnapshot("yes");
    sub.addListener({
        onItemUpdate: function(obj) {
          console.log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"));
        }
    });
    var client = new LightstreamerClient("http://push.lightstreamer.com","DEMO");  
    client.connect();
    client.subscribe(sub);
    </script>
</head>  
</html>
```

### Webpack ###

A basic usage of [Webpack](https://webpack.js.org) bundler requires the installation of `webpack` and `webpack-cli` packages.
To create the application bundle imported by `index.html`, run the command `webpack` in the directory where `webpack.config.js` resides.

```
---------- webpack.config.js ----------

const path = require('path');

module.exports = {
  mode: 'production',
  entry: './main.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist')
  }
};

---------- main.js ----------

import {Subscription, LightstreamerClient} from 'lightstreamer-client-web';

var sub = new Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"]);
sub.setDataAdapter("QUOTE_ADAPTER");
sub.setRequestedSnapshot("yes");
sub.addListener({
    onItemUpdate: function(obj) {
      console.log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"));
    }
});
var client = new LightstreamerClient("http://push.lightstreamer.com","DEMO");  
client.connect();
client.subscribe(sub);

---------- index.html ----------

<html>
<head>
    <script src="dist/bundle.js"></script>
</head>  
</html>
```

### Rollup.js ###

A basic usage of [Rollup.js](https://rollupjs.org) bundler requires the installation of `rollup` and `rollup-plugin-node-resolve` packages.
To create the application bundle imported by `index.html`, run the command `rollup -c` in the directory where `rollup.config.js` resides.

```
---------- rollup.config.js ----------

import resolve from 'rollup-plugin-node-resolve';

export default {
    input: './main.js',
    output: {
        file: 'dist/bundle.js',
        format: 'iife'
    },
    plugins: [ resolve() ]
};

---------- main.js ----------

import {Subscription, LightstreamerClient} from 'lightstreamer-client-web';

var sub = new Subscription("MERGE",["item1","item2","item3"],["stock_name","last_price"]);
sub.setDataAdapter("QUOTE_ADAPTER");
sub.setRequestedSnapshot("yes");
sub.addListener({
    onItemUpdate: function(obj) {
      console.log(obj.getValue("stock_name") + ": " + obj.getValue("last_price"));
    }
});
var client = new LightstreamerClient("http://push.lightstreamer.com","DEMO");  
client.connect();
client.subscribe(sub);

---------- index.html ----------

<html>
<head>
    <script src="dist/bundle.js"></script>
</head>  
</html>
```

### Browserify ###

A basic usage of [Browserify](http://browserify.org) bundler requires the installation of `browserify` package.
To create the application bundle imported by `index.html`, run the command `browserify main.js -o dist/bundle.js`.

```
---------- main.js ----------

var Ls = require('lightstreamer-client-web');

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

---------- index.html ----------

<html>
<head>
    <script src="dist/bundle.js"></script>
</head>  
</html>
```

## Compatibility ##

The library requires Server 7.3.2. 

## Documentation ##

- [Web Client Guide](https://github.com/Lightstreamer/Lightstreamer-lib-client-haxe/blob/v@VERSION@-Web/docs/WebClientGuide.adoc)
- [API Reference](https://lightstreamer.com/api/ls-web-client/@VERSION@)
- [Demos](https://demos.lightstreamer.com/?p=lightstreamer&t=client&a=javascriptclient )
- [Changelog](https://github.com/Lightstreamer/Lightstreamer-lib-client-haxe/blob/master/CHANGELOG.md)

## FAQ ##

**Q: The library is too big. Is there a way to make it smaller?**

You can build a custom library comprising only the modules you need. Refer to the [Github project](https://github.com/Lightstreamer/Lightstreamer-lib-client-haxe) for further information.