This JavaScript library enables any JavaScript application running in a web browser to communicate bidirectionally with the Lightstreamer Server. A different library, specific for Node.js, is available on NPM.
The API allows to subscribe to real-time data pushed by the server, to display such data, and to send any message to the server.
The library is distributed through the <a href="https://www.npmjs.com/package/lightstreamer-client-web" target="_top">npm service</a>. It supports module bundlers like Webpack, Rollup.js and Browserify; further it is compatible with an AMD loader like Require.js, and it can be accessed through global variables. 
It is recommended to leverage the build script distributed with the source files on the [Github project](https://github.com/Lightstreamer/Lightstreamer-lib-client-javascript) to prepare a custom library 
that contains only the needed bits and in the preferred format. Look for the relevant tag. The Github project documentation will also show how and which files to include and how to reference the included classes. 

The library can also be used inside a Web Worker. The documentation highlights which class can or can't be used on such environment.

Depending on the chosen deployment architecture, on the browser in use, and on some configuration parameters, the Web Client Library will try to connect to the designated Lightstreamer Server in the best possible way.
A <a href="https://docs.google.com/spreadsheets/d/1Lu-g-dmm_9gmrnf043wbjYRcoRC7fFAFCfUirIUpzXg/edit#gid=1" target="_top">Deployment Configuration Matrix</a> is available online, which summarizes the client-side combinations and the instructions on which settings to use to guarantee that an optimal connection is established. See the legend on the second tab to learn about the meaning of each column.

More introductory notes are provided in the Web Client Guide document that can be found in the [Github project](https://github.com/Lightstreamer/Lightstreamer-lib-client-javascript). Look for the relevant tag.

The JavaScript library can be available depending on Edition and License Type. To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at /dashboard).

To have a quick overview of the library, start digging into the API from the {@link LightstreamerClient} object.

Check out the available <a href="http://demos.lightstreamer.com/?p=lightstreamer&t=client&a=javascriptclient">examples</a> and associated README to learn more.

If there is any issue, you can find a solution on <a href="http://forums.lightstreamer.com/forumdisplay.php?11-JavaScript-Client-API" target="_top">our public forum</a>.

Note the following documentation convention:
<br>
Function arguments qualified as `<optional>` can be omitted only if not followed by further arguments.
In some cases, arguments that can be omitted (subject to the same restriction) may not be qualified as `<optional>`, but their optionality will be clear from the description.
