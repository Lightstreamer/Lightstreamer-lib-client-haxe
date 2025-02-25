# Lightstreamer Client SDKs

The Lightstreamer Client SDKs are a suite of libraries designed to work on different platforms (**Web**, **Node.JS**, **Android**, **Java SE**, **.NET**, **Python**, and **C++**) but exposing the same API. The project is based on the [Haxe](https://haxe.org) language and each native library is derived by transpiling the Haxe code, adding specific code and modules, and wrapping the interfaces. The result is a fully native library for each target platform.<br>
Other platforms are available, which expose the same API but are not derived from this Haxe project. In particular, a [Swift SDK](https://github.com/Lightstreamer/Lightstreamer-lib-client-swift) is available for **Apple** platforms.

The API enables any application to communicate bidirectionally with a Lightstreamer Server, that is to subscribe to real-time data pushed by a Server and to send messages to a Server. It offers automatic recovery from connection failures, automatic selection of the best available transport, and full decoupling of subscription and connection operations. It is responsible of forwarding the subscriptions to the Server and re-forwarding all the subscriptions whenever the connection is broken and then reopened.

Further on the Web and Android platforms the API offers support for Web and Mobile Push Notifications (MPN) by means of the **Apple Push Notification Service (APNs)** and the **Firebase Cloud Messaging (FCM)**. While real-time subscriptions deliver their updates via the client connection, MPN subscriptions deliver their updates via push notifications, even when the application is offline. They are handled by a special module of the Server, the MPN Module, that keeps them active at all times and continues pushing with no need for a client connection. However, push notifications are not real-time, they may be delayed by the service provider and their delivery is not guaranteed.

## Installing

|||
|---|---|
|**Web**|[Get the lib](https://www.npmjs.com/package/lightstreamer-client-web/v/9.2.3)<br>[Changelog](CHANGELOG-Web.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-web-client/9.2.3/api/index.html#quickstart)<br>[API Reference](https://sdk.lightstreamer.com/ls-web-client/9.2.3/api/index.html)<br>[Building](#web)|
|**Node.js**|[Get the lib](https://www.npmjs.com/package/lightstreamer-client-node/v/9.2.2)<br>[Changelog](CHANGELOG-Node.js.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-nodejs-client/9.2.2/api/index.html#quickstart)<br>[API Reference](https://sdk.lightstreamer.com/ls-nodejs-client/9.2.2/api/index.html)<br>[Building](#nodejs)|
|**Android**|[Get the lib](https://central.sonatype.com/artifact/com.lightstreamer/ls-android-client/5.2.1)<br>[Changelog](CHANGELOG-Android.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-android-client/5.2.1/api/index.html#quickstart)<br>[API Reference](https://sdk.lightstreamer.com/ls-android-client/5.2.1/api/index.html)<br>[Building](#android)|
|**Java SE**|[Get the lib](https://central.sonatype.com/artifact/com.lightstreamer/ls-javase-client/5.2.1)<br>[Changelog](CHANGELOG-JavaSE.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-javase-client/5.2.1/api/index.html#quickstart)<br>[API Reference](https://sdk.lightstreamer.com/ls-javase-client/5.2.1/api/index.html)<br>[Building](#java-se)|
|**.NET**|[Get the lib](https://www.nuget.org/packages/Lightstreamer.DotNetStandard.Client/6.2.0)<br>[Changelog](CHANGELOG-.NET.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-dotnetstandard-client/6.2.0/api/articles/intro.html#quickstart)<br>[API Reference](https://sdk.lightstreamer.com/ls-dotnetstandard-client/6.2.0/api/api/index.html)<br>[Building](#net)|
|**Python**|[Get the lib](https://pypi.org/project/lightstreamer-client-lib/2.2.1/)<br>[Changelog](CHANGELOG-Python.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-python-client/2.2.1/api/intro.html#quickstart)<br>[API Reference](https://sdk.lightstreamer.com/ls-python-client/2.2.1/api/modules.html)<br>[Building](#python)|
|**C++**|[Changelog](CHANGELOG-C++.md)<br>[Quickstart](https://sdk.lightstreamer.com/ls-cpp-client/1.0.0/api/index.html)<br>[API Reference](https://sdk.lightstreamer.com/ls-cpp-client/1.0.0/api/annotated.html)<br>[Building](#cpp)|

## Building

The Lightstreamer Client SDKs are written in [Haxe](https://haxe.org), an open-source programming language and cross compiler that allows the compilation of a single code-base to multiple targets.

The source files are hosted on Github.

```sh
git clone https://github.com/Lightstreamer/Lightstreamer-lib-client-haxe.git
```

To build the supported targets, follow the instructions below. 
All the commands need to be issued from the folder containing the cloned project.

### Haxe set up

To set up a Haxe 4.3.4 development environment, first you need to install the following tools:

- [node.js 22+](https://nodejs.org) and npm CLI (which is bundled with node.js)
- [lix](https://github.com/lix-pm/lix.client), a package manager for Haxe.

lix is installed through npm:

```
npm install -g lix
```

To install the right versions of Haxe dependencies and to fetch the project specific Haxe version, enter the command

```
lix download
```

You can check the installation with typing `haxe --version`. You should get an output like `4.3.4`.

**WARNING** It has been observed that lix may occasionally not work as expected. Should you experience any anomalies, the following steps are recommended:

1. Uninstall lix from your system: `npm uninstall -g lix`
2. Manually install [Haxe 4.3.4](https://haxe.org/download/)
3. Install the project dependencies by executing `haxelib install --always tools/deps.hxml` within the project directory

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
Finally make sure the environment variable `ANDROID_HOME` points to the Android home folder.

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

### C++ <a name="cpp"></a>

**Initial Project Setup**

If you're setting up the project for the first time, execute the command:

```
haxelib run hxcpp
```

Should you be prompted to rebuild the hxcpp tool, please respond with "yes".

**Building the Lightstreamer Client SDK**

The following notes assume that your system has a C++ toolchain installed, such as g++, clang++, or MSVC++. If not, it is recommended to install the latest Xcode from the App Store on Mac, use the system package manager to install the compilers on Linux, or use Microsoft Visual Studio on Windows. The installed compiler must support the C++17 standard.

Navigate to the `tools/cpp` directory and run the following command to build the SDK:

```
ant -e -Dbuild.settings=<hxml-file>
```

Replace `<hxml-file>` with the path to your configuration file. You can find a selection of pre-defined configuration files for common systems within the `tools/cpp/res` directory. These files are organized by operating system and specify whether you're building a debug or release version, and whether you're compiling a dynamic or static library. Omitting the `build.settings` flag defaults to constructing a dynamic debug library for your current operating system.

> [!WARNING]  
> Before building the library, carefully review the configuration files you want to use, as the default settings may not be suited to your system.

For example, to compile a dynamic library with debug symbols for macOS, use:

```
ant -e -Dbuild.settings=tools/cpp/res/build.mac.debug.hxml
```

The resulting library will be placed in the `bin/cpp` directory, under an OS-specific subfolder. Specifically, the command above will generate `lightstreamer_clientd.dylib` in `bin/cpp/mac/debug`.

**HXML files**

Haxe HXML files are configuration files used in Haxe development projects. By grouping compiler arguments together, they make it easier to maintain and manage build configurations.

HXML files contain two primary types of arguments:

- [Haxe Flags](https://haxe.org/manual/compiler-usage.html): These are utilized by the Haxe compiler to direct the conversion of Haxe code into C++ code. They are essential for defining the structure and behavior of the generated C++ output.

- [Hxcpp Flags](https://haxe.org/manual/target-cpp-defines.html): These are specific to the hxcpp tool, which is responsible for the actual compilation of the C++ code. Within these flags, some are directly interpreted by hxcpp to manage the compilation process, while others are passed on to the underlying C++ compiler (such as clang, gcc, or msvc) that hxcpp invokes to compile the generated C++ files.

For our purposes, the most important flags are those pertaining to the C++ compiler and linker. 

These flags are organized into four distinct groups of symbols:

- `CXXFLAG_<num>`: These are compiler flags for C++. They dictate various compiler settings and optimizations.

- `CPPFLAG_<num>`: Preprocessor flags for C++. They typically inform the preprocessor about the locations of header files.

- `LDFLAG_<num>`: Linker flags. Commonly used to define the library search paths during the linking stage.

- `LDLIB_<num>`: Additional linker flags. These are used to specify the actual libraries to be linked with the Lightstreamer Client SDK.

Here, `<num>` represents a single digit ranging from 0 to 9. 

Keep in mind that each symbol must define a single flag. For instance `CXXFLAG_0=-x` is an appropriate definition, whereas `CXXFLAG_0=-x -y` may confuse the compiler and therefore must be avoided.
If the compiler option is a key-value pair, each component must appear in a distinct flag. For example the option `-o a.out` must be written as 

```
-D CXXFLAG_0=-o
-D CXXFLAG_1=a.out
```

The syntax for these flags varies based on the toolchain being used. For practical examples, refer to the build configurations located in `tools/cpp/res`.

A list of the most common flags is the following. For more information, refer to the documentation of [Haxe](https://haxe.org/manual/compiler-usage-flags.html) and [Hxcpp](https://haxe.org/manual/target-cpp-defines.html).

* `--debug`: Add debug symbols to the generated library.
* `-D HXCPP_ARM64`: Compile for ARM64 architecture. Other options are `HXCPP_M32` and `HXCPP_M64` for 32-bit and 64-bit Intel/AMD architectures.
* `--cpp <path>`: Store the generated source files and binaries in the specified path.
* `-D HAXE_OUTPUT_FILE=<file name>`: Use the given name (without the file extension part) as the name of the generated library.
* `-D LDLIB_EXT=<ext>`: Use the given file extension as the extension of the generated library. Example: `.so` (don't forget the leading dot). If omitted, the default system extension is used.
* `-D dll_link`: Create a dynamic library. To create a static library, use `-D static_link`. If omitted, an executable file is generated.
* `-D NO_PRECOMPILED_HEADERS`: Don't precompile the header files. If omitted, the default behavior depends on the compiler toolchain. Usually the headers are not precompiled, except by MSVC.
* `-D windows`: (Windows only) Add this flag if the compilation is for Windows.
* `-D ABI=<option>`: (Windows only) Use the multithread dynamic/static version of the C++ standard runtime library. The possible values are: `/MD`, `/MT`, `/MDd` and `/MTd`. See the [MSVC docs](https://learn.microsoft.com/en-us/cpp/build/reference/md-mt-ld-use-run-time-library) for an explanation.
* `-D CXXFLAG_<num>=<option>`: Add a compiler flag. Example: `-D CXXFLAG_0=-O2`.
* `-D CPPFLAG_<num>=<option>`: Add a preprocessor flag. Example: `-D CPPFLAG_0=-I/usr/local/include`.
* `-D LDFLAG_<num>=<option>`: Add a linker flag. Example: `-D LDFLAG_0=-L/usr/local/lib`.
* `-D LDLIB_<num>=<option>`: Add a library to be linked. Example: = `-D LDLIB_0=-lssl`.

## Support

For questions and support please use the [Official Forum](https://forums.lightstreamer.com/). The issue list of this page is **exclusively** for bug reports and feature requests.

## License

[Apache 2.0](https://opensource.org/licenses/Apache-2.0)
