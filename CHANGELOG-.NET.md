# Lightstreamer .NET Standard Client Changelog

## 6.0.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 4 Jul 2023* 

Added a second argument to the listener `ClientMessageListener.onProcessed` carrying the response, from the Metadata Adapter of a Lightstreamer Server, to a message sent by the Client through the method `LightstreamerClient.sendMessage`.


## 6.0.0-beta.3
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 22 Jun 2023* 

Fixed the validation check of the setter `Items` of the class `Subscription` in order to accept item names that start with a digit but contain non-digit characters too.

Updated the library haxe-concurrent to version 5.1.3.


## 6.0.0-beta.2
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 5 Apr 2023*

Rewritten the function to decode the percent encoded messages sent by the Server so that it has the same behavior on all the targets.

Suppressed the unsolicited console outputs produced by the library.


## 6.0.0-beta.1
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 14 Mar 2023*

Rewritten the whole Client SDK in the cross-platform programming language Haxe, which allows to share the core features with the other Client SDKs and at the same time to add functionalities specific to this platform.<br>
The old library is still available [here](https://github.com/Lightstreamer/Lightstreamer-lib-client-dotnet).

Now the library requires *.Net Standard 2.1*. Previously it used to require *.Net Standard 2.0*.

Improved the "delta delivery" mechanism, by adding the support for value differences, as per the extension introduced in Server version 7.3.0.
Currently two "diff" formats are supported: JSON Patch and TLCP-diff.

Added the getValueAsJSONPatchIfAvailable function in the ItemUpdate class, to take advantage of the new support for JSON Patch differences, which may prove useful in some use cases.
See the Docs for details.

Added the new error code 70 to the interface method `ClientListener.onServerError`, to report that an unusable port was configured on the server address.
Previously a similar case was treated as a request syntax error.

The logging facilities have been revised in order to expose the same API on all supported platforms.<br/>
They consist of:

- the ILogger and ILoggerProvider interfaces
- the off-the-shelf ConsoleLoggerProvider class, which prints messages to the standard output when passed to the method `LightstreamerClient.setLoggerProvider(ILoggerProvider)`.

The logging methods `fatal(string)`, `error(string)`, `warn(string)`, `info(string)` and `debug(string)` have been removed from the ILogger interface.

The logging namespace `Lightstreamer.DotNet.Logging.Log` has been renamed to `com.lightstreamer.log` to better match the main namespace `com.lightstreamer.client`.

The following properties have been changed:

- `Subscription.Items`
- `Subscription.ItemGroup`
- `Subscription.Fields`
- `Subscription.FieldSchema`
- `Subscription.CommandSeconLevelFields`
- `Subscription.CommandSecondLevelFieldSchema`

Now they return null when the values are not available. 
Previously they threw an IllegalStateException.

The following obsolete properties have been removed:

- `ConnectionOptions.ConnectTimeout`
- `ConnectionOptions.CurrentConnectTimeout`
- `ConnectionOptions.EarlyWSOpenEnabled`

The signatures of the following methods have been changed:

- `ClientListener.onListenStart` and `ClientListener.onListendEnd`: removed the parameter of type LightstreamerClient
- `SubscriptionListener.onListenStart` and `SubscriptionListener.onListendEnd`: removed the parameter of type Subscription

The signatures of the methods `LightstreamerClient.addCookies` and `LightstreamerClient.getCookies` have been changed. Now they take and return an object of the standard type `System.Net.CookieCollection`.

The inline documentation of the method `LightstreamerClient.addCookies` has been clarified.

The lifecycle of the property `ConnectionOptions.Proxy` has been changed. Now it may be called only once before creating any LightstreamerClient instance.

The lifecycle of the property `LightstreamerClient.TrustManagerFactory` has been changed. Now it may be called only once before creating any LightstreamerClient instance.


## Previous Versions

See the full [changelog](https://github.com/Lightstreamer/Lightstreamer-lib-client-dotnet/blob/master/CHANGELOG.md).