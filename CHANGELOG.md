
# all

The methods 

- Subscription.getItems
- Subscription.getItemGroup
- Subscription.getFields
- Subscription.getFieldSchema
- Subscription.getCommandSeconLevelFields
- Subscription.getCommandSecondLevelFieldSchema 

return null when the values are not available. 
Previously they threw an IllegalStateException.

Added support for JSON field compression.

removed ConnectionSharing (web only)

revised logging mechanism (same API on all platforms)

removed methods
- ConnectionOptions.getConnectTimeout
- ConnectionOptions.setConnectTimeout
- ConnectionOptions.getCurrentConnectTimeout
- ConnectionOptions.setCurrentConnectTimeout
- ConnectionOptions.isEarlyWSOpenEnabled
- ConnectionOptions.setEarlyWSOpenEnabled

added methods
- MpnSubscription.getActualTriggerExpression
- MpnSubscription.getActualNotificationFormat
- MpnSubscriptionListener.onModificationError

removed methods on android
- MpnBuilder.contentAvailable(String contentAvailable)
- MpnBuilder.contentAvailableAsString()
- MpnBuilder.contentAvailable(boolean contentAvailable)
- MpnBuilder.contentAvailableAsBool()

moved classes
- to com.lightstreamer.client.mpn.MpnDevice from com.lightstreamer.client.mpn.android.MpnDevice
- to com.lightstreamer.client.mpn.MpnBuilder from com.lightstreamer.client.mpn.util.MpnBuilder

all
Added new error code 70 to ClientListener.onServerError, to report that an unusable port was configured on the server address; previously, a similar case was treated as a request syntax error.

java
- LightstreamerClient: removed support for system property "com.lightstreamer.client.session.thread": By default, all instances will share the same thread for their internal operations, but can be instructed to use dedicated threads by setting the custom "com.lightstreamer.client.session.thread" system property as "dedicated"

android:
- removed "compact" library

# MPN

The behavior of the property setters `MpnSubscription.setTriggerExpression()` and `MpnSubscription.getNotificationFormat()` has been partially changed. When they are called while an MpnSubscription is "active", a request is sent to the Server in order to change the corresponding parameter. If the request has success, the method `MpnSubscriptionListener.onPropertyChanged()` will eventually be called. In case of error, the new method `MpnSubscriptionListener.onModificationError()` will be called instead.
The behavior of the property getters `MpnSubscription.getTriggerExpression()` and `MpnSubscription.getNotificationFormat()` has been partially changed as well. Now they return the last value requested by the user.

Two new properties has been added: `MpnSubscription.getActualTriggerExpression()` and `MpnSubscription.getActualNotificationFormat()`, that return the actual values of the trigger expression and of the notification format as seen by the Server.  

The behavior of the copy constructor `MpnSubscription(MpnSubscription)` has been partially changed. It still creates an MpnSubscription object copying all the properties from the specified MPN subscription, but it doesn't copy the property *subscriptionId* anymore. As a consequence, when the object is supplied to `LightstreamerClient.subscribeMpn()` in order to bring it to "active" state, the client creates a new MPN subscription on the Server. Previously any property changed would have replaced the corresponding value of the MPN subscription with the same subscription ID on the server.

# nodejs

- LightstreamerClient.addCookies: remove "It can be null." from uri parameter docs (unified with Java)

- ConnectionOptions.setHttpExtraHeaders: remove "Note that when the value is set WebSockets are disabled unless ConnectionOptions#setHttpExtraHeadersOnSessionCreationOnly is set to true" from docs
- ConnectionOptions.setHttpExtraHeadersOnSessionCreationOnly: remove "as a consequence, if any extra header is actually specified, WebSockets will be disabled (as the current browser client API does not support the setting of custom HTTP headers)" from docs

# cs

- changed signatures of LightstreamerClient.addCookies and LightstreamerClient.getCookies

- LightstreamerClient.addCookies: remove "More precisely, this explicit sharing is only needed when the library uses its own cookie storage. This depends on the availability of a default global storage.
In fact, the library will setup its own local cookie storage only if, upon the first usage of the cookies, a default CookieHandler is not available; then it will always stick to the internal storage.
On the other hand, if a default CookieHandler is available upon the first usage of the cookies, the library, from then on, will always stick to the default it finds upon each request; in this case, the cookie storage will be already shared with the rest of the application. However, whenever a default CookieHandler of type different from CookieManager is found, the library will not be able to use it and will skip cookie handling."

- LightstreamerClient.getCookies: remove ", or null." and "If a null URI was supplied, all available non-expired cookies will be returned."

- ConnectionOptions.setProxy: remove "Lifecycle: This value can be set and changed at any time. The supplied value will be used for the next connection attempt." and change to "Lifecycle: the proxy is shared by all the client instances; hence once set, it cannot be changed with another value."

- compatible with .net standard 2.1