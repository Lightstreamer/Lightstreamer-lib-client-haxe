# Lightstreamer Client SDKs Changelogs

- [Web Client Changelog](#lightstreamer-web-client-changelog)
- [Node.js Client Changelog](#lightstreamer-nodejs-client-changelog)
- [Android Client Changelog](#lightstreamer-android-client-changelog)
- [JavaSE Client Changelog](#lightstreamer-javase-client-changelog)
- [.NET Client Changelog](#lightstreamer-net-standard-client-changelog)
- [Python Client Changelog](#lightstreamer-python-client-changelog)

---

# Lightstreamer Web Client Changelog

## XXXXXXXXXX
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on XXXXXXXXXX* 

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

---

# Lightstreamer Node.js Client Changelog

## XXXXXXXXXX
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on XXXXXXXXXX* 

Improved the "delta delivery" mechanism, by adding the support for value differences, as per the extension introduced in Server version 7.3.0.
Currently two "diff" formats are supported: JSON Patch and TLCP-diff.

Added the getValueAsJSONPatchIfAvailable function in the ItemUpdate class, to take advantage of the new support for JSON Patch differences, which may prove useful in some use cases.
See the Docs for details.

Added the new error code 70 to the interface method `ClientListener.onServerError`, to report that an unusable port was configured on the server address.
Previously a similar case was treated as a request syntax error.

Removed the following restriction on the method `ConnectionOptions.setHttpExtraHeaders`: the Websocket transport is no more disabled when any extra headers are set.

The logging facilities have been revised in order to expose the same API on all supported platforms.<br/>
They consist of:

- the Logger and LoggerProvider interfaces
- the off-the-shelf ConsoleLoggerProvider class, which prints messages to the console when passed to the method `LightstreamerClient.setLoggerProvider(LoggerProvider)`.

The logging methods `fatal(String)`, `error(String)`, `warn(String)`, `info(String)` and `debug(String)` have been removed from the Logger interface.

Added the following restriction to the method `LightstreamerClient.addCookies`: the URI argument must not be null.

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

---

# Lightstreamer Android Client Changelog

## XXXXXXXXXX
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on XXXXXXXXXX* 

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

---

# Lightstreamer JavaSE Client Changelog

## XXXXXXXXXX
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on XXXXXXXXXX* 

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

---

# Lightstreamer .NET Standard Client Changelog

## 6.0.0-beta.1

*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on XXXXXXXXXX*

Improved the "delta delivery" mechanism, by adding the support for value differences, as per the extension introduced in Server version 7.3.0.
Currently two "diff" formats are supported: JSON Patch and TLCP-diff.

Added the getValueAsJSONPatchIfAvailable function in the ItemUpdate class, to take advantage of the new support for JSON Patch differences, which may prove useful in some use cases.
See the Docs for details.

Added the new error code 70 to the interface method `ClientListener.onServerError`, to report that an unusable port was configured on the server address.
Previously a similar case was treated as a request syntax error.

The library requires *.Net Standard 2.1*. Previously it used to require *.Net Standard 2.0*.

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

---

# Lightstreamer Python Client Changelog

## 1.0.1 build 20221205
_Compatible with Lightstreamer Server since 7.3.0._<br>
_Compatible with code developed for the previous versions._<br>
_Released on 5 Dec 2022._

<!-- 2022/12/05 -->
Fixed a bug that could have caused a `Subscription` object not to be deleted after a call to `LightstreamerClient.unsubscribe`.


## 1.0.0 build 20221122
_Compatible with Lightstreamer Server since 7.3.0._<br>
_Not compatible with code developed for the previous versions._<br>
_Released on 22 Nov 2022._

Improved the "delta delivery" mechanism, by adding the support for value differences, as per the extension introduced in Server version 7.3.0.

Added the `getValueAsJSONPatchIfAvailable` function in the `ItemUpdate` class, to take advantage of the new support for JSON Patch differences, which may prove useful in some use cases.

Changed the package name of the library from `lightstreamer_client` to `lightstreamer.client`.

Leveraged the standard module `logging` for the implementation of the class `ConsoleLoggerProvider`. Now all the log messages are forwarded to the logger (of type `logging.Logger`) with name `lightstreamer`.

Improved the compatibility: now the library is compatible with Python 3.7 or above.


## 1.0.0-beta.2 build 20220809

_Compatible with Lightstreamer Server since 7.2._<br>
_Released on 9 August 2022_

Fixed the exception `TypeError: can only concatenate str (not "int") to str` that could have concealed a network error.


## 1.0.0-beta.1 build 20220624

_Compatible with Lightstreamer Server since 7.2._<br>
_Released on July 2022_

The new Python client library introduces full support for the Unified Client API model that we have been introducing in all client libraries for some years now. The big advantage in using the Unified API is that the same consistent interface and behavior are guaranteed across different client platforms. In other words, the same abstractions and internal mechanisms are provided for very different platforms (Web, Andorid, Java, iOS, ...), while respecting the conventions, styles, and best practice of each platform.
