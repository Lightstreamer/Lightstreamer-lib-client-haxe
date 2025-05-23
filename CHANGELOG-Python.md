# Lightstreamer Python Client Changelog

## 2.2.2
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 23 May 2025*

Fixed an uncaught exception that occurred when `LightstreamerClient` was configured with a logger set to INFO level or higher.


## 2.2.1
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 25 Feb 2025*

Changed HTTP `Content-Type` header to use `text/plain` instead of `application/x-www-form-urlencoded`.


## 2.2.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*May not be compatible with code developed with the previous version.*<br/>
*Made available on 29 Oct 2024*

Changed the behavior of the listener `ClientListener.onPropertyChange` to be called whenever the value of a property is changed by the server or by the user through a property setter.


## 2.1.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 19 Dec 2023*

Improved the client's performance to handle more server updates per second.


## 2.0.0
*Compatible with Lightstreamer Server since 7.4.0*<br/>
*Not compatible with code developed with the previous version.*<br/>
*Made available on 10 Jul 2023* 

Added a second argument to the listener `ClientMessageListener.onProcessed` carrying the response, from the Metadata Adapter of a Lightstreamer Server, to a message sent by the Client through the method `LightstreamerClient.sendMessage`.

Added this check: when a `Subscription` is configured by means of an ItemList or a FieldList, the client checks that the number of items and fields returned by the server coincides with the number of elements in the ItemList and the FieldList, and if the numbers are different, the client deletes the subscription and fires the listener `SubscriptionListener.onSubscriptionError` with the error code 61.


## 1.0.3
*Compatible with Lightstreamer Server since 7.3.2*<br/>
*Compatible with code developed with the previous version.*<br/>
*Made available on 22 Jun 2023* 

Fixed the validation check of the setter `setItems` of the class `Subscription` in order to accept item names that start with a digit but contain non-digit characters too.

Updated the library haxe-concurrent to version 5.1.3.


## 1.0.2
_Compatible with Lightstreamer Server since 7.3.2._<br>
_Compatible with code developed for the previous versions._<br>
_Released on 5 Apr 2023._

Rewritten the function to decode the percent encoded messages sent by the Server so that it has the same behavior on all the targets.

Suppressed the unsolicited console outputs produced by the library.


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
