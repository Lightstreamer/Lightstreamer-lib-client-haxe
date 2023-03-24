# Lightstreamer Client SDKs

The Lightstreamer Client SDKs are a suite of libraries designed to work on different platforms (**Web**, **Node.JS**, **Android**, **Java SE**, **.NET**, and **Python**) but exposing the same API. The project is based on the [Haxe](https://haxe.org) language and each native library is derived by transpiling the Haxe code, adding specific code and modules, and wrapping the interfaces. The result is a fully native library for each target platform.<br>
Other platforms are available, which expose the same API but are not derived from this Haxe project. In particular, a [Swift SDK](https://github.com/Lightstreamer/Lightstreamer-lib-client-swift) is available for **Apple** platforms.

The API enables any application to communicate bidirectionally with a Lightstreamer Server, that is to subscribe to real-time data pushed by a Server and to send messages to a Server. It offers automatic recovery from connection failures, automatic selection of the best available transport, and full decoupling of subscription and connection operations. It is responsible of forwarding the subscriptions to the Server and re-forwarding all the subscriptions whenever the connection is broken and then reopened.

Further on the Web and Android platforms the API offers support for Web and Mobile Push Notifications (MPN) by means of the **Apple Push Notification Service (APNs)** and the **Firebase Cloud Messaging (FCM)**. While real-time subscriptions deliver their updates via the client connection, MPN subscriptions deliver their updates via push notifications, even when the application is offline. They are handled by a special module of the Server, the MPN Module, that keeps them active at all times and continues pushing with no need for a client connection. However, push notifications are not real-time, they may be delayed by the service provider and their delivery is not guaranteed.

## Installing

|||
|---|---|
|**Web**|[Get the lib](https://www.npmjs.com/package/lightstreamer-client-web/v/9.0.0-beta.1)<br>[Changelog](CHANGELOG-Web.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-web-client/9.0.0-beta.1/api/index.html#quickstart)<br>[API Reference](https://sdk.lightstreamer.com/ls-web-client/9.0.0-beta.1/api/index.html)<br>[Building](#web)|
|**Node.js**|[Get the lib](https://www.npmjs.com/package/lightstreamer-client-node/v/9.0.0-beta.1)<br>[Changelog](CHANGELOG-Node.js.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-nodejs-client/9.0.0-beta.1/api/index.html#quickstart)<br>[API Reference](https://sdk.lightstreamer.com/ls-nodejs-client/9.0.0-beta.1/api/index.html)<br>[Building](#nodejs)|
|**Android**|[Get the lib](https://central.sonatype.com/artifact/com.lightstreamer/ls-android-client/5.0.0-beta.1)<br>[Changelog](CHANGELOG-Android.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-android-client/5.0.0-beta.1/api/index.html#quickstart)<br>[API Reference](https://sdk.lightstreamer.com/ls-android-client/5.0.0-beta.1/api/index.html)<br>[Building](#android)|
|**Java SE**|[Get the lib](https://central.sonatype.com/artifact/com.lightstreamer/ls-javase-client/5.0.0-beta.1)<br>[Changelog](CHANGELOG-JavaSE.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-javase-client/5.0.0-beta.1/api/index.html#quickstart)<br>[API Reference](https://sdk.lightstreamer.com/ls-javase-client/5.0.0-beta.1/api/index.html)<br>[Building](#java-se)|
|**.NET**|[Get the lib](https://www.nuget.org/packages/Lightstreamer.DotNetStandard.Client/6.0.0-beta.1)<br>[Changelog](CHANGELOG-.NET.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-dotnetstandard-client/6.0.0-beta.1/api/articles/intro.html#quickstart)<br>[API Reference](https://sdk.lightstreamer.com/ls-dotnetstandard-client/6.0.0-beta.1/api/api/index.html)<br>[Building](#net)|
|**Python**|[Get the lib](https://pypi.org/project/lightstreamer-client-lib/1.0.1/)<br>[Changelog](CHANGELOG-Python.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-python-client/1.0.1/api/intro.html#quickstart)<br>[API Reference](https://sdk.lightstreamer.com/ls-python-client/1.0.1/api/modules.html)<br>[Building](#python)|

## Building

The Lightstreamer Client SDKs are written in [Haxe](https://haxe.org), an open-source programming language and cross compiler that allows the compilation of a single code-base to multiple targets.

The source files are hosted on Github.

```
git clone https://github.com/Lightstreamer/Lightstreamer-lib-client-haxe.git
```

To build the supported targets, follow the instructions below. 
All the commands need to be issued from the folder containing the cloned project.

### Haxe set up

To set up a Haxe 4.3+ development environment, first you need to install the following tools:

- [node.js 18+](https://nodejs.org) and npm CLI 9+ (which is bundled with node.js)
- [lix](https://github.com/lix-pm/lix.client), a package manager for Haxe.

lix is installed through npm:

```
npm install -g lix
```

To install the right versions of Haxe dependencies and to fetch the project specific Haxe version, enter the command

```
lix download
```

You can check the installation with typing `haxe --version`. You should get an output like `4.3.0-rc.1+966864c`.

### Other tools set up

In order to build the SDKs you need a few other tools.

First enter the command

```
npm install
```

Then install [Ant 1.10+](https://ant.apache.org/manual/install.html#getting), a Java-based build tool (you will also need a [JDK 8+](https://openjdk.org) installed on your system).

You can check the installation with typing `ant -version`. You should get an output like `Apache Ant(TM) version 1.10.12 compiled on October 13 2021`.

### Web

In order to build the Web Client SDK run the commands

```
cd tools/web
ant
```

The generated libraries are saved in `bin/web/build/dist/npm`.

The folder contains a variety of formats to suit the needs of the major development flavors.

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

#### Logmaps

In order to shrink the size of the library, it is possible to substitute the log messages produced by the library when the internal logger is enabled with numeric codes referring to a *logmap*, that is a json file keeping track of the mapping between the numeric codes and the original messages.

To strip the log messages and generate a logmap, set to `true` the properties `LS_STRIP_LOGS` in the file `tools/web/build.xml`.

To decode an encoded log file, invoke the script `tools/decode-logs.js` passing as arguments the encoded log file and the logmap file generated by the build script. The decoded log is printed to the console.

For example:

```
node decode-logs log.txt logmap.json
```

### Node.js

In order to build the Node.js Client SDK run the commands

```
cd tools/node
ant
```

The generated libraries are saved in `bin/node/build/dist/npm`.

### Android

If not already installed, install [Ant Ivy 2.5.0+](https://ant.apache.org/ivy/history/2.5.1/install.html) (see the section named *Manually* and follow the instructions about Ant 1.6 or superior).

Then install the [Android toolkit](https://developer.android.com/studio). 
Once installed, get the *Android SDK Platform 11 (R) API Level 30* (if you have *Android Studio*, open the *SDK Manager* and go to the tab *SDK Platforms*).
Finally make sure the environment variable `ANDROID_SDK` points to the Android home folder.

Finally download [Bouncy Castle 1.72](https://www.bouncycastle.org/latest_releases.html) cryptographic libraries and copy the files `bcprov-jdk18on-172.jar` (the cryptography provider) and `bcpg-jdk18on-172.2.jar` (the GPG driver) to the folder `ANT_HOME/lib`. 

In order to build the Android Client SDK run the commands

```
cd tools/android
ant
```

The generated library `ls-android-client.jar` is saved in the folder `bin/android/build/lib`.

### Java SE

If not already installed, install [Ant Ivy 2.5.0+](https://ant.apache.org/ivy/history/2.5.1/install.html) (see the section named *Manually* and follow the instructions about Ant 1.6 or superior).

Then download [Bouncy Castle 1.72](https://www.bouncycastle.org/latest_releases.html) cryptographic libraries and copy the files `bcprov-jdk18on-172.jar` (the cryptography provider) and `bcpg-jdk18on-172.2.jar` (the GPG driver) to the folder `ANT_HOME/lib`.

In order to build the Java SE Client SDK run the commands

```
cd tools/java
ant
```

The generated library `ls-javase-client.jar` is saved in the folder `bind/java/build/lib`.

### .NET

If not already installed, install [.NET SDK 6.0+](https://dotnet.microsoft.com/en-us/download/dotnet) and NuGet 6.2+ (get the version for [windows](https://www.nuget.org/downloads) or the version for [linux/mac](https://www.mono-project.com/download/stable)).

In order to build the .NET Client SDK run the commands

```
cd tools/cs
ant
```

The generated nuget package is saved in the folder `bin/cs/dist`.

### Python

If not already installed, install [Python 3.7+](https://www.python.org/downloads/).

In order to build the Python Client SDK run the commands

```
cd tools/python
ant
```

The generated package is saved in the folder `bin/python/build/lib`.

## Support

For questions and support please use the [Official Forum](https://forums.lightstreamer.com/). The issue list of this page is **exclusively** for bug reports and feature requests.

## License

[Apache 2.0](https://opensource.org/licenses/Apache-2.0)
