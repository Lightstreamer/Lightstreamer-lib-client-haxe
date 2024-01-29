# Lightstreamer Web Client Changelog

## XXXXXX
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on XXXXXX*

Fixed the problem caused by the throttling of the timers in background tabs by creating a web worker and setting the timers only there.


## 9.1.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 19 Dec 2023*

Improved the client's performance to handle more server updates per second.

Fixed the issue with the `MpnSubscription` constructor that caused incorrect handling of `MpnSubscription` or `Subscription` arguments.


## 9.0.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 10 Jul 2023* 

Added a second argument to the listener `ClientMessageListener.onProcessed` carrying the response, from the Metadata Adapter of a Lightstreamer Server, to a message sent by the Client through the method `LightstreamerClient.sendMessage`.

Added this check: when a `Subscription` is configured by means of an ItemList or a FieldList, the client checks that the number of items and fields returned by the server coincides with the number of elements in the ItemList and the FieldList, and if the numbers are different, the client deletes the subscription and fires the listener `SubscriptionListener.onSubscriptionError` with the error code 61.

Changed the behavior of the method `ItemUpdate.forEachChangedField` when `ItemUpdate` refers to the first server update (possibly the snapshot): the iterator function passed to the method is invoked on every field, while previously it was invoked only on non-null fields. 


## 9.0.0-beta.6
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 22 Jun 2023* 

Fixed the validation check of the setter `setItems` of the classes `Subscription` and `MpnSubscription` in order to accept item names that start with a digit but contain non-digit characters too.


## 9.0.0-beta.5
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 19 Jun 2023* 

Fixed a bug which caused the "core" variant of the library to crash when executed in a Web Worker.


## 9.0.0-beta.4
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 24 May 2023* 

Patched the method `haxe.Timer.delay` so that it uses the function `setTimeout` instead of the function `setInterval`, which has an unexpected behavior when executed in a React Native application (see the issue https://github.com/facebook/react-native/issues/37464).

Fixed the value of the default server address, that must be null when the library is used in a React Native application.

Updated the library haxe-concurrent to version 5.1.3.


## 9.0.0-beta.3
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 21 Apr 2023* 

Fixed Typescript declarations.


## 9.0.0-beta.2
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 5 Apr 2023* 

Rewritten the function to decode the percent encoded messages sent by the Server so that it has the same behavior on all the targets.

Suppressed the unsolicited console outputs produced by the library.

Removed from the StatusWidget the led showing the status of the connection sharing.


## 9.0.0-beta.1
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 14 Mar 2023* 

Rewritten the whole Client SDK in the cross-platform programming language Haxe, which allows to share the core features with the other Client SDKs and at the same time to add functionalities specific to this platform.<br>
The old library is still available [here](https://github.com/Lightstreamer/Lightstreamer-lib-client-javascript).

Improved the "delta delivery" mechanism, by adding the support for value differences, as per the extension introduced in Server version 7.3.0.
Currently two "diff" formats are supported: JSON Patch and TLCP-diff.

Added the getValueAsJSONPatchIfAvailable function in the ItemUpdate class, to take advantage of the new support for JSON Patch differences, which may prove useful in some use cases.
See the Docs for details.

Added the new error code 70 to the interface method `ClientListener.onServerError`, to report that an unusable port was configured on the server address.
Previously a similar case was treated as a request syntax error.

Changed the default library exposed by the npm package *lightstreamer-client-web*. Now the default is the smaller "core" variant (previously it was the "full" variant, containing the Widgets and Mobile Push Notifications in addition to the core modules). Further a third variant has been added to the npm package, the "MPN" variant, which contains the Mobile Push Notifications support in addition to the core modules. 
See the [npm page](https://www.npmjs.com/package/lightstreamer-client-web) of the package for the details.

The class ConnectionSharing and the method `LightstreamerClient.enableSharing` have been removed and in general the whole sharing mechanism has been discontinued due to the increasing security restrictions enforced by the browsers.

The logging facilities have been revised in order to expose the same API on all supported platforms.<br/>
They consist of:

- the Logger and LoggerProvider interfaces
- the off-the-shelf ConsoleLoggerProvider class, which prints messages to the console when passed to the method `LightstreamerClient.setLoggerProvider(LoggerProvider)`.

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

### Mobile Push Notifications (MPN) changes

The behavior of the property setters `MpnSubscription.setTriggerExpression()` and `MpnSubscription.getNotificationFormat()` has been partially changed. When they are called while an MpnSubscription is "active", a request is sent to the Server in order to change the corresponding parameter. If the request has success, the method `MpnSubscriptionListener.onPropertyChanged()` will eventually be called. In case of error, the new method `MpnSubscriptionListener.onModificationError()` will be called instead.

The behavior of the property getters `MpnSubscription.getTriggerExpression()` and `MpnSubscription.getNotificationFormat()` has been partially changed as well. 
Now they return the last value requested by the user.

Two new property getters have been added: `MpnSubscription.getActualTriggerExpression()` and `MpnSubscription.getActualNotificationFormat()`, that return the actual values of the trigger expression and of the notification format as seen by the Server.  

The behavior of the copy constructor `MpnSubscription(MpnSubscription)` has been partially changed. It still creates an MpnSubscription object copying all the properties from the specified MPN subscription, but it doesn't copy the property *subscriptionId* anymore. As a consequence, when the object is supplied to `LightstreamerClient.subscribeMpn()` in order to bring it to "active" state, the client creates a new MPN subscription on the Server. Previously any property changed would have replaced the corresponding value of the MPN subscription with the same subscription ID on the server.

The signatures of the following methods have been changed:

- `MpnDeviceListener.onListenStart` and `MpnDeviceListener.onListendEnd`: removed the parameter of type MpnDevice
- `MpnSubscriptionListener.onListenStart` and `MpnSubscriptionListener.onListendEnd`: removed the parameter of type MpnSubscription


# Previous Versions

See the full [changelog](https://github.com/Lightstreamer/Lightstreamer-lib-client-javascript/blob/master/CHANGELOG_Web.md).