# Lightstreamer Android Client Changelog

## [Unreleased]
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with code developed with the previous version.*<br/>

Fixed the methods `LightstreamerClient.getMpnSubscriptions` and `LightstreamerClient.findMpnSubscription` which, under certain situations,
could fail to return the so-called Server MpnSubscriptions, i.e. those subscriptions that are created during a different session from the one in which the two methods are called.


## 5.2.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*May not be compatible with code developed with the previous version.*<br/>
*Made available on 27 Aug 2024*

Changed the behavior of the listener `ClientListener.onPropertyChange` to be called whenever the value of a property is changed by the server or by the user through a property setter.

Fixed a bug that could lead to memory leaks in connections managed by the OkHttp library.


## 5.1.1
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 31 Jan 2024*

Fixed a bug that could prevent the `onSubscriptionsUpdated` event of `MpnDeviceListener` from firing when the `unsubscribeMpnSubscriptions` method of `LightstreamerClient` was invoked while registering an `MpnDevice`.


## 5.1.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 19 Dec 2023*

Improved the client's performance to handle more server updates per second.

Raised the minimum Android requirement from Android 6 (API level 23) to Android 8 (API level 26).


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

Fixed the validation check of the setter `setItems` of the classes `Subscription` and `MpnSubscription` in order to accept item names that start with a digit but contain non-digit characters too.

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

The "compact" variant of this library has been discontinued. 
The last version available was 4.2.6.

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

### Mobile Push Notifications (MPN) changes

The behavior of the property setters `MpnSubscription.setTriggerExpression()` and `MpnSubscription.getNotificationFormat()` has been partially changed. When they are called while an MpnSubscription is "active", a request is sent to the Server in order to change the corresponding parameter. If the request has success, the method `MpnSubscriptionListener.onPropertyChanged()` will eventually be called. In case of error, the new method `MpnSubscriptionListener.onModificationError()` will be called instead.

The behavior of the property getters `MpnSubscription.getTriggerExpression()` and `MpnSubscription.getNotificationFormat()` has been partially changed as well. 
Now they return the last value requested by the user.

Two new property getters have been added: `MpnSubscription.getActualTriggerExpression()` and `MpnSubscription.getActualNotificationFormat()`, that return the actual values of the trigger expression and of the notification format as seen by the Server.  

The behavior of the copy constructor `MpnSubscription(MpnSubscription)` has been partially changed. It still creates an MpnSubscription object copying all the properties from the specified MPN subscription, but it doesn't copy the property *subscriptionId* anymore. As a consequence, when the object is supplied to `LightstreamerClient.subscribeMpn()` in order to bring it to "active" state, the client creates a new MPN subscription on the Server. Previously any property changed would have replaced the corresponding value of the MPN subscription with the same subscription ID on the server.

The following deprecated methods have been removed:

- `MpnBuilder.contentAvailable(String contentAvailable)`
- `MpnBuilder.contentAvailableAsString()`
- `MpnBuilder.contentAvailable(boolean contentAvailable)`
- `MpnBuilder.contentAvailableAsBool()`

The signatures of the following methods have been changed:

- `MpnDeviceListener.onListenStart` and `MpnDeviceListener.onListendEnd`: removed the parameter of type MpnDevice
- `MpnSubscriptionListener.onListenStart` and `MpnSubscriptionListener.onListendEnd`: removed the parameter of type MpnSubscription

The following classes have been moved:

- MpnDevice: from the package `com.lightstreamer.client.mpn.android` to the package `com.lightstreamer.client.mpn`
- MpnBuilder: from the package `com.lightstreamer.client.mpn.util` to the package `com.lightstreamer.client.mpn`

The "compact" variant of the library is not available anymore.


## Previous Versions

See the full [changelog](https://github.com/Lightstreamer/Lightstreamer-lib-client-java/blob/master/CHANGELOG_Android.md).