# Lightstreamer .NET Standard Client Changelog

## Unreleased

*Compatible with Lightstreamer Server since 8.0.0.*<br/>
*Compatible with .NET Standard 2.1.*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Requires a Metadata Adapter based on the v9+ Java In-Process Adapter SDK. A pre-v9 Metadata Adapter requires `support_LiteralBased_subscriptions` to be enabled for that adapter (see compatibility notes below).*

**Changed (breaking):** Removed Item Group and Field Schema support, including the `Subscription.ItemGroup`, `Subscription.FieldSchema`, and `Subscription.CommandSecondLevelFieldSchema` properties. Migrate to explicit lists through the constructor or the `Items`, `Fields`, and `CommandSecondLevelFields` properties. Item and field lists must be configured before subscribing; constructing an initially unconfigured subscription remains supported.

**New:** Item and field names may now contain any character, including spaces, numeric-only names, reserved characters, and Unicode. Individual names must still be non-empty. This also applies to COMMAND second-level field names and item names derived from COMMAND keys.

**New:** Added Data Adapter and Metadata Adapter health notifications through `ClientListener.onDataAdapterStateChange(state, dataAdapterName)` and `ClientListener.onMetadataAdapterStateChange(state)`. Each received notification reports one of `started`, `disabled`, `resumed`, `restarted`, or `terminated`; pre-v9 Adapters may report only `started` and `terminated`. Update listener implementations to handle the new callbacks.

**New:** Added support for `STALE` and `RESUME` item notifications through `SubscriptionListener.onItemStale` and `SubscriptionListener.onItemResume`.

**Changed (breaking):** Replaced the three-argument loss callback with `onItemLostUpdates(itemName, itemPos, lostUpdates, isOverflow)`. `isOverflow` is true for Server buffer overflow (`OV`) and false for Data Adapter loss (`LOST`); `lostUpdates` is -1 when the count is unavailable.

Second-level COMMAND stale, resume, and Data Adapter loss notifications are ignored. Second-level Server overflow continues through the unchanged `onCommandSecondLevelItemLostUpdates(lostUpdates, key)` callback.

**New:** Added support for session creation error `12`, reported through `ClientListener.onServerError` without retrying when the Metadata Adapter uses the pre-v9 Java In-Process Adapter SDK and does not support explicit-list subscriptions. The `support_LiteralBased_subscriptions` setting can restore compatibility subject to its documented conditions; this setting applies to the individual Adapter.

**New:** Documented subscription errors reported through `SubscriptionListener.onSubscriptionError` with v9+ Data Adapters:

- `6`: The subscription request cannot be evaluated because the Data Adapter is disabled.
- `63`: The Data Adapter refused the subscription.
- `64`: The Data Adapter threw an unchecked exception while managing the subscription request.


## 6.2.1
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with .NET Standard 2.1.*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 25 Feb 2025*

Changed HTTP `Content-Type` header to use `text/plain` instead of `application/x-www-form-urlencoded`.


## 6.2.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with .NET Standard 2.1.*<br/>
*May not be compatible with code developed with the previous version.*<br/>
*Made available on 29 Oct 2024*

Changed the behavior of the listener `ClientListener.onPropertyChange` to be called whenever the value of a property is changed by the server or by the user through a property setter.


## 6.1.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with .NET Standard 2.1.*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 19 Dec 2023*

Improved the client's performance to handle more server updates per second.


## 6.0.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with .NET Standard 2.1.*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 10 Jul 2023* 

Added a second argument to the listener `ClientMessageListener.onProcessed` carrying the response, from the Metadata Adapter of a Lightstreamer Server, to a message sent by the Client through the method `LightstreamerClient.sendMessage`.

Added this check: when a `Subscription` is configured by means of an ItemList or a FieldList, the client checks that the number of items and fields returned by the server coincides with the number of elements in the ItemList and the FieldList, and if the numbers are different, the client deletes the subscription and fires the listener `SubscriptionListener.onSubscriptionError` with the error code 61.


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