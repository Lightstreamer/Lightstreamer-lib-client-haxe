
# js only

- removed ConnectionSharing

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

renamed methods (java and cs)
- LightstreamerClient.subscribe(MpnSubscription sub) as LightstreamerClient.subscribeMpn
- LightstreamerClient.unsubscribe(MpnSubscription sub) as LightstreamerClient.unsubscribeMpn

removed methods on android
- MpnBuilder.contentAvailable(String contentAvailable)
- MpnBuilder.contentAvailableAsString()
- MpnBuilder.contentAvailable(boolean contentAvailable)
- MpnBuilder.contentAvailableAsBool()

moved classes
- to com.lightstreamer.client.mpn.MpnDevice from com.lightstreamer.client.mpn.android.MpnDevice
- to com.lightstreamer.client.mpn.MpnBuilder from com.lightstreamer.client.mpn.util.MpnBuilder

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