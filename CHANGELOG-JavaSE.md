# Lightstreamer Java SE Client Changelog

## Unreleased

*Compatible with Lightstreamer Server since 8.0.0.*<br/>
*Compatible with Java 8+.*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Requires a Metadata Adapter based on the v9+ Java In-Process Adapter SDK. A pre-v9 Metadata Adapter requires `support_LiteralBased_subscriptions` to be enabled for that adapter (see compatibility notes below).*

**Changed (breaking):** Removed Item Group and Field Schema support, including `Subscription.setItemGroup`, `Subscription.getItemGroup`, `Subscription.setFieldSchema`, `Subscription.getFieldSchema`, `Subscription.setCommandSecondLevelFieldSchema`, and `Subscription.getCommandSecondLevelFieldSchema`. Migrate to explicit lists through the constructor or `setItems`/`getItems`, `setFields`/`getFields`, and `setCommandSecondLevelFields`/`getCommandSecondLevelFields`. Item and field lists must be configured before subscribing; constructing an initially unconfigured subscription remains supported.

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


## 5.3.3
*Compatible with Lightstreamer Server since 7.4.0.*<br/>
*Compatible with Java 8+.*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 13 Aug 2026.*

Bumped the version of `com.fasterxml.jackson.core:jackson-databind` to 2.22.1, in order to fix security vulnerabilities affecting the previous versions of the library.


## 5.3.2
*Compatible with Lightstreamer Server since 7.4.0.*<br/>
*Compatible with Java 8+.*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 6 Jul 2026.*

Updated the `zjsonpatch` library to version 0.4.16. 

Updated the `jackson-databind` library to version 2.18.8.


## 5.3.1
*Compatible with Lightstreamer Server since 7.4.0.*<br/>
*Compatible with Java 8+.*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 26 Mar 2026.*

Bumped the version of the `com.fasterxml.jackson.core` library to 2.21.2, in order to fix the security vulnerability [GHSA-72hv-8253-57qq](https://github.com/advisories/GHSA-72hv-8253-57qq) affecting the previous versions of the library.


## 5.3.0
*Compatible with Lightstreamer Server since 7.4.0.*<br/>
*Compatible with Java 8+.*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 10 Mar 2026.*

**New:** Added support for certificate pinning through the `ConnectionDetails.setCertificatePins` method, allowing clients to restrict TLS connections to servers presenting specific certificates.


## 5.2.1
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 25 Feb 2025*

Changed HTTP `Content-Type` header to use `text/plain` instead of `application/x-www-form-urlencoded`.


## 5.2.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*May not be compatible with code developed with the previous version.*<br/>
*Made available on 27 Aug 2024*

Changed the behavior of the listener `ClientListener.onPropertyChange` to be called whenever the value of a property is changed by the server or by the user through a property setter.

Fixed a bug that could lead to memory leaks in connections managed by the OkHttp library.


## 5.1.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 19 Dec 2023*

Improved the client's performance to handle more server updates per second.


## 5.0.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 10 Jul 2023* 

Added a second argument to the listener `ClientMessageListener.onProcessed` carrying the response, from the Metadata Adapter of a Lightstreamer Server, to a message sent by the Client through the method `LightstreamerClient.sendMessage`.

Added this check: when a `Subscription` is configured by means of an ItemList or a FieldList, the client checks that the number of items and fields returned by the server coincides with the number of elements in the ItemList and the FieldList, and if the numbers are different, the client deletes the subscription and fires the listener `SubscriptionListener.onSubscriptionError` with the error code 61.


## 5.0.0-beta.3
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 22 Jun 2023* 

Fixed the validation check of the setter `setItems` of the class `Subscription` in order to accept item names that start with a digit but contain non-digit characters too.

Updated the library haxe-concurrent to version 5.1.3.


## 5.0.0-beta.2
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 5 Apr 2023* 

Rewritten the function to decode the percent encoded messages sent by the Server so that it has the same behavior on all the targets.

Suppressed the unsolicited console outputs produced by the library.


## 5.0.0-beta.1
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 16 Mar 2023* 

Rewritten the whole Client SDK in the cross-platform programming language Haxe, which allows to share the core features with the other Client SDKs and at the same time to add functionalities specific to this platform.<br>
The old library is still available [here](https://github.com/Lightstreamer/Lightstreamer-lib-client-java).

Improved the "delta delivery" mechanism, by adding the support for value differences, as per the extension introduced in Server version 7.3.0.
Currently two "diff" formats are supported: JSON Patch and TLCP-diff.

Added the getValueAsJSONPatchIfAvailable function in the ItemUpdate class, to take advantage of the new support for JSON Patch differences, which may prove useful in some use cases.
See the Docs for details.

Added the new error code 70 to the interface method `ClientListener.onServerError`, to report that an unusable port was configured on the server address.
Previously a similar case was treated as a request syntax error.

The logging facilities have been revised in order to expose the same API on all supported platforms.<br/>
They consist of:

- the Logger and LoggerProvider interfaces
- the off-the-shelf ConsoleLoggerProvider class, which prints messages to the standard output when passed to the method `LightstreamerClient.setLoggerProvider(LoggerProvider)`.

The logging methods `fatal(String)`, `error(String)`, `warn(String)`, `info(String)` and `debug(String)` have been removed from the Logger interface.

The following properties have been changed:

- `Subscription.getItems`
- `Subscription.getItemGroup`
- `Subscription.getFields`
- `Subscription.getFieldSchema`
- `Subscription.getCommandSecondLevelFields`
- `Subscription.getCommandSecondLevelFieldSchema`

Now they return null when the values are not available. 
Previously they threw an IllegalStateException.

The following obsolete methods have been removed:

- `ConnectionOptions.getConnectTimeout`
- `ConnectionOptions.setConnectTimeout`
- `ConnectionOptions.getCurrentConnectTimeout`
- `ConnectionOptions.setCurrentConnectTimeout`
- `ConnectionOptions.isEarlyWSOpenEnabled`
- `ConnectionOptions.setEarlyWSOpenEnabled`

The signatures of the following methods have been changed:

- `ClientListener.onListenStart` and `ClientListener.onListendEnd`: removed the parameter of type LightstreamerClient
- `SubscriptionListener.onListenStart` and `SubscriptionListener.onListendEnd`: removed the parameter of type Subscription

The system property `com.lightstreamer.client.session.thread`, which instructed the library to use a dedicated thread for each LightstreamerClient instance, is not supported anymore.


# Previous Versions

See the full [changelog](https://github.com/Lightstreamer/Lightstreamer-lib-client-java/blob/master/CHANGELOG_Java.md).